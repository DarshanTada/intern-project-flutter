/**
 * NHL API Service
 * Handles fetching game data from the public NHL Stats API
 */

import axios, { AxiosInstance, AxiosError } from 'axios';
import { NHLScheduleResponse, NHLGame } from '../types/nhl';

export class NHLApiService {
  private client: AxiosInstance;
  private readonly baseUrl: string;

  constructor(baseUrl: string = 'https://statsapi.web.nhl.com/api/v1') {
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
   * Fetch games for a specific date
   * @param date - Date in YYYY-MM-DD format
   * @returns Array of games for that date
   */
  async getGamesByDate(date: string): Promise<NHLGame[]> {
    try {
      const response = await this.client.get<NHLScheduleResponse>('/schedule', {
        params: {
          date: date,
          expand: 'schedule.linescore', // Get score information
        },
      });

      if (!response.data || !response.data.dates || response.data.dates.length === 0) {
        return [];
      }

      // Return games from the first (and typically only) date in the response
      return response.data.dates[0]?.games || [];
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError;
        if (axiosError.response) {
          throw new Error(
            `NHL API error: ${axiosError.response.status} - ${axiosError.response.statusText}`
          );
        } else if (axiosError.request) {
          if (axiosError.code === 'ENOTFOUND' || axiosError.code === 'ECONNREFUSED') {
            throw new Error(`NHL API connection failed: ${axiosError.message}. Check your internet connection and DNS settings.`);
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
    const today = new Date().toISOString().split('T')[0];
    return this.getGamesByDate(today);
  }

  /**
   * Fetch games for multiple dates
   * @param dates - Array of dates in YYYY-MM-DD format
   * @returns Map of date to games array
   */
  async getGamesByDates(dates: string[]): Promise<Map<string, NHLGame[]>> {
    const results = new Map<string, NHLGame[]>();
    
    // Fetch in parallel for better performance
    const promises = dates.map(async (date) => {
      try {
        const games = await this.getGamesByDate(date);
        return { date, games };
      } catch (error) {
        console.error(`Error fetching games for ${date}:`, error);
        return { date, games: [] };
      }
    });

    const responses = await Promise.allSettled(promises);
    
    responses.forEach((response) => {
      if (response.status === 'fulfilled') {
        results.set(response.value.date, response.value.games);
      }
    });

    return results;
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

