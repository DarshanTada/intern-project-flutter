/**
 * Firestore Data Model Types
 */

export interface FirestoreTeam {
  id: number;
  name: string;
  abbreviation?: string;
  teamName?: string;
  locationName?: string;
  logoUrl?: string;
}

export interface FirestoreGame {
  gameId: number;
  startTime: string; // ISO 8601 timestamp
  homeTeam: {
    id: number;
    name: string;
    score: number | null;
    logoUrl?: string;
  };
  awayTeam: {
    id: number;
    name: string;
    score: number | null;
    logoUrl?: string;
  };
  status: string; // "scheduled", "live", "final", etc.
  season?: string;
  gameType?: string;
  venue?: {
    id?: number;
    name?: string;
  };
  metadata?: {
    [key: string]: any; // Store any additional fields from NHL API
  };
  updatedAt: string; // ISO 8601 timestamp
  createdAt: string; // ISO 8601 timestamp
}

export interface FirestoreTeamStats {
  teamId: number;
  teamName: string;
  wins: number;
  losses: number;
  ot?: number;
  points?: number;
  logoUrl?: string; // Team logo URL from NHL API
  lastUpdated: string;
}

