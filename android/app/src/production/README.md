# Production Environment Configuration

## Google Services JSON

Place your `google-services.json` file for the **production** Firebase project in this directory.

### Steps to obtain the file:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the **yajid-connect** (production) project
3. Click the gear icon next to "Project Overview" → "Project settings"
4. Scroll down to "Your apps" section
5. Select your Android app or add a new one with package name: `com.example.myapp`
6. Download the `google-services.json` file
7. Place it in this directory (`android/app/src/production/`)

### Important Notes:

- This file contains API keys and should NOT be committed to version control
- The `.gitignore` file should exclude `google-services.json` from git
- Each team member needs to download this file from Firebase Console
- CI/CD pipelines should inject this file using secrets/environment variables

### Firebase Project Configuration:

- **Project ID**: `yajid-connect`
- **Package Name**: `com.example.myapp`
- **Environment**: Production
- **Features Enabled**: Crashlytics (enabled), Performance (enabled), Logging (disabled)
