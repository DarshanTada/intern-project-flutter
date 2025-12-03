# NHL Scores - Full-Stack Mini App

A full-stack application for displaying NHL game scores with real-time updates, built with Node.js/TypeScript backend and Flutter mobile app.

## 🏗️ Project Structure

```
nhl/
├── backend/          # Node.js/TypeScript data ingestion service
│   ├── src/
│   │   ├── services/ # NHL API and Firestore services
│   │   ├── types/    # TypeScript type definitions
│   │   ├── utils/    # Utility functions
│   │   └── index.ts  # Main entry point
│   ├── package.json
│   └── README.md     # Backend-specific documentation
├── app/              # Flutter mobile application
│   ├── lib/
│   │   ├── models/   # Data models
│   │   ├── services/ # Firestore service
│   │   ├── screens/  # UI screens
│   │   ├── widgets/  # Reusable widgets
│   │   └── main.dart # App entry point
│   └── pubspec.yaml
├── firestore.rules   # Firestore security rules
└── README.md         # This file
```

## ✨ Features

### Backend
- ✅ Fetches today's games from NHL Stats API
- ✅ Optional: Fetch games for previous days (configurable)
- ✅ Idempotent writes (no duplicate games)
- ✅ Graceful error handling
- ✅ Schema flexibility (preserves additional API fields)
- ✅ Team statistics tracking
- ✅ Batch processing for performance
- ✅ Comprehensive logging

### Flutter App
- ✅ Games list screen with real-time updates
- ✅ Game detail screen with all game information
- ✅ Team screen with season stats and recent games
- ✅ Filter games by status (All, Live, Scheduled, Final)
- ✅ Real-time score updates via Firestore streams
- ✅ Loading and error states
- ✅ Graceful degradation for missing data
- ✅ Navigation between screens

## 🚀 Quick Start

### Backend Setup

1. **Navigate to backend directory:**
```bash
cd backend
```

2. **Install dependencies:**
```bash
npm install
```

3. **Configure environment variables:**
   Create a `.env` file:
   ```
   FIRESTORE_PROJECT_ID=your-project-id
   GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json
   NHL_API_BASE_URL=https://statsapi.web.nhl.com/api/v1
   ```

4. **Run the ingestion service:**
```bash
# Fetch today's games
npm run ingest

# Fetch last 3 days
npm run ingest -- --days 3

# Fetch specific date
npm run ingest -- --date 2024-01-15
```

See [backend/README.md](backend/README.md) for detailed backend documentation.

### Flutter App Setup

1. **Navigate to app directory:**
```bash
cd app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure Firebase:**
   - Use FlutterFire CLI: `flutterfire configure`
   - Or manually add:
     - `google-services.json` to `android/app/`
     - `GoogleService-Info.plist` to `ios/Runner/`

4. **Deploy Firestore security rules:**
```bash
firebase deploy --only firestore:rules
```

5. **Run the app:**
```bash
flutter run
```

## 📊 Data Model

### Firestore Collections

#### `games/{gameId}`
Each game document contains:
- `gameId` (number): Unique game identifier
- `startTime` (string): ISO 8601 timestamp
- `homeTeam`: { id, name, score }
- `awayTeam`: { id, name, score }
- `status` (string): "scheduled", "live", "final"
- `season` (string, optional)
- `gameType` (string, optional)
- `venue` (object, optional)
- `metadata` (object, optional): Additional fields from NHL API
- `updatedAt` (string): Last update timestamp
- `createdAt` (string): Creation timestamp

#### `teamStats/{teamId}`
Team statistics (automatically calculated):
- `teamId` (number): Team identifier
- `teamName` (string): Team name
- `wins` (number): Number of wins
- `losses` (number): Number of losses
- `ot` (number, optional): Overtime losses
- `lastUpdated` (string): Last update timestamp

## 🔒 Security

Firestore security rules are configured in `firestore.rules`:
- **Read access**: Public (anyone can read games and team stats)
- **Write access**: Restricted to backend service account only

To deploy rules:
```bash
firebase deploy --only firestore:rules
```

## 🎯 Implementation Details

### Backend Architecture

**Services:**
- `NHLApiService`: Handles NHL Stats API communication
  - Parallel fetching for multiple dates
  - Error handling and retry logic
- `FirestoreService`: Manages Firestore operations
  - Idempotent upserts using transactions
  - Batch processing (up to 500 operations)
  - Team statistics updates

**Key Features:**
- **Idempotency**: Uses `gameId` as document ID to prevent duplicates
- **Schema Flexibility**: Unknown API fields stored in `metadata`
- **Error Handling**: Validates data, skips invalid records, continues processing
- **Performance**: Parallel API calls, batch writes, transaction-based updates

### Flutter Architecture

**Screens:**
- `GamesListScreen`: Today's games with filtering
- `GameDetailScreen`: Complete game information
- `TeamScreen`: Team stats and recent games

**Services:**
- `FirestoreService`: Real-time Firestore streams
  - Optimized queries with error handling
  - Graceful degradation for missing data

**Features:**
- **Real-time Updates**: Uses Firestore streams for live score updates
- **Error Handling**: Loading states, error messages, retry functionality
- **Performance**: Efficient queries, minimal rebuilds, proper stream management

## 🧪 Testing

### Backend Testing
```bash
# Run ingestion
npm run ingest

# Check logs for errors
npm run ingest 2>&1 | tee ingestion.log
```

### Flutter Testing
```bash
# Run app
flutter run

# Run tests (if implemented)
flutter test
```

## 📝 Assumptions & Limitations

### Assumptions
1. Firestore project is already set up
2. Service account has Firestore write permissions
3. NHL Stats API is publicly accessible (no auth required)
4. Firebase is configured for Flutter app

### Limitations
1. **Rate Limiting**: No rate limiting implemented (may need for high-frequency runs)
2. **Retries**: Network errors are logged but not automatically retried
3. **Team Games Query**: Firestore doesn't support OR queries, so team games are filtered client-side
4. **Offline Support**: Basic offline support via Firestore caching (not fully implemented)

### Compromises Made
1. **Team Games**: Due to Firestore query limitations, we fetch more games than needed and filter client-side
2. **Composite Indexes**: Some queries may require composite indexes in Firestore (will show error if needed)
3. **Team Logos**: Using placeholder icons (would need NHL logo API or asset files)

## 🚧 What Would I Improve Next?

### Backend
1. **Retry Logic**: Implement exponential backoff for API failures
2. **Rate Limiting**: Add rate limiting for NHL API calls
3. **Monitoring**: Add metrics, alerting, and health checks
4. **Caching**: Cache team information to reduce API calls
5. **Incremental Updates**: Only fetch games that have changed
6. **Pub/Sub Integration**: Trigger updates via Pub/Sub messages

### Flutter App
1. **Offline Support**: Implement full offline caching with local database
2. **Team Logos**: Integrate NHL logo API or add asset files
3. **Push Notifications**: Notify users of score updates
4. **Favorites**: Allow users to favorite teams
5. **Search**: Add search functionality for games and teams
6. **Animations**: Add smooth animations for score updates
7. **Performance**: Implement pagination for large game lists

### General
1. **Testing**: Add unit and integration tests
2. **CI/CD**: Set up automated testing and deployment
3. **Documentation**: Add API documentation and code comments
4. **Error Tracking**: Integrate error tracking (Sentry, etc.)
5. **Analytics**: Add usage analytics

## 🤖 AI Usage

### Where AI Was Used
- Initial project structure setup
- Type definitions and interfaces
- Code scaffolding and boilerplate

### Where Human Intelligence Was Applied
- Architecture decisions (idempotency, schema design)
- Error handling strategies
- Performance optimizations (batch processing, parallel fetching)
- Firestore query design and limitations
- UI/UX decisions and widget structure
- Security rules design
- Documentation and explanations

## 📚 Additional Resources

- [NHL Stats API Documentation](https://gitlab.com/dword4/nhlapi)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

## 📄 License

This project is part of an intern challenge submission.

---

**Note**: This implementation focuses on demonstrating:
- Clean architecture and code organization
- Performance optimizations
- Error handling and graceful degradation
- Real-time data synchronization
- Best practices for both backend and mobile development
