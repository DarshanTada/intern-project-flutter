/// Firestore service for real-time data access
library;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../models/team_stats.dart';

class FirestoreService {
  FirebaseFirestore get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore not initialized: $e');
      rethrow;
    }
  }

  /// Stream of today's games, sorted by start time
  /// Includes games that start today or tomorrow (to catch games starting at midnight UTC)
  Stream<List<Game>> getTodaysGamesStream() {
    final today = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(today.year, today.month, today.day);
    // Include next day to catch games starting at midnight UTC
    final endOfDay = startOfDay.add(const Duration(days: 2));

    final startStr = startOfDay.toIso8601String();
    final endStr = endOfDay.toIso8601String();
    
    debugPrint('🔍 Querying games: $startStr to $endStr');

    return _firestore
        .collection('games')
        .where('startTime', isGreaterThanOrEqualTo: startStr)
        .where('startTime', isLessThan: endStr)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      debugPrint('📊 Firestore returned ${snapshot.docs.length} documents');
      final games = snapshot.docs
        .map((doc) {
            try {
              final game = Game.fromFirestore(doc.data(), doc.id);
              debugPrint('✅ Parsed game: ${game.gameId} - ${game.awayTeam.name} @ ${game.homeTeam.name}');
              return game;
            } catch (e) {
              debugPrint('❌ Error parsing game: $e');
              return null;
            }
          })
          .where((game) => game != null)
          .cast<Game>()
          .toList();
      // Sort by start time as a fallback
      games.sort((a, b) => a.startTime.compareTo(b.startTime));
      debugPrint('🎮 Returning ${games.length} games');
      return games;
    });
  }

  /// Stream of games filtered by status
  /// Includes games that start today or tomorrow (to catch games starting at midnight UTC)
  Stream<List<Game>> getGamesByStatusStream(String status) {
    final today = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(today.year, today.month, today.day);
    // Include next day to catch games starting at midnight UTC
    final endOfDay = startOfDay.add(const Duration(days: 2));

    // Fetch all today's games and filter by status in memory to avoid composite index requirement
    return _firestore
        .collection('games')
        .where('startTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('startTime', isLessThan: endOfDay.toIso8601String())
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      final games = snapshot.docs
          .map((doc) {
            try {
              return Game.fromFirestore(doc.data(), doc.id);
            } catch (e) {
              return null;
            }
          })
          .where((game) {
            if (game == null) return false;
            // Handle legacy status values
            final gameStatus = game.status.toLowerCase();
            final filterStatus = status.toLowerCase();
            
            // Map legacy "ok" status to "scheduled"
            if (gameStatus == 'ok' && filterStatus == 'scheduled') {
              return true;
            }
            
            return gameStatus == filterStatus;
          })
          .cast<Game>()
          .toList();
      // Already sorted by startTime from query
      return games;
    });
  }

  /// Get a single game by ID
  Stream<Game?> getGameStream(int gameId) {
    return _firestore
        .collection('games')
        .doc(gameId.toString())
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Game.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Get team statistics
  Future<TeamStats?> getTeamStats(int teamId) async {
    try {
      final doc = await _firestore
          .collection('teamStats')
          .doc(teamId.toString())
          .get();

      if (!doc.exists) return null;
      return TeamStats.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  /// Stream of team statistics
  Stream<TeamStats?> getTeamStatsStream(int teamId) {
    return _firestore
        .collection('teamStats')
        .doc(teamId.toString())
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return TeamStats.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Get last N games for a team
  /// Includes all games (final, live, scheduled) for the team
  Stream<List<Game>> getTeamGamesStream(int teamId, {int limit = 5}) {
    // Firestore doesn't support OR queries, so we fetch all games and filter
    // Get recent games (last 30 days) to include both final and upcoming games
    final cutoffDate = DateTime.now().toUtc().subtract(const Duration(days: 30));
    
    return _firestore
        .collection('games')
        .where('startTime', isGreaterThanOrEqualTo: cutoffDate.toIso8601String())
        .orderBy('startTime', descending: true)
        .limit(limit * 3) // Fetch more to account for filtering
        .snapshots()
        .map((snapshot) {
      final games = snapshot.docs
          .map((doc) {
            try {
              return Game.fromFirestore(doc.data(), doc.id);
            } catch (e) {
              debugPrint('Error parsing team game: $e');
              return null;
            }
          })
          .where((game) => 
              game != null && 
              (game.homeTeam.id == teamId || game.awayTeam.id == teamId))
          .cast<Game>()
          .take(limit)
          .toList();
      debugPrint('📊 Team $teamId: Found ${games.length} games');
      return games;
    });
  }

  /// Get all games for a team (for calculating stats)
  Future<List<Game>> getTeamAllGames(int teamId) async {
    try {
      // Get games where team is home
      final homeGames = await _firestore
          .collection('games')
          .where('homeTeam.id', isEqualTo: teamId)
          .where('status', isEqualTo: 'final')
          .get();

      // Get games where team is away
      final awayGames = await _firestore
          .collection('games')
          .where('awayTeam.id', isEqualTo: teamId)
          .where('status', isEqualTo: 'final')
          .get();

      final allGames = <Game>[];
      allGames.addAll(homeGames.docs
          .map((doc) => Game.fromFirestore(doc.data(), doc.id)));
      allGames.addAll(awayGames.docs
          .map((doc) => Game.fromFirestore(doc.data(), doc.id)));

      // Sort by start time descending
      allGames.sort((a, b) => b.startTime.compareTo(a.startTime));

      return allGames;
    } catch (e) {
      return [];
    }
  }
}

