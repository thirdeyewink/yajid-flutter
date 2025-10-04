# Yajid Phase 2 Roadmap

**Version:** 1.0
**Created:** October 4, 2025
**Status:** Planning
**Estimated Duration:** 12-16 weeks
**Prerequisites:** Phase 1 MVP Complete + Cloud Functions Implemented

---

## Phase 2 Overview

Phase 2 focuses on **monetization features** and **advanced engagement mechanics** that build upon the solid MVP foundation. This phase introduces QR ticketing for event monetization, auction systems for gamification engagement, and enhanced payment processing.

**Business Goals:**
- Generate 850K MAD revenue in Year 1 (per BRD-002)
- Achieve 100K tickets sold annually
- Increase user engagement by 40%
- Establish recurring revenue streams

**Success Criteria:**
- QR Ticketing Platform live and processing transactions
- Auction system with 1,000+ weekly bids
- Payment integration complete with CMI and Stripe
- 60%+ test coverage
- Zero critical security vulnerabilities

---

## Phase 2 Features

### 1. QR Ticketing Platform (8-12 weeks)
**Priority:** P0 - Critical for revenue generation
**Business Impact:** 850K MAD Year 1 revenue target
**Dependencies:** Payment integration, Event system completion

#### 1.1 Event Management System (2-3 weeks)
**Deliverables:**
- Complete Event model integration with EventService
- Event creation UI with form validation
- Event categories (concerts, sports, exhibitions, conferences)
- Multi-tier pricing (VIP, Regular, Early Bird)
- Capacity management with real-time availability
- Event scheduling with date/time pickers
- Location integration with maps
- Event photo gallery upload
- Event editing and cancellation workflows
- Admin dashboard for event moderation

**Technical Tasks:**
```dart
// lib/models/event_model.dart
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final Location location;
  final List<TicketTier> ticketTiers;
  final int capacity;
  final int sold;
  final EventCategory category;
  final String organizerId;
  final List<String> photoUrls;
  final EventStatus status;
  final DateTime createdAt;
}

enum EventStatus { draft, published, cancelled, completed }
enum EventCategory { concert, sports, exhibition, conference, theater }

class TicketTier {
  final String name;
  final double price;
  final int capacity;
  final int sold;
  final DateTime? salesStart;
  final DateTime? salesEnd;
}
```

**Firestore Collections:**
```javascript
events/{eventId}
  - title, description, dates, location
  - ticketTiers[], capacity, sold
  - category, organizerId, status

event_bookings/{bookingId}
  - eventId, userId, ticketTierId
  - quantity, totalPrice
  - status (pending, confirmed, cancelled)
```

**Security Rules:**
```javascript
match /events/{eventId} {
  allow read: if isAuthenticated();
  allow create: if isAuthenticated() &&
                   request.resource.data.organizerId == request.auth.uid;
  allow update, delete: if isAuthenticated() &&
                           resource.data.organizerId == request.auth.uid;
}
```

#### 1.2 QR Ticket Generation (1-2 weeks)
**Deliverables:**
- QR code generation with encryption
- Ticket PDF generation with branding
- Unique ticket ID with collision prevention
- Digital wallet integration (Apple Wallet, Google Pay)
- Email delivery with ticket attachments
- SMS delivery with ticket links
- In-app ticket storage

**Technical Implementation:**
```dart
// Use qr_flutter package for QR generation
class TicketQRGenerator {
  static Future<String> generateTicketQR({
    required String ticketId,
    required String eventId,
    required String userId,
    required DateTime eventDate,
  }) async {
    // Create encrypted payload
    final payload = await _encryptTicketData({
      'ticketId': ticketId,
      'eventId': eventId,
      'userId': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'eventDate': eventDate.millisecondsSinceEpoch,
    });

    // Generate QR code
    return payload;
  }

  static Future<String> _encryptTicketData(Map<String, dynamic> data) async {
    // Use AES-256 encryption
    // Include HMAC signature for integrity
    // Add timestamp for replay attack prevention
  }
}
```

**Required Packages:**
```yaml
dependencies:
  qr_flutter: ^4.1.0
  encrypt: ^5.0.3
  pdf: ^3.10.7
  flutter_email_sender: ^6.0.2
```

#### 1.3 Ticket Scanner Application (3 weeks)
**Deliverables:**
- Dedicated scanner app for event organizers
- QR code scanning with camera
- Offline validation support
- Duplicate detection (prevents double-scanning)
- Real-time attendance tracking
- Entry/exit logging
- Scanner authentication
- Multi-scanner support for large events
- Scanner analytics dashboard

**Architecture:**
```
Scanner App:
├── Authentication (organizer/staff only)
├── Event Selection
├── QR Scanner Interface
│   ├── Camera integration
│   ├── QR detection and decryption
│   ├── Validation (ticket valid, not used, correct event)
│   └── Visual/audio feedback
├── Offline Mode
│   ├── Local ticket database sync
│   ├── Offline validation
│   └── Queue for sync when online
└── Analytics
    ├── Total scanned
    ├── Valid/invalid attempts
    ├── Entry times heatmap
```

**Cloud Function for Validation:**
```typescript
// functions/src/tickets/validateTicket.ts
export const validateTicket = functions.https.onCall(async (data, context) => {
  const { encryptedPayload, scannerId, eventId } = data;

  // 1. Decrypt ticket data
  const ticketData = await decryptTicketPayload(encryptedPayload);

  // 2. Verify ticket authenticity
  if (!await verifyHMAC(ticketData)) {
    return { valid: false, reason: 'Invalid ticket signature' };
  }

  // 3. Check ticket exists in database
  const ticketDoc = await admin.firestore()
    .collection('tickets')
    .doc(ticketData.ticketId)
    .get();

  if (!ticketDoc.exists) {
    return { valid: false, reason: 'Ticket not found' };
  }

  const ticket = ticketDoc.data();

  // 4. Validate ticket status
  if (ticket.status === 'used') {
    return {
      valid: false,
      reason: 'Ticket already used',
      usedAt: ticket.usedAt,
      usedBy: ticket.usedBy,
    };
  }

  if (ticket.status === 'cancelled') {
    return { valid: false, reason: 'Ticket cancelled' };
  }

  // 5. Verify event match
  if (ticket.eventId !== eventId) {
    return { valid: false, reason: 'Wrong event' };
  }

  // 6. Mark ticket as used
  await ticketDoc.ref.update({
    status: 'used',
    usedAt: admin.firestore.FieldValue.serverTimestamp(),
    usedBy: scannerId,
  });

  // 7. Log entry
  await admin.firestore().collection('event_entries').add({
    ticketId: ticketData.ticketId,
    eventId,
    scannerId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    valid: true,
    ticketHolder: ticket.userName,
    ticketTier: ticket.tierName,
  };
});
```

#### 1.4 Ticket Purchase Flow (2 weeks)
**Deliverables:**
- Browse events by category/location/date
- Event detail page with ticket selection
- Quantity selector with tier selection
- Shopping cart for multiple events
- Checkout flow integration with payments
- Order confirmation page
- Order history screen
- Ticket refund/cancellation flow
- Transfer ticket to another user

**User Flow:**
```
1. Browse Events → 2. Event Details → 3. Select Tickets → 4. Checkout
                                           ↓
5. Order Confirmation ← Payment ← Review Order
                         ↓
                    Ticket Delivery (Email + In-App)
```

#### 1.5 Event Analytics Dashboard (1 week)
**Deliverables:**
- Sales tracking (revenue, tickets sold)
- Attendance tracking (scanned vs purchased)
- Revenue by ticket tier
- Sales velocity graphs
- Geographic distribution of attendees
- Peak scanning times
- Refund/cancellation rates
- Organizer payout calculations

**Metrics Tracked:**
```dart
class EventAnalytics {
  final int totalTicketsSold;
  final double totalRevenue;
  final int totalAttendees;
  final Map<String, int> salesByTier;
  final Map<String, double> revenueByTier;
  final List<TimestampedSale> salesTimeline;
  final int refunds;
  final double refundAmount;
  final double organizerPayout; // After platform fee
}
```

**Testing Requirements:**
- [ ] Unit tests for Event model serialization
- [ ] Unit tests for QR encryption/decryption
- [ ] Integration tests for ticket purchase flow
- [ ] Integration tests for scanner validation
- [ ] Load testing for concurrent ticket purchases
- [ ] Security testing for QR forgery attempts
- [ ] End-to-end test: Create event → Purchase ticket → Scan ticket

---

### 2. Auction System (4-6 weeks)
**Priority:** P1 - High engagement feature
**Business Impact:** Increase daily active users by 40%
**Dependencies:** Gamification Cloud Functions complete

#### 2.1 Auction Models and Service (1 week)
**Deliverables:**
- Auction model with bid history
- Auction service with real-time updates
- Auction BLoC for state management
- WebSocket integration for live bidding
- Anti-sniping mechanism (extend time if last-minute bid)
- Reserve price logic
- Auto-bidding (proxy bidding)
- Auction notifications

**Data Models:**
```dart
class Auction {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int startingPrice; // in points
  final int? reservePrice;
  final DateTime startTime;
  final DateTime endTime;
  final AuctionStatus status;
  final String createdBy;
  final AuctionType type; // points-only, hybrid (points + MAD)
  final List<String> categories;
  final int currentBid;
  final String? currentBidder;
  final int bidCount;
  final List<String> watchers;
}

class Bid {
  final String id;
  final String auctionId;
  final String userId;
  final String userName;
  final int amount; // points
  final DateTime timestamp;
  final BidType type; // manual, auto
}

enum AuctionStatus { scheduled, active, ended, cancelled }
enum AuctionType { pointsOnly, hybrid }
```

**Firestore Structure:**
```javascript
auctions/{auctionId}
  - title, description, imageUrl
  - startingPrice, reservePrice, currentBid
  - startTime, endTime, status
  - currentBidder, bidCount, watchers[]

auction_bids/{bidId}
  - auctionId, userId, userName
  - amount, timestamp, type

user_auction_activity/{userId}/auctions/{auctionId}
  - status: won, outbid, watching
  - highestBid, bidCount
```

#### 2.2 Real-Time Bidding Engine (2 weeks)
**Deliverables:**
- WebSocket connection for live updates
- Bid validation (sufficient points, auction active)
- Concurrent bid handling (prevent race conditions)
- Bid increment rules (minimum 5% increase)
- Auto-bidding system (set max bid, system bids for you)
- Outbid notifications (push + in-app)
- Last-minute extension (anti-sniping)
- Bid retraction policy (first 5 minutes only)

**Cloud Function for Bidding:**
```typescript
// functions/src/auctions/placeBid.ts
export const placeBid = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { auctionId, bidAmount } = data;
  const userId = context.auth.uid;

  return await admin.firestore().runTransaction(async (transaction) => {
    // 1. Get auction
    const auctionRef = admin.firestore().collection('auctions').doc(auctionId);
    const auctionDoc = await transaction.get(auctionRef);

    if (!auctionDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Auction not found');
    }

    const auction = auctionDoc.data();

    // 2. Validate auction is active
    const now = admin.firestore.Timestamp.now();
    if (auction.status !== 'active' ||
        now < auction.startTime ||
        now > auction.endTime) {
      throw new functions.https.HttpsError('failed-precondition', 'Auction not active');
    }

    // 3. Validate bid amount
    const minimumBid = Math.ceil(auction.currentBid * 1.05); // 5% increase
    if (bidAmount < minimumBid) {
      throw new functions.https.HttpsError('invalid-argument',
        `Minimum bid is ${minimumBid} points`);
    }

    // 4. Check user has enough points
    const userPointsRef = admin.firestore()
      .collection('user_points')
      .doc(userId);
    const userPointsDoc = await transaction.get(userPointsRef);

    if (!userPointsDoc.exists || userPointsDoc.data().totalPoints < bidAmount) {
      throw new functions.https.HttpsError('failed-precondition',
        'Insufficient points');
    }

    // 5. Place bid
    const bidRef = admin.firestore().collection('auction_bids').doc();
    transaction.set(bidRef, {
      auctionId,
      userId,
      userName: context.auth.token.name || 'Anonymous',
      amount: bidAmount,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      type: 'manual',
    });

    // 6. Update auction
    const previousBidder = auction.currentBidder;
    transaction.update(auctionRef, {
      currentBid: bidAmount,
      currentBidder: userId,
      bidCount: admin.firestore.FieldValue.increment(1),
      lastBidTime: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 7. Anti-sniping: extend auction if bid in last 2 minutes
    const timeRemaining = auction.endTime.toMillis() - now.toMillis();
    if (timeRemaining < 120000) { // 2 minutes
      transaction.update(auctionRef, {
        endTime: admin.firestore.Timestamp.fromMillis(
          auction.endTime.toMillis() + 120000 // Add 2 minutes
        ),
      });
    }

    // 8. Notify previous bidder (if exists)
    if (previousBidder && previousBidder !== userId) {
      const notificationRef = admin.firestore()
        .collection('notifications')
        .doc(previousBidder)
        .collection('notifications')
        .doc();

      transaction.set(notificationRef, {
        type: 'auction_outbid',
        title: 'You\'ve been outbid!',
        message: `Someone bid ${bidAmount} points on "${auction.title}"`,
        auctionId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
    }

    return {
      success: true,
      newBid: bidAmount,
      timeExtended: timeRemaining < 120000,
    };
  });
});
```

**WebSocket Integration:**
```dart
// lib/services/auction_realtime_service.dart
class AuctionRealtimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream auction updates
  Stream<Auction> streamAuction(String auctionId) {
    return _firestore
        .collection('auctions')
        .doc(auctionId)
        .snapshots()
        .map((doc) => Auction.fromFirestore(doc));
  }

  // Stream bid history
  Stream<List<Bid>> streamBids(String auctionId) {
    return _firestore
        .collection('auction_bids')
        .where('auctionId', isEqualTo: auctionId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bid.fromFirestore(doc))
            .toList());
  }
}
```

#### 2.3 Auction UI & UX (1-2 weeks)
**Deliverables:**
- Browse auctions page (active, upcoming, ended)
- Auction detail page with live bid feed
- Bid placement interface with confirmation
- Auction countdown timer
- Bid history timeline
- My Bids screen (active bids, won items, lost bids)
- My Watchlist (auctions user is watching)
- Winner announcement screen
- Item claim/delivery flow

**UI Components:**
```dart
// Auction card showing on browse page
class AuctionCard extends StatelessWidget {
  - Auction image
  - Title and category
  - Current bid / Starting price
  - Countdown timer
  - "Place Bid" / "View" button
  - Watch icon (save to watchlist)
}

// Auction detail screen
class AuctionDetailScreen extends StatelessWidget {
  - Full-screen image carousel
  - Title and detailed description
  - Auction status banner (Active / Ending Soon / Ended)
  - Current bid with real-time updates
  - Next minimum bid calculator
  - Bid history list (real-time)
  - Place bid button with amount input
  - Watch/Unwatch button
  - Share button
  - Seller info
}

// Bid placement dialog
class PlaceBidDialog extends StatefulWidget {
  - Current bid display
  - Bid amount input (with +10, +50, +100 quick buttons)
  - Your points balance display
  - Estimated new total if outbid
  - Confirm/Cancel buttons
  - Loading state during bid submission
}
```

#### 2.4 Auction End and Winner Selection (1 week)
**Deliverables:**
- Scheduled Cloud Function to end auctions
- Winner selection logic (highest bidder)
- Winner notification (push + email)
- Loser notifications (refund points if escrowed)
- Points deduction for winner
- Prize distribution workflow
- Seller payout calculation
- Auction history archival

**Cloud Function for Auction End:**
```typescript
// functions/src/auctions/endAuction.ts
// Runs every minute to check for ended auctions
export const checkEndedAuctions = functions.pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    // Find auctions that ended in last minute
    const endedAuctions = await admin.firestore()
      .collection('auctions')
      .where('status', '==', 'active')
      .where('endTime', '<=', now)
      .get();

    for (const auctionDoc of endedAuctions.docs) {
      await processAuctionEnd(auctionDoc);
    }
  });

async function processAuctionEnd(auctionDoc: FirebaseFirestore.DocumentSnapshot) {
  const auction = auctionDoc.data();
  const auctionId = auctionDoc.id;

  // Update auction status
  await auctionDoc.ref.update({
    status: 'ended',
    endedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // If no bids or reserve not met
  if (!auction.currentBidder ||
      (auction.reservePrice && auction.currentBid < auction.reservePrice)) {
    await auctionDoc.ref.update({ outcome: 'no_winner' });
    return;
  }

  // Deduct points from winner
  await admin.firestore()
    .collection('user_points')
    .doc(auction.currentBidder)
    .update({
      totalPoints: admin.firestore.FieldValue.increment(-auction.currentBid),
    });

  // Record transaction
  await admin.firestore().collection('points_transactions').add({
    userId: auction.currentBidder,
    points: -auction.currentBid,
    category: 'auction_won',
    description: `Won auction: ${auction.title}`,
    referenceId: auctionId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Notify winner
  await admin.firestore()
    .collection('notifications')
    .doc(auction.currentBidder)
    .collection('notifications')
    .add({
      type: 'auction_won',
      title: 'Congratulations! You won!',
      message: `You won the auction for "${auction.title}" with ${auction.currentBid} points`,
      auctionId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });

  // Mark auction as won
  await auctionDoc.ref.update({
    outcome: 'won',
    winnerId: auction.currentBidder,
  });
}
```

**Testing Requirements:**
- [ ] Unit tests for Auction/Bid models
- [ ] Integration tests for bid validation
- [ ] Concurrent bidding stress tests (100+ simultaneous bids)
- [ ] Anti-sniping mechanism tests
- [ ] Auto-bid proxy tests
- [ ] WebSocket connection reliability tests
- [ ] Auction end timing accuracy tests

---

### 3. Payment Integration (3-4 weeks)
**Priority:** P0 - Required for revenue
**Business Impact:** Enable all monetization features
**Dependencies:** None (parallel with other features)

#### 3.1 CMI Payment Gateway Integration (1-2 weeks)
**Deliverables:**
- CMI SDK integration for Moroccan market
- Credit/debit card payment flow
- 3D Secure authentication
- Payment webhook handling
- Refund processing
- Payment receipt generation
- Merchant account configuration
- PCI DSS compliance audit

**Implementation:**
```dart
// lib/services/payment/cmi_payment_service.dart
class CMIPaymentService {
  final String merchantId;
  final String apiKey;
  final String storeKey;

  Future<PaymentResult> processPayment({
    required double amount,
    required String currency, // MAD
    required String orderId,
    required PaymentMethod method,
  }) async {
    // 1. Create payment session
    final sessionId = await _createPaymentSession(amount, currency, orderId);

    // 2. Open CMI payment page (web view or redirect)
    final result = await _openCMIPaymentPage(sessionId);

    // 3. Handle callback
    if (result.status == '3D_AUTH_REQUIRED') {
      // Redirect to 3D Secure
      final authResult = await _handle3DSecure(result.authUrl);
      return _confirmPayment(sessionId, authResult);
    }

    return result;
  }

  Future<RefundResult> processRefund({
    required String transactionId,
    required double amount,
  }) async {
    // CMI refund API call
  }
}
```

**CMI Configuration:**
```yaml
# config/cmi_config.yaml
production:
  merchant_id: "YOUR_MERCHANT_ID"
  api_endpoint: "https://payment.cmi.co.ma/fim/api"
  callback_url: "https://yajid.ma/payment/callback"

sandbox:
  merchant_id: "TEST_MERCHANT_ID"
  api_endpoint: "https://testpayment.cmi.co.ma/fim/api"
  callback_url: "https://staging.yajid.ma/payment/callback"
```

#### 3.2 Stripe Integration (1 week)
**Deliverables:**
- Stripe Flutter SDK integration
- Credit card tokenization
- Apple Pay / Google Pay support
- Subscription payments (for future premium features)
- Stripe Connect for seller payouts
- Webhook handling for payment events
- Dispute handling

**Implementation:**
```dart
// lib/services/payment/stripe_payment_service.dart
class StripePaymentService {
  final Stripe _stripe = Stripe.instance;

  Future<void> initialize() async {
    _stripe.publishableKey = stripePublishableKey;
    await _stripe.applySettings();
  }

  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required String customerId,
  }) async {
    // 1. Create payment intent on backend
    final paymentIntent = await _createPaymentIntent(amount, currency);

    // 2. Confirm payment with card
    final result = await _stripe.confirmPayment(
      paymentIntentClientSecret: paymentIntent.clientSecret,
      data: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      ),
    );

    return PaymentResult.fromStripe(result);
  }

  Future<PaymentResult> payWithApplePay({
    required double amount,
    required String currency,
  }) async {
    // Apple Pay integration
    if (!await _stripe.isApplePaySupported()) {
      throw PaymentException('Apple Pay not supported');
    }

    await _stripe.presentApplePay(
      params: ApplePayPresentParams(
        cartItems: [
          ApplePayCartSummaryItem(label: 'Order', amount: amount.toString()),
        ],
        country: 'MA',
        currency: currency,
      ),
    );

    return await _stripe.confirmApplePayPayment(paymentIntent.clientSecret);
  }
}
```

#### 3.3 Payment Security & Compliance (1 week)
**Deliverables:**
- PCI DSS Level 1 compliance audit
- Tokenization (never store raw card data)
- Encrypted communication (TLS 1.3)
- Fraud detection integration
- Rate limiting on payment endpoints
- Payment dispute handling workflow
- Refund policy implementation
- Payment audit logging

**Security Checklist:**
- [ ] No card data stored in app or Firestore
- [ ] All payment data transmitted over HTTPS
- [ ] Payment forms use PCI-compliant tokenization
- [ ] Failed payment attempts rate-limited
- [ ] Suspicious transaction flagging (multiple failed attempts)
- [ ] 3D Secure enforced for high-value transactions
- [ ] Webhook signature verification
- [ ] Audit logs for all payment operations

**Cloud Function for Payment Processing:**
```typescript
// functions/src/payments/createPaymentIntent.ts
export const createPaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { amount, currency, orderId } = data;

  // Validate amount
  if (amount < 10 || amount > 100000) { // 10 MAD to 100,000 MAD
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount');
  }

  // Create Stripe payment intent
  const stripe = new Stripe(functions.config().stripe.secret_key);

  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(amount * 100), // Stripe uses cents
    currency: currency.toLowerCase(),
    customer: context.auth.uid,
    metadata: {
      orderId,
      userId: context.auth.uid,
    },
  });

  // Log payment attempt
  await admin.firestore().collection('payment_logs').add({
    userId: context.auth.uid,
    amount,
    currency,
    orderId,
    paymentIntentId: paymentIntent.id,
    status: 'initiated',
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    clientSecret: paymentIntent.client_secret,
    paymentIntentId: paymentIntent.id,
  };
});
```

**Testing Requirements:**
- [ ] Unit tests for payment models
- [ ] Integration tests with CMI sandbox
- [ ] Integration tests with Stripe test mode
- [ ] Refund flow tests
- [ ] 3D Secure flow tests
- [ ] Webhook handling tests
- [ ] Failure scenario tests (declined cards, network errors)
- [ ] Security penetration testing

---

## Phase 2 Timeline

### Week 1-3: QR Ticketing - Event Management
- Week 1: Event model, service, and BLoC
- Week 2: Event creation UI and validation
- Week 3: Event browsing and detail screens

### Week 4-5: QR Ticketing - Ticket Generation
- Week 4: QR generation and encryption
- Week 5: Ticket delivery (email, SMS, in-app)

### Week 6-8: QR Ticketing - Scanner App
- Week 6: Scanner app setup and authentication
- Week 7: QR scanning and validation
- Week 8: Offline mode and analytics

### Week 9-10: Auction System - Core Features
- Week 9: Auction models, service, and BLoC
- Week 10: Bidding engine and WebSocket integration

### Week 11-12: Auction System - UI & Polish
- Week 11: Auction UI screens
- Week 12: Auction end handling and notifications

### Week 13-15: Payment Integration (Parallel)
- Week 13: CMI integration
- Week 14: Stripe integration
- Week 15: Security audit and compliance

### Week 16: Testing, Bug Fixes, Deployment
- Integration testing
- Security audit
- Performance optimization
- Production deployment

---

## Success Metrics

### Business Metrics
- **Revenue:** 850K MAD in first year
- **Tickets Sold:** 100K tickets annually
- **Average Ticket Price:** 85 MAD
- **Auction Engagement:** 1,000+ weekly bids
- **Payment Success Rate:** >95%

### Technical Metrics
- **Test Coverage:** 60%+
- **API Response Time:** <500ms (95th percentile)
- **Payment Processing Time:** <3 seconds
- **QR Validation Time:** <1 second
- **Uptime:** 99.9%

### User Metrics
- **Monthly Active Users:** +40% increase
- **User Retention:** 60%+ (Month 1 to Month 3)
- **Average Session Duration:** 15+ minutes
- **Feature Adoption:** 30%+ users try auctions

---

## Risk Management

### Technical Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Payment gateway integration delays | HIGH | Start early, use sandbox extensively |
| QR code forgery/duplication | CRITICAL | Strong encryption, HMAC signatures |
| Auction sniping abuse | MEDIUM | Anti-sniping time extension |
| Concurrent bid race conditions | HIGH | Use Firestore transactions |
| Scanner app offline reliability | MEDIUM | Comprehensive offline mode with sync queue |

### Business Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Low ticket sales adoption | HIGH | Marketing campaign, early-bird discounts |
| Payment fraud | CRITICAL | 3D Secure, fraud detection, dispute handling |
| Auction manipulation | MEDIUM | Bid validation, user verification |
| Merchant account approval delays | HIGH | Apply early, have backup options |

---

## Dependencies

### External Dependencies
- CMI merchant account approval (3-4 weeks lead time)
- Stripe account verification (1-2 weeks)
- Email service provider (SendGrid, Mailgun)
- SMS service provider (Twilio)
- Apple Wallet certificates

### Internal Dependencies
- Cloud Functions implementation complete
- Payment models and services from Phase 1
- Event model integration
- Gamification points system operational

---

## Resource Requirements

### Development Team
- 2 Backend Developers (Cloud Functions, payment integration)
- 2 Frontend Developers (Flutter UI)
- 1 QA Engineer (testing, security audit)
- 1 DevOps Engineer (deployment, monitoring)
- 1 Product Manager (coordination, stakeholder management)

### Infrastructure
- Firebase Hosting for scanner app
- Stripe/CMI merchant accounts
- SendGrid/Mailgun for email delivery
- Twilio for SMS delivery
- Increased Firestore read/write quota

---

## Deployment Plan

### Staging Deployment (Week 14)
- Deploy to staging environment
- Internal testing with real merchant sandbox accounts
- QA team comprehensive testing
- Security audit

### Beta Release (Week 15)
- Limited release to 100 beta users
- Monitor payment flows
- Gather feedback
- Fix critical bugs

### Production Release (Week 16)
- Full production deployment
- Monitoring dashboards active
- Support team trained
- Marketing campaign launch

---

**Document Control:**
- **Next Review:** November 1, 2025
- **Owner:** Product Team
- **Stakeholders:** Engineering, Business, Marketing
- **Related Docs:** PHASE_1_ROADMAP.md, PHASE_3_ROADMAP.md, BRD-002
