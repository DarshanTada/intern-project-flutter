/// Game card widget for displaying game information in list
library;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game.dart';
import '../theme/nhl_theme.dart';
import 'animated_score.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final int index;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = game.isLive;
    final isFinal = game.isFinal;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isLive ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isLive
            ? const BorderSide(color: NHLTheme.nhlRed, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
          padding: const EdgeInsets.all(20),
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
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
                  .animate(delay: Duration(milliseconds: index * 50))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 16),
              // Away team name and score
              _buildTeamRow(
                context,
                game.awayTeam.name,
                game.awayTeam.score,
                isLive: isLive,
                isFinal: isFinal,
              )
                  .animate(delay: Duration(milliseconds: index * 50 + 50))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 12),
              // Divider
              Divider(
                color: NHLTheme.nhlLightGray.withOpacity(0.3),
                height: 1,
              )
                  .animate(delay: Duration(milliseconds: index * 50 + 100))
                  .fadeIn(duration: 200.ms),
              const SizedBox(height: 12),
              // Home team name and score
              _buildTeamRow(
                context,
                game.homeTeam.name,
                game.homeTeam.score,
                isHome: true,
                isLive: isLive,
                isFinal: isFinal,
              )
                  .animate(delay: Duration(milliseconds: index * 50 + 150))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: -0.1, end: 0),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic)
        .shimmer(
          delay: 200.ms,
          duration: 1000.ms,
          color: Colors.white.withOpacity(0.1),
        );
  }

  Widget _buildStatusChip(bool isLive, bool isFinal) {
    Color color;
    String text;
    Widget? pulseWidget;

    if (isLive) {
      color = NHLTheme.nhlRed;
      text = 'LIVE';
      pulseWidget = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(delay: 0.ms, duration: 1000.ms, begin: const Offset(1, 1), end: const Offset(1.5, 1.5))
          .then()
          .fadeOut(duration: 500.ms);
    } else if (isFinal) {
      color = Colors.grey;
      text = 'FINAL';
    } else {
      color = NHLTheme.nhlLightBlue;
      text = 'SCHEDULED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulseWidget != null) ...[
            pulseWidget,
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow(
    BuildContext context,
    String teamName,
    int? score, {
    bool isHome = false,
    bool isLive = false,
    bool isFinal = false,
  }) {
    final theme = Theme.of(context);
    final hasScore = score != null;
    
    return Row(
      children: [
        if (isHome) ...[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: NHLTheme.nhlLightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.home,
              size: 16,
              color: NHLTheme.nhlLightBlue,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            teamName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        // Always show score position as per PDF requirement
        // For scheduled games without scores, show "-"
        // For live/final games with scores, show animated score
        // For live/final games without scores yet, show "-"
        if (hasScore)
          AnimatedScore(
            score: score,
            isLive: isLive,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          )
        else
          // Show "-" for games without scores (scheduled or live/final without scores yet)
          Text(
            '-',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white60,
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

