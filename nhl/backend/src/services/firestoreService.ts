/**
 * Firestore Service
 * Handles all Firestore operations with idempotent writes
 */

import { Firestore } from '@google-cloud/firestore';
import { FirestoreGame, FirestoreTeamStats } from '../types/firestore';
import { NHLGame } from '../types/nhl';

export class FirestoreService {
  private db: Firestore;
  private gamesCollection: string = 'games';
  private teamsCollection: string = 'teams';
  private teamStatsCollection: string = 'teamStats';

  constructor(projectId?: string) {
    this.db = new Firestore({
      projectId: projectId || process.env.FIRESTORE_PROJECT_ID,
    });
  }

  /**
   * Transform NHL API game data to Firestore format
   * Handles schema flexibility by preserving additional fields in metadata
   */
  private transformGame(nhlGame: NHLGame): FirestoreGame {
    const now = new Date().toISOString();
    
    // Extract known fields
    const game: FirestoreGame = {
      gameId: nhlGame.gamePk,
      startTime: nhlGame.gameDate,
      homeTeam: {
        id: nhlGame.teams.home.team.id,
        name: nhlGame.teams.home.team.name,
        score: nhlGame.teams.home.score ?? null,
        ...(nhlGame.teams.home.team.logoUrl && { logoUrl: nhlGame.teams.home.team.logoUrl }),
      },
      awayTeam: {
        id: nhlGame.teams.away.team.id,
        name: nhlGame.teams.away.team.name,
        score: nhlGame.teams.away.score ?? null,
        ...(nhlGame.teams.away.team.logoUrl && { logoUrl: nhlGame.teams.away.team.logoUrl }),
      },
      status: this.normalizeStatus(nhlGame.status.detailedState),
      updatedAt: now,
      createdAt: now,
    };

    // Add optional known fields
    if (nhlGame.season) game.season = nhlGame.season;
    if (nhlGame.gameType) game.gameType = nhlGame.gameType;
    if (nhlGame.venue && nhlGame.venue.name) {
      // Only include venue if we have at least a name
      game.venue = {
        ...(nhlGame.venue.id && { id: nhlGame.venue.id }),
        name: nhlGame.venue.name,
      };
    }

    // Store any additional fields in metadata for schema flexibility
    const knownFields = new Set([
      'gamePk', 'gameType', 'season', 'gameDate', 'status', 'teams', 'venue',
      'linescore', 'liveData', 'copyright',
    ]);

    const metadata: Record<string, any> = {};
    for (const [key, value] of Object.entries(nhlGame)) {
      if (!knownFields.has(key) && value !== undefined) {
        metadata[key] = value;
      }
    }

    if (Object.keys(metadata).length > 0) {
      game.metadata = metadata;
    }

    return game;
  }

  /**
   * Normalize game status to consistent format
   */
  private normalizeStatus(detailedState: string): string {
    const statusMap: Record<string, string> = {
      'Scheduled': 'scheduled',
      'Pre-Game': 'scheduled',
      'Preview': 'scheduled',
      'OK': 'scheduled',  // gameScheduleState: "OK" means scheduled
      'In Progress': 'live',
      'In Progress - Critical': 'live',
      'Live': 'live',
      'Game Over': 'final',
      'Final': 'final',
    };

    // Normalize the input
    const normalized = detailedState.trim();
    return statusMap[normalized] || statusMap[normalized.toUpperCase()] || normalized.toLowerCase();
  }

  /**
   * Idempotent write: Upsert a game document
   * Uses gameId as document ID to ensure no duplicates
   */
  async upsertGame(nhlGame: NHLGame): Promise<void> {
    try {
      const game = this.transformGame(nhlGame);
      const gameRef = this.db.collection(this.gamesCollection).doc(game.gameId.toString());

      // Use transaction to ensure atomicity
      await this.db.runTransaction(async (transaction) => {
        const doc = await transaction.get(gameRef);
        
        if (doc.exists) {
          // Update existing document, preserve createdAt
          const existing = doc.data() as FirestoreGame;
          game.createdAt = existing.createdAt; // Preserve original creation time
          transaction.update(gameRef, game as any);
        } else {
          // Create new document
          transaction.set(gameRef, game);
        }
      });
    } catch (error) {
      throw new Error(
        `Failed to upsert game ${nhlGame.gamePk}: ${error instanceof Error ? error.message : 'Unknown error'}`
      );
    }
  }

  /**
   * Batch upsert multiple games for better performance
   */
  async upsertGames(nhlGames: NHLGame[]): Promise<{ success: number; failed: number }> {
    const batch = this.db.batch();
    const gameRefs: Array<{ ref: FirebaseFirestore.DocumentReference; game: FirestoreGame }> = [];
    
    let successCount = 0;
    let failedCount = 0;

    // Prepare all games for batch write
    for (const nhlGame of nhlGames) {
      try {
        const game = this.transformGame(nhlGame);
        const gameRef = this.db.collection(this.gamesCollection).doc(game.gameId.toString());
        gameRefs.push({ ref: gameRef, game });
      } catch (error) {
        console.error(`Error transforming game ${nhlGame.gamePk}:`, error);
        failedCount++;
      }
    }

    // Use transactions for each game to handle idempotency
    // Firestore batches are limited to 500 operations, so we'll process in chunks
    const chunkSize = 500;
    for (let i = 0; i < gameRefs.length; i += chunkSize) {
      const chunk = gameRefs.slice(i, i + chunkSize);
      
      try {
        await Promise.all(
          chunk.map(async ({ ref, game }) => {
            try {
              await this.db.runTransaction(async (transaction) => {
                const doc = await transaction.get(ref);
                if (doc.exists) {
                  const existing = doc.data() as FirestoreGame;
                  game.createdAt = existing.createdAt;
                  transaction.update(ref, game as any);
                } else {
                  transaction.set(ref, game);
                }
              });
              successCount++;
            } catch (error) {
              console.error(`Error upserting game ${game.gameId}:`, error);
              failedCount++;
            }
          })
        );
      } catch (error) {
        console.error(`Error processing batch chunk:`, error);
        failedCount += chunk.length;
      }
    }

    return { success: successCount, failed: failedCount };
  }

  /**
   * Update team statistics based on game results
   * This helps with the Team screen requirements
   */
  async updateTeamStats(game: FirestoreGame): Promise<void> {
    if (game.status !== 'final') {
      return; // Only update stats for final games
    }

    const teams = [game.homeTeam, game.awayTeam];
    
    for (const team of teams) {
      const statsRef = this.db
        .collection(this.teamStatsCollection)
        .doc(team.id.toString());

      await this.db.runTransaction(async (transaction) => {
        const statsDoc = await transaction.get(statsRef);
        const isHome = team.id === game.homeTeam.id;
        const isWinner = 
          (isHome && game.homeTeam.score! > game.awayTeam.score!) ||
          (!isHome && game.awayTeam.score! > game.homeTeam.score!);

        // Get logo URL from game data if available
        const logoUrl = (team.id === game.homeTeam.id ? game.homeTeam.logoUrl : game.awayTeam.logoUrl) || undefined;
        
        if (statsDoc.exists) {
          const current = statsDoc.data() as FirestoreTeamStats;
          const updated: FirestoreTeamStats = {
            ...current,
            wins: isWinner ? current.wins + 1 : current.wins,
            losses: !isWinner ? current.losses + 1 : current.losses,
            ...(logoUrl && { logoUrl }), // Update logo URL if available
            lastUpdated: new Date().toISOString(),
          };
          transaction.update(statsRef, updated as any);
        } else {
          const newStats: FirestoreTeamStats = {
            teamId: team.id,
            teamName: team.name,
            wins: isWinner ? 1 : 0,
            losses: isWinner ? 0 : 1,
            ...(logoUrl && { logoUrl }), // Include logo URL if available
            lastUpdated: new Date().toISOString(),
          };
          transaction.set(statsRef, newStats);
        }
      });
    }
  }

  /**
   * Get a game by ID
   */
  async getGame(gameId: number): Promise<FirestoreGame | null> {
    const doc = await this.db
      .collection(this.gamesCollection)
      .doc(gameId.toString())
      .get();

    return doc.exists ? (doc.data() as FirestoreGame) : null;
  }
}

