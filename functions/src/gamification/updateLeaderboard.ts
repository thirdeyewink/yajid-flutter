/**
 * Update Leaderboard Cloud Function
 *
 * This function automatically updates the leaderboard whenever a user's points change.
 * It runs as a Firestore trigger on the user_points collection.
 *
 * Features:
 * - Automatic leaderboard sync on points changes
 * - Efficient updates (only when points actually change)
 * - Includes user profile data (display name, photo)
 * - Timestamp tracking for sorting/display
 *
 * @module gamification/updateLeaderboard
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Firestore trigger that runs when user_points document is updated
 *
 * This automatically keeps the leaderboard in sync with user points.
 * The leaderboard is a denormalized collection for fast queries.
 */
export const updateLeaderboard = functions.firestore
  .document("user_points/{userId}")
  .onWrite(async (change, context) => {
    const userId = context.params.userId;

    // If document was deleted, remove from leaderboard
    if (!change.after.exists) {
      functions.logger.info(`Removing user ${userId} from leaderboard (points deleted)`);
      await admin.firestore().collection("leaderboard").doc(userId).delete();
      return null;
    }

    const newData = change.after.data();
    const newPoints = newData?.totalPoints || 0;

    // If document was created (not updated), check if points exist
    if (!change.before.exists) {
      functions.logger.info(`Adding user ${userId} to leaderboard (new user)`);
      return await updateLeaderboardEntry(userId, newPoints);
    }

    const oldData = change.before.data();
    const oldPoints = oldData?.totalPoints || 0;

    // Only update if points actually changed
    if (newPoints === oldPoints) {
      functions.logger.debug(`Points unchanged for user ${userId}, skipping leaderboard update`);
      return null;
    }

    functions.logger.info(
      `Updating leaderboard for user ${userId}: ${oldPoints} → ${newPoints} points`
    );

    return await updateLeaderboardEntry(userId, newPoints);
  });

/**
 * Update or create leaderboard entry for a user
 *
 * @param userId - The user ID
 * @param totalPoints - The user's total points
 */
async function updateLeaderboardEntry(userId: string, totalPoints: number): Promise<void> {
  try {
    const db = admin.firestore();

    // Get user profile data
    const userDoc = await db.collection("users").doc(userId).get();

    let displayName = "Anonymous";
    let profileImageUrl: string | null = null;

    if (userDoc.exists) {
      const userData = userDoc.data();
      displayName = userData?.displayName || "Anonymous";
      profileImageUrl = userData?.photoURL || null;
    } else {
      functions.logger.warn(`User document not found for ${userId}, using default data`);
    }

    // Get user level data for tier information
    const levelDoc = await db.collection("user_levels").doc(userId).get();
    const level = levelDoc.exists ? levelDoc.data()?.level || 1 : 1;
    const tier = levelDoc.exists ? levelDoc.data()?.tier || "novice" : "novice";

    // Update leaderboard entry
    await db.collection("leaderboard").doc(userId).set({
      userId,
      displayName,
      profileImageUrl,
      totalPoints,
      level,
      tier,
      rank: 0, // Rank is calculated by client queries (orderBy totalPoints desc)
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    functions.logger.info(`Successfully updated leaderboard for user ${userId}`);
  } catch (error) {
    functions.logger.error(`Error updating leaderboard for user ${userId}:`, error);
    // Don't throw - we don't want to block points updates if leaderboard fails
  }
}

/**
 * Callable function to get leaderboard rankings
 *
 * This allows clients to fetch paginated leaderboard data efficiently.
 * Rankings are calculated dynamically based on totalPoints ordering.
 */
export const getLeaderboard = functions.https.onCall(
  async (data: { limit?: number; startAfter?: number }, context) => {
    const limit = Math.min(data.limit || 50, 100); // Cap at 100
    const startAfter = data.startAfter || 0;

    try {
      const leaderboardQuery = admin.firestore()
        .collection("leaderboard")
        .orderBy("totalPoints", "desc")
        .limit(limit);

      const snapshot = await leaderboardQuery.get();

      const leaderboard = snapshot.docs.map((doc, index) => ({
        ...doc.data(),
        rank: startAfter + index + 1, // Calculate rank based on position
      }));

      return {
        success: true,
        leaderboard,
        hasMore: snapshot.docs.length === limit,
      };
    } catch (error: any) {
      functions.logger.error("Error fetching leaderboard:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to fetch leaderboard",
        error.message
      );
    }
  }
);

/**
 * Get user's leaderboard position
 *
 * Efficiently finds a specific user's rank without fetching all entries.
 */
export const getUserRank = functions.https.onCall(
  async (data: { userId?: string }, context) => {
    // Use authenticated user if no userId provided
    const targetUserId = data.userId || context.auth?.uid;

    if (!targetUserId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "User ID is required"
      );
    }

    try {
      const db = admin.firestore();

      // Get user's leaderboard entry
      const userEntry = await db.collection("leaderboard").doc(targetUserId).get();

      if (!userEntry.exists) {
        return {
          success: true,
          rank: null,
          message: "User not on leaderboard",
        };
      }

      const userPoints = userEntry.data()?.totalPoints || 0;

      // Count how many users have more points
      const higherScoresSnapshot = await db.collection("leaderboard")
        .where("totalPoints", ">", userPoints)
        .count()
        .get();

      const rank = higherScoresSnapshot.data().count + 1;

      return {
        success: true,
        rank,
        totalPoints: userPoints,
        ...userEntry.data(),
      };
    } catch (error: any) {
      functions.logger.error(`Error getting rank for user ${targetUserId}:`, error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to get user rank",
        error.message
      );
    }
  }
);
