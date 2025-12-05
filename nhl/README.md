# NHL Scores App

Hey! This is my NHL scores app - a full-stack project that I built to pull live game data from the NHL API and display it in a Flutter mobile app. Everything updates in real-time, so you will see scores change as games happen.

**📦 Received this as a ZIP file?** No problem! Just extract it and follow the setup instructions below.

**📧 I have sent you the Firestore project ID and service account key file via email.** Check the "Setting Up the Backend" section below to see exactly where to put these files.

## What I Built

I built this app with two main parts:

1. **Backend (Node.js/TypeScript)**: I created a service that fetches game data from the NHL API and stores it in Firestore. You run it whenever you want to update the data.

2. **Flutter App**: I built a mobile app that reads from Firestore and shows games, scores, and team stats. It updates automatically when new data comes in.

## Project Structure

```
nhl/
├── backend/          # The data ingestion service
│   ├── src/
│   │   ├── services/ # NHL API and Firestore services
│   │   ├── types/    # TypeScript type definitions
│   │   ├── utils/    # Helper functions
│   │   └── index.ts  # Main entry point
│   └── package.json
├── app/              # The Flutter mobile app
│   ├── lib/
│   │   ├── models/   # Data models
│   │   ├── services/ # Firestore service
│   │   ├── screens/  # UI screens
│   │   ├── widgets/  # Reusable widgets
│   │   └── main.dart # App entry point
│   └── pubspec.yaml
└── firestore.rules   # Security rules for Firestore
```

## Getting Started

### Prerequisites

Before starting, make sure you have:

- **Node.js** (v18 or higher) for the backend - [Download here](https://nodejs.org/)
- **Flutter SDK** (latest stable) for the mobile app - [Download here](https://docs.flutter.dev/get-started/install)
- A **Google Cloud Project** with Firestore enabled
- A **Firebase project** (can be the same as Google Cloud)
- Your **Firestore Project ID** (you will need this - find it in [Google Cloud Console](https://console.cloud.google.com/))

### If You Received This as a ZIP File

1. Extract the ZIP file to a folder (e.g., `nhl` or `nhl-scores`)
2. Open a terminal/command prompt
3. Navigate to the extracted folder
4. Follow the setup instructions below

### Setting Up the Backend

1. **Go to the backend folder:**

```bash
cd backend
```

2. **Install dependencies:**

```bash
npm install
```

3. **Set up environment variables:**

   - Copy the example file:
     - On Mac/Linux: `cp .env.example .env`
     - On Windows: `copy .env.example .env`
   - Open `.env` in a text editor
   - Replace `your-firestore-project-id` with your actual Firestore project ID:
     ```
     FIRESTORE_PROJECT_ID=your-actual-project-id-here
     GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
     NHL_API_BASE_URL=https://api-web.nhle.com/v1
     ```

   **Important**:

   - Replace `your-actual-project-id-here` with your real Firestore project ID
   - You can find your project ID in the [Google Cloud Console](https://console.cloud.google.com/) under your project settings
   - The project ID is usually something like `my-project-12345` or `nhl-scores-abc123`

4. **Add the service account key I sent you:**

   I have sent you the Firestore project ID and service account key file via email. Here is where to put them:

   - **Service Account File:**

     - Download the JSON file from the email I sent
     - Place it in the `backend/` folder (same folder as `.env`)
     - Make sure it is named exactly: `service-account-key.json`
     - The file path should be: `backend/service-account-key.json`

   - **Project ID:**
     - Open the `backend/.env` file in a text editor
     - Find the line: `FIRESTORE_PROJECT_ID=your-actual-project-id-here`
     - Replace `your-actual-project-id-here` with the project ID I sent you in the email
     - Save the file
     - Example: If I sent you project ID `nhl-scores-abc123`, your `.env` should have:
       ```
       FIRESTORE_PROJECT_ID=nhl-scores-abc123
       ```

   **If for some reason you do not have the files I sent, you can create a service account key yourself:**

   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Select your Firestore project
   - Go to: **IAM & Admin** → **Service Accounts**
   - Click **Create Service Account** (or use an existing one)
   - Give it a name (e.g., "nhl-backend")
   - Grant it **Firestore Admin** or **Cloud Datastore User** role
   - Click **Done**
   - Click on the service account you just created
   - Go to **Keys** tab → **Add Key** → **Create new key** → Choose **JSON**
   - Download the JSON file
   - Rename it to `service-account-key.json`
   - Place it in the `backend/` folder

5. **Test it:**

```bash
npm run ingest
```

This will fetch today's games (and yesterday's final games) from the NHL API and store them in Firestore. You should see logs showing games being processed.

### Setting Up the Flutter App

1. **Go to the app folder:**

```bash
cd app
```

2. **Install dependencies:**

```bash
flutter pub get
```

3. **Configure Firebase:**

   **Option A: Using FlutterFire CLI (Recommended)**

   ```bash
   # Install FlutterFire CLI (one time only)
   dart pub global activate flutterfire_cli

   # Configure Firebase
   flutterfire configure
   ```

   When prompted:

   - Select your Firebase project (same as your Firestore project)
   - Select platforms (Android, iOS, Web, etc.)
   - This will automatically create `firebase_options.dart`

   **Option B: Manual Configuration**

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings
   - For Android: Download `google-services.json` → Place in `app/android/app/`
   - For iOS: Download `GoogleService-Info.plist` → Place in `app/ios/Runner/`

4. **Deploy Firestore security rules:**

```bash
   # From the project root
firebase deploy --only firestore:rules
```

Or manually copy the rules from `firestore.rules` to the Firebase Console.

5. **Run the app:**

```bash
flutter run
```

## How to Use

### Running the Backend

The backend uses a script that you run whenever you want to update the data. By default, it fetches:

- Yesterday's games (to get final scores)
- Today's games (scheduled, live, and final)

**Basic usage:**

```bash
cd backend
npm run ingest
```

**Fetch games for multiple days:**

```bash
npm run ingest -- --days 7
```

**Fetch a specific date:**

```bash
npm run ingest -- --date 2024-12-15
```

**Fetch final games from a specific date:**

```bash
npm run ingest -- --final-date 2024-12-10
```

**Fetch live games from a specific date:**

```bash
npm run ingest -- --live-date 2024-12-15
```

The service is idempotent, which means you can run it multiple times without creating duplicate games. It will update existing games if scores change.

### Utility Commands

**Delete all games:**

```bash
npm run delete-all-games
```

This command clears all games from Firestore. It is useful when you want to start fresh.

**Add a sample game (for testing):**

```bash
npm run add-sample-game
```

This command adds one sample game to Firestore. It is useful for testing or when there are no games on a particular day (like during the off-season). This is just for demonstration purposes - all real data comes from the NHL API via `npm run ingest`.

**Note for reviewers:** If you are testing the app and there are no games available on a particular day, you can use `npm run add-sample-game` to add a sample game so you can test the UI. Then run `npm run delete-all-games` to clear it and use `npm run ingest` to get real games.

### Quick Commands Reference

```bash
# Backend
cd backend
npm install                    # Install dependencies (first time only)
npm run ingest                # Fetch games from NHL API
npm run delete-all-games      # Clear all games from Firestore
npm run add-sample-game       # Add one sample game for testing

# Flutter
cd app
flutter pub get               # Install dependencies (first time only)
flutterfire configure         # Configure Firebase (first time only)
flutter run                   # Run the app
```

### Using the Flutter App

Once you have run the backend and have games in Firestore:

1. **Home Screen**: Shows all of today's games. Each game card shows:

   - Home team name and score
   - Away team name and score
   - Game status (scheduled, live, or final)
   - Games are sorted by start time

2. **Filter Games**: Tap the filter icon in the app bar to filter by:

   - All games
   - Live games only
   - Scheduled games only
   - Final games only

3. **Game Details**: Tap any game to see:

   - Full game information (scores, status, start time, venue, season, game type, game ID)
   - Missing data fields show "NA" (for example, if venue is not available)
   - Clickable team names (tap to see team info)

4. **Team Screen**: Tap a team name to see:
   - Team name and actual team logo (from NHL API)
   - Season record (wins, losses, win percentage, total games)
   - Last 5 games for that team

Everything updates in real-time! If I run the backend again and scores change, the app will automatically show the new scores without needing to refresh.

## How It Works

### Data Flow

The app uses this data flow:

1. **Backend fetches from NHL API** → Transforms the data → Stores in Firestore
2. **Flutter app reads from Firestore** → Displays in the UI → Updates automatically

The Flutter app never calls the NHL API directly - it only reads from Firestore. This keeps things simple and ensures all data goes through the backend.

### Data Storage

**Games Collection** (`games/{gameId}`):

- Each game is stored with its `gameId` as the document ID
- Contains: gameId, startTime, homeTeam (id, name, score, logoUrl), awayTeam (id, name, score, logoUrl), status, season, gameType, venue, metadata, timestamps
- Team logo URLs are extracted from the NHL API and stored for display

**Team Stats Collection** (`teamStats/{teamId}`):

- Automatically calculated when games finish
- Contains: teamId, teamName, wins, losses, overtime losses, win percentage, logoUrl
- Logo URLs are stored when team stats are updated from final games

### Key Features

**Idempotency**: The backend uses `gameId` as the document ID, so running it multiple times will not create duplicates. It will update existing games if scores change.

**Real-time Updates**: The Flutter app uses Firestore streams, so when data changes in Firestore, the UI updates automatically.

**Error Handling**:

- Network errors are logged but do not crash the service
- Missing data fields are handled gracefully:
  - Missing scores show "-" in game cards
  - Missing venue, season, or game type show "NA" in game details
  - Missing team logos fall back to placeholder icons
- Invalid games are skipped, but processing continues

**Schema Flexibility**: Any new fields from the NHL API are stored in a `metadata` object automatically, so nothing breaks if the API changes.

## Troubleshooting

### Backend Issues

**"Cannot find module" error:**

- Make sure you ran `npm install` in the `backend/` folder

**"ENOTFOUND" or DNS errors:**

- Check your internet connection
- Verify the NHL API URL in `.env` is correct: `https://api-web.nhle.com/v1`

**"Permission denied" for Firestore:**

- Make sure your service account key has Firestore write permissions
- Check that the `GOOGLE_APPLICATION_CREDENTIALS` path in `.env` is correct

**No games showing up:**

- Make sure you ran `npm run ingest` successfully
- Check the Firestore console to see if games were actually created
- Verify the date you are querying has games (NHL does not have games every day)

### Flutter App Issues

**"Firebase not configured" error:**

- Run `flutterfire configure` or manually add Firebase config files
- Make sure `firebase_options.dart` exists

**No games showing in the app:**

- Verify the backend has ingested games for today
- Check Firestore console to see if games exist
- Make sure Firestore security rules allow read access
- Check that you are using the same Firebase project for both backend and app

**Build errors:**

- Try `flutter clean` and then `flutter pub get`
- Make sure you have the correct Flutter SDK version
- Check that all dependencies are compatible

## Production Deployment

For production, I would want to:

1. **Automate the backend**: Set up a Cloud Scheduler or cron job to run `npm run ingest` regularly (e.g., every hour during game days)

2. **Deploy the backend**: Use Cloud Functions, Cloud Run, or a similar service instead of running locally

3. **Use environment variables**: Store sensitive data (like service account keys) in Google Cloud Secret Manager

4. **Add monitoring**: Set up logging and alerting to know if something breaks

5. **Add rate limiting**: The NHL API might have rate limits, so add rate limiting for high-frequency runs

### How to Trigger in Production

The backend script can be triggered in several ways:

**Option 1: Cloud Scheduler (Recommended)**

- Create a Cloud Scheduler job that runs on a schedule (e.g., every hour during game days)
- Configure it to trigger a Cloud Function or Cloud Run service
- The service would run `npm run ingest` when triggered

**Option 2: Cloud Functions + Pub/Sub**

- Deploy the ingestion logic as a Cloud Function
- Set up a Pub/Sub topic that triggers the function
- Use Cloud Scheduler to publish messages to the topic on a schedule

**Option 3: Cron Job (Traditional)**

- Set up a cron job on a server: `0 * * * * cd /path/to/backend && npm run ingest`
- Runs every hour automatically
- Requires a server that's always running

**Example Cloud Scheduler Configuration:**

```
Schedule: 0 * * * * (every hour)
Target: Cloud Function or Cloud Run
Command: npm run ingest
```

### 30-Day Backfill

To backfill the last 30 days of games, you can run:

```bash
npm run ingest -- --days 30
```

This will fetch games for the last 30 days and store them in Firestore. The service is idempotent, so you can run it multiple times safely - it will update existing games and add new ones without creating duplicates.

**How it works:**

- The script calculates dates for the last N days
- Fetches games for each date from the NHL API
- Stores them in Firestore with `gameId` as the document ID
- Existing games are updated, new games are added

**For production backfill:**

- Run during off-peak hours to avoid API rate limits
- Consider adding delays between date fetches if needed
- Monitor Firestore write quotas

## What I Would Improve Next

If I had more time, here is what I would work on:

**Backend:**

- Add retry logic with exponential backoff for API failures
- Implement rate limiting for NHL API calls
- Add health check endpoints for monitoring
- Cache team information to reduce API calls
- Only fetch games that have actually changed (incremental updates)

**Flutter App:**

- Full offline support with local database (currently just basic Firestore caching)
- Push notifications for score updates
- Let users favorite teams
- Add search functionality
- Better animations for score updates
- Pagination for large game lists

**General:**

- Add unit and integration tests
- Set up CI/CD for automated testing
- Add error tracking (like Sentry)
- Add usage analytics

## Assumptions and Limitations

**What I assumed:**

- You already have a Firestore project set up
- You have a service account with write permissions
- The NHL API is publicly accessible (no auth needed)
- Firebase is configured for the Flutter app

**Limitations:**

- Automatic retries for network errors are not implemented (they are logged but not retried)
- The app fetches the last 30 days for team games queries and filters client-side (Firestore does not support OR queries)
- Team stats are only calculated for "final" games (so teams without finished games will not have stats yet)
- Team logos are loaded from NHL API URLs - if a logo fails to load, a placeholder icon is shown

**Compromises made:**

- Due to Firestore query limitations, more games than needed are fetched for team screens and filtered client-side. It is less efficient but works.
- Error handling continues processing even if some games fail - this maximizes data ingestion but means you might miss some games if there are issues.
- The app queries games for "today" but extends to include the next day (UTC) to catch games starting at midnight UTC. This is a workaround for timezone differences.

## Requirements Met

This project meets all the requirements from the specification:

**Backend**: Fetches from NHL API, stores in Firestore, idempotent, handles errors, and uses a flexible schema

**Flutter App**: Shows today's games, game details, real-time updates, loading/error states, and graceful degradation

**Team Screen**: Allows navigation from game details, shows team name, actual team logo (from NHL API), season record, last 5 games, all from Firestore

All mandatory requirements are complete, and all assumptions or compromises are documented clearly.

## AI Usage and Research

AI assistance was used in the following areas during development:

**Research and Documentation:**

- Researching the NHL API endpoint structure and response format when the original endpoint was deprecated
- Looking up Firestore best practices for querying and data modeling
- Researching Flutter real-time data patterns using StreamBuilder
- Finding solutions for handling timezone differences in date queries

**Code Assistance:**

- Generating boilerplate code for TypeScript interfaces and Dart models based on API responses
- Creating initial project structure and file templates
- Getting help with error message formatting and logging patterns
- Getting assistance with Flutter widget structure and layout code

**Problem Solving:**

- Debugging DNS resolution issues when the NHL API endpoint changed
- Troubleshooting Firestore query limitations and finding workarounds
- Resolving timezone mismatches between backend and Flutter app
- Fixing data parsing issues when API response structure changed

**All core logic, architecture decisions, and implementation details were done independently:**

- Designing the idempotent data ingestion approach
- Implementing the schema flexibility with metadata storage
- Creating the real-time update system using Firestore streams
- Designing the UI/UX and navigation flow
- Making all performance optimizations and error handling strategies
- Writing all business logic and data transformation code

## Questions?

If you run into issues:

1. Check the troubleshooting section above
2. Look at the logs when running `npm run ingest`
3. Check the Firestore console to see if data is being stored
4. Make sure your Firebase/Firestore configuration is correct

The code is well-commented, so if you want to understand how something works, the source files should be pretty clear!

---

**Note**: This is a project I built as part of an intern challenge. It demonstrates full-stack development, real-time data synchronization, and best practices for both backend and mobile development.
