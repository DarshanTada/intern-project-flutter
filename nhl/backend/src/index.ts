/**
 * NHL Scores Data Ingestion Service
 * 
 * Fetches game data from NHL API and stores it in Firestore
 * with idempotent writes and graceful error handling
 * 
 * IMPORTANT: This service ONLY fetches data from the NHL API.
 * No hardcoded or test data is used. All game data comes directly
 * from the official NHL Stats API endpoint.
 */

import * as dotenv from 'dotenv';
import { NHLApiService } from './services/nhlApi';
import { FirestoreService } from './services/firestoreService';
import { Logger } from './utils/logger';
import { NHLGame } from './types/nhl';

// Load environment variables
dotenv.config();

interface IngestionOptions {
  days?: number; // Number of days to fetch (default: 1 for today only)
  date?: string; // Specific date in YYYY-MM-DD format (overrides days)
  finalDate?: string; // Specific date for final games in YYYY-MM-DD format
  liveDate?: string; // Specific date for live games in YYYY-MM-DD format
}

class IngestionService {
  private nhlApi: NHLApiService;
  private firestore: FirestoreService;

  constructor() {
    this.nhlApi = new NHLApiService(process.env.NHL_API_BASE_URL);
    this.firestore = new FirestoreService(process.env.FIRESTORE_PROJECT_ID);
  }

  /**
   * Validate and extract game data, handling partial/missing data gracefully
   */
  private validateGame(game: NHLGame): boolean {
    try {
      // Required fields validation
      if (!game.gamePk) {
        Logger.warn('Game missing gamePk, skipping:', game);
        return false;
      }

      if (!game.teams?.home?.team?.id || !game.teams?.away?.team?.id) {
        Logger.warn(`Game ${game.gamePk} missing team IDs, skipping`);
        return false;
      }

      if (!game.teams.home.team.name || !game.teams.away.team.name) {
        Logger.warn(`Game ${game.gamePk} missing team names, skipping`);
        return false;
      }

      if (!game.gameDate) {
        Logger.warn(`Game ${game.gamePk} missing gameDate, skipping`);
        return false;
      }

      return true;
    } catch (error) {
      Logger.error(`Error validating game:`, error);
      return false;
    }
  }

  /**
   * Process a single game with error handling
   */
  private async processGame(game: NHLGame): Promise<boolean> {
    try {
      if (!this.validateGame(game)) {
        return false;
      }

      await this.firestore.upsertGame(game);
      
      // Update team stats for final games
      const firestoreGame = await this.firestore.getGame(game.gamePk);
      if (firestoreGame) {
        await this.firestore.updateTeamStats(firestoreGame);
      }

      return true;
    } catch (error) {
      Logger.error(`Failed to process game ${game.gamePk}:`, error);
      return false;
    }
  }

  /**
   * Main ingestion method
   */
  async ingest(options: IngestionOptions = {}): Promise<void> {
    const startTime = Date.now();
    Logger.info('Starting NHL data ingestion...');

    // Test API connectivity first
    Logger.info('Testing NHL API connectivity...');
    const isConnected = await this.nhlApi.testConnection();
    if (!isConnected) {
      Logger.error('NHL API connectivity test failed. The API endpoint may be unavailable or there may be network issues.');
      Logger.info('Attempting to fetch data anyway, but this will likely fail...');
    } else {
      Logger.info('NHL API connectivity test passed.');
    }

    try {
      let dates: string[] = [];
      const today = new Date().toISOString().split('T')[0];
      
      if (options.date) {
        // Specific date provided
        dates = [options.date];
        Logger.info(`Fetching games for date: ${options.date}`);
      } else {
        // Default: fetch yesterday (for final games) and today (for scheduled/live games)
        // This ensures we get games in all statuses: scheduled, live, and final
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        const yesterdayStr = yesterday.toISOString().split('T')[0];
        
        dates.push(yesterdayStr); // Yesterday's games (final)
        dates.push(today); // Today's games (scheduled/live)
        Logger.info('Fetching games: yesterday (final) and today (scheduled/live)');
        
        // Add final date if specified (overrides yesterday)
        if (options.finalDate) {
          dates = dates.filter(d => d !== yesterdayStr);
          dates.push(options.finalDate);
          Logger.info(`Also fetching final games for date: ${options.finalDate}`);
        }
        
        // Add live date if specified (overrides today)
        if (options.liveDate) {
          dates = dates.filter(d => d !== today);
          dates.push(options.liveDate);
          Logger.info(`Also fetching live games for date: ${options.liveDate}`);
        }
        
        // If days option is provided (and no specific dates), use it
        if (options.days && options.days > 1 && !options.finalDate && !options.liveDate) {
          dates = NHLApiService.getLastNDays(options.days);
          Logger.info(`Fetching games for last ${options.days} days`);
        }
      }
      
      // Remove duplicates
      dates = [...new Set(dates)];

      // Fetch games from NHL API
      const { results: gamesByDate, failedDates } = await this.nhlApi.getGamesByDates(dates);
      
      // If all API calls failed, throw an error
      if (failedDates.length === dates.length) {
        throw new Error(
          `Failed to fetch games for all requested dates. ` +
          `This is likely due to network/DNS issues. ` +
          `Please check your internet connection and DNS settings. ` +
          `See TROUBLESHOOTING.md for more information.`
        );
      }

      // Log warnings for partial failures
      if (failedDates.length > 0) {
        Logger.warn(`Failed to fetch games for ${failedDates.length} date(s): ${failedDates.join(', ')}`);
      }
      
      let totalGames = 0;
      let processedGames = 0;
      let failedGames = 0;

      // Process games by date
      for (const [date, games] of gamesByDate.entries()) {
        Logger.info(`Processing ${games.length} games for ${date}`);
        totalGames += games.length;

        // Use batch processing for better performance
        const validGames = games.filter(game => this.validateGame(game));
        const result = await this.firestore.upsertGames(validGames);
        
        processedGames += result.success;
        failedGames += result.failed;

        // Update team stats for final games
        for (const game of validGames) {
          try {
            const firestoreGame = await this.firestore.getGame(game.gamePk);
            if (firestoreGame && firestoreGame.status === 'final') {
              await this.firestore.updateTeamStats(firestoreGame);
            }
          } catch (error) {
            Logger.warn(`Failed to update team stats for game ${game.gamePk}:`, error);
          }
        }

        Logger.info(
          `Date ${date}: ${result.success} successful, ${result.failed} failed`
        );
      }

      const duration = ((Date.now() - startTime) / 1000).toFixed(2);
      Logger.info('Ingestion completed!');
      Logger.info(`Total games: ${totalGames}, Processed: ${processedGames}, Failed: ${failedGames}`);
      Logger.info(`Duration: ${duration}s`);

      if (failedGames > 0) {
        Logger.warn(`${failedGames} games failed to process. Check logs for details.`);
      }
    } catch (error) {
      Logger.error('Ingestion failed:', error);
      throw error;
    }
  }
}

// CLI interface
async function main() {
  const args = process.argv.slice(2);
  const options: IngestionOptions = {};

  // Parse command line arguments
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--days' && i + 1 < args.length) {
      options.days = parseInt(args[i + 1], 10);
      i++;
    } else if (args[i] === '--date' && i + 1 < args.length) {
      options.date = args[i + 1];
      i++;
    } else if (args[i] === '--final-date' && i + 1 < args.length) {
      options.finalDate = args[i + 1];
      i++;
    } else if (args[i] === '--live-date' && i + 1 < args.length) {
      options.liveDate = args[i + 1];
      i++;
    }
  }

  // Validate environment
  if (!process.env.FIRESTORE_PROJECT_ID && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    Logger.error(
      'Missing required environment variables: FIRESTORE_PROJECT_ID or GOOGLE_APPLICATION_CREDENTIALS'
    );
    Logger.info('Please set FIRESTORE_PROJECT_ID in your .env file or environment');
    process.exit(1);
  }

  const service = new IngestionService();
  
  try {
    await service.ingest(options);
    Logger.info('Ingestion service completed successfully');
    process.exit(0);
  } catch (error) {
    Logger.error('Ingestion service failed:', error);
    process.exit(1);
  }
}

// Run if executed directly
if (require.main === module) {
  main();
}

export { IngestionService };

