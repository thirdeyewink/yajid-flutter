# Cloud Functions Deployment Guide

This guide walks you through deploying the Yajid gamification Cloud Functions to Firebase.

## Overview

The Yajid platform uses Firebase Cloud Functions for secure server-side operations, particularly for the gamification system. Cloud Functions ensure that:
- Points cannot be manipulated by clients
- Daily limits are enforced server-side
- Badges and leaderboards update automatically
- All operations are atomic and secure

## Prerequisites

Before deploying, ensure you have:

1. **Firebase Blaze Plan** - ⚠️ **REQUIRED** for Cloud Functions
   - Cloud Functions require the Blaze (pay-as-you-go) plan
   - Includes free tier: 2M invocations/month, then $0.40 per million
   - Upgrade at: https://console.firebase.google.com/project/yajid-connect/usage/details
   - **You must upgrade before deployment will work**

2. **Node.js 18 or later** - Required for Cloud Functions
   ```bash
   node --version  # Should show v18.x or later
   ```

3. **Firebase CLI** - Install globally
   ```bash
   npm install -g firebase-tools
   ```

4. **Firebase Project** - The project should already be configured (`yajid-connect`)

5. **Firebase Authentication** - Login to Firebase
   ```bash
   firebase login
   ```

## Project Structure

```
functions/
├── src/
│   ├── index.ts                          # Main entry point
│   └── gamification/
│       ├── awardPoints.ts                # Points awarding function
│       ├── updateLeaderboard.ts          # Leaderboard sync function
│       └── checkBadgeUnlocks.ts          # Badge unlock checker
├── package.json                          # Node dependencies
├── tsconfig.json                         # TypeScript config
└── .eslintrc.js                          # ESLint config
```

## Step 1: Install Dependencies

Navigate to the functions directory and install Node.js dependencies:

```bash
cd functions
npm install
```

This will install:
- `firebase-admin` - Firebase Admin SDK for backend operations
- `firebase-functions` - Cloud Functions framework
- TypeScript and ESLint tools

## Step 2: Configure Firebase Project

Verify your Firebase project is correctly configured:

```bash
firebase use --add
```

Select `yajid-connect` from the list and set an alias (e.g., `production`).

To check the current project:
```bash
firebase projects:list
firebase use
```

## Step 3: Local Testing with Firebase Emulator

Before deploying to production, test locally with the Firebase Emulator Suite.

### Start the Emulator

```bash
# From project root
firebase emulators:start
```

This starts:
- **Auth Emulator** on port 9099
- **Firestore Emulator** on port 8080
- **Functions Emulator** on port 5001
- **Emulator UI** on port 4000 (http://localhost:4000)

### Test Cloud Functions Locally

1. Open the Emulator UI at `http://localhost:4000`
2. Navigate to Functions tab to see your deployed functions
3. Test calling functions from your Flutter app (it should auto-detect emulators)

### Flutter App Configuration for Emulator

In your Flutter app, add this code to connect to local emulators during development:

```dart
// lib/main.dart - Add after Firebase.initializeApp()

if (kDebugMode) {
  // Use Firebase Emulators in debug mode
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
}
```

## Step 4: Deploy to Firebase Production

Once testing is complete, deploy to production:

### Deploy All Functions

```bash
# From project root
firebase deploy --only functions
```

### Deploy Specific Functions

To deploy only specific functions (faster):

```bash
# Deploy only gamification functions
firebase deploy --only functions:awardPoints,functions:updateLeaderboard,functions:checkBadgeUnlocks

# Deploy only the leaderboard getter functions
firebase deploy --only functions:getLeaderboard,functions:getUserRank

# Deploy only badge functions
firebase deploy --only functions:checkBadgeUnlocks,functions:getBadgeDefinitions
```

### Monitor Deployment

The deployment process will:
1. Build TypeScript code to JavaScript
2. Upload code to Firebase
3. Provision Cloud Functions
4. Return public URLs for HTTP functions

Expected output:
```
✔  functions[us-central1-awardPoints] Successful create operation.
✔  functions[us-central1-updateLeaderboard] Successful create operation.
✔  functions[us-central1-checkBadgeUnlocks] Successful create operation.
✔  functions[us-central1-onPointsUpdateCheckBadges] Successful create operation.
✔  functions[us-central1-getLeaderboard] Successful create operation.
✔  functions[us-central1-getUserRank] Successful create operation.
✔  functions[us-central1-getBadgeDefinitions] Successful create operation.

✔  Deploy complete!
```

## Step 5: Deploy Firestore Rules

The gamification system requires updated Firestore security rules that restrict write access to Cloud Functions only.

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules
```

**IMPORTANT:** Ensure you deploy the rules AFTER deploying Cloud Functions, otherwise the gamification system will be locked down without the Cloud Functions to manage it.

## Step 6: Verify Deployment

### Check Function Status

View deployed functions in Firebase Console:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select `yajid-connect` project
3. Navigate to **Functions** section
4. Verify all 7 functions are deployed and healthy

### Test Functions in Production

Test the functions from your Flutter app:

```dart
// Example: Award points
final callable = FirebaseFunctions.instance.httpsCallable('awardPoints');
final result = await callable.call({
  'points': 10,
  'category': 'dailyLogin',
  'description': 'Daily login bonus',
});
print(result.data); // Should show success: true
```

### Monitor Function Logs

View real-time logs:

```bash
# View all function logs
firebase functions:log

# Follow logs in real-time
firebase functions:log --only awardPoints

# Filter by time
firebase functions:log --since 1h
```

Or view logs in Firebase Console:
1. Go to **Functions** → Select function → **Logs** tab

## Step 7: Monitor Performance & Costs

### View Function Metrics

In Firebase Console → Functions:
- **Invocations** - Number of times each function was called
- **Execution time** - Average and max execution duration
- **Memory usage** - RAM consumption
- **Errors** - Function failures and crashes

### Estimate Costs

Cloud Functions pricing (as of 2024):
- **Free tier**: 2 million invocations/month
- **Paid tier**: $0.40 per million invocations (after free tier)
- **Compute time**: $0.0000025 per GB-second

Estimated costs for Yajid:
- **10,000 MAU**: ~3-5 million function calls/month = $0.40-1.20/month
- **50,000 MAU**: ~15-25 million calls/month = $5.20-9.20/month
- **100,000 MAU**: ~30-50 million calls/month = $11.20-19.20/month

## Troubleshooting

### Issue: "firebase command not found"

**Solution:** Install Firebase CLI globally
```bash
npm install -g firebase-tools
firebase --version
```

### Issue: "Permission denied" during deployment

**Solution:** Re-authenticate with Firebase
```bash
firebase logout
firebase login
firebase use yajid-connect
```

### Issue: "Node version not supported"

**Solution:** Update to Node.js 18 or later
```bash
node --version  # Check current version
# Install Node 18+ from nodejs.org
```

### Issue: Functions deploy but return errors

**Solution:** Check function logs for errors
```bash
firebase functions:log --only awardPoints
```

Common causes:
- Missing Firestore indexes (check Firebase Console → Firestore → Indexes)
- Firestore rules blocking Cloud Functions (ensure rules allow service accounts)
- Invalid function code (check TypeScript compilation errors)

### Issue: "Daily limit reached" errors

**Solution:** Adjust daily limits in Cloud Function or database
```typescript
// In functions/src/gamification/awardPoints.ts
const DEFAULT_DAILY_LIMIT = 500; // Increase this value
```

### Issue: Badge unlocks not working

**Solution:** Manually trigger badge check
```dart
final callable = FirebaseFunctions.instance.httpsCallable('checkBadgeUnlocks');
await callable.call({'userId': currentUserId});
```

### Issue: Leaderboard not updating

**Solution:** The `updateLeaderboard` function runs automatically on Firestore triggers. Check:
1. Function is deployed: `firebase functions:list`
2. No errors in logs: `firebase functions:log --only updateLeaderboard`
3. Firestore triggers are enabled (they should auto-enable)

## Best Practices

### 1. Use Emulator for Development

Always test with emulators before deploying to production:
```bash
firebase emulators:start
```

### 2. Version Control Your Functions

Tag releases in git before deploying:
```bash
git tag -a v1.0.0 -m "Initial Cloud Functions deployment"
git push origin v1.0.0
firebase deploy --only functions
```

### 3. Monitor Error Rates

Set up Cloud Function alerts in Firebase Console:
1. Go to **Functions** → Select function → **Metrics**
2. Click **Create Alert**
3. Set threshold (e.g., error rate > 5%)

### 4. Optimize Function Performance

- **Cold starts**: Keep functions warm by calling them periodically
- **Timeouts**: Set appropriate timeout values (default: 60s, max: 540s)
- **Memory**: Adjust memory allocation based on usage (default: 256MB)

### 5. Implement Idempotency

All functions use `referenceId` for idempotency - ensure your client always provides unique IDs:
```dart
await awardPoints(
  userId: userId,
  points: 10,
  category: PointsCategory.bookmark,
  referenceId: 'bookmark_$recommendationId', // Unique per action
);
```

## Security Considerations

### Cloud Functions Service Account

Cloud Functions run with elevated permissions via Firebase service account. They can:
- ✅ Bypass Firestore security rules
- ✅ Access any document in any collection
- ✅ Perform admin operations

**Ensure your functions validate all inputs** to prevent abuse.

### Client-Side Validation

Even though Cloud Functions validate inputs, add client-side validation for better UX:
```dart
// Before calling awardPoints
final (minPoints, maxPoints) = category.pointsRange;
if (points < minPoints || points > maxPoints) {
  showError('Invalid points amount');
  return;
}
```

### Rate Limiting

Cloud Functions include built-in rate limiting:
- Daily points limit per user (default: 500 points/day)
- Idempotency checks prevent duplicate awards
- Firestore transaction isolation prevents race conditions

## Next Steps

After successful deployment:

1. **Update TODO.md** - Mark Cloud Functions tasks as complete
2. **Update Documentation** - Remove "Phase 2" labels from gamification features
3. **Test End-to-End** - Verify entire gamification flow works in production
4. **Monitor Metrics** - Check Firebase Console for function performance
5. **Plan Phase 2** - Move on to QR ticketing and auction features

## Reference Links

- [Firebase Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Cloud Functions Pricing](https://firebase.google.com/pricing)
- [TypeScript for Cloud Functions](https://firebase.google.com/docs/functions/typescript)

---

**Deployment Checklist:**

- [ ] Node.js 18+ installed
- [ ] Firebase CLI installed and authenticated
- [ ] Functions dependencies installed (`npm install`)
- [ ] Tested locally with emulators
- [ ] Deployed functions (`firebase deploy --only functions`)
- [ ] Deployed Firestore rules (`firebase deploy --only firestore:rules`)
- [ ] Verified functions in Firebase Console
- [ ] Tested functions from Flutter app
- [ ] Monitoring function logs for errors
- [ ] Set up alerts for error rates
