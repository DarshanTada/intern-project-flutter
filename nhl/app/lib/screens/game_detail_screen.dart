/// Game detail screen showing all game information
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../widgets/animated_score.dart';
import '../widgets/page_transitions.dart';
import '../theme/nhl_theme.dart';
import 'team_screen.dart';

class GameDetailScreen extends StatelessWidget {
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<Game?>(
        stream: firestoreService.getGameStream(gameId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading game...');
          }

          if (snapshot.hasError) {
            return ErrorMessage(
              message: 'Error loading game: ${snapshot.error}',
              onRetry: () {},
            );
          }

          if (!snapshot.hasData) {
            return const ErrorMessage(message: 'Game not found');
          }

          final game = snapshot.data!;
          return _buildGameDetails(context, game);
        },
      ),
    );
  }

  Widget _buildGameDetails(BuildContext context, Game game) {
    final theme = Theme.of(context);
    final isLive = game.isLive;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score section
          Card(
                elevation: isLive ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: isLive
                      ? const BorderSide(color: NHLTheme.nhlRed, width: 2)
                      : BorderSide.none,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isLive
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              NHLTheme.nhlDarkGray,
                              NHLTheme.nhlDarkGray.withOpacity(0.8),
                            ],
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildTeamRow(
                            context,
                            game.awayTeam,
                            isLive: isLive,
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: TeamScreen(teamId: game.awayTeam.id),
                                  direction: SlideDirection.right,
                                ),
                              );
                            },
                          )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 24),
                      Divider(
                        color: NHLTheme.nhlLightGray.withOpacity(0.3),
                        height: 1,
                      ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                      const SizedBox(height: 24),
                      _buildTeamRow(
                            context,
                            game.homeTeam,
                            isHome: true,
                            isLive: isLive,
                            onTap: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: TeamScreen(teamId: game.homeTeam.id),
                                  direction: SlideDirection.right,
                                ),
                              );
                            },
                          )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .slideX(begin: -0.1, end: 0),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 50.ms, duration: 500.ms)
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                curve: Curves.easeOutCubic,
              ),
          const SizedBox(height: 20),

          // Game Info Card
          Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Status',
                        game.statusDisplay,
                        theme,
                        isLive: isLive,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Start Time',
                        _formatDateTime(game.startTime),
                        theme,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Venue', game.venue?.name ?? 'NA', theme),
                      const SizedBox(height: 16),
                      _buildInfoRow('Season', game.season ?? 'NA', theme),
                      const SizedBox(height: 16),
                      _buildInfoRow('Game Type', game.gameType ?? 'NA', theme),
                      const SizedBox(height: 16),
                      _buildInfoRow('Game ID', game.gameId.toString(), theme),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildTeamRow(
    BuildContext context,
    TeamScore team, {
    bool isHome = false,
    bool isLive = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final hasScore = team.score != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              if (isHome)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: NHLTheme.nhlLightBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.home,
                    color: NHLTheme.nhlLightBlue,
                    size: 20,
                  ),
                ),
              if (isHome) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  team.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              // Only show score if it exists, otherwise show nothing for scheduled games
              if (hasScore)
                AnimatedScore(
                  score: team.score,
                  isLive: isLive,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                )
              else if (isLive)
                // For live games without score yet, show "-"
                Text(
                  '-',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.white60,
                  ),
                ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right, color: Colors.white60, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme, {
    bool isLive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: isLive && label == 'Status'
                  ? NHLTheme.nhlRed
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
