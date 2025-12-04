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

// Get today's date for games
const today = new Date();
const todayStr = today.toISOString().split('T')[0];

const testGames = [
  // Final games with scores
  {
    gameId: 2024020001,
    startTime: new Date(`${todayStr}T19:00:00Z`).toISOString(),
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
    startTime: new Date(`${todayStr}T20:00:00Z`).toISOString(),
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
    startTime: new Date(`${todayStr}T21:00:00Z`).toISOString(),
    homeTeam: {
      id: 5,
      name: 'Pittsburgh Penguins',
      score: 5,
    },
    awayTeam: {
      id: 6,
      name: 'Washington Capitals',
      score: 2,
    },
    status: 'final',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5034,
      name: 'PPG Paints Arena',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  {
    gameId: 2024020004,
    startTime: new Date(`${todayStr}T22:00:00Z`).toISOString(),
    homeTeam: {
      id: 7,
      name: 'Boston Bruins',
      score: 6,
    },
    awayTeam: {
      id: 8,
      name: 'Toronto Maple Leafs',
      score: 3,
    },
    status: 'final',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5080,
      name: 'TD Garden',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  // Live games with scores
  {
    gameId: 2024020005,
    startTime: new Date(`${todayStr}T23:00:00Z`).toISOString(),
    homeTeam: {
      id: 9,
      name: 'Chicago Blackhawks',
      score: 2,
    },
    awayTeam: {
      id: 10,
      name: 'Detroit Red Wings',
      score: 1,
    },
    status: 'live',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5092,
      name: 'United Center',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  {
    gameId: 2024020006,
    startTime: new Date(`${todayStr}T00:00:00Z`).toISOString(),
    homeTeam: {
      id: 11,
      name: 'Colorado Avalanche',
      score: 4,
    },
    awayTeam: {
      id: 12,
      name: 'Edmonton Oilers',
      score: 3,
    },
    status: 'live',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5039,
      name: 'Ball Arena',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  // Scheduled games (no scores)
  {
    gameId: 2024020007,
    startTime: new Date(`${todayStr}T01:00:00Z`).toISOString(),
    homeTeam: {
      id: 13,
      name: 'Dallas Stars',
      score: null,
    },
    awayTeam: {
      id: 14,
      name: 'Minnesota Wild',
      score: null,
    },
    status: 'scheduled',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5019,
      name: 'American Airlines Center',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  {
    gameId: 2024020008,
    startTime: new Date(`${todayStr}T02:00:00Z`).toISOString(),
    homeTeam: {
      id: 15,
      name: 'Vegas Golden Knights',
      score: null,
    },
    awayTeam: {
      id: 16,
      name: 'Los Angeles Kings',
      score: null,
    },
    status: 'scheduled',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5178,
      name: 'T-Mobile Arena',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  {
    gameId: 2024020009,
    startTime: new Date(`${todayStr}T03:00:00Z`).toISOString(),
    homeTeam: {
      id: 17,
      name: 'Vancouver Canucks',
      score: null,
    },
    awayTeam: {
      id: 18,
      name: 'Calgary Flames',
      score: null,
    },
    status: 'scheduled',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5073,
      name: 'Rogers Arena',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  // More final games with different scores
  {
    gameId: 2024020010,
    startTime: new Date(`${todayStr}T18:00:00Z`).toISOString(),
    homeTeam: {
      id: 19,
      name: 'Tampa Bay Lightning',
      score: 7,
    },
    awayTeam: {
      id: 20,
      name: 'Florida Panthers',
      score: 4,
    },
    status: 'final',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5026,
      name: 'Amalie Arena',
    },
    updatedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  },
  {
    gameId: 2024020011,
    startTime: new Date(`${todayStr}T17:00:00Z`).toISOString(),
    homeTeam: {
      id: 21,
      name: 'Carolina Hurricanes',
      score: 1,
    },
    awayTeam: {
      id: 22,
      name: 'Nashville Predators',
      score: 0,
    },
    status: 'final',
    season: '20242025',
    gameType: 'R',
    venue: {
      id: 5064,
      name: 'PNC Arena',
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

