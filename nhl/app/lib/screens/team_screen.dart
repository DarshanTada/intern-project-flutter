/// Team screen showing team information and recent games
library;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/team_stats.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../widgets/game_card.dart';
import '../widgets/page_transitions.dart';
import '../theme/nhl_theme.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    NHLTheme.nhlLightBlue.withOpacity(0.2),
                    NHLTheme.nhlDarkGray,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Team logo placeholder
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: NHLTheme.nhlLightBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: NHLTheme.nhlLightBlue,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.sports_hockey,
                      size: 50,
                      color: NHLTheme.nhlLightBlue,
                    ),
                  )
                      .animate()
                      .scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut)
                      .shimmer(delay: 700.ms, duration: 1500.ms, color: NHLTheme.nhlLightBlue.withOpacity(0.3)),
                  const SizedBox(height: 20),
                  Text(
                    stats?.teamName ?? 'Team $teamId',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutCubic),
          const SizedBox(height: 20),

          // Season record
          if (stats != null) ...[
            Text(
              'Season Record',
              style: theme.textTheme.titleLarge,
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, 'Wins', stats.wins.toString(), 0),
                    _buildStatItem(context, 'Losses', stats.losses.toString(), 1),
                    if (stats.ot != null && stats.ot! > 0)
                      _buildStatItem(context, 'OT', stats.ot.toString(), 2),
                    _buildStatItem(context, 'Record', stats.record, 3),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms)
                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Win %',
                      '${(stats.winPercentage * 100).toStringAsFixed(1)}%',
                      0,
                    ),
                    _buildStatItem(
                      context,
                      'Total Games',
                      stats.totalGames.toString(),
                      1,
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 400.ms)
                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
            const SizedBox(height: 24),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: Colors.white60,
                    )
                        .animate()
                        .scale(delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    Text(
                      'No season statistics available yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Stats will appear after games are completed',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 400.ms),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
            const SizedBox(height: 24),
          ],

          // Recent games
          Text(
            'Recent Games',
            style: theme.textTheme.titleLarge,
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 400.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          if (games.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.white60,
                    )
                        .animate()
                        .scale(delay: 900.ms, duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    Text(
                      'No recent games found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 400.ms),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 900.ms, duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1))
          else
            ...games.asMap().entries.map((entry) {
              final index = entry.key;
              final game = entry.value;
              return GameCard(
                game: game,
                index: index,
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: GameDetailScreen(gameId: game.gameId),
                      direction: SlideDirection.right,
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, int index) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: NHLTheme.nhlLightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: NHLTheme.nhlLightBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: NHLTheme.nhlLightBlue,
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: 800 + index * 100))
            .scale(delay: 0.ms, duration: 400.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 300.ms),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        )
            .animate(delay: Duration(milliseconds: 900 + index * 100))
            .fadeIn(duration: 300.ms),
      ],
    );
  }
}

