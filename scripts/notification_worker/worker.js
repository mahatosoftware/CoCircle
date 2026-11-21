const fs = require('fs');
const admin = require('firebase-admin');
const { FcmHttpV1Client } = require('./fcm_http_v1_client');
const { EventProcessor, EVENT_STATUS } = require('./event_processor');
const { RemindersProcessor } = require('./reminders_processor');

// Configuration
const ENVIRONMENT = process.env.ENVIRONMENT || 'dev';
const WORKER_MODE = process.env.WORKER_MODE || 'all'; // 'events', 'reminders', 'all'
const DRY_RUN = (process.env.DRY_RUN || 'false').toLowerCase() === 'true';
const BATCH_SIZE = parseInt(process.env.BATCH_SIZE || '50', 10);
const PROJECT_ID = process.env.PROJECT_ID || (
  ENVIRONMENT === 'prod' ? 'cocircle-firebase-prod' : 'cocircle-firebase-dev'
);

function initFirebase() {
  if (admin.apps.length > 0) return admin.app();

  // 1. Check for Service Account JSON in environment variable
  const saString = process.env.FIREBASE_SERVICE_ACCOUNT || process.env.GCP_SA_KEY;
  if (saString) {
    try {
      const saJson = JSON.parse(
        saString.startsWith('{') ? saString : Buffer.from(saString, 'base64').toString('utf8')
      );
      return admin.initializeApp({
        credential: admin.credential.cert(saJson),
        projectId: saJson.project_id || PROJECT_ID,
      });
    } catch (e) {
      console.warn('Could not parse FIREBASE_SERVICE_ACCOUNT as JSON, falling back to Application Default Credentials');
    }
  }

  // 2. Fall back to Application Default Credentials (OIDC / Workload Identity Federation)
  return admin.initializeApp({
    projectId: PROJECT_ID,
  });
}

async function run() {
  const startTime = Date.now();
  console.log(`Starting CoCircle Notification Worker [Environment: ${ENVIRONMENT}, DryRun: ${DRY_RUN}, BatchSize: ${BATCH_SIZE}, Project: ${PROJECT_ID}]`);

  const app = initFirebase();
  const db = admin.firestore(app);

  const fcmClient = new FcmHttpV1Client({ projectId: PROJECT_ID });
  const processor = new EventProcessor({
    db,
    fcmClient,
    workerId: process.env.GITHUB_RUN_ID || `local_${Date.now()}`,
  });

  const summary = {
    success: true,
    environment: ENVIRONMENT,
    dryRun: DRY_RUN,
    projectId: PROJECT_ID,
    eventsScanned: 0,
    eventsProcessed: 0,
    notificationsSent: 0,
    notificationsSkipped: 0,
    failedNotifications: 0,
    duplicatesPrevented: 0,
    cleanedTokens: 0,
    durationMs: 0,
  };

  try {
    // 1. Process Event Queue (Expenses, Splits, Deletions)
    if (WORKER_MODE === 'all' || WORKER_MODE === 'events') {
      const query = db
        .collection('notification_events')
        .where('status', 'in', [EVENT_STATUS.PENDING, EVENT_STATUS.RETRYABLE, EVENT_STATUS.PROCESSING])
        .orderBy('createdAt', 'asc')
        .limit(BATCH_SIZE);

      const snapshot = await query.get();
      summary.eventsScanned = snapshot.size;

      console.log(`Discovered ${snapshot.size} candidate event(s) in queue.`);

      for (const doc of snapshot.docs) {
        try {
          const res = await processor.processEvent(doc, { dryRun: DRY_RUN });
          if (res.skipped) {
            summary.duplicatesPrevented++;
          } else if (res.failed) {
            summary.failedNotifications++;
          } else if (res.completed) {
            summary.eventsProcessed++;
            summary.notificationsSent += (res.notificationsSent || 0);
            summary.failedNotifications += (res.notificationsFailed || 0);
            summary.cleanedTokens += (res.cleanedTokens || 0);
            if (res.recipients === 0) summary.notificationsSkipped++;
          }
        } catch (eventErr) {
          summary.failedNotifications++;
          console.error(`Error processing event ${doc.id}:`, eventErr.message);
        }
      }
    }

    // 2. Process Scheduled Milestone Reminders (Upcoming Trips, Polls, Task Digest)
    if (WORKER_MODE === 'all' || WORKER_MODE === 'reminders') {
      console.log('Evaluating milestone reminders (Upcoming Trips, Polls, and Task Digest)...');
      const remindersProcessor = new RemindersProcessor({ db, fcmClient });

      const [tripRes, pollRes, taskRes] = await Promise.all([
        remindersProcessor.processUpcomingTripReminders({ dryRun: DRY_RUN }).catch((e) => {
          console.error('Error in processUpcomingTripReminders:', e);
          return { sent: 0, skipped: 0, quietHoursDeferred: 0 };
        }),
        remindersProcessor.processPollClosingReminders({ dryRun: DRY_RUN }).catch((e) => {
          console.error('Error in processPollClosingReminders:', e);
          return { sent: 0, skipped: 0, quietHoursDeferred: 0 };
        }),
        remindersProcessor.processPendingTaskReminders({ dryRun: DRY_RUN }).catch((e) => {
          console.error('Error in processPendingTaskReminders:', e);
          return { sent: 0, skipped: 0, quietHoursDeferred: 0 };
        }),
      ]);

      summary.remindersSent = {
        trips: tripRes.sent,
        polls: pollRes.sent,
        tasks: taskRes.sent,
      };
      summary.notificationsSent += (tripRes.sent + pollRes.sent + taskRes.sent);
      summary.duplicatesPrevented += (tripRes.skipped + pollRes.skipped + taskRes.skipped);
      summary.quietHoursDeferred = (tripRes.quietHoursDeferred + pollRes.quietHoursDeferred + taskRes.quietHoursDeferred);

      console.log(`Reminders sent: Trips (${tripRes.sent}), Polls (${pollRes.sent}), Tasks (${taskRes.sent}).`);
      if (summary.quietHoursDeferred > 0) {
        console.log(`Quiet hours deferred: ${summary.quietHoursDeferred} notification(s).`);
      }
    }
  } catch (err) {
    summary.success = false;
    summary.error = err.message;
    console.error('Fatal error during worker execution:', err);
  } finally {
    summary.durationMs = Date.now() - startTime;
  }

  // Print Structured JSON Summary
  console.log('\n--- STRUCTURED EXECUTION SUMMARY ---');
  console.log(JSON.stringify(summary, null, 2));

  // Write GitHub Step Summary if running in GitHub Actions
  if (process.env.GITHUB_STEP_SUMMARY) {
    const md = `
### 🔔 CoCircle Expense Push Notification Worker Report

* **Environment**: \`${summary.environment}\`
* **Dry Run**: \`${summary.dryRun}\`
* **Status**: ${summary.success ? '✅ Success' : '❌ Failed'}
* **Duration**: \`${summary.durationMs}ms\`

| Metric | Count |
| :--- | :--- |
| **Events Scanned** | ${summary.eventsScanned} |
| **Events Processed** | ${summary.eventsProcessed} |
| **Notifications Dispatched** | ${summary.notificationsSent} |
| **Notifications Skipped** | ${summary.notificationsSkipped} |
| **Delivery Failures** | ${summary.failedNotifications} |
| **Dead Tokens Cleaned** | ${summary.cleanedTokens} |
| **Duplicate Claims Prevented** | ${summary.duplicatesPrevented} |
`;
    try {
      fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, md);
    } catch (_) {}
  }

  if (!summary.success) {
    process.exit(1);
  }
}

if (require.main === module) {
  run().catch((err) => {
    console.error('Unhandled fatal error in worker:', err);
    process.exit(1);
  });
}

module.exports = { run, initFirebase };
