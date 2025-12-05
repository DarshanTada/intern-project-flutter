/**
 * Script to add ONE sample game to Firestore
 * Use this for testing when there are no games on a particular day
 * This is just for demonstration/review purposes
 */

import * as dotenv from 'dotenv';
import { Firestore } from '@google-cloud/firestore';

dotenv.config();

const db = new Firestore({
  projectId: process.env.FIRESTORE_PROJECT_ID,
});

// Single sample game for testing
const sampleGame = {
  gameId: 2024999999, // Using a high number to avoid conflicts with real games
  startTime: new Date().toISOString(),
  homeTeam: {
    id: 1,
    name: 'New Jersey Devils',
    score: 3,
  },
  awayTeam: {
    id: 2,
    name: 'New York Islanders',
    score: 2,
  },
  status: 'final',
  season: '20242025',
  gameType: 'R',
  venue: {
    name: 'Prudential Center',
  },
  updatedAt: new Date().toISOString(),
  createdAt: new Date().toISOString(),
};

async function addSampleGame() {
  console.log('Adding one sample game to Firestore...');
  console.log('(This is for testing when there are no real games available)');

  try {
    await db.collection('games').doc(sampleGame.gameId.toString()).set(sampleGame);
    console.log(`Added sample game ${sampleGame.gameId}`);
    console.log(`  ${sampleGame.awayTeam.name} (${sampleGame.awayTeam.score}) @ ${sampleGame.homeTeam.name} (${sampleGame.homeTeam.score})`);
    console.log(`  Status: ${sampleGame.status}`);
    console.log('\nSample game added successfully!');
    console.log('You can now test the Flutter app with this sample game.');
  } catch (error) {
    console.error('Failed to add sample game:', error);
    throw error;
  }
}

addSampleGame().catch(console.error);

