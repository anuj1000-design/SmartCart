// Cloud Functions for SmartCart - Push Notifications
// Deploy with: firebase deploy --only functions

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Send push notification when a notification document is created
exports.sendPushNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    // Check if this is a user-specific notification
    if (notification.userId && notification.token) {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
        token: notification.token,
      };

      try {
        await admin.messaging().send(message);
        console.log('Push notification sent successfully');
        
        // Mark as sent
        await snap.ref.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp() });
      } catch (error) {
        console.error('Error sending push notification:', error);
        await snap.ref.update({ error: error.message });
      }
    }
    
    // Check if this is a broadcast notification
    if (notification.message && !notification.userId) {
      try {
        // Get all users with FCM tokens
        const usersSnapshot = await admin.firestore().collection('users').get();
        const tokens = [];
        
        usersSnapshot.forEach(doc => {
          const userData = doc.data();
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        });

        if (tokens.length === 0) {
          console.log('No users with FCM tokens found');
          return;
        }

        // Send to all users in batches of 500
        const batchSize = 500;
        for (let i = 0; i < tokens.length; i += batchSize) {
          const batch = tokens.slice(i, i + batchSize);
          
          const message = {
            notification: {
              title: notification.title,
              body: notification.message,
            },
            tokens: batch,
          };

          const response = await admin.messaging().sendMulticast(message);
          console.log(`Sent to ${response.successCount} devices, ${response.failureCount} failed`);
        }

        console.log(`Broadcast notification sent to ${tokens.length} devices`);
      } catch (error) {
        console.error('Error sending broadcast notification:', error);
      }
    }
  });

// Send notification when order status changes
exports.notifyOrderStatusChange = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Check if status changed
    if (before.status === after.status) {
      return null;
    }

    const userId = after.userId;
    const orderId = context.params.orderId;
    
    // Get user's FCM token
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    
    if (!fcmToken) {
      console.log('User has no FCM token');
      return null;
    }

    const statusMessages = {
      confirmed: 'Your order has been confirmed!',
      preparing: 'Your order is being prepared',
      packed: 'Your order has been packed',
      outForDelivery: 'Your order is out for delivery!',
      delivered: 'Your order has been delivered',
      cancelled: 'Your order has been cancelled',
    };

    const message = {
      notification: {
        title: 'Order Update',
        body: statusMessages[after.status] || 'Your order status has been updated',
      },
      data: {
        orderId: orderId,
        status: after.status,
        type: 'order_update',
      },
      token: fcmToken,
    };

    try {
      await admin.messaging().send(message);
      console.log('Order status notification sent');
    } catch (error) {
      console.error('Error sending order notification:', error);
    }
  });

// Send notification when product price drops
exports.notifyPriceChange = functions.firestore
  .document('products/{productId}/price_history/{historyId}')
  .onCreate(async (snap, context) => {
    const priceChange = snap.data();
    const productId = context.params.productId;
    
    // Only notify if price decreased
    if (priceChange.change >= 0) {
      return null;
    }

    // Get product details
    const productDoc = await admin.firestore().collection('products').doc(productId).get();
    const product = productDoc.data();
    
    if (!product) return null;

    const percentOff = Math.abs(priceChange.changePercent);
    
    // Get all users who have this product in their shopping list
    const shoppingListsSnapshot = await admin.firestore().collectionGroup('items')
      .where('productId', '==', productId)
      .get();

    const userIds = new Set();
    shoppingListsSnapshot.forEach(doc => {
      const parentPath = doc.ref.parent.parent.path;
      const userId = parentPath.split('/')[1];
      userIds.add(userId);
    });

    if (userIds.size === 0) {
      console.log('No users have this product in their shopping list');
      return null;
    }

    // Send notification to each user
    const promises = [];
    for (const userId of userIds) {
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      const fcmToken = userDoc.data()?.fcmToken;
      
      if (fcmToken) {
        const message = {
          notification: {
            title: '🎉 Price Drop Alert!',
            body: `${product.name} is now ${percentOff}% off! New price: ₹${(priceChange.newPrice / 100).toFixed(2)}`,
          },
          data: {
            productId: productId,
            type: 'price_drop',
          },
          token: fcmToken,
        };
        
        promises.push(admin.messaging().send(message));
      }
    }

    await Promise.all(promises);
    console.log(`Price drop notifications sent to ${promises.length} users`);
  });

// Clean up old notifications (run daily)
exports.cleanupOldNotifications = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const snapshot = await admin.firestore()
      .collection('notifications')
      .where('timestamp', '<', thirtyDaysAgo)
      .get();

    const batch = admin.firestore().batch();
    snapshot.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Deleted ${snapshot.size} old notifications`);
  });
