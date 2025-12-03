/// Game detail screen showing all game information
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
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
            return const ErrorMessage(
              message: 'Game not found',
            );
          }

          final game = snapshot.data!;
          return _buildGameDetails(context, game);
        },
      ),
    );
  }

  Widget _buildGameDetails(BuildContext context, Game game) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildTeamRow(
                    context,
                    game.awayTeam,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamScreen(teamId: game.awayTeam.id),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildTeamRow(
                    context,
                    game.homeTeam,
                    isHome: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamScreen(teamId: game.homeTeam.id),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status
          _buildInfoRow('Status', game.statusDisplay, theme),
          const SizedBox(height: 8),

          // Start time
          _buildInfoRow(
            'Start Time',
            _formatDateTime(game.startTime),
            theme,
          ),
          const SizedBox(height: 8),

          // Venue
          if (game.venue?.name != null)
            _buildInfoRow('Venue', game.venue!.name!, theme),
          if (game.venue?.name != null) const SizedBox(height: 8),

          // Season
          if (game.season != null)
            _buildInfoRow('Season', game.season!, theme),
          if (game.season != null) const SizedBox(height: 8),

          // Game type
          if (game.gameType != null)
            _buildInfoRow('Game Type', game.gameType!, theme),
          if (game.gameType != null) const SizedBox(height: 8),

          // Updated at
          _buildInfoRow(
            'Last Updated',
            _formatDateTime(game.updatedAt),
            theme,
          ),

          // Metadata section (if exists)
          if (game.metadata != null && game.metadata!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Additional Information',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: game.metadata!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _buildInfoRow(
                        entry.key,
                        entry.value.toString(),
                        theme,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamRow(
    BuildContext context,
    TeamScore team, {
    bool isHome = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          if (isHome)
            Icon(Icons.home, color: theme.primaryColor),
          if (isHome) const SizedBox(width: 8),
          Expanded(
            child: Text(
              team.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            team.score?.toString() ?? 'N/A',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
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

