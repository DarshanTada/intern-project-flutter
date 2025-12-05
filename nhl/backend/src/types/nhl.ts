/**
 * NHL API Response Types
 * Based on the NHL Stats API structure
 */

export interface NHLTeam {
  id: number;
  name: string;
  link?: string;
  abbreviation?: string;
  teamName?: string;
  locationName?: string;
  logoUrl?: string; // Logo URL from NHL API
}

export interface NHLTeamScore {
  team: NHLTeam;
  score?: number;
  leagueRecord?: {
    wins: number;
    losses: number;
    ot?: number;
    type: string;
  };
}

export interface NHLGameStatus {
  abstractGameState: string; // "Live", "Final", "Preview"
  codedGameState: string;
  detailedState: string; // "Scheduled", "In Progress", "Final", etc.
  statusCode: string;
  startTimeTBD?: boolean;
}

export interface NHLVenue {
  id?: number;
  name?: string;
  link?: string;
}

export interface NHLGame {
  gamePk: number; // This is the gameId
  gameType: string;
  season: string;
  gameDate: string; // ISO 8601 format
  status: NHLGameStatus;
  teams: {
    away: NHLTeamScore;
    home: NHLTeamScore;
  };
  venue?: NHLVenue;
  linescore?: any;
  liveData?: any;
  [key: string]: any; // Allow additional fields for schema flexibility
}

export interface NHLScheduleResponse {
  copyright: string;
  totalItems: number;
  totalEvents: number;
  totalGames: number;
  totalMatches: number;
  wait: number;
  dates: Array<{
    date: string;
    totalItems: number;
    totalEvents: number;
    totalGames: number;
    totalMatches: number;
    games: NHLGame[];
    events: any[];
    matches: any[];
  }>;
}

