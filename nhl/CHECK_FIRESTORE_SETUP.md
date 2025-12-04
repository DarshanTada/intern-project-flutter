# How to Check Firestore Setup

## 1. Check Firestore Connection - Verify Firebase Project ID

### Flutter App Configuration:
- **File**: `app/lib/firebase_options.dart`
- **Current Project ID**: `nhl-scores-93ccb` (line 56 for iOS, line 65 for Android)

### Backend Configuration:
- **File**: `backend/.env`
- **Check**: Run this command:
  ```bash
  cd backend
  cat .env | grep FIRESTORE_PROJECT_ID
  ```
- **Should match**: `FIRESTORE_PROJECT_ID=nhl-scores-93ccb`

### Verify They Match:
✅ **Flutter App Project ID**: `nhl-scores-93ccb`
✅ **Backend Project ID**: Should be `nhl-scores-93ccb`

**If they don't match**, update the backend `.env` file to use the same project ID.

---

## 2. Verify Date Range - Check Games for Today's Date

### Check Today's Date:
```bash
date
```

### Check What Date Games Were Ingested:
```bash
cd backend
npm run ingest
```

Look for this line in the output:
```
[INFO] Fetching games for date: YYYY-MM-DD
```

### Check Games in Firestore Console:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `nhl-scores-93ccb`
3. Go to **Firestore Database** → **Data** tab
4. Click on `games` collection
5. Check the `startTime` field of documents
6. Verify games exist for today's date (in UTC)

### Manual Check via Backend:
```bash
cd backend
# Fetch today's games
npm run ingest

# Or fetch specific date
npm run ingest -- --date 2025-12-03
```

### Expected Date Format:
- Games are stored with `startTime` in UTC format: `2025-12-03T00:00:00Z`
- Flutter app queries for games where `startTime` is between:
  - Start of today (UTC): `2025-12-03T00:00:00Z`
  - End of today (UTC): `2025-12-04T00:00:00Z`

---

## 3. Check Firestore Rules - Verify Read Permissions

### Check Current Rules:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `nhl-scores-93ccb`
3. Go to **Firestore Database** → **Rules** tab
4. Check the current rules

### Required Rules for Reading Games:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to games collection
    match /games/{gameId} {
      allow read: if true;  // Public read access
      allow write: if false;  // Only backend can write
    }
    
    // Allow read access to teamStats collection
    match /teamStats/{teamId} {
      allow read: if true;  // Public read access
      allow write: if false;  // Only backend can write
    }
  }
}
```

### Test Rules:
1. In Firebase Console → **Firestore Database** → **Rules** tab
2. Click **"Publish"** after making changes
3. Rules take effect immediately

### Verify Rules Are Working:
- If you see games in the Firestore Console but not in the app, rules might be blocking reads
- Check browser console (if web) or Flutter logs for permission errors

---

## Quick Diagnostic Commands

### 1. Check Project IDs Match:
```bash
# Check Flutter app
grep -r "projectId.*nhl-scores" app/lib/firebase_options.dart

# Check backend
cd backend && cat .env | grep FIRESTORE_PROJECT_ID
```

### 2. Check Today's Date and Ingest Games:
```bash
# Get today's date
date -u +"%Y-%m-%d"

# Ingest today's games
cd backend
npm run ingest
```

### 3. Check Firestore Rules (via Firebase Console):
- Go to: https://console.firebase.google.com/project/nhl-scores-93ccb/firestore/rules
- Verify rules allow public read access

---

## Troubleshooting

### Games Not Showing in App:

1. **Check Project ID Match**:
   - Flutter: `app/lib/firebase_options.dart` → `projectId: 'nhl-scores-93ccb'`
   - Backend: `backend/.env` → `FIRESTORE_PROJECT_ID=nhl-scores-93ccb`

2. **Check Date Range**:
   - Run: `cd backend && npm run ingest`
   - Verify games were ingested for today's date
   - Check Firestore Console to see if games exist

3. **Check Firestore Rules**:
   - Go to Firebase Console → Firestore → Rules
   - Ensure `allow read: if true;` is set for `games` collection

4. **Check Timezone**:
   - Games are stored in UTC
   - App queries use UTC dates
   - Make sure you're ingesting games for the correct date

5. **Check App Logs**:
   - Run Flutter app with: `flutter run -v`
   - Look for Firestore connection errors
   - Check for permission denied errors

---

## Expected Behavior

✅ **Correct Setup**:
- Project IDs match between Flutter app and backend
- Games are ingested for today's date (UTC)
- Firestore rules allow public read access
- Games appear in app automatically via `.snapshots()` stream

❌ **Common Issues**:
- Project ID mismatch → App connects to wrong project
- Wrong date ingested → Games don't match today's query
- Rules block reads → Permission denied errors
- Timezone mismatch → Date queries don't match

