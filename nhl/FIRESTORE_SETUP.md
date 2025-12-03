# Firestore Setup Guide

This guide will walk you through setting up Firestore for the NHL Scores app.

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or select an existing project
3. Follow the setup wizard:
   - Enter project name (e.g., "nhl-scores")
   - Enable/disable Google Analytics (optional)
   - Click **"Create project"**

## Step 2: Enable Firestore Database

1. In your Firebase project, click **"Firestore Database"** in the left sidebar
2. Click **"Create database"**
3. Choose **"Start in production mode"** (we'll add security rules next)
4. Select a location for your database (choose closest to you)
5. Click **"Enable"**

## Step 3: Deploy Security Rules

1. In Firebase Console, go to **Firestore Database** → **Rules** tab
2. Copy the contents of `firestore.rules` from this project
3. Paste into the rules editor
4. Click **"Publish"**

Alternatively, use Firebase CLI:

```bash
# Install Firebase CLI if you haven't
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not already done)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

## Step 4: Create Service Account (For Backend)

The backend needs a service account to write to Firestore.

1. In Firebase Console, click the **gear icon** ⚙️ → **Project settings**
2. Go to **"Service accounts"** tab
3. Click **"Generate new private key"**
4. Save the JSON file securely (e.g., `service-account-key.json`)
5. **IMPORTANT**: Never commit this file to git!

## Step 5: Configure Backend

1. Place the service account key file in the `backend/` directory (or anywhere secure)
2. Create `backend/.env` file:

```env
FIRESTORE_PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
NHL_API_BASE_URL=https://statsapi.web.nhl.com/api/v1
```

Replace `your-project-id` with your actual Firebase project ID (found in Project Settings).

## Step 6: Configure Flutter App

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase for your Flutter app:

```bash
cd app
flutterfire configure
```

3. Select your Firebase project and platforms (iOS, Android, Web)

This automatically generates:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- Updates `lib/firebase_options.dart`

### Option B: Manual Configuration

1. In Firebase Console, go to **Project Settings** → **Your apps**
2. Click **"Add app"** → Select **Android**

   - Register app with package name: `com.nhl.scores.nhl_scores_app`
   - Download `google-services.json`
   - Place it in `app/android/app/`

3. Click **"Add app"** → Select **iOS**
   - Register app with bundle ID: `com.nhl.scores.nhlScoresApp`
   - Download `GoogleService-Info.plist`
   - Place it in `app/ios/Runner/`

## Step 7: Create Firestore Indexes (If Needed)

Some queries may require composite indexes. If you see errors like:

```
The query requires an index. You can create it here: [URL]
```

1. Click the URL in the error message, or
2. Go to Firestore → **Indexes** tab → **Create Index**

Common indexes you might need:

- Collection: `games`
  - Fields: `status` (Ascending), `startTime` (Ascending)

## Step 8: Test the Setup

### Test Backend:

```bash
cd backend
npm run ingest
```

You should see logs indicating games are being fetched and stored.

### Test Flutter App:

```bash
cd app
flutter run
```

The app should connect to Firestore and display games (if any exist).

## Step 9: Verify Data

1. Go to Firebase Console → **Firestore Database** → **Data** tab
2. You should see:
   - `games` collection with game documents
   - `teamStats` collection (created after games are processed)

## Troubleshooting

### Backend Issues:

**Error: "Could not load the default credentials"**

- Make sure `GOOGLE_APPLICATION_CREDENTIALS` points to the correct service account file
- Verify the service account has Firestore permissions

**Error: "Permission denied"**

- Check that security rules are deployed
- Verify service account has proper permissions

### Flutter App Issues:

**Error: "Firebase not initialized"**

- Make sure `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Run `flutter clean` and `flutter pub get`

**Error: "MissingPluginException"**

- Run `flutter pub get`
- For iOS: `cd ios && pod install`
- Restart the app

**No data showing:**

- Make sure backend has run and populated data
- Check Firestore Console to verify data exists
- Check app logs for Firestore errors

## Security Best Practices

1. **Never commit service account keys to git**

   - Add to `.gitignore`:
     ```
     service-account-key.json
     *.json
     .env
     ```

2. **Use environment variables in production**

   - Use Google Cloud Secret Manager
   - Or set environment variables in your deployment platform

3. **Review security rules regularly**
   - Ensure read-only access for clients
   - Only backend should have write access

## Next Steps

Once Firestore is set up:

1. Run the backend ingestion: `cd backend && npm run ingest`
2. Run the Flutter app: `cd app && flutter run`
3. Verify real-time updates work by running ingestion again while app is open
