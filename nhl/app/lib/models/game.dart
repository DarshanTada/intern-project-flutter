/// Game data model matching Firestore structure
class Game {
  final int gameId;
  final DateTime startTime;
  final TeamScore homeTeam;
  final TeamScore awayTeam;
  final String status;
  final String? season;
  final String? gameType;
  final Venue? venue;
  final Map<String, dynamic>? metadata;
  final DateTime updatedAt;
  final DateTime createdAt;

  Game({
    required this.gameId,
    required this.startTime,
    required this.homeTeam,
    required this.awayTeam,
    required this.status,
    this.season,
    this.gameType,
    this.venue,
    this.metadata,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Game.fromFirestore(Map<String, dynamic> data, String id) {
    return Game(
      gameId: data['gameId'] as int? ?? int.tryParse(id) ?? 0,
      startTime: _parseDateTime(data['startTime']),
      homeTeam: TeamScore.fromMap(data['homeTeam'] as Map<String, dynamic>? ?? {}),
      awayTeam: TeamScore.fromMap(data['awayTeam'] as Map<String, dynamic>? ?? {}),
      status: data['status'] as String? ?? 'unknown',
      season: _parseString(data['season']),
      gameType: _parseString(data['gameType']),
      venue: data['venue'] != null ? Venue.fromMap(data['venue'] as Map<String, dynamic>) : null,
      metadata: data['metadata'] as Map<String, dynamic>?,
      updatedAt: _parseDateTime(data['updatedAt']),
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is num) return value.toString();
    return value.toString();
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'startTime': startTime.toIso8601String(),
      'homeTeam': homeTeam.toMap(),
      'awayTeam': awayTeam.toMap(),
      'status': status,
      'season': season,
      'gameType': gameType,
      'venue': venue?.toMap(),
      'metadata': metadata,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isLive => status == 'live';
  bool get isFinal => status == 'final';
  bool get isScheduled => status == 'scheduled';

  String get statusDisplay {
    switch (status) {
      case 'live':
        return 'Live';
      case 'final':
        return 'Final';
      case 'scheduled':
        return 'Scheduled';
      default:
        return status;
    }
  }
}

class TeamScore {
  final int id;
  final String name;
  final int? score;

  TeamScore({
    required this.id,
    required this.name,
    this.score,
  });

  factory TeamScore.fromMap(Map<String, dynamic> map) {
    return TeamScore(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? 'Unknown',
      score: map['score'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'score': score,
    };
  }
}

class Venue {
  final int? id;
  final String? name;

  Venue({this.id, this.name});

  factory Venue.fromMap(Map<String, dynamic> map) {
    return Venue(
      id: map['id'] as int?,
      name: map['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

