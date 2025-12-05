/**
 * Script to delete ALL games from Firestore
 * Use this to clear the database before re-ingesting
 */

import * as dotenv from 'dotenv';
import { Firestore } from '@google-cloud/firestore';

dotenv.config();

const db = new Firestore({
  projectId: process.env.FIRESTORE_PROJECT_ID,
});

async function deleteAllGames() {
  console.log('Deleting ALL games from Firestore...');
  console.log('WARNING: This will delete all game data!');

  try {
    // Get all games
    const gamesSnapshot = await db.collection('games').get();
    const totalGames = gamesSnapshot.size;
    
    console.log(`Found ${totalGames} games to delete...`);

    if (totalGames === 0) {
      console.log('No games found. Nothing to delete.');
      return;
    }

    // Delete in batches (Firestore batch limit is 500)
    const batchSize = 500;
    let deletedCount = 0;
    let batch = db.batch();
    let batchCount = 0;

    for (const doc of gamesSnapshot.docs) {
      batch.delete(doc.ref);
      batchCount++;

      if (batchCount >= batchSize) {
        await batch.commit();
        deletedCount += batchCount;
        console.log(`Deleted ${deletedCount}/${totalGames} games...`);
        batch = db.batch();
        batchCount = 0;
      }
    }

    // Commit remaining deletes
    if (batchCount > 0) {
      await batch.commit();
      deletedCount += batchCount;
    }

    console.log('');
    console.log(`Successfully deleted ${deletedCount} games`);
    console.log('\nYou can now run "npm run ingest" to add games again from the NHL API.');
  } catch (error) {
    console.error('Error deleting games:', error);
    throw error;
  }
}

deleteAllGames().catch(console.error);

