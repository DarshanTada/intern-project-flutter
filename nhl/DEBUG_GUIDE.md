# Debug Guide - "No Games Today" Issue

## Steps to Debug

### 1. Hot Restart the App
In your Flutter terminal, press `R` (capital R) to hot restart and pick up the latest code changes.

### 2. Check Flutter Debug Console
Look for these debug messages in the Flutter console (not Android logs):

```
🔍 Querying games: 2025-12-03T00:00:00.000Z to 2025-12-05T00:00:00.000Z
📊 Firestore returned X documents
✅ Parsed game: 2025020421 - Dallas Stars @ New Jersey Devils
🎮 Returning X games
```

### 3. Common Issues and Solutions

#### Issue: "Firestore returned 0 documents"
**Possible Causes:**
- Date range mismatch
- Games not ingested for today
- Query format issue

**Solution:**
- Verify games exist: Run `cd backend && node test-firestore-connection.js`
- Check date range in debug output matches today's date

#### Issue: "Error parsing game"
**Possible Causes:**
- Data format mismatch
- Missing required fields

**Solution:**
- Check the error message for which field is failing
- Verify game data structure in Firestore Console

#### Issue: "Index required" error
**Possible Causes:**
- Firestore needs a composite index for the query

**Solution:**
1. The error will include a URL like:
   `https://console.firebase.google.com/v1/r/project/.../firestore/indexes?create_composite=...`
2. Click the URL to create the index automatically
3. Or manually create in Firebase Console:
   - Go to Firestore → Indexes
   - Create composite index:
     - Collection: `games`
     - Fields: 
       - `startTime` (Ascending)
       - `startTime` (Ascending) - for the second where clause
     - Query scope: Collection

### 4. Verify Data Exists

Run this command to verify games exist:
```bash
cd backend
node test-firestore-connection.js
```

Expected output:
```
✅ Found 5 games for today
📋 Games found:
   - Game 2025020421: Dallas Stars @ New Jersey Devils
   ...
```

### 5. Check Firestore Console

1. Go to: https://console.firebase.google.com/project/nhl-scores-93ccb/firestore/data
2. Navigate to `games` collection
3. Check if games exist with `startTime` around today's date
4. Verify the `status` field is set (should be "scheduled", "live", or "final")

### 6. Test Query Manually

If games exist but query returns 0, the issue might be:
- Date format mismatch
- Timezone issue
- Query syntax issue

Check the debug output to see the exact query being made.

