/**
 * Quick test script to verify Firestore connection and data
 * Run with: node test-firestore-connection.js
 */

require('dotenv').config();
const { Firestore } = require('@google-cloud/firestore');

const db = new Firestore({
  projectId: process.env.FIRESTORE_PROJECT_ID,
});

async function testConnection() {
  console.log('🔍 Testing Firestore Connection...\n');
  console.log(`Project ID: ${process.env.FIRESTORE_PROJECT_ID}\n`);

  try {
    // Get today's date in UTC
    // Include next day to catch games starting at midnight UTC
    const today = new Date();
    const startOfDay = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate()));
    const endOfDay = new Date(startOfDay);
    endOfDay.setUTCDate(endOfDay.getUTCDate() + 2); // Include today + tomorrow

    console.log(`📅 Checking for games between:`);
    console.log(`   Start: ${startOfDay.toISOString()}`);
    console.log(`   End:   ${endOfDay.toISOString()}\n`);

    // Query games for today
    const gamesRef = db.collection('games');
    const snapshot = await gamesRef
      .where('startTime', '>=', startOfDay.toISOString())
      .where('startTime', '<', endOfDay.toISOString())
      .get();

    console.log(`✅ Found ${snapshot.size} games for today\n`);

    if (snapshot.empty) {
      console.log('⚠️  No games found for today!');
      console.log('   Run: npm run ingest\n');
    } else {
      console.log('📋 Games found:');
      snapshot.forEach((doc) => {
        const data = doc.data();
        console.log(`   - Game ${data.gameId}: ${data.awayTeam.name} @ ${data.homeTeam.name}`);
        console.log(`     Start: ${data.startTime}`);
        console.log(`     Status: ${data.status}\n`);
      });
    }

    // Check total games in collection
    const allGames = await gamesRef.limit(10).get();
    console.log(`📊 Total games in collection (first 10): ${allGames.size}`);

    // Check team stats
    const teamStatsRef = db.collection('teamStats');
    const teamStatsSnapshot = await teamStatsRef.limit(5).get();
    console.log(`📊 Team stats documents: ${teamStatsSnapshot.size}\n`);

    console.log('✅ Firestore connection successful!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.code === 7) {
      console.error('   Permission denied - check Firestore rules');
    } else if (error.code === 14) {
      console.error('   Unavailable - check network connection');
    }
    process.exit(1);
  }
}

testConnection();

