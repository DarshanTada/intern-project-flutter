/// Game card widget for displaying game information in list
import 'package:flutter/material.dart';
import '../models/game.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = game.isLive;
    final isFinal = game.isFinal;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(isLive, isFinal),
                  Text(
                    _formatTime(game.startTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Away team
              _buildTeamRow(
                context,
                game.awayTeam.name,
                game.awayTeam.score,
                isFinal || isLive,
              ),
              const SizedBox(height: 8),
              // Home team
              _buildTeamRow(
                context,
                game.homeTeam.name,
                game.homeTeam.score,
                isFinal || isLive,
                isHome: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isLive, bool isFinal) {
    Color color;
    String text;

    if (isLive) {
      color = Colors.red;
      text = 'LIVE';
    } else if (isFinal) {
      color = Colors.grey;
      text = 'FINAL';
    } else {
      color = Colors.blue;
      text = 'SCHEDULED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTeamRow(
    BuildContext context,
    String teamName,
    int? score,
    bool showScore, {
    bool isHome = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (isHome) ...[
          Icon(Icons.home, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            teamName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (showScore)
          Text(
            score?.toString() ?? 'N/A',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            _formatTime(game.startTime),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

