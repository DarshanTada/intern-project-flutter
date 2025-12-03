/// Firestore service for real-time data access
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
  Stream<List<Game>> getTodaysGamesStream() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

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
              // Gracefully handle malformed data
              return null;
            }
          })
          .where((game) => game != null)
          .cast<Game>()
          .toList();
      // Sort by start time as a fallback
      games.sort((a, b) => a.startTime.compareTo(b.startTime));
      return games;
    });
  }

  /// Stream of games filtered by status
  Stream<List<Game>> getGamesByStatusStream(String status) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

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
          .where((game) => game != null && game.status == status)
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
  Stream<List<Game>> getTeamGamesStream(int teamId, {int limit = 5}) {
    // Firestore doesn't support OR queries, so we need to fetch more and filter
    // In production, you might want to maintain a separate collection for team games
    return _firestore
        .collection('games')
        .where('status', isEqualTo: 'final')
        .orderBy('startTime', descending: true)
        .limit(limit * 2) // Fetch more to account for filtering
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
          .where((game) => 
              game != null && 
              (game.homeTeam.id == teamId || game.awayTeam.id == teamId))
          .cast<Game>()
          .take(limit)
          .toList();
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

