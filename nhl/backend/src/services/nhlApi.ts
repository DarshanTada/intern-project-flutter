/**
 * NHL API Service
 * Handles fetching game data from the public NHL Stats API
 */

import axios, { AxiosInstance, AxiosError } from 'axios';
import { NHLScheduleResponse, NHLGame } from '../types/nhl';
import { Logger } from '../utils/logger';

export class NHLApiService {
  private client: AxiosInstance;
  private readonly baseUrl: string;

  constructor(baseUrl: string = 'https://api-web.nhle.com/v1') {
    this.baseUrl = baseUrl;
    this.client = axios.create({
      baseURL: this.baseUrl,
      timeout: 30000, // 30 second timeout
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'NHL-Scores-Backend/1.0',
      },
    });
  }

  /**
   * Test connectivity to the NHL API
   * @returns true if connection is successful, false otherwise
   */
  async testConnection(): Promise<boolean> {
    try {
      // Try a simple request to test connectivity
      await this.client.get('/schedule/now', {
        timeout: 10000, // Shorter timeout for connectivity test
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  /**
   * Fetch games for a specific date
   * @param date - Date in YYYY-MM-DD format
   * @returns Array of games for that date
   */
  async getGamesByDate(date: string): Promise<NHLGame[]> {
    try {
      const response = await this.client.get<any>(`/schedule/${date}`);

      if (!response.data || !response.data.gameWeek || response.data.gameWeek.length === 0) {
        return [];
      }

      // Find the games for the requested date
      const gameWeek = response.data.gameWeek.find((week: any) => week.date === date);
      if (!gameWeek || !gameWeek.games) {
        return [];
      }

      // Transform the new API format to our NHLGame format
      return gameWeek.games.map((game: any) => this.transformGame(game, date));
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError;
        if (axiosError.response) {
          throw new Error(
            `NHL API error: ${axiosError.response.status} - ${axiosError.response.statusText}`
          );
        } else if (axiosError.request) {
          if (axiosError.code === 'ENOTFOUND' || axiosError.code === 'ECONNREFUSED') {
            const hostname = new URL(this.baseUrl).hostname;
            throw new Error(
              `NHL API connection failed: Cannot resolve hostname "${hostname}". ` +
              `Error: ${axiosError.message}\n\n` +
              `Troubleshooting steps:\n` +
              `1. Check your internet connection\n` +
              `2. Verify DNS settings (try: nslookup ${hostname})\n` +
              `3. Check if you're behind a firewall or proxy\n` +
              `4. Try using a different DNS server (e.g., 8.8.8.8 or 1.1.1.1)\n` +
              `5. Verify the API endpoint is correct: ${this.baseUrl}`
            );
          }
          throw new Error(`NHL API request failed: No response received (timeout or network issue)`);
        }
      }
      throw new Error(`Failed to fetch NHL games: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Fetch today's games
   */
  async getTodaysGames(): Promise<NHLGame[]> {
    try {
      const response = await this.client.get<any>('/schedule/now');
      
      if (!response.data || !response.data.gameWeek || response.data.gameWeek.length === 0) {
        return [];
      }

      // Get today's date
      const today = new Date().toISOString().split('T')[0];
      const gameWeek = response.data.gameWeek.find((week: any) => week.date === today);
      
      if (!gameWeek || !gameWeek.games) {
        return [];
      }

      // Transform the new API format to our NHLGame format
      return gameWeek.games.map((game: any) => this.transformGame(game, today));
    } catch (error) {
      // Fallback to date-based endpoint
      const today = new Date().toISOString().split('T')[0];
      return this.getGamesByDate(today);
    }
  }

  /**
   * Transform the new NHL API game format to our NHLGame interface
   */
  private transformGame(game: any, date: string): NHLGame {
    // Construct full team names from placeName + commonName
    const awayTeamName = this.constructTeamName(game.awayTeam);
    const homeTeamName = this.constructTeamName(game.homeTeam);
    
    // Handle venue - it can be an object with 'default' property or a string
    const venueName = typeof game.venue === 'object' && game.venue?.default 
      ? game.venue.default 
      : typeof game.venue === 'string' 
        ? game.venue 
        : undefined;

    return {
      gamePk: game.id,
      gameType: game.gameType?.toString() || 'R',
      season: game.season?.toString() || '',
      gameDate: game.startTimeUTC || date,
      status: {
        abstractGameState: this.mapGameState(game.gameState),
        codedGameState: game.gameState || '',
        detailedState: game.gameScheduleState || game.gameState || 'Scheduled',
        statusCode: game.gameState || '1',
      },
      teams: {
        away: {
          team: {
            id: game.awayTeam?.id,
            name: awayTeamName,
            abbreviation: game.awayTeam?.abbrev,
          },
          score: game.awayTeam?.score,
        },
        home: {
          team: {
            id: game.homeTeam?.id,
            name: homeTeamName,
            abbreviation: game.homeTeam?.abbrev,
          },
          score: game.homeTeam?.score,
        },
      },
      venue: venueName ? {
        name: venueName,
      } : undefined,
      // Preserve additional fields
      ...game,
    };
  }

  /**
   * Construct full team name from placeName and commonName
   */
  private constructTeamName(team: any): string {
    if (!team) return '';
    
    const placeName = team.placeName?.default || '';
    const commonName = team.commonName?.default || '';
    
    if (placeName && commonName) {
      return `${placeName} ${commonName}`;
    }
    
    // Fallback to just placeName or commonName if one is missing
    return placeName || commonName || '';
  }

  /**
   * Map the new API gameState to abstractGameState
   */
  private mapGameState(gameState: string): string {
    const stateMap: Record<string, string> = {
      'FINAL': 'Final',
      'LIVE': 'Live',
      'PREVIEW': 'Preview',
      'OFF': 'Preview',
    };
    return stateMap[gameState] || 'Preview';
  }

  /**
   * Fetch games for multiple dates
   * @param dates - Array of dates in YYYY-MM-DD format
   * @returns Map of date to games array and array of failed dates
   */
  async getGamesByDates(dates: string[]): Promise<{ results: Map<string, NHLGame[]>, failedDates: string[] }> {
    const results = new Map<string, NHLGame[]>();
    const failedDates: string[] = [];
    
    // Fetch in parallel for better performance
    const promises = dates.map(async (date) => {
      try {
        const games = await this.getGamesByDate(date);
        return { date, games, success: true };
      } catch (error) {
        Logger.error(`Error fetching games for ${date}:`, error);
        return { date, games: [], success: false };
      }
    });

    const responses = await Promise.allSettled(promises);
    
    responses.forEach((response) => {
      if (response.status === 'fulfilled') {
        const { date, games, success } = response.value;
        results.set(date, games);
        if (!success) {
          failedDates.push(date);
        }
      } else {
        // This shouldn't happen since we catch errors, but handle it anyway
        Logger.error(`Unexpected error for date:`, response.reason);
      }
    });

    return { results, failedDates };
  }

  /**
   * Get dates for the last N days
   * @param days - Number of days to go back
   * @returns Array of date strings in YYYY-MM-DD format
   */
  static getLastNDays(days: number): string[] {
    const dates: string[] = [];
    const today = new Date();
    
    for (let i = 0; i < days; i++) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      dates.push(date.toISOString().split('T')[0]);
    }
    
    return dates;
  }
}

