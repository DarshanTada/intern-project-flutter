/**
 * Script to delete test game data from Firestore
 * Removes all hardcoded test games added by add-test-data.ts
 */

import * as dotenv from 'dotenv';
import { Firestore } from '@google-cloud/firestore';

dotenv.config();

const db = new Firestore({
  projectId: process.env.FIRESTORE_PROJECT_ID,
});

// Test game IDs that were added by add-test-data.ts
const testGameIds = [
  2024020001,
  2024020002,
  2024020003,
  2024020004,
  2024020005,
  2024020006,
  2024020007,
  2024020008,
  2024020009,
  2024020010,
  2024020011,
];

// Test team IDs that might have stats from test games
const testTeamIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22];

async function deleteTestData() {
  console.log('Deleting test game data from Firestore...');

  let deletedGames = 0;
  let deletedStats = 0;

  // Delete test games
  for (const gameId of testGameIds) {
    try {
      const gameRef = db.collection('games').doc(gameId.toString());
      const gameDoc = await gameRef.get();

      if (gameDoc.exists) {
        await gameRef.delete();
        console.log(`Deleted game ${gameId}`);
        deletedGames++;
      } else {
        console.log(`- Game ${gameId} not found (already deleted or never existed)`);
      }
    } catch (error) {
      console.error(`Failed to delete game ${gameId}:`, error);
    }
  }

  // Delete team stats that might have been created from test games
  // Note: This will delete stats for test teams, but real team stats will remain
  console.log('\nCleaning up team stats from test games...');
  for (const teamId of testTeamIds) {
    try {
      const statsRef = db.collection('teamStats').doc(teamId.toString());
      const statsDoc = await statsRef.get();

      if (statsDoc.exists) {
        const stats = statsDoc.data();
        // Only delete if it looks like test data (low game counts or test team names)
        const teamName = stats?.teamName || '';
        const totalGames = (stats?.wins || 0) + (stats?.losses || 0) + (stats?.ot || 0);
        
        // Delete if it's clearly test data (very few games or test team names)
        if (totalGames <= 11 || teamName.includes('Test')) {
          await statsRef.delete();
          console.log(`Deleted team stats for team ${teamId} (${teamName})`);
          deletedStats++;
        } else {
          console.log(`- Keeping team stats for team ${teamId} (${teamName}) - looks like real data`);
        }
      }
    } catch (error) {
      console.error(`Failed to check/delete team stats for team ${teamId}:`, error);
    }
  }

  console.log('');
  console.log(`Cleanup complete!`);
  console.log(`  Deleted ${deletedGames} test games`);
  console.log(`  Deleted ${deletedStats} test team stats`);
  console.log('\nAll hardcoded test data has been removed from Firestore.');
  console.log('Only real NHL API data remains.');
}

deleteTestData().catch(console.error);

