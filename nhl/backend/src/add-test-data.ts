/**
 * Script to add test game data to Firestore
 * Use this to test the Flutter app when NHL API is unavailable
 */

import * as dotenv from 'dotenv';
import { Firestore } from '@google-cloud/firestore';

dotenv.config();

const db = new Firestore({
  projectId: process.env.FIRESTORE_PROJECT_ID,
});

const testGames = [
  {
    gameId: 2024020001,
    startTime: new Date('2024-12-02T19:00:00Z').toISOString(),
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
      id: 5066,
      name: 'Prudential Center',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  {
    gameId: 2024020002,
    startTime: new Date('2024-12-02T20:00:00Z').toISOString(),
    homeTeam: {
      id: 3,
      name: 'New York Rangers',
      score: 4,
    },
    awayTeam: {
      id: 4,
      name: 'Philadelphia Flyers',
      score: 1,
    },
    status: 'final',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5054,
      name: 'Madison Square Garden',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  {
    gameId: 2024020003,
    startTime: new Date('2024-12-02T22:00:00Z').toISOString(),
    homeTeam: {
      id: 5,
      name: 'Pittsburgh Penguins',
      score: null,
    },
    awayTeam: {
      id: 6,
      name: 'Washington Capitals',
      score: null,
    },
    status: 'scheduled',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5034,
      name: 'PPG Paints Arena',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
];

async function addTestData() {
  console.log('Adding test game data to Firestore...');

  for (const game of testGames) {
    try {
      await db.collection('games').doc(game.gameId.toString()).set(game);
      console.log(`✓ Added game ${game.gameId}: ${game.awayTeam.name} @ ${game.homeTeam.name}`);
    } catch (error) {
      console.error(`✗ Failed to add game ${game.gameId}:`, error);
    }
  }

  // Add team stats for final games
  const finalGames = testGames.filter(g => g.status === 'final');
  for (const game of finalGames) {
    // Update home team stats
    const homeStatsRef = db.collection('teamStats').doc(game.homeTeam.id.toString());
    const homeStats = await homeStatsRef.get();
    const isHomeWinner = game.homeTeam.score! > game.awayTeam.score!;
    
    if (homeStats.exists) {
      const current = homeStats.data()!;
      await homeStatsRef.update({
        wins: isHomeWinner ? current.wins + 1 : current.wins,
        losses: !isHomeWinner ? current.losses + 1 : current.losses,
        lastUpdated: new Date().toISOString(),
      });
    } else {
      await homeStatsRef.set({
        teamId: game.homeTeam.id,
        teamName: game.homeTeam.name,
        wins: isHomeWinner ? 1 : 0,
        losses: isHomeWinner ? 0 : 1,
        lastUpdated: new Date().toISOString(),
      });
    }

    // Update away team stats
    const awayStatsRef = db.collection('teamStats').doc(game.awayTeam.id.toString());
    const awayStats = await awayStatsRef.get();
    const isAwayWinner = game.awayTeam.score! > game.homeTeam.score!;
    
    if (awayStats.exists) {
      const current = awayStats.data()!;
      await awayStatsRef.update({
        wins: isAwayWinner ? current.wins + 1 : current.wins,
        losses: !isAwayWinner ? current.losses + 1 : current.losses,
        lastUpdated: new Date().toISOString(),
      });
    } else {
      await awayStatsRef.set({
        teamId: game.awayTeam.id,
        teamName: game.awayTeam.name,
        wins: isAwayWinner ? 1 : 0,
        losses: isAwayWinner ? 0 : 1,
        lastUpdated: new Date().toISOString(),
      });
    }
  }

  console.log('\n✓ Test data added successfully!');
  console.log('Refresh your Flutter app to see the games.');
}

addTestData().catch(console.error);

