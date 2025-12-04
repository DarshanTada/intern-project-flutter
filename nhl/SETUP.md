# Setup Guide for New Users

This guide will help you set up the project on a new computer.

## Prerequisites

### Backend
- Node.js v18 or higher
- npm (comes with Node.js)
- Google Cloud Project with Firestore enabled
- Service account key with Firestore write permissions

### Flutter App
- Flutter SDK (latest stable version)
- Android Studio / Xcode (for mobile development)
- Firebase project (same as backend or separate)

## Step-by-Step Setup

### 1. Clone or Extract the Project

If using GitHub:
```bash
git clone <repository-url>
cd nhl
```

If using a ZIP file:
```bash
unzip nhl-project.zip
cd nhl
```

### 2. Backend Setup

#### 2.1 Install Dependencies
```bash
cd backend
npm install
```

#### 2.2 Configure Environment Variables

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set your values:
   ```
   FIRESTORE_PROJECT_ID=your-firestore-project-id
   GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
   NHL_API_BASE_URL=https://api-web.nhle.com/v1
   ```

3. **Get a Service Account Key:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Select your project
   - Navigate to: IAM & Admin → Service Accounts
   - Create a new service account or use an existing one
   - Create a key (JSON format)
   - Download the key file
   - Place it in the `backend/` directory as `service-account-key.json`

#### 2.3 Test the Backend
```bash
npm run ingest
```

You should see logs indicating games are being fetched and stored.

### 3. Flutter App Setup

#### 3.1 Install Dependencies
```bash
cd app
flutter pub get
```

#### 3.2 Configure Firebase

**Option A: Using FlutterFire CLI (Recommended)**
```bash
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

Follow the prompts to:
- Select your Firebase project
- Select platforms (Android, iOS, etc.)
- This will automatically generate `firebase_options.dart`

**Option B: Manual Configuration**

1. **For Android:**
   - Go to Firebase Console → Project Settings
   - Download `google-services.json`
   - Place it in `app/android/app/google-services.json`

2. **For iOS:**
   - Go to Firebase Console → Project Settings
   - Download `GoogleService-Info.plist`
   - Place it in `app/ios/Runner/GoogleService-Info.plist`

3. **Update `firebase_options.dart`:**
   - Use FlutterFire CLI or manually configure based on your Firebase project

#### 3.3 Deploy Firestore Security Rules

```bash
# From the project root
firebase deploy --only firestore:rules
```

Or manually copy the rules from `firestore.rules` to Firebase Console.

#### 3.4 Run the App

```bash
# Make sure you're in the app directory
cd app

# Run on connected device/emulator
flutter run
```

### 4. Verify Everything Works

1. **Backend:**
   - Run `npm run ingest` in `backend/`
   - Check Firestore console to see games being created

2. **Flutter App:**
   - Launch the app
   - You should see today's games (if any)
   - Tap a game to see details
   - Tap a team name to see team screen

## Troubleshooting

### Backend Issues

**Error: "Cannot find module"**
- Run `npm install` in the `backend/` directory

**Error: "ENOTFOUND" or DNS issues**
- Check your internet connection
- Verify the NHL API URL is correct in `.env`

**Error: "Permission denied" (Firestore)**
- Verify your service account has Firestore write permissions
- Check that `GOOGLE_APPLICATION_CREDENTIALS` points to the correct file

### Flutter Issues

**Error: "Firebase not configured"**
- Run `flutterfire configure` or manually add Firebase config files
- Verify `firebase_options.dart` exists and is correct

**Error: "No games showing"**
- Verify backend has ingested games for today
- Check Firestore console to see if games exist
- Verify Firestore security rules allow read access

**Error: "Build failed"**
- Run `flutter clean` and `flutter pub get`
- Check that you have the correct Flutter SDK version
- Verify all dependencies are compatible

## Common Questions

**Q: Do I need to run the backend continuously?**
A: No, the backend is a script that runs on-demand. You can run it manually or set up a scheduler (cron, Cloud Scheduler, etc.).

**Q: Can I use a different Firebase project for the app?**
A: Yes, but make sure the Firestore database is the same or you'll need to ingest data into both projects.

**Q: Do I need to deploy to production?**
A: No, this is for local development. For production, you'd set up Cloud Functions, Cloud Run, or similar services.

## Next Steps

Once everything is set up:
1. Run the backend to ingest today's games
2. Launch the Flutter app
3. Explore the features:
   - View today's games
   - Filter by status
   - View game details
   - View team information

For more details, see the main [README.md](README.md).

