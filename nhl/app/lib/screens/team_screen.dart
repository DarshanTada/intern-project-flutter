/// Team screen showing team information and recent games
import 'package:flutter/material.dart';
import '../models/team_stats.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';

class TeamScreen extends StatelessWidget {
  final int teamId;

  const TeamScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
      ),
      body: StreamBuilder<TeamStats?>(
        stream: firestoreService.getTeamStatsStream(teamId),
        builder: (context, statsSnapshot) {
          return StreamBuilder<List<Game>>(
            stream: firestoreService.getTeamGamesStream(teamId, limit: 5),
            builder: (context, gamesSnapshot) {
              if (statsSnapshot.connectionState == ConnectionState.waiting ||
                  gamesSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator(message: 'Loading team data...');
              }

              final stats = statsSnapshot.data;
              final games = gamesSnapshot.data ?? [];

              if (statsSnapshot.hasError || gamesSnapshot.hasError) {
                return ErrorMessage(
                  message: 'Error loading team data',
                  onRetry: () {},
                );
              }

              return _buildTeamContent(context, stats, games);
            },
          );
        },
      ),
    );
  }

  Widget _buildTeamContent(
    BuildContext context,
    TeamStats? stats,
    List<Game> games,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Team logo placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sports_hockey,
                      size: 40,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    stats?.teamName ?? 'Team $teamId',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Season record
          if (stats != null) ...[
            Text(
              'Season Record',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, 'Wins', stats.wins.toString()),
                    _buildStatItem(context, 'Losses', stats.losses.toString()),
                    if (stats.ot != null && stats.ot! > 0)
                      _buildStatItem(context, 'OT', stats.ot.toString()),
                    _buildStatItem(
                      context,
                      'Record',
                      stats.record,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Win %',
                      '${(stats.winPercentage * 100).toStringAsFixed(1)}%',
                    ),
                    _buildStatItem(
                      context,
                      'Total Games',
                      stats.totalGames.toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No season statistics available yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Recent games
          Text(
            'Recent Games',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (games.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No recent games found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ...games.map((game) => GameCard(
                  game: game,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailScreen(gameId: game.gameId),
                      ),
                    );
                  },
                )),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

