# NHL Scores Flutter App

Flutter mobile application for displaying NHL game scores with real-time updates.

## Features

- ✅ Games list screen with today's games
- ✅ Game detail screen with complete information
- ✅ Team screen with season stats and recent games
- ✅ Real-time score updates via Firestore streams
- ✅ Filter games by status (All, Live, Scheduled, Final)
- ✅ Loading and error states
- ✅ Graceful degradation for missing data
- ✅ Navigation between screens

## Setup

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project configured
- iOS Simulator / Android Emulator / Physical device

### Installation

1. **Install dependencies:**
```bash
flutter pub get
```

2. **Configure Firebase:**
   - Use FlutterFire CLI: `flutterfire configure`
   - Or manually add:
     - `google-services.json` to `android/app/`
     - `GoogleService-Info.plist` to `ios/Runner/`

3. **Run the app:**
```bash
flutter run
```

## Architecture

### Models
- `Game`: Game data model with team scores and status
- `TeamStats`: Team statistics model

### Services
- `FirestoreService`: Handles all Firestore operations
  - Real-time streams for games
  - Team statistics queries
  - Team games queries

### Screens
- `GamesListScreen`: Main screen showing today's games
- `GameDetailScreen`: Detailed game information
- `TeamScreen`: Team statistics and recent games

### Widgets
- `GameCard`: Reusable game card widget
- `LoadingIndicator`: Loading state widget
- `ErrorMessage`: Error state widget with retry

## Data Flow

1. **Games List**: Streams today's games from Firestore, sorted by start time
2. **Game Detail**: Streams single game by ID for real-time updates
3. **Team Screen**: Streams team stats and recent games

## Performance Considerations

1. **Efficient Queries**: Uses Firestore queries with proper indexing
2. **Stream Management**: Properly manages Firestore streams
3. **Error Handling**: Gracefully handles missing or malformed data
4. **Minimal Rebuilds**: Uses StreamBuilder efficiently

## Limitations

1. **Team Games Query**: Due to Firestore OR query limitations, fetches more games and filters client-side
2. **Team Logos**: Uses placeholder icons (would need NHL logo API)
3. **Offline Support**: Basic offline via Firestore caching (not fully implemented)

## Future Improvements

1. Full offline support with local database
2. Team logo integration
3. Push notifications for score updates
4. Favorites functionality
5. Search functionality
6. Animations for score updates
7. Pagination for large lists
