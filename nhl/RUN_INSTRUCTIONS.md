# How to Run the NHL Scores App

## Prerequisites

- Node.js v18+ installed
- Flutter SDK installed
- Firebase project configured (see `FIRESTORE_SETUP.md`)
- Service account key for backend

## Step 1: Configure Backend

1. **Navigate to backend directory:**

   ```bash
   cd backend
   ```

2. **Create `.env` file** (if not already created):

   ```bash
   # Create .env file
   touch .env
   ```

3. **Add your Firebase configuration to `.env`:**

   ```
   FIRESTORE_PROJECT_ID=nhl-scores-93ccb
   GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
   NHL_API_BASE_URL=https://statsapi.web.nhl.com/api/v1
   ```

   **Note:** Make sure `service-account-key.json` is in the `backend/` directory.

4. **Install dependencies** (if not already done):
   ```bash
   npm install
   ```

## Step 2: Run Backend (Data Ingestion)

**In the `backend/` directory:**

```bash
# Fetch today's games
npm run ingest

# Or fetch last 3 days
npm run ingest -- --days 3

# Or fetch specific date
npm run ingest -- --date 2024-12-02
```

**Expected output:**

```
[INFO] Starting NHL data ingestion...
[INFO] Fetching today's games
[INFO] Processing X games for 2024-12-02
[INFO] Date 2024-12-02: X successful, 0 failed
[INFO] Ingestion completed!
```

**Verify data in Firestore:**

- Go to Firebase Console → Firestore Database → Data
- You should see `games` collection with game documents
- After processing final games, you'll see `teamStats` collection

## Step 3: Run Flutter App

**Open a new terminal window/tab:**

1. **Navigate to app directory:**

   ```bash
   cd app
   ```

2. **Install dependencies** (if not already done):

   ```bash
   flutter pub get
   ```

3. **Check available devices:**

   ```bash
   flutter devices
   ```

4. **Run the app:**

   ```bash
   # Run on available device (iOS Simulator, Android Emulator, or connected device)
   flutter run

   # Or specify a device
   flutter run -d <device-id>
   ```

**For iOS (macOS only):**

```bash
# Open iOS Simulator first, then:
flutter run -d ios
```

**For Android:**

```bash
# Make sure Android Emulator is running, then:
flutter run -d android
```

## Step 4: Verify Everything Works

1. **Backend is running:**

   - Check terminal for successful ingestion logs
   - Verify games appear in Firestore Console

2. **Flutter app is running:**
   - App should show "NHL Scores" title
   - Games list screen should display today's games (if any)
   - You can filter by status (All, Live, Scheduled, Final)
   - Tap a game to see details
   - Tap team name to see team stats

## Troubleshooting

### Backend Issues

**Error: "Could not load the default credentials"**

- Check that `GOOGLE_APPLICATION_CREDENTIALS` path is correct
- Verify `service-account-key.json` exists in `backend/` directory

**Error: "Permission denied"**

- Verify service account has Firestore write permissions
- Check that security rules are deployed

**No games fetched:**

- Check NHL API is accessible
- Verify date format (YYYY-MM-DD)
- Check network connection

### Flutter App Issues

**Error: "Firebase not initialized"**

- Verify `firebase_options.dart` exists
- Check that Firebase project is configured
- Run `flutterfire configure` again if needed

**No data showing:**

- Make sure backend has run and populated data
- Check Firestore Console to verify data exists
- Verify app is connected to correct Firebase project

**Build errors:**

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Quick Commands Reference

### Backend

```bash
cd backend
npm run ingest              # Fetch today's games
npm run ingest -- --days 3  # Fetch last 3 days
npm run build               # Build TypeScript
npm start                   # Run built version
```

### Flutter App

```bash
cd app
flutter pub get            # Install dependencies
flutter run                # Run app
flutter devices            # List available devices
flutter clean              # Clean build
```

## Typical Workflow

1. **Start with backend:**

   ```bash
   cd backend
   npm run ingest
   ```

2. **Then run Flutter app** (in separate terminal):

   ```bash
   cd app
   flutter run
   ```

3. **To update data:**

   - Run `npm run ingest` again in backend
   - App will automatically update via Firestore streams

4. **To see real-time updates:**
   - Keep app running
   - Run backend ingestion again
   - Scores will update in app automatically!
