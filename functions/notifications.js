const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendWelcomeMessage = functions.auth.user().onCreate(async (user) => {
  const maxRetries = 5;
  const delayMs = 1000;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {

      const userDoc = await admin.firestore().collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;
        const userName = userData.name || 'User';

        console.log(`Found user data for ${userName}:`, userData);
        console.log(`FCM token: ${fcmToken}`);

        if (fcmToken) {
          const message = {
            notification: {
              title: 'Welcome!',
              body: `Hello ${userName}, welcome to Notify! This message was sent from the Cloud Functions.`,
            },
            token: fcmToken,
          };

          await admin.messaging().send(message);
          console.log('Successfully sent welcome message');
          return;
        } else {
          console.log('No FCM token found for this user');
          return;
        }
      }
    } catch (error) {
      console.error(`Attempt ${attempt} - Error fetching user data:`, error);
    }


    await new Promise((resolve) => setTimeout(resolve, delayMs));
  }

  console.error('Failed to fetch user data after multiple attempts.');
});