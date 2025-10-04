/**
 * Badge Unlock Checker Cloud Function
 *
 * This function checks for and awards badges based on various achievements.
 * Badges are awarded for:
 * - Point milestones
 * - Activity streaks
 * - Special achievements
 * - Social engagement
 *
 * @module gamification/checkBadgeUnlocks
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Badge definitions with unlock criteria
 */
interface BadgeDefinition {
  id: string;
  name: string;
  description: string;
  tier: "bronze" | "silver" | "gold" | "platinum";
  category: "points" | "activity" | "social" | "special";
  unlockCriteria: {
    type: string;
    threshold?: number;
    pointsCategory?: string;
  };
}

const BADGE_DEFINITIONS: BadgeDefinition[] = [
  // Points Milestones
  {
    id: "points_1000",
    name: "Thousand Club",
    description: "Earned 1,000 total points",
    tier: "bronze",
    category: "points",
    unlockCriteria: { type: "totalPoints", threshold: 1000 },
  },
  {
    id: "points_5000",
    name: "Five Thousand Strong",
    description: "Earned 5,000 total points",
    tier: "silver",
    category: "points",
    unlockCriteria: { type: "totalPoints", threshold: 5000 },
  },
  {
    id: "points_10000",
    name: "Ten Thousand Legend",
    description: "Earned 10,000 total points",
    tier: "gold",
    category: "points",
    unlockCriteria: { type: "totalPoints", threshold: 10000 },
  },
  {
    id: "points_25000",
    name: "Master of Points",
    description: "Earned 25,000 total points",
    tier: "platinum",
    category: "points",
    unlockCriteria: { type: "totalPoints", threshold: 25000 },
  },

  // Level Achievements
  {
    id: "level_5_achiever",
    name: "Rising Star",
    description: "Reached level 5",
    tier: "bronze",
    category: "points",
    unlockCriteria: { type: "level", threshold: 5 },
  },
  {
    id: "level_10_master",
    name: "Expert Achiever",
    description: "Reached level 10",
    tier: "silver",
    category: "points",
    unlockCriteria: { type: "level", threshold: 10 },
  },
  {
    id: "level_20_legend",
    name: "Legendary Status",
    description: "Reached level 20",
    tier: "gold",
    category: "points",
    unlockCriteria: { type: "level", threshold: 20 },
  },

  // Activity Badges
  {
    id: "daily_login_7",
    name: "Week Warrior",
    description: "Logged in 7 days in a row",
    tier: "bronze",
    category: "activity",
    unlockCriteria: { type: "loginStreak", threshold: 7 },
  },
  {
    id: "daily_login_30",
    name: "Monthly Master",
    description: "Logged in 30 days in a row",
    tier: "silver",
    category: "activity",
    unlockCriteria: { type: "loginStreak", threshold: 30 },
  },
  {
    id: "daily_login_100",
    name: "Centurion",
    description: "Logged in 100 days in a row",
    tier: "gold",
    category: "activity",
    unlockCriteria: { type: "loginStreak", threshold: 100 },
  },

  // Social Badges
  {
    id: "social_butterfly",
    name: "Social Butterfly",
    description: "Connected with 10 friends",
    tier: "bronze",
    category: "social",
    unlockCriteria: { type: "friendCount", threshold: 10 },
  },
  {
    id: "social_influencer",
    name: "Social Influencer",
    description: "Connected with 50 friends",
    tier: "silver",
    category: "social",
    unlockCriteria: { type: "friendCount", threshold: 50 },
  },

  // Review Badges
  {
    id: "review_master",
    name: "Review Master",
    description: "Wrote 10 helpful reviews",
    tier: "bronze",
    category: "activity",
    unlockCriteria: { type: "pointsByCategory", pointsCategory: "review", threshold: 200 },
  },

  // Booking Badges
  {
    id: "frequent_visitor",
    name: "Frequent Visitor",
    description: "Completed 10 bookings",
    tier: "bronze",
    category: "activity",
    unlockCriteria: { type: "bookingCount", threshold: 10 },
  },
];

/**
 * Manually check and award badges for a user
 *
 * Can be called from client or scheduled function
 */
export const checkBadgeUnlocks = functions.https.onCall(
  async (data: { userId?: string }, context) => {
    const userId = data.userId || context.auth?.uid;

    if (!userId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "User ID is required"
      );
    }

    functions.logger.info(`Checking badge unlocks for user ${userId}`);

    try {
      const newBadges = await checkAndAwardBadges(userId);

      return {
        success: true,
        newBadges,
        message: newBadges.length > 0
          ? `Unlocked ${newBadges.length} new badge(s)!`
          : "No new badges unlocked",
      };
    } catch (error: any) {
      functions.logger.error(`Error checking badges for user ${userId}:`, error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to check badge unlocks",
        error.message
      );
    }
  }
);

/**
 * Automatic badge checking when user_points changes
 *
 * Triggers whenever points are updated
 */
export const onPointsUpdateCheckBadges = functions.firestore
  .document("user_points/{userId}")
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;

    functions.logger.info(`Auto-checking badges for user ${userId} after points update`);

    try {
      await checkAndAwardBadges(userId);
    } catch (error) {
      functions.logger.error(`Error auto-checking badges for user ${userId}:`, error);
      // Don't throw - we don't want to block points updates
    }

    return null;
  });

/**
 * Check all badge criteria and award eligible badges
 *
 * @param userId - The user to check badges for
 * @returns Array of newly awarded badge IDs
 */
async function checkAndAwardBadges(userId: string): Promise<string[]> {
  const db = admin.firestore();
  const newBadges: string[] = [];

  // Get user data
  const [userPoints, userLevel, userStats] = await Promise.all([
    db.collection("user_points").doc(userId).get(),
    db.collection("user_levels").doc(userId).get(),
    db.collection("user_stats").doc(userId).get(), // Stats like booking count, friend count
  ]);

  const pointsData = userPoints.data();
  const levelData = userLevel.data();
  const statsData = userStats.data() || {};

  if (!pointsData) {
    functions.logger.warn(`No points data found for user ${userId}`);
    return newBadges;
  }

  // Get already earned badges
  const earnedBadgesSnapshot = await db.collection("user_badges")
    .where("userId", "==", userId)
    .get();

  const earnedBadgeIds = new Set(
    earnedBadgesSnapshot.docs.map((doc) => doc.data().badgeId)
  );

  // Check each badge definition
  for (const badge of BADGE_DEFINITIONS) {
    // Skip if already earned
    if (earnedBadgeIds.has(badge.id)) {
      continue;
    }

    // Check if criteria met
    let criteriaMet = false;

    switch (badge.unlockCriteria.type) {
      case "totalPoints":
        criteriaMet = (pointsData.totalPoints || 0) >= (badge.unlockCriteria.threshold || 0);
        break;

      case "level":
        criteriaMet = (levelData?.level || 0) >= (badge.unlockCriteria.threshold || 0);
        break;

      case "pointsByCategory":
        const categoryPoints = pointsData.pointsByCategory?.[badge.unlockCriteria.pointsCategory || ""] || 0;
        criteriaMet = categoryPoints >= (badge.unlockCriteria.threshold || 0);
        break;

      case "loginStreak":
        criteriaMet = (statsData.loginStreak || 0) >= (badge.unlockCriteria.threshold || 0);
        break;

      case "friendCount":
        criteriaMet = (statsData.friendCount || 0) >= (badge.unlockCriteria.threshold || 0);
        break;

      case "bookingCount":
        criteriaMet = (statsData.completedBookings || 0) >= (badge.unlockCriteria.threshold || 0);
        break;

      default:
        functions.logger.warn(`Unknown badge criteria type: ${badge.unlockCriteria.type}`);
    }

    // Award badge if criteria met
    if (criteriaMet) {
      await db.collection("user_badges").doc(`${userId}_${badge.id}`).set({
        userId,
        badgeId: badge.id,
        name: badge.name,
        description: badge.description,
        tier: badge.tier,
        category: badge.category,
        earnedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      newBadges.push(badge.id);
      functions.logger.info(`Awarded badge ${badge.id} to user ${userId}`);

      // Send notification
      await sendBadgeNotification(userId, badge);
    }
  }

  return newBadges;
}

/**
 * Send notification when badge is unlocked
 *
 * @param userId - User who earned the badge
 * @param badge - Badge that was earned
 */
async function sendBadgeNotification(userId: string, badge: BadgeDefinition): Promise<void> {
  try {
    const db = admin.firestore();

    await db.collection("notifications")
      .doc(userId)
      .collection("notifications")
      .add({
        type: "badge_unlocked",
        title: "🏆 New Badge Unlocked!",
        message: `You earned the "${badge.name}" badge: ${badge.description}`,
        badgeId: badge.id,
        badgeName: badge.name,
        badgeTier: badge.tier,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
  } catch (error) {
    functions.logger.error(`Error sending badge notification for ${badge.id}:`, error);
    // Don't throw - notification failure shouldn't block badge award
  }
}

/**
 * Get all available badge definitions
 *
 * Useful for displaying badge showcase with locked/unlocked states
 */
export const getBadgeDefinitions = functions.https.onCall(async () => {
  return {
    success: true,
    badges: BADGE_DEFINITIONS,
  };
});
