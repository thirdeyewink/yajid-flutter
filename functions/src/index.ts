/**
 * Yajid Cloud Functions
 *
 * This file exports all Cloud Functions for the Yajid platform.
 * Functions are organized by domain (gamification, payments, notifications, etc.)
 */

import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export gamification functions
export * from "./gamification/awardPoints";
export * from "./gamification/updateLeaderboard";
export * from "./gamification/checkBadgeUnlocks";

// Export payment functions (to be implemented in Phase 2)
// export * from "./payments/createPaymentIntent";
// export * from "./payments/handleWebhook";

// Export notification functions (to be implemented)
// export * from "./notifications/sendPushNotification";

// Export auction functions (to be implemented in Phase 2)
// export * from "./auctions/placeBid";
// export * from "./auctions/endAuction";
