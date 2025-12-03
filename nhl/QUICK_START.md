# Quick Start Guide

## Firestore Setup (5 minutes)

### 1. Create Firebase Project
- Go to https://console.firebase.google.com/
- Click "Add project"
- Name it (e.g., "nhl-scores")
- Complete setup

### 2. Enable Firestore
- Click "Firestore Database" in sidebar
- Click "Create database"
- Choose "Start in production mode"
- Select location → Enable

### 3. Deploy Security Rules
- Go to Firestore → Rules tab
- Copy contents from `firestore.rules` file
- Paste and click "Publish"

### 4. Get Service Account Key (for backend)
- Firebase Console → ⚙️ Settings → Project settings
- "Service accounts" tab
- Click "Generate new private key"
- Save as `service-account-key.json` in `backend/` folder

### 5. Configure Backend
Create `backend/.env`:
```env
FIRESTORE_PROJECT_ID=your-project-id-here
GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
NHL_API_BASE_URL=https://statsapi.web.nhl.com/api/v1
```

### 6. Configure Flutter App
```bash
cd app
flutterfire configure
```
Select your Firebase project and platforms.

### 7. Test It!
```bash
# Backend - fetch games
cd backend
npm run ingest

# Flutter - run app
cd app
flutter run
```

## That's It! 🎉

Your Firestore database will automatically create:
- `games/` collection (when backend runs)
- `teamStats/` collection (when games are processed)

See `FIRESTORE_SETUP.md` for detailed instructions.

