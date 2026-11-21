const admin = require('firebase-admin');

const EVENT_STATUS = {
  PENDING: 'pending',
  PROCESSING: 'processing',
  COMPLETED: 'completed',
  RETRYABLE: 'retryable',
  FAILED: 'failed',
};

const LEASE_DURATION_MS = 10 * 60 * 1000; // 10 minutes lease
const MAX_ATTEMPTS = 5;

class EventProcessor {
  constructor({ db, fcmClient, workerId = 'worker' }) {
    this.db = db;
    this.fcmClient = fcmClient;
    this.workerId = workerId;
  }

  /**
   * Atomically claims an event using a Firestore transaction.
   * Prevents concurrent workers from processing the same event.
   */
  async claimEvent(eventRef) {
    return this.db.runTransaction(async (transaction) => {
      const doc = await transaction.get(eventRef);
      if (!doc.exists) return null;

      const data = doc.data();
      const now = Date.now();
      const leasedAtMs = data.leasedAt ? data.leasedAt.toMillis() : 0;
      const isLeaseExpired = now - leasedAtMs > LEASE_DURATION_MS;

      const isClaimable =
        data.status === EVENT_STATUS.PENDING ||
        data.status === EVENT_STATUS.RETRYABLE ||
        (data.status === EVENT_STATUS.PROCESSING && isLeaseExpired);

      if (!isClaimable) {
        return null; // Already claimed or completed
      }

      const attempts = (data.attempts || 0) + 1;
      if (attempts > MAX_ATTEMPTS) {
        transaction.update(eventRef, {
          status: EVENT_STATUS.FAILED,
          lastError: `Exceeded max attempts (${MAX_ATTEMPTS})`,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return null;
      }

      transaction.update(eventRef, {
        status: EVENT_STATUS.PROCESSING,
        attempts,
        leasedAt: admin.firestore.FieldValue.serverTimestamp(),
        workerId: this.workerId,
      });

      return { ...data, attempts };
    });
  }

  /**
   * Resolves eligible recipients by cross-validating trip and circle membership.
   */
  async resolveRecipients(event) {
    const { tripId, circleId, createdBy: actorUid, metadata = {} } = event;

    // 1. Fetch Trip
    const tripDoc = await this.db.collection('trips').doc(tripId).get();
    if (!tripDoc.exists) {
      return { error: `Trip ${tripId} not found`, recipients: [] };
    }
    const tripData = tripDoc.data();
    const effectiveCircleId = circleId || tripData.circleId;

    // 2. Fetch Circle
    const circleDoc = await this.db.collection('circles').doc(effectiveCircleId).get();
    if (!circleDoc.exists) {
      return { error: `Circle ${effectiveCircleId} not found`, recipients: [] };
    }
    const circleData = circleDoc.data();
    const circleMemberSet = new Set(circleData.memberIds || []);

    // 3. Candidates: must be active circle members
    const candidateSet = new Set();
    if (Array.isArray(tripData.participantIds) && tripData.participantIds.length > 0) {
      for (const uid of tripData.participantIds) {
        if (circleMemberSet.has(uid)) {
          candidateSet.add(uid);
        }
      }
    } else {
      for (const uid of circleMemberSet) {
        candidateSet.add(uid);
      }
    }

    // Include split participant if in circle
    const splitDetails = metadata.splitDetails || {};
    for (const uid of Object.keys(splitDetails)) {
      if (circleMemberSet.has(uid)) {
        candidateSet.add(uid);
      }
    }

    // 4. Exclude the actor/creator
    candidateSet.delete(actorUid);

    if (candidateSet.size === 0) {
      return { recipients: [], tripData, circleData };
    }

    // 5. Fetch user profiles & check notification preferences
    const candidateUids = Array.from(candidateSet);
    const userRefs = candidateUids.map((uid) => this.db.collection('users').doc(uid));
    const userDocs = await this.db.getAll(...userRefs);

    const eligibleRecipients = [];
    for (const uDoc of userDocs) {
      if (!uDoc.exists) continue;
      const userData = uDoc.data();
      const uid = uDoc.id;
      const prefs = userData.notificationPreferences || {};

      // Muting & global preference checks
      if (prefs.expensesEnabled === false) continue;
      if (Array.isArray(prefs.mutedTrips) && prefs.mutedTrips.includes(tripId)) continue;
      if (Array.isArray(prefs.mutedCircles) && prefs.mutedCircles.includes(effectiveCircleId)) continue;

      // Extract device tokens
      const tokens = new Set();
      if (Array.isArray(userData.fcmTokens)) {
        userData.fcmTokens.forEach((t) => typeof t === 'string' && t && tokens.add(t));
      } else if (userData.fcmTokens && typeof userData.fcmTokens === 'object') {
        Object.keys(userData.fcmTokens).forEach((t) => t && tokens.add(t));
      }
      if (typeof userData.fcmToken === 'string' && userData.fcmToken) {
        tokens.add(userData.fcmToken);
      }

      eligibleRecipients.push({
        uid,
        displayName: userData.displayName || 'Member',
        hideAmountsOnLockScreen: prefs.hideAmountsOnLockScreen === true,
        tokens: Array.from(tokens),
      });
    }

    return { recipients: eligibleRecipients, tripData, circleData };
  }

  /**
   * Process a single claimed notification event.
   */
  async processEvent(eventDoc, { dryRun = false } = {}) {
    const eventRef = eventDoc.ref;
    const event = await this.claimEvent(eventRef);
    if (!event) {
      return { skipped: true, reason: 'could_not_claim' };
    }

    const { recipients, tripData, circleData, error } = await this.resolveRecipients(event);

    if (error) {
      await eventRef.update({
        status: EVENT_STATUS.FAILED,
        lastError: error,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return { failed: true, error };
    }

    if (recipients.length === 0) {
      await eventRef.update({
        status: EVENT_STATUS.COMPLETED,
        deliveredRecipients: [],
        note: 'No eligible recipients',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return { completed: true, notificationsSent: 0, recipients: 0 };
    }

    // Resolve Actor Name
    let actorName = 'A member';
    if (event.createdBy) {
      const actorDoc = await this.db.collection('users').doc(event.createdBy).get();
      if (actorDoc.exists && actorDoc.data().displayName) {
        actorName = actorDoc.data().displayName;
      }
    }

    const currency = (circleData && circleData.currency) ? circleData.currency : '₹';
    const tripName = (tripData && tripData.name) ? tripData.name : 'Trip';
    const metadata = event.metadata || {};
    const amountFormatted = Number(metadata.amount || 0).toLocaleString('en-IN', { maximumFractionDigits: 2 });
    const titleText = metadata.title || 'Expense';

    // Build Titles & Base Bodies
    let notifTitle = 'New expense added';
    let baseBody = `${actorName} added ${currency}${amountFormatted} for "${titleText}" in ${tripName}.`;
    let targetPath = `/trip/${event.tripId}/expense/${event.expenseId}`;

    if (event.eventType === 'expense_updated') {
      notifTitle = 'Expense updated';
      baseBody = `${actorName} updated "${titleText}" (${currency}${amountFormatted}) in ${tripName}.`;
    } else if (event.eventType === 'expense_split_changed') {
      notifTitle = 'Expense split changed';
      baseBody = `${actorName} changed the split for "${titleText}" in ${tripName}.`;
    } else if (event.eventType === 'expense_deleted') {
      notifTitle = 'Expense removed';
      baseBody = `An expense was removed from ${tripName}.`;
      targetPath = `/trip/${event.tripId}?tab=5`;
    }

    // Partial Delivery Tracking: do not re-send to already delivered recipients
    const alreadyDelivered = new Set(event.deliveredRecipients || []);
    const newlyDelivered = [];
    const deadTokensToClean = [];

    let notificationsSent = 0;
    let notificationsFailed = 0;
    const batch = this.db.batch();

    for (const recipient of recipients) {
      if (alreadyDelivered.has(recipient.uid)) {
        continue; // Already delivered in a previous attempt
      }

      // Respect Lock-screen Financial Amount Privacy
      let body = baseBody;
      if (recipient.hideAmountsOnLockScreen) {
        body = `${actorName} updated arrangements for "${titleText}" in ${tripName}.`;
      } else if (metadata.splitDetails && metadata.splitDetails[recipient.uid] != null && event.eventType !== 'expense_deleted') {
        const share = Number(metadata.splitDetails[recipient.uid] || 0);
        body += ` Your share: ${currency}${share.toLocaleString('en-IN', { maximumFractionDigits: 2 })}`;
      }

      const notificationId = `notif_${event.eventId}_${recipient.uid}`;

      // In-App Notification Record
      if (!dryRun) {
        const notifRef = this.db.collection('notifications').doc(notificationId);
        batch.set(notifRef, {
          id: notificationId,
          eventId: event.eventId,
          title: notifTitle,
          body,
          type: event.eventType,
          targetPath,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          isRead: false,
          recipientUid: recipient.uid,
          senderUid: event.createdBy,
          senderName: actorName,
          tripId: event.tripId,
          expenseId: event.expenseId,
          deliveryStatus: 'delivered',
        });
      }

      // FCM HTTP v1 Push
      if (recipient.tokens && recipient.tokens.length > 0 && this.fcmClient) {
        for (const token of recipient.tokens) {
          if (dryRun) {
            notificationsSent++;
            continue;
          }

          const sendResult = await this.fcmClient.sendMessage({
            token,
            notification: { title: notifTitle, body },
            data: {
              type: event.eventType,
              expenseId: event.expenseId || '',
              tripId: event.tripId || '',
              circleId: event.circleId || '',
              actorId: event.createdBy || '',
              notificationId,
              targetPath,
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
          });

          if (sendResult.success) {
            notificationsSent++;
          } else {
            notificationsFailed++;
            if (sendResult.invalidToken) {
              deadTokensToClean.push({ uid: recipient.uid, token });
            }
          }
        }
      }

      newlyDelivered.push(recipient.uid);
    }

    if (!dryRun) {
      await batch.commit();

      // Prune dead tokens
      if (deadTokensToClean.length > 0) {
        const cleanupPromises = deadTokensToClean.map(({ uid, token }) =>
          this.db.collection('users').doc(uid).update({
            fcmTokens: admin.firestore.FieldValue.arrayRemove(token),
          }).catch(() => {})
        );
        await Promise.allSettled(cleanupPromises);
      }

      // Update event state
      const allDelivered = Array.from(new Set([...alreadyDelivered, ...newlyDelivered]));
      await eventRef.update({
        status: EVENT_STATUS.COMPLETED,
        deliveredRecipients: allDelivered,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return {
      completed: true,
      notificationsSent,
      notificationsFailed,
      cleanedTokens: deadTokensToClean.length,
      recipients: recipients.length,
    };
  }
}

module.exports = { EventProcessor, EVENT_STATUS };
