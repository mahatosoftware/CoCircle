const admin = require('firebase-admin');

class RemindersProcessor {
  constructor({ db, fcmClient }) {
    this.db = db;
    this.fcmClient = fcmClient;
  }

  /**
   * Evaluates if the user is currently in their quiet hours window (10 PM to 8 AM local time).
   */
  isQuietHours(userData) {
    const prefs = userData.notificationPreferences || {};
    if (prefs.quietHoursEnabled === false) return false;

    // Use timezone offset (default to IST UTC+5:30)
    const tzOffsetMinutes = Number(userData.timezoneOffsetMinutes ?? 330);
    const nowUtcMs = Date.now();
    const userLocalMs = nowUtcMs + tzOffsetMinutes * 60 * 1000;
    const userLocalDate = new Date(userLocalMs);
    const localHour = userLocalDate.getUTCHours();

    // 10 PM (22:00) to 8 AM (08:00)
    return localHour >= 22 || localHour < 8;
  }

  /**
   * Checks the deduplication delivery log to guarantee no duplicate reminders.
   */
  async hasDelivered({ userId, entityId, reminderType, threshold }) {
    const logId = `${userId}_${entityId}_${reminderType}_${threshold}`;
    const logDoc = await this.db.collection('notification_delivery_log').doc(logId).get();
    return logDoc.exists;
  }

  /**
   * Records successful notification delivery in the anti-irritation delivery log.
   */
  async recordDelivery({ userId, entityId, reminderType, threshold, title, body }) {
    const logId = `${userId}_${entityId}_${reminderType}_${threshold}`;
    await this.db.collection('notification_delivery_log').doc(logId).set({
      logId,
      userId,
      entityId,
      reminderType,
      threshold,
      title,
      body,
      deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  /**
   * 1. Process Upcoming Trip Reminders: 7d, 3d, 1d, 3h, and 30m milestones.
   */
  async processUpcomingTripReminders({ dryRun = false } = {}) {
    const results = { scanned: 0, sent: 0, skipped: 0, quietHoursDeferred: 0 };
    const now = Date.now();

    // Query active upcoming trips
    const tripsSnap = await this.db
      .collection('trips')
      .where('isActive', '==', true)
      .get();

    results.scanned = tripsSnap.size;

    const MILESTONES = [
      { id: '7d', windowMs: 7 * 24 * 60 * 60 * 1000, toleranceMs: 4 * 60 * 60 * 1000, label: '7 days to departure' },
      { id: '3d', windowMs: 3 * 24 * 60 * 60 * 1000, toleranceMs: 2 * 60 * 60 * 1000, label: '3 days to departure' },
      { id: '1d', windowMs: 24 * 60 * 60 * 1000, toleranceMs: 60 * 60 * 1000, label: 'departs tomorrow' },
      { id: '3h', windowMs: 3 * 60 * 60 * 1000, toleranceMs: 30 * 60 * 1000, label: 'departs in 3 hours' },
      { id: '30m', windowMs: 30 * 60 * 1000, toleranceMs: 15 * 60 * 1000, label: 'departs in 30 minutes', bypassQuietHours: true },
    ];

    for (const doc of tripsSnap.docs) {
      const trip = doc.data();
      if (!trip.startDate || trip.status === 'closed' || trip.status === 'cancelled') continue;

      const startDateMs = trip.startDate.toMillis ? trip.startDate.toMillis() : new Date(trip.startDate).getTime();
      const diffMs = startDateMs - now;

      // Skip past trips
      if (diffMs < 0) continue;

      for (const milestone of MILESTONES) {
        // Check if within milestone window
        if (Math.abs(diffMs - milestone.windowMs) <= milestone.toleranceMs) {
          const participants = Array.isArray(trip.participantIds) ? trip.participantIds : [];

          for (const uid of participants) {
            const alreadySent = await this.hasDelivered({
              userId: uid,
              entityId: doc.id,
              reminderType: 'trip_reminder',
              threshold: milestone.id,
            });

            if (alreadySent) {
              results.skipped++;
              continue;
            }

            const userDoc = await this.db.collection('users').doc(uid).get();
            if (!userDoc.exists) continue;
            const userData = userDoc.data();
            const prefs = userData.notificationPreferences || {};

            if (prefs.tripRemindersEnabled === false) continue;
            if (Array.isArray(prefs.mutedTrips) && prefs.mutedTrips.includes(doc.id)) continue;

            if (!milestone.bypassQuietHours && this.isQuietHours(userData)) {
              results.quietHoursDeferred++;
              continue;
            }

            const title = `Upcoming Trip: ${trip.name}`;
            const body = `Your trip "${trip.name}" ${milestone.label}! Tap to check meeting points and arrangements.`;
            const targetPath = `/trip/${doc.id}?tab=overview`;

            if (!dryRun) {
              await this._sendReminderPushAndHistory({
                userId: uid,
                userData,
                title,
                body,
                type: 'trip_reminder',
                targetPath,
                tripId: doc.id,
              });

              await this.recordDelivery({
                userId: uid,
                entityId: doc.id,
                reminderType: 'trip_reminder',
                threshold: milestone.id,
                title,
                body,
              });
            }
            results.sent++;
          }
        }
      }
    }

    return results;
  }

  /**
   * 2. Process Poll Closing Reminders: 24h and 1h thresholds for unvoted members.
   */
  async processPollClosingReminders({ dryRun = false } = {}) {
    const results = { scanned: 0, sent: 0, skipped: 0, quietHoursDeferred: 0 };
    const now = Date.now();

    const pollsSnap = await this.db
      .collection('polls')
      .where('isActive', '==', true)
      .get();

    results.scanned = pollsSnap.size;

    const MILESTONES = [
      { id: '24h', windowMs: 24 * 60 * 60 * 1000, toleranceMs: 60 * 60 * 1000, label: 'closes in 24 hours' },
      { id: '1h', windowMs: 60 * 60 * 1000, toleranceMs: 20 * 60 * 1000, label: 'closes in 1 hour', bypassQuietHours: true },
    ];

    for (const doc of pollsSnap.docs) {
      const poll = doc.data();
      if (!poll.deadline) continue;

      const deadlineMs = poll.deadline.toMillis ? poll.deadline.toMillis() : new Date(poll.deadline).getTime();
      const diffMs = deadlineMs - now;

      if (diffMs < 0) continue; // Already expired

      for (const milestone of MILESTONES) {
        if (Math.abs(diffMs - milestone.windowMs) <= milestone.toleranceMs) {
          // Fetch trip to identify participants
          const tripDoc = await this.db.collection('trips').doc(poll.tripId).get();
          if (!tripDoc.exists) continue;
          const trip = tripDoc.data();
          const participants = Array.isArray(trip.participantIds) ? trip.participantIds : [];

          // ANTI-IRRITATION: Only notify participants who have NOT voted yet
          const votesMap = poll.votes || {};

          for (const uid of participants) {
            // Skip members who have already voted
            if (votesMap[uid] && votesMap[uid].length > 0) {
              results.skipped++;
              continue;
            }

            const alreadySent = await this.hasDelivered({
              userId: uid,
              entityId: doc.id,
              reminderType: 'poll_closing',
              threshold: milestone.id,
            });

            if (alreadySent) {
              results.skipped++;
              continue;
            }

            const userDoc = await this.db.collection('users').doc(uid).get();
            if (!userDoc.exists) continue;
            const userData = userDoc.data();
            const prefs = userData.notificationPreferences || {};

            if (prefs.pollRemindersEnabled === false) continue;
            if (Array.isArray(prefs.mutedTrips) && prefs.mutedTrips.includes(poll.tripId)) continue;

            if (!milestone.bypassQuietHours && this.isQuietHours(userData)) {
              results.quietHoursDeferred++;
              continue;
            }

            const title = `Poll Closing Soon: ${poll.question}`;
            const body = `Voting on "${poll.question}" ${milestone.label}! Tap to cast your vote.`;
            const targetPath = `/trip/${poll.tripId}?tab=3`;

            if (!dryRun) {
              await this._sendReminderPushAndHistory({
                userId: uid,
                userData,
                title,
                body,
                type: 'poll_closing',
                targetPath,
                tripId: poll.tripId,
              });

              await this.recordDelivery({
                userId: uid,
                entityId: doc.id,
                reminderType: 'poll_closing',
                threshold: milestone.id,
                title,
                body,
              });
            }
            results.sent++;
          }
        }
      }
    }

    return results;
  }

  /**
   * 3. Process Pending Task Reminders: Maximum once every 24 hours per user as a single digest.
   */
  async processPendingTaskReminders({ dryRun = false } = {}) {
    const results = { scanned: 0, sent: 0, skipped: 0, quietHoursDeferred: 0 };
    const todayDateStr = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

    // Query incomplete tasks
    const tasksSnap = await this.db
      .collection('tasks')
      .where('isCompleted', '==', false)
      .get();

    results.scanned = tasksSnap.size;

    // Group tasks by (assignedTo, tripId)
    const userTripTaskMap = new Map();

    for (const doc of tasksSnap.docs) {
      const task = doc.data();
      if (!task.assignedTo || !task.tripId) continue;

      const key = `${task.assignedTo}_${task.tripId}`;
      if (!userTripTaskMap.has(key)) {
        userTripTaskMap.set(key, {
          userId: task.assignedTo,
          tripId: task.tripId,
          tasks: [],
        });
      }
      userTripTaskMap.get(key).tasks.push({ id: doc.id, ...task });
    }

    for (const { userId, tripId, tasks } of userTripTaskMap.values()) {
      // ANTI-IRRITATION: Maximum once every 24 hours via daily threshold key
      const alreadySent = await this.hasDelivered({
        userId,
        entityId: tripId,
        reminderType: 'task_digest',
        threshold: todayDateStr,
      });

      if (alreadySent) {
        results.skipped++;
        continue;
      }

      const userDoc = await this.db.collection('users').doc(userId).get();
      if (!userDoc.exists) continue;
      const userData = userDoc.data();
      const prefs = userData.notificationPreferences || {};

      if (prefs.taskRemindersEnabled === false) continue;
      if (Array.isArray(prefs.mutedTrips) && prefs.mutedTrips.includes(tripId)) continue;

      if (this.isQuietHours(userData)) {
        results.quietHoursDeferred++;
        continue;
      }

      const tripDoc = await this.db.collection('trips').doc(tripId).get();
      const tripName = tripDoc.exists ? (tripDoc.data().name || 'Trip') : 'Trip';

      // Build Digest Message
      const count = tasks.length;
      const firstTaskTitle = tasks[0].title;
      const title = count === 1 ? `Pending Task: ${tripName}` : `${count} Pending Tasks: ${tripName}`;
      const body = count === 1
        ? `You have 1 open task for ${tripName}: "${firstTaskTitle}". Tap to view.`
        : `You have ${count} open tasks for ${tripName}: "${firstTaskTitle}" and ${count - 1} more.`;
      const targetPath = `/trip/${tripId}?tab=4`;

      if (!dryRun) {
        await this._sendReminderPushAndHistory({
          userId,
          userData,
          title,
          body,
          type: 'task_reminder',
          targetPath,
          tripId,
        });

        await this.recordDelivery({
          userId,
          entityId: tripId,
          reminderType: 'task_digest',
          threshold: todayDateStr,
          title,
          body,
        });
      }
      results.sent++;
    }

    return results;
  }

  async _sendReminderPushAndHistory({ userId, userData, title, body, type, targetPath, tripId }) {
    const notificationId = `notif_${type}_${userId}_${Date.now()}`;

    // 1. In-App Notification Record
    await this.db.collection('notifications').doc(notificationId).set({
      id: notificationId,
      title,
      body,
      type,
      targetPath,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
      recipientUid: userId,
      senderUid: 'system',
      senderName: 'CoCircle Reminder',
      tripId,
      deliveryStatus: 'delivered',
    });

    // 2. FCM Push Notification to registered devices
    const tokens = new Set();
    if (Array.isArray(userData.fcmTokens)) {
      userData.fcmTokens.forEach((t) => t && tokens.add(t));
    }
    if (userData.fcmToken) tokens.add(userData.fcmToken);

    if (tokens.size > 0 && this.fcmClient) {
      for (const token of tokens) {
        await this.fcmClient.sendMessage({
          token,
          notification: { title, body },
          data: {
            type,
            tripId: tripId || '',
            notificationId,
            targetPath,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        }).catch(() => {});
      }
    }
  }
}

module.exports = { RemindersProcessor };
