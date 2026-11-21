const admin = require('firebase-admin');

// Configuration
const ENVIRONMENT = process.env.ENVIRONMENT || 'dev';
const PROJECT_ID = process.env.PROJECT_ID || (
  ENVIRONMENT === 'prod' ? 'cocircle-firebase-prod' : 'cocircle-firebase-dev'
);

function initFirebase() {
  if (admin.apps.length > 0) return admin.app();

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

  return admin.initializeApp({
    projectId: PROJECT_ID,
  });
}

async function auditUsers() {
  console.log(`Auditing user device registrations [Environment: ${ENVIRONMENT}, Project: ${PROJECT_ID}]...\n`);
  
  const app = initFirebase();
  const db = admin.firestore(app);

  const snapshot = await db.collection('users').get();
  
  let totalUsers = 0;
  let registeredUsers = 0;
  let totalDeviceTokens = 0;
  const pendingUsers = [];

  snapshot.forEach((doc) => {
    totalUsers++;
    const data = doc.data() || {};
    const tokens = Array.isArray(data.fcmTokens) ? data.fcmTokens : [];
    
    if (tokens.length > 0) {
      registeredUsers++;
      totalDeviceTokens += tokens.length;
    } else {
      pendingUsers.push({
        uid: doc.id,
        displayName: data.displayName || 'Unknown',
        email: data.email || 'No email',
      });
    }
  });

  console.log('====================================================');
  console.log('             COCIRCLE DEVICE REGISTRATION AUDIT      ');
  console.log('====================================================');
  console.log(`Total Users in Firestore:        ${totalUsers}`);
  console.log(`Users with Registered Devices:   ${registeredUsers} (${totalUsers > 0 ? Math.round((registeredUsers / totalUsers) * 100) : 0}%)`);
  console.log(`Total Active Device Tokens:      ${totalDeviceTokens}`);
  console.log(`Users Pending Device Sync:       ${pendingUsers.length}`);
  console.log('====================================================\n');

  if (pendingUsers.length > 0) {
    console.log('Users who have not yet launched the updated app:');
    pendingUsers.slice(0, 20).forEach((u, i) => {
      console.log(`  ${i + 1}. ${u.displayName} (${u.email}) - UID: ${u.uid}`);
    });
    if (pendingUsers.length > 20) {
      console.log(`  ... and ${pendingUsers.length - 20} more`);
    }
    console.log('\nNote: Their devices will automatically register the next time they open the app.');
  } else {
    console.log('All existing users have registered device tokens!');
  }
}

if (require.main === module) {
  auditUsers().catch((err) => {
    console.error('Audit failed:', err.message);
    process.exit(1);
  });
}

module.exports = { auditUsers };
