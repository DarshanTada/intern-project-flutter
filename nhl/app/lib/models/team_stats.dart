/// Team statistics model
class TeamStats {
  final int teamId;
  final String teamName;
  final int wins;
  final int losses;
  final int? ot;
  final int? points;
  final String? logoUrl; // Team logo URL from NHL API
  final DateTime lastUpdated;

  TeamStats({
    required this.teamId,
    required this.teamName,
    required this.wins,
    required this.losses,
    this.ot,
    this.points,
    this.logoUrl,
    required this.lastUpdated,
  });

  factory TeamStats.fromFirestore(Map<String, dynamic> data, String id) {
    return TeamStats(
      teamId: data['teamId'] as int? ?? int.tryParse(id) ?? 0,
      teamName: data['teamName'] as String? ?? 'Unknown',
      wins: data['wins'] as int? ?? 0,
      losses: data['losses'] as int? ?? 0,
      ot: data['ot'] as int?,
      points: data['points'] as int?,
      logoUrl: data['logoUrl'] as String?,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.tryParse(data['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'wins': wins,
      'losses': losses,
      'ot': ot,
      'points': points,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  int get totalGames => wins + losses + (ot ?? 0);
  double get winPercentage => totalGames > 0 ? wins / totalGames : 0.0;
  String get record => '$wins-$losses${ot != null && ot! > 0 ? '-$ot' : ''}';
}
