# NHL Scores Backend

Node.js/TypeScript service for ingesting NHL game data from the public NHL Stats API and storing it in Firestore.

## Features

- ✅ Fetches today's games (required)
- ✅ Optional: Fetch games for previous days (configurable via CLI)
- ✅ Idempotent writes (no duplicate games)
- ✅ Graceful error handling
- ✅ Schema flexibility (preserves additional API fields)
- ✅ Team statistics tracking
- ✅ Batch processing for performance
- ✅ Comprehensive logging

## Setup

### Prerequisites

- Node.js v18 or higher
- Google Cloud Project with Firestore enabled
- Service account key with Firestore write permissions

### Installation

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Edit `.env` and set the following variables:
     ```
     FIRESTORE_PROJECT_ID=your-project-id
     GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
     NHL_API_BASE_URL=https://api-web.nhle.com/v1
     ```
   - Place your service account key JSON file in the `backend/` directory

### Running

**Fetch today's games:**
```bash
npm run ingest
```

**Fetch games for last 3 days:**
```bash
npm run ingest -- --days 3
```

**Fetch games for a specific date:**
```bash
npm run ingest -- --date 2024-01-15
```

## Data Model

### Games Collection (`games/{gameId}`)

Each game document contains:
- `gameId` (number): Unique game identifier
- `startTime` (string): ISO 8601 timestamp
- `homeTeam`: { id, name, score }
- `awayTeam`: { id, name, score }
- `status` (string): "scheduled", "live", "final"
- `season` (string, optional): Season identifier
- `gameType` (string, optional): Game type
- `venue` (object, optional): Venue information
- `metadata` (object, optional): Additional fields from NHL API
- `updatedAt` (string): Last update timestamp
- `createdAt` (string): Creation timestamp

### Team Stats Collection (`teamStats/{teamId}`)

Team statistics are automatically calculated from final games:
- `teamId` (number): Team identifier
- `teamName` (string): Team name
- `wins` (number): Number of wins
- `losses` (number): Number of losses
- `ot` (number, optional): Overtime losses
- `lastUpdated` (string): Last update timestamp

## Architecture

### Services

- **NHLApiService**: Handles communication with NHL Stats API
  - Fetches games by date
  - Handles network errors gracefully
  - Supports parallel fetching for multiple dates

- **FirestoreService**: Manages Firestore operations
  - Idempotent upserts using transactions
  - Batch processing for performance
  - Team statistics updates
  - Schema transformation with metadata preservation

### Error Handling

The service handles:
- Network failures (retries not implemented, but logged)
- API errors (skips bad records, continues processing)
- Missing data fields (validates required fields, skips invalid games)
- Firestore errors (logs and continues with other games)

### Idempotency

Games are stored using `gameId` as the document ID. Re-running the ingestion:
- Updates existing games (preserves `createdAt`)
- Creates new games if they don't exist
- Never creates duplicates

### Schema Flexibility

Additional fields from the NHL API that aren't explicitly handled are stored in the `metadata` object. This ensures:
- New API fields don't break the service
- All data is preserved for future use
- Existing fields remain accessible

## Performance Optimizations

1. **Parallel API Calls**: Multiple dates are fetched in parallel
2. **Batch Processing**: Games are processed in batches (up to 500 per batch)
3. **Transaction-based Writes**: Uses Firestore transactions for atomic updates
4. **Selective Updates**: Only updates team stats for final games

## Extending for 30-Day Backfill

To backfill the last 30 days:

```bash
npm run ingest -- --days 30
```

The service will:
1. Calculate dates for the last 30 days
2. Fetch games in parallel for all dates
3. Process and store all games idempotently

**Note**: The NHL API may have rate limits. For production, consider:
- Adding rate limiting
- Implementing retry logic with exponential backoff
- Processing in smaller batches over time

## Production Deployment

### Cloud Scheduler / Cron

To run automatically, you can use:

1. **Google Cloud Scheduler**:
   - Create a Cloud Function or Cloud Run service
   - Schedule it to run every hour or as needed
   - Use Pub/Sub trigger if needed

2. **Cron Job**:
   ```bash
   # Run every hour
   0 * * * * cd /path/to/backend && npm run ingest
   ```

### Environment Variables

In production, use:
- Google Cloud Secret Manager for credentials
- Environment variables in Cloud Run/Cloud Functions
- Service account with minimal required permissions

## Logging

The service uses a simple logger that outputs:
- Timestamp
- Log level (INFO, WARN, ERROR, DEBUG)
- Message and context

Enable debug logging:
```bash
DEBUG=true npm run ingest
```

## Limitations & Assumptions

1. **Firestore Project**: Assumes Firestore is already set up
2. **Service Account**: Requires service account key with write permissions
3. **NHL API**: Uses public NHL Stats API (no authentication required)
4. **Rate Limiting**: No rate limiting implemented (may need for high-frequency runs)
5. **Retries**: Network errors are logged but not retried automatically

## What Would I Improve Next?

1. **Retry Logic**: Implement exponential backoff for API failures
2. **Rate Limiting**: Add rate limiting for NHL API calls
3. **Monitoring**: Add metrics and alerting
4. **Caching**: Cache team information to reduce API calls
5. **Incremental Updates**: Only fetch games that have changed
6. **Pub/Sub Integration**: Trigger updates via Pub/Sub messages
7. **Health Checks**: Add health check endpoint for monitoring

