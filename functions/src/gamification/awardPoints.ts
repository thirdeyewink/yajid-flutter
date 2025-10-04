/**
 * Award Points Cloud Function
 *
 * This function handles all points awarding operations securely on the server-side.
 * Client-side code calls this function, and all validation and processing happens here.
 *
 * Security features:
 * - Points range validation per category
 * - Idempotency checks (prevent duplicate awards)
 * - Daily points limit enforcement
 * - Atomic transactions (prevent race conditions)
 * - Automatic level progression checking
 *
 * @module gamification/awardPoints
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Points category definitions with min/max ranges
 */
const POINTS_RANGES: Record<string, { min: number; max: number }> = {
  dailyLogin: { min: 5, max: 15 },
  review: { min: 20, max: 100 },
  photoUpload: { min: 10, max: 30 },
  socialShare: { min: 5, max: 15 },
  friendReferral: { min: 200, max: 200 },
  firstVisit: { min: 100, max: 100 },
  weeklyChallenge: { min: 100, max: 300 },
  eventAttendance: { min: 50, max: 200 },
  profileComplete: { min: 50, max: 50 },
  socialConnection: { min: 10, max: 10 },
  helpfulReview: { min: 5, max: 5 },
  achievementUnlock: { min: 50, max: 500 },
  levelUp: { min: 100, max: 100 },
  bookmarkCreated: { min: 5, max: 5 },
  ratingSubmitted: { min: 10, max: 10 },
};

/**
 * Default daily points limit (can be customized per user)
 */
const DEFAULT_DAILY_LIMIT = 500;

/**
 * Interface for the award points request
 */
interface AwardPointsRequest {
  points: number;
  category: string;
  description?: string;
  referenceId?: string;
  metadata?: Record<string, any>;
}

/**
 * Award points to a user
 *
 * @param data - Request data containing points, category, and optional metadata
 * @param context - Firebase callable function context with auth info
 * @returns Promise with success status and new points total
 */
export const awardPoints = functions.https.onCall(
  async (data: AwardPointsRequest, context: functions.https.CallableContext) => {
    // 1. Authentication check
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to award points"
      );
    }

    const userId = context.auth.uid;
    const { points, category, description, referenceId, metadata } = data;

    // 2. Input validation
    if (!points || !category) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Points and category are required"
      );
    }

    if (typeof points !== "number" || points <= 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Points must be a positive number"
      );
    }

    // 3. Validate points range for category
    const pointsRange = POINTS_RANGES[category];
    if (!pointsRange) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        `Unknown category: ${category}`
      );
    }

    if (points < pointsRange.min || points > pointsRange.max) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        `Points for ${category} must be between ${pointsRange.min} and ${pointsRange.max}`
      );
    }

    // 4. Idempotency check (prevent duplicate awards)
    if (referenceId) {
      const existingTransaction = await admin.firestore()
        .collection("points_transactions")
        .where("userId", "==", userId)
        .where("referenceId", "==", referenceId)
        .limit(1)
        .get();

      if (!existingTransaction.empty) {
        functions.logger.warn(
          `Duplicate points award prevented for user ${userId}, referenceId: ${referenceId}`
        );
        return {
          success: false,
          reason: "duplicate",
          message: "Points already awarded for this action",
        };
      }
    }

    // 5. Execute atomic transaction
    try {
      const result = await admin.firestore().runTransaction(async (transaction) => {
        const db = admin.firestore();
        const today = getTodayDateString();
        const dailyLimitRef = db.collection("daily_points_limit").doc(`${userId}_${today}`);
        const userPointsRef = db.collection("user_points").doc(userId);

        // Read daily limit document
        const dailyLimitDoc = await transaction.get(dailyLimitRef);
        const dailyLimitData = dailyLimitDoc.data();
        const currentDailyPoints = dailyLimitData?.pointsEarnedToday || 0;
        const dailyLimit = dailyLimitData?.dailyLimit || DEFAULT_DAILY_LIMIT;

        // Check daily limit
        if (currentDailyPoints + points > dailyLimit) {
          throw new functions.https.HttpsError(
            "resource-exhausted",
            `Daily points limit reached (${currentDailyPoints}/${dailyLimit})`
          );
        }

        // Read current user points
        const userPointsDoc = await transaction.get(userPointsRef);
        const currentPoints = userPointsDoc.data()?.totalPoints || 0;

        // Create points transaction record
        const transactionRef = db.collection("points_transactions").doc();
        transaction.set(transactionRef, {
          userId,
          points,
          category,
          description: description || `Earned ${points} points for ${category}`,
          referenceId: referenceId || null,
          metadata: metadata || null,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update user_points
        const updatedData: any = {
          totalPoints: admin.firestore.FieldValue.increment(points),
          lifetimePoints: admin.firestore.FieldValue.increment(points),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        };

        // Update points by category
        updatedData[`pointsByCategory.${category}`] = admin.firestore.FieldValue.increment(points);

        if (userPointsDoc.exists) {
          transaction.update(userPointsRef, updatedData);
        } else {
          // Initialize user points if doesn't exist
          transaction.set(userPointsRef, {
            userId,
            totalPoints: points,
            lifetimePoints: points,
            pointsByCategory: { [category]: points },
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        }

        // Update daily points limit
        const dailyLimitUpdate: any = {
          userId,
          date: today,
          pointsEarnedToday: admin.firestore.FieldValue.increment(points),
          dailyLimit,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        };

        if (dailyLimitDoc.exists) {
          transaction.update(dailyLimitRef, dailyLimitUpdate);
        } else {
          transaction.set(dailyLimitRef, dailyLimitUpdate);
        }

        return {
          success: true,
          points,
          newTotal: currentPoints + points,
          dailyPoints: currentDailyPoints + points,
        };
      });

      // 6. Check for level up (outside transaction to avoid recursion)
      await checkAndUpdateLevel(userId);

      functions.logger.info(
        `Awarded ${points} points to user ${userId} for ${category}`
      );

      return result;
    } catch (error: any) {
      functions.logger.error(`Error awarding points to user ${userId}:`, error);

      // Re-throw HttpsError as-is
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      // Wrap other errors
      throw new functions.https.HttpsError(
        "internal",
        "Failed to award points. Please try again.",
        error.message
      );
    }
  }
);

/**
 * Check if user should level up and update accordingly
 *
 * @param userId - The user ID to check
 */
async function checkAndUpdateLevel(userId: string): Promise<void> {
  try {
    const db = admin.firestore();

    // Get current points
    const userPointsDoc = await db.collection("user_points").doc(userId).get();
    const totalPoints = userPointsDoc.data()?.totalPoints || 0;

    // Calculate new level
    const newLevel = calculateLevel(totalPoints);

    // Get current level
    const userLevelDoc = await db.collection("user_levels").doc(userId).get();
    const currentLevel = userLevelDoc.data()?.level || 1;

    // Check if level increased
    if (newLevel > currentLevel) {
      functions.logger.info(`User ${userId} leveled up from ${currentLevel} to ${newLevel}`);

      const pointsRequiredForNextLevel = getPointsRequiredForLevel(newLevel + 1);
      const pointsInCurrentLevel = totalPoints - getPointsRequiredForLevel(newLevel);

      const levelUpdate = {
        userId,
        level: newLevel,
        tier: calculateTier(totalPoints),
        totalPoints,
        pointsInCurrentLevel,
        pointsRequiredForNextLevel: pointsRequiredForNextLevel - totalPoints,
        lastLevelUpDate: admin.firestore.FieldValue.serverTimestamp(),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (userLevelDoc.exists) {
        await userLevelDoc.ref.update(levelUpdate);
      } else {
        await userLevelDoc.ref.set(levelUpdate);
      }

      // Check for badge unlocks (level-based badges)
      await checkLevelBadges(userId, newLevel);

      // Award level-up bonus points (but don't trigger another level check)
      // Note: This is handled separately to prevent infinite recursion
    }
  } catch (error) {
    functions.logger.error(`Error checking level for user ${userId}:`, error);
  }
}

/**
 * Calculate user level based on total points
 * Formula: Level increases exponentially (100 * 1.5^(level-1))
 *
 * @param totalPoints - Total points accumulated
 * @returns The user's level
 */
function calculateLevel(totalPoints: number): number {
  let level = 1;
  while (totalPoints >= getPointsRequiredForLevel(level + 1)) {
    level++;
  }
  return level;
}

/**
 * Get points required to reach a specific level
 *
 * @param level - The target level
 * @returns Points required
 */
function getPointsRequiredForLevel(level: number): number {
  return Math.floor(100 * Math.pow(1.5, level - 1));
}

/**
 * Calculate user tier based on total points
 *
 * @param totalPoints - Total points accumulated
 * @returns User tier (novice, expert, master, legend)
 */
function calculateTier(totalPoints: number): string {
  if (totalPoints >= 50000) return "legend";
  if (totalPoints >= 25000) return "master";
  if (totalPoints >= 10000) return "expert";
  return "novice";
}

/**
 * Check and award level-based badges
 *
 * @param userId - The user ID
 * @param level - The new level achieved
 */
async function checkLevelBadges(userId: string, level: number): Promise<void> {
  const levelBadges: Record<number, string> = {
    5: "level_5_achiever",
    10: "level_10_master",
    20: "level_20_legend",
    30: "level_30_elite",
    50: "level_50_ultimate",
  };

  if (levelBadges[level]) {
    const badgeId = levelBadges[level];
    const db = admin.firestore();
    const badgeRef = db.collection("user_badges").doc(`${userId}_${badgeId}`);

    const badgeDoc = await badgeRef.get();
    if (!badgeDoc.exists) {
      await badgeRef.set({
        userId,
        badgeId,
        name: `Level ${level} Achiever`,
        description: `Reached level ${level}`,
        tier: level <= 10 ? "bronze" : level <= 30 ? "silver" : "gold",
        earnedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`Awarded badge ${badgeId} to user ${userId}`);
    }
  }
}

/**
 * Get today's date as a string (YYYY-MM-DD)
 *
 * @returns Date string
 */
function getTodayDateString(): string {
  const now = new Date();
  return now.toISOString().split("T")[0];
}
