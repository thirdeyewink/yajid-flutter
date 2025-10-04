# Yajid Phase 3 Roadmap

**Version:** 1.0
**Created:** October 4, 2025
**Status:** Planning
**Estimated Duration:** 14-20 weeks
**Prerequisites:** Phase 2 Complete, 10K+ Active Users, Revenue Stream Established

---

## Phase 3 Overview

Phase 3 focuses on **platform maturation**, **B2B features**, and **advanced monetization**. This phase transforms Yajid from a consumer app into a comprehensive platform that serves both end-users and business partners (venues, event organizers, advertisers).

**Business Goals:**
- Onboard 500+ business partners
- Generate 1.2M MAD annual revenue from partnerships
- Achieve 50K+ monthly active users
- Establish recurring subscription revenue
- Create advertiser network with 50+ active campaigns

**Success Criteria:**
- Business Partner Dashboard live with 100+ active partners
- Advertising Platform generating 300K MAD/year
- Premium subscriptions: 5% of user base
- 80%+ test coverage
- <2 second average page load
- 99.95% uptime

---

## Phase 3 Features

### 1. Business Partner Dashboard (6-8 weeks)
**Priority:** P0 - Critical for B2B growth
**Business Impact:** 500+ partners, 800K MAD/year revenue
**Target Users:** Venue owners, event organizers, brand managers

#### 1.1 Partner Registration & Onboarding (1-2 weeks)
**Deliverables:**
- Partner registration portal
- Business verification workflow (document upload, review)
- KYC (Know Your Customer) compliance
- Multi-step onboarding wizard
- Partner profile setup (business info, photos, hours)
- Subscription tier selection (Free, Professional, Enterprise)
- Payment method setup for commissions
- Contract acceptance (terms of service, commission structure)
- Onboarding checklist with progress tracking

**Partner Tiers:**
```dart
enum PartnerTier {
  free,        // 20% commission, basic listing
  professional, // 15% commission, enhanced listing, analytics
  enterprise,  // 10% commission, priority support, API access
}

class PartnerSubscription {
  final PartnerTier tier;
  final double monthlyFee;   // MAD
  final double commissionRate; // Percentage
  final Map<String, bool> features;
  final DateTime startDate;
  final DateTime? endDate;
  final bool autoRenew;
}

// Pricing
const partnerPricing = {
  PartnerTier.free: {
    'monthlyFee': 0,
    'commission': 0.20,
    'features': {
      'basicListing': true,
      'photos': 5,
      'analytics': false,
      'priorityPlacement': false,
      'customBranding': false,
      'apiAccess': false,
    },
  },
  PartnerTier.professional: {
    'monthlyFee': 299, // MAD
    'commission': 0.15,
    'features': {
      'basicListing': true,
      'photos': 20,
      'analytics': true,
      'priorityPlacement': true,
      'customBranding': false,
      'apiAccess': false,
    },
  },
  PartnerTier.enterprise: {
    'monthlyFee': 799, // MAD
    'commission': 0.10,
    'features': {
      'basicListing': true,
      'photos': 100,
      'analytics': true,
      'priorityPlacement': true,
      'customBranding': true,
      'apiAccess': true,
    },
  },
};
```

**Verification Workflow:**
```
Partner Applies → Document Upload → Admin Review →
   (Approved → Partner Activated) OR (Rejected → Feedback Given)
```

#### 1.2 Venue Management Interface (2 weeks)
**Deliverables:**
- Add/edit/delete venues
- Venue photo management (upload, crop, reorder)
- Operating hours editor (different hours per day)
- Amenities and services checklist
- Pricing information (menus, price ranges)
- Capacity and reservation settings
- Special offers and promotions
- Temporarily close venue feature
- Bulk import venues (CSV upload)

**Venue Management UI:**
```dart
class VenueManagementScreen extends StatefulWidget {
  Sections:
  1. Venue List
     - Table view with search/filter
     - Status indicators (active, paused, draft)
     - Quick actions (edit, duplicate, delete)
     - Bulk operations (activate, deactivate)

  2. Add/Edit Venue Form
     - Basic Info (name, description, category)
     - Location (address, map picker, GPS coordinates)
     - Photos (drag-drop upload, reorder, set cover)
     - Hours (weekly schedule editor)
     - Amenities (checkboxes: WiFi, parking, etc.)
     - Contact Info (phone, email, website)
     - Social Media (Facebook, Instagram, Twitter)
     - Pricing (menus, price range indicator)
     - Booking Settings (accept reservations, capacity)

  3. Venue Preview
     - See how venue appears to users
     - Test booking flow
}
```

#### 1.3 Booking Management Dashboard (2 weeks)
**Deliverables:**
- View all bookings (today, upcoming, past, cancelled)
- Booking detail view with customer info
- Accept/reject booking requests
- Modify booking (change time, party size)
- Cancel booking with refund processing
- No-show marking
- Customer contact (phone, message)
- Booking calendar view (week/month)
- Table/resource assignment
- Waitlist management

**Booking States:**
```dart
enum BookingStatus {
  pending,      // Awaiting partner approval
  confirmed,    // Partner confirmed
  arrived,      // Customer checked in
  completed,    // Service completed
  cancelled,    // Cancelled by user or partner
  noShow,       // Customer didn't show up
}

class BookingAction {
  final String id;
  final BookingStatus fromStatus;
  final BookingStatus toStatus;
  final String reason;
  final DateTime timestamp;
  final String performedBy; // partnerId or userId
}
```

**Booking Management UI:**
```dart
class BookingDashboard extends StatefulWidget {
  Features:
  1. Booking List
     - Filter by status, date range, venue
     - Search by customer name/email
     - Color-coded status indicators
     - Quick actions (confirm, reject, contact)

  2. Booking Detail
     - Customer info (name, phone, email, photo)
     - Booking details (date, time, party size, special requests)
     - Status history timeline
     - Action buttons (confirm, reject, modify, cancel)
     - Notes section (internal notes, customer instructions)
     - Payment status and amount
     - Send confirmation email/SMS button

  3. Calendar View
     - Day/Week/Month views
     - Drag-and-drop to reschedule
     - Color-coded by status
     - Capacity indicator
     - Click to view/edit booking
}
```

#### 1.4 Revenue Analytics & Reporting (1-2 weeks)
**Deliverables:**
- Revenue dashboard (daily, weekly, monthly, yearly)
- Revenue by venue breakdown
- Commission calculations
- Payout history
- Revenue trends (graphs and charts)
- Booking conversion funnel
- Customer analytics (new vs returning, demographics)
- Peak hours/days analysis
- Seasonal trends
- Export reports (PDF, Excel)
- Custom date range reports
- Comparative analysis (this month vs last month)

**Analytics Metrics:**
```dart
class PartnerAnalytics {
  // Revenue Metrics
  final double totalRevenue;
  final double platformCommission;
  final double netRevenue;
  final double averageOrderValue;
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;

  // Performance Metrics
  final double conversionRate; // views → bookings
  final double acceptanceRate; // accepted / total requests
  final double noShowRate;
  final double averageRating;
  final int totalReviews;

  // Customer Metrics
  final int uniqueCustomers;
  final int returningCustomers;
  final double customerRetentionRate;
  final Map<String, int> customersByAge;
  final Map<String, int> customersByLocation;

  // Time-based Metrics
  final Map<int, double> revenueByHour; // Hour of day
  final Map<int, double> revenueByDayOfWeek;
  final List<TimeSeriesData> revenueTimeline;

  // Venue Performance (for multi-venue partners)
  final Map<String, VenueAnalytics> venueBreakdown;
}
```

**Analytics Dashboard UI:**
```dart
class AnalyticsDashboard extends StatefulWidget {
  Widgets:
  1. Summary Cards
     - Total Revenue (with percentage change)
     - Total Bookings (with percentage change)
     - Average Rating (with star display)
     - Net Payout (after commission)

  2. Revenue Chart
     - Line/bar chart showing revenue over time
     - Selectable time ranges (7D, 30D, 90D, 1Y)
     - Comparison mode (vs previous period)

  3. Booking Funnel
     - Views → Booking Requests → Confirmed → Completed
     - Conversion rates at each stage
     - Identify drop-off points

  4. Customer Insights
     - New vs Returning pie chart
     - Age/Gender distribution
     - Location heatmap
     - Top customers list

  5. Performance Tables
     - Top performing venues
     - Best days/hours
     - Popular services
     - Review highlights
}
```

#### 1.5 Partner Communication Tools (1 week)
**Deliverables:**
- In-app messaging with customers
- Broadcast notifications to customers
- Email campaign builder
- SMS marketing (with opt-in compliance)
- Review response interface
- FAQ management
- Announcement creation
- Support ticket system

**Communication Features:**
```dart
class PartnerCommunication {
  // Message individual customer
  Future<void> sendMessage({
    required String customerId,
    required String message,
  });

  // Broadcast to customer segment
  Future<void> broadcastMessage({
    required String message,
    required CustomerSegment segment, // all, recent, frequent
    List<String>? specificCustomers,
  });

  // Email campaigns
  Future<void> sendEmailCampaign({
    required String subject,
    required String htmlContent,
    required List<String> recipients,
    DateTime? scheduledTime,
  });

  // Review management
  Future<void> respondToReview({
    required String reviewId,
    required String response,
  });
}

enum CustomerSegment {
  all,                // All customers
  recent,             // Customers in last 30 days
  frequent,           // Customers with 3+ bookings
  newCustomers,       // First-time bookers
  hasUpcomingBooking, // Customers with future bookings
}
```

#### 1.6 Marketing & Promotions Manager (1 week)
**Deliverables:**
- Create special offers (% off, fixed amount off, BOGO)
- Set promotion dates and times
- Apply to specific venues or all venues
- Coupon code generator
- Usage limits (per user, total uses)
- Featured placement purchase
- Sponsored listings in search results
- Banner ad creation
- Promotion performance tracking

**Promotion System:**
```dart
class Promotion {
  final String id;
  final String title;
  final String description;
  final PromotionType type;
  final double value; // Percentage or fixed amount
  final DateTime startDate;
  final DateTime endDate;
  final int? maxUses;
  final int? maxUsesPerUser;
  final List<String>? applicableVenues;
  final String? couponCode;
  final bool isActive;
  final int timesUsed;
}

enum PromotionType {
  percentageOff,    // 20% off
  fixedAmountOff,   // 50 MAD off
  bogo,             // Buy one get one
  freeItem,         // Free appetizer
}

// Featured Placement
class FeaturedPlacement {
  final String venueId;
  final DateTime startDate;
  final DateTime endDate;
  final FeaturedType type;
  final double costPerDay; // MAD
  final int impressions;
  final int clicks;
  final double ctr; // Click-through rate
}

enum FeaturedType {
  homepageHero,     // Top banner on homepage
  categoryTop,      // Top of category listing
  searchTop,        // Top 3 in search results
  sidebarAd,        // Sidebar advertisement
}
```

**Testing Requirements:**
- [ ] Partner registration flow end-to-end test
- [ ] Venue CRUD operation tests
- [ ] Booking management workflow tests
- [ ] Analytics calculation accuracy tests
- [ ] Permission tests (partner can only access own data)
- [ ] Commission calculation tests
- [ ] Payout processing tests
- [ ] Promotion validation tests

---

### 2. Advertising Platform (6-8 weeks)
**Priority:** P1 - Key revenue stream
**Business Impact:** 300K MAD/year from advertisers
**Target Users:** Brands, marketers, agencies

#### 2.1 Ad Campaign Management (2 weeks)
**Deliverables:**
- Campaign creation wizard
- Ad creative upload (images, videos)
- Targeting options (demographics, interests, location, behavior)
- Budget and bidding (daily budget, total budget, CPC/CPM bidding)
- Schedule campaigns (start/end dates, time of day)
- A/B testing support (multiple ad variants)
- Campaign approval workflow
- Campaign pause/resume/edit
- Bulk campaign management

**Ad Campaign Model:**
```dart
class AdCampaign {
  final String id;
  final String advertiserId;
  final String name;
  final String objective; // awareness, engagement, conversions
  final AdCreative creative;
  final AdTargeting targeting;
  final AdBudget budget;
  final AdSchedule schedule;
  final CampaignStatus status;
  final AdPerformance performance;
}

class AdCreative {
  final AdFormat format; // banner, video, native
  final String headline;
  final String description;
  final String imageUrl;
  final String? videoUrl;
  final String ctaText; // Call-to-action
  final String destinationUrl;
}

class AdTargeting {
  final List<String>? locations; // Cities
  final int? minAge;
  final int? maxAge;
  final List<String>? genders;
  final List<String>? interests; // food, sports, music, etc.
  final List<String>? behaviors; // frequent bookers, point collectors
}

class AdBudget {
  final BudgetType type; // daily, lifetime
  final double amount; // MAD
  final BidStrategy strategy; // CPC, CPM, target CPA
  final double? bidAmount;
}

enum AdFormat { banner, video, native, interstitial }
enum BudgetType { daily, lifetime }
enum BidStrategy { cpc, cpm, targetCPA }
enum CampaignStatus { draft, pending, active, paused, completed, rejected }
```

#### 2.2 Ad Serving Engine (2 weeks)
**Deliverables:**
- Ad selection algorithm (targeting match, bid auction)
- Frequency capping (max 3 times/day per user)
- Ad rotation (even distribution)
- Context-aware placement (relevant to page content)
- Load-time optimization (<500ms to select ad)
- Ad impression tracking
- Click tracking with attribution
- Conversion tracking
- Viewability measurement (50% visible for 1+ seconds)

**Ad Selection Algorithm:**
```typescript
// functions/src/ads/selectAd.ts
export const selectAd = functions.https.onCall(async (data, context) => {
  const { placement, userId, pageContext } = data;

  // 1. Get user profile for targeting
  const userProfile = await getUserProfile(userId);

  // 2. Find eligible campaigns
  const eligibleCampaigns = await firestore()
    .collection('ad_campaigns')
    .where('status', '==', 'active')
    .where('placement', '==', placement)
    .where('budget.remaining', '>', 0)
    .get();

  // 3. Filter by targeting criteria
  const targetedCampaigns = eligibleCampaigns.docs.filter((doc) => {
    const campaign = doc.data();
    return matchesTargeting(campaign.targeting, userProfile);
  });

  // 4. Check frequency caps
  const capFilteredCampaigns = await filterByFrequencyCap(
    targetedCampaigns,
    userId
  );

  if (capFilteredCampaigns.length === 0) {
    return { ad: null }; // No ad to show
  }

  // 5. Run auction (highest bid wins)
  const winner = runAdAuction(capFilteredCampaigns);

  // 6. Record impression
  await recordImpression(winner.id, userId, placement);

  // 7. Deduct from budget
  await deductFromBudget(winner.id, winner.bid);

  return {
    ad: winner.creative,
    campaignId: winner.id,
    impressionId: generateImpressionId(),
  };
});

function matchesTargeting(targeting: AdTargeting, profile: UserProfile): boolean {
  // Location match
  if (targeting.locations && !targeting.locations.includes(profile.city)) {
    return false;
  }

  // Age match
  if (targeting.minAge && profile.age < targeting.minAge) return false;
  if (targeting.maxAge && profile.age > targeting.maxAge) return false;

  // Gender match
  if (targeting.genders && !targeting.genders.includes(profile.gender)) {
    return false;
  }

  // Interest match (at least one overlap)
  if (targeting.interests) {
    const hasInterestMatch = targeting.interests.some((interest) =>
      profile.interests.includes(interest)
    );
    if (!hasInterestMatch) return false;
  }

  return true;
}

function runAdAuction(campaigns: Campaign[]): Campaign {
  // Second-price auction: Winner pays second-highest bid + 1 cent
  const sortedByBid = campaigns.sort((a, b) => b.bid - a.bid);
  const winner = sortedByBid[0];
  const secondPrice = sortedByBid.length > 1 ? sortedByBid[1].bid + 0.01 : winner.bid;

  return {
    ...winner,
    actualCost: secondPrice,
  };
}
```

#### 2.3 Ad Performance Dashboard (1 week)
**Deliverables:**
- Real-time campaign metrics
- Impressions, clicks, CTR, conversions
- Cost metrics (spent, remaining, CPC, CPM, CPA)
- ROI calculator
- Audience insights (who saw/clicked)
- Placement performance (which placements perform best)
- Time-of-day analysis
- Device breakdown (mobile vs web)
- Geographic performance
- Export reports

**Performance Metrics:**
```dart
class AdPerformance {
  // Delivery Metrics
  final int impressions;
  final int clicks;
  final double ctr; // Click-through rate (clicks / impressions)
  final int conversions;
  final double conversionRate;

  // Cost Metrics
  final double totalSpent;
  final double budgetRemaining;
  final double avgCPC; // Average cost per click
  final double avgCPM; // Average cost per 1000 impressions
  final double avgCPA; // Average cost per action/conversion

  // Efficiency Metrics
  final double roi; // Return on investment
  final double roas; // Return on ad spend
  final int reach; // Unique users who saw ad
  final double frequency; // Avg times user saw ad

  // Engagement Metrics
  final int videoViews; // For video ads
  final double avgViewDuration;
  final int shares;
  final int likes;
  final int comments;
}
```

#### 2.4 Advertiser Self-Service Portal (1-2 weeks)
**Deliverables:**
- Advertiser registration
- Account verification (business documents)
- Payment method setup (credit card, bank transfer)
- Billing history
- Invoice generation
- Campaign creation wizard
- Creative library management
- Audience builder (saved targeting profiles)
- Budget management
- Support ticket system

**Advertiser Portal Sections:**
```dart
class AdvertiserPortal {
  1. Dashboard
     - Active campaigns summary
     - Spend vs budget chart
     - Top performing campaigns
     - Alerts (low budget, campaign ending)

  2. Campaigns
     - Create new campaign wizard
     - Active campaigns list
     - Paused campaigns
     - Completed campaigns
     - Duplicate campaign feature

  3. Creative Library
     - Upload ad creatives
     - Image/video management
     - Ad preview tool
     - Compliance checker

  4. Audiences
     - Create saved audiences
     - Lookalike audience builder
     - Audience size estimator

  5. Billing
     - Add/edit payment methods
     - Billing history
     - Download invoices
     - Set billing alerts

  6. Reports
     - Campaign performance reports
     - Custom date ranges
     - Export to CSV/PDF
     - Scheduled reports (email daily/weekly)
}
```

#### 2.5 Ad Compliance & Moderation (1 week)
**Deliverables:**
- Ad review queue for admins
- Automated policy checks (prohibited content detection)
- Manual review workflow
- Approval/rejection with feedback
- Appeal process
- Restricted categories (alcohol, gambling, politics)
- Content filtering (profanity, misleading claims)
- Compliance reports

**Ad Policy Checks:**
```typescript
// functions/src/ads/moderateAd.ts
export const moderateAd = functions.firestore
  .document('ad_campaigns/{campaignId}')
  .onCreate(async (snapshot, context) => {
    const campaign = snapshot.data();

    // Automated checks
    const violations = [];

    // 1. Check for prohibited words
    const prohibitedWords = ['guarantee', 'free money', 'click here'];
    const text = `${campaign.creative.headline} ${campaign.creative.description}`;
    for (const word of prohibitedWords) {
      if (text.toLowerCase().includes(word)) {
        violations.push(`Prohibited word: ${word}`);
      }
    }

    // 2. Check image for inappropriate content (use ML API)
    const imageModeration = await moderateImage(campaign.creative.imageUrl);
    if (imageModeration.explicitContent > 0.5) {
      violations.push('Image contains explicit content');
    }

    // 3. Check destination URL is valid
    if (!isValidURL(campaign.creative.destinationUrl)) {
      violations.push('Invalid destination URL');
    }

    // 4. Check targeting is not discriminatory
    if (campaign.targeting.genders && campaign.targeting.genders.length === 1) {
      violations.push('Discriminatory gender targeting');
    }

    if (violations.length > 0) {
      // Auto-reject with reasons
      await snapshot.ref.update({
        status: 'rejected',
        rejectionReasons: violations,
        reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Notify advertiser
      await sendRejectionEmail(campaign.advertiserId, violations);
    } else {
      // Send to manual review queue
      await admin.firestore().collection('ad_review_queue').add({
        campaignId: context.params.campaignId,
        priority: campaign.budget.amount > 1000 ? 'high' : 'normal',
        submittedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });
```

**Testing Requirements:**
- [ ] Ad selection algorithm tests (targeting accuracy)
- [ ] Auction mechanism tests (pricing correctness)
- [ ] Frequency cap enforcement tests
- [ ] Impression/click tracking accuracy tests
- [ ] Budget deduction correctness tests
- [ ] Performance metrics calculation tests
- [ ] Ad moderation policy tests
- [ ] Load tests (10K+ concurrent ad requests)

---

### 3. Premium Subscriptions (2-3 weeks)
**Priority:** P2 - Recurring revenue stream
**Business Impact:** 200K MAD/year from subscriptions
**Target**: 5% of user base (2,500 users @ 80 MAD/month)

#### 3.1 Premium Tier Features (1 week)
**Deliverables:**
- Ad-free experience
- Priority booking (get booking confirmations faster)
- Exclusive deals and discounts
- Early access to new features
- Advanced gamification (extra points, exclusive badges)
- VIP customer support
- Extended refund window (7 days vs 2 days)
- Multi-device sync (up to 5 devices)

**Subscription Tiers:**
```dart
enum SubscriptionTier {
  free,
  premium,    // 80 MAD/month or 800 MAD/year (2 months free)
  premiumPlus, // 150 MAD/month or 1500 MAD/year
}

class UserSubscription {
  final String userId;
  final SubscriptionTier tier;
  final DateTime startDate;
  final DateTime expiryDate;
  final BillingCycle cycle; // monthly, yearly
  final double price;
  final bool autoRenew;
  final PaymentMethod paymentMethod;
  final SubscriptionStatus status;
}

enum SubscriptionStatus {
  active,
  cancelled,
  expired,
  paymentFailed,
  gracePeriod, // 3 days after payment failure
}

const subscriptionFeatures = {
  SubscriptionTier.premium: {
    'adFree': true,
    'priorityBooking': true,
    'exclusiveDeals': true,
    'pointsMultiplier': 1.5,
    'exclusiveBadges': true,
    'vipSupport': true,
    'refundWindow': 7, // days
    'maxDevices': 5,
  },
  SubscriptionTier.premiumPlus: {
    'adFree': true,
    'priorityBooking': true,
    'exclusiveDeals': true,
    'pointsMultiplier': 2.0,
    'exclusiveBadges': true,
    'vipSupport': true,
    'refundWindow': 14, // days
    'maxDevices': 10,
    'personalConcierge': true, // Dedicated support agent
    'earlyFeatureAccess': true,
  },
};
```

#### 3.2 Subscription Purchase Flow (1 week)
**Deliverables:**
- Subscription plans showcase page
- Free trial (7 days, no credit card required)
- Upgrade/downgrade flow
- Cancellation flow (with retention offers)
- Billing management screen
- Subscription renewal notifications
- Payment retry logic (on failure)
- Proration calculations (mid-month upgrades)

**Purchase Flow:**
```
Browse Plans → Select Tier → Start Free Trial OR Pay Now →
Payment → Confirmation → Access Premium Features
```

**Cloud Function for Subscription Management:**
```typescript
// functions/src/subscriptions/subscribe.ts
export const createSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { tier, cycle } = data;
  const userId = context.auth.uid;

  // Calculate pricing
  const pricing = getSubscriptionPricing(tier, cycle);

  // Create Stripe subscription
  const stripe = new Stripe(functions.config().stripe.secret_key);
  const stripeCustomer = await getOrCreateStripeCustomer(userId);

  const subscription = await stripe.subscriptions.create({
    customer: stripeCustomer.id,
    items: [{ price: pricing.stripePriceId }],
    trial_period_days: 7, // 7-day free trial
    metadata: {
      userId,
      tier,
      cycle,
    },
  });

  // Save subscription to Firestore
  await admin.firestore().collection('user_subscriptions').doc(userId).set({
    userId,
    tier,
    cycle,
    stripeSubscriptionId: subscription.id,
    status: 'trialing',
    startDate: admin.firestore.Timestamp.fromDate(
      new Date(subscription.trial_start * 1000)
    ),
    trialEndDate: admin.firestore.Timestamp.fromDate(
      new Date(subscription.trial_end * 1000)
    ),
    autoRenew: true,
  });

  // Grant premium features
  await grantPremiumFeatures(userId, tier);

  return {
    success: true,
    subscriptionId: subscription.id,
    trialEndsAt: subscription.trial_end,
  };
});

// Webhook handler for subscription events
export const handleSubscriptionWebhook = functions.https.onRequest(async (req, res) => {
  const event = req.body;

  switch (event.type) {
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object);
      break;
    case 'customer.subscription.deleted':
      await handleSubscriptionCancelled(event.data.object);
      break;
    case 'invoice.payment_failed':
      await handlePaymentFailed(event.data.object);
      break;
    case 'invoice.payment_succeeded':
      await handlePaymentSucceeded(event.data.object);
      break;
  }

  res.json({ received: true });
});
```

#### 3.3 Subscription Analytics (1 week)
**Deliverables:**
- MRR (Monthly Recurring Revenue) tracking
- Churn rate calculation
- Lifetime value (LTV) per subscriber
- Subscription cohort analysis
- Trial conversion rate
- Cancellation reasons tracking
- Retention metrics
- Revenue forecasting

**Subscription Metrics:**
```dart
class SubscriptionAnalytics {
  // Revenue Metrics
  final double mrr; // Monthly Recurring Revenue
  final double arr; // Annual Recurring Revenue
  final int totalSubscribers;
  final int activeSubscribers;
  final int trialingSubscribers;

  // Conversion Metrics
  final double trialConversionRate;
  final int newSubscribersThisMonth;
  final int cancelledSubscribersThisMonth;

  // Retention Metrics
  final double churnRate; // Percentage
  final double retentionRate;
  final double avgLifetimeMonths;
  final double customerLTV; // Lifetime Value

  // Tier Distribution
  final Map<SubscriptionTier, int> subscribersByTier;
  final Map<BillingCycle, int> subscribersByCycle;

  // Financial Forecast
  final double projected3MonthRevenue;
  final double projected12MonthRevenue;
}
```

**Testing Requirements:**
- [ ] Subscription purchase flow tests
- [ ] Free trial expiration tests
- [ ] Payment retry logic tests
- [ ] Cancellation and refund tests
- [ ] Feature access control tests (premium-only features)
- [ ] Webhook handling tests
- [ ] Proration calculation tests

---

### 4. Advanced Analytics & Insights (2-3 weeks)
**Priority:** P2 - Data-driven decision making
**Business Impact:** Improve retention by 20%, increase revenue by 15%

#### 4.1 User Behavior Analytics (1 week)
**Deliverables:**
- User journey mapping
- Funnel analysis (registration → first booking → repeat booking)
- Session recording and heatmaps
- A/B testing framework
- Cohort retention analysis
- Feature usage tracking
- Drop-off point identification
- User segmentation

**Analytics Implementation:**
```dart
// Use Firebase Analytics + Mixpanel for advanced analytics
class AdvancedAnalytics {
  // Track user events
  void trackEvent(String eventName, Map<String, dynamic> properties) {
    FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: properties,
    );
    Mixpanel.track(eventName, properties);
  }

  // Track screen views
  void trackScreenView(String screenName) {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: screenName);
  }

  // Set user properties
  void setUserProperties(Map<String, dynamic> properties) {
    for (var entry in properties.entries) {
      FirebaseAnalytics.instance.setUserProperty(
        name: entry.key,
        value: entry.value.toString(),
      );
    }
    Mixpanel.people.set(properties);
  }

  // Track revenue
  void trackRevenue(double amount, String currency, String transactionId) {
    Mixpanel.people.trackCharge(amount);
    FirebaseAnalytics.instance.logEvent(
      name: 'purchase',
      parameters: {
        'value': amount,
        'currency': currency,
        'transaction_id': transactionId,
      },
    );
  }
}
```

#### 4.2 Business Intelligence Dashboard (1-2 weeks)
**Deliverables:**
- Executive dashboard (KPIs at a glance)
- Revenue breakdown (by source, category, region)
- User growth metrics
- Engagement metrics (DAU, MAU, session duration)
- GMV (Gross Merchandise Value) tracking
- Take rate analysis
- Market share by city
- Competitive analysis integration

**BI Metrics:**
```dart
class BusinessMetrics {
  // Growth Metrics
  final int totalUsers;
  final int mau; // Monthly Active Users
  final int dau; // Daily Active Users
  final double dauMauRatio; // Stickiness
  final int newUsersThisMonth;
  final double growthRate;

  // Revenue Metrics
  final double gmv; // Gross Merchandise Value
  final double totalRevenue;
  final double takeRate; // Platform commission percentage
  final Map<String, double> revenueBySource; // tickets, commissions, ads, subscriptions

  // Engagement Metrics
  final double avgSessionDuration; // minutes
  final double avgBookingsPerUser;
  final double bookingFrequency; // bookings per month per active user

  // Market Metrics
  final Map<String, int> usersByCity;
  final Map<String, double> revenueByCity;
  final int totalPartners;
  final int activePartners;
}
```

---

## Phase 3 Timeline

### Week 1-8: Business Partner Dashboard
- Week 1-2: Partner registration and onboarding
- Week 3-4: Venue management interface
- Week 5-6: Booking management dashboard
- Week 7: Revenue analytics
- Week 8: Communication tools and marketing

### Week 9-16: Advertising Platform (Parallel with Partner Dashboard)
- Week 9-10: Ad campaign management
- Week 11-12: Ad serving engine and algorithm
- Week 13: Ad performance dashboard
- Week 14-15: Advertiser self-service portal
- Week 16: Ad compliance and moderation

### Week 17-19: Premium Subscriptions
- Week 17: Premium tier features
- Week 18: Subscription purchase flow
- Week 19: Subscription analytics

### Week 20: Platform Analytics & BI
- Week 20: Advanced analytics and BI dashboard

---

## Success Metrics

### Business Metrics
- **Partners Onboarded:** 500+ active partners
- **Partner Revenue:** 800K MAD/year
- **Ad Revenue:** 300K MAD/year
- **Subscription Revenue:** 200K MAD/year
- **Total Revenue:** 2.3M MAD/year (GMV + commissions + ads + subscriptions)

### User Metrics
- **MAU:** 50,000+
- **Premium Subscribers:** 2,500 (5% of users)
- **User Retention:** 65%+ (Month 1 to Month 6)
- **Average Revenue Per User (ARPU):** 46 MAD/month

### Platform Metrics
- **GMV:** 10M MAD/year
- **Take Rate:** 12% average
- **Partner Retention:** 80%+
- **Advertiser Retention:** 70%+

---

## Deployment & Rollout

### Beta Phase (Weeks 1-2)
- Invite 20 pilot partners
- Limited feature set
- Intensive feedback collection
- Daily bug fixes

### Limited Release (Weeks 3-4)
- Expand to 100 partners
- All features enabled
- Monitor performance closely
- A/B test pricing

### Full Production (Week 5+)
- Open registration to all partners
- Marketing campaign
- Partner onboarding webinars
- 24/7 support

---

**Document Control:**
- **Next Review:** December 1, 2025
- **Owner:** Product Team
- **Stakeholders:** Engineering, Business Development, Marketing, Sales
- **Related Docs:** PHASE_2_ROADMAP.md, BRD-002, FSD-004
