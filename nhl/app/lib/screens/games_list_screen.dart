/// Games list screen showing today's games
library;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';
import '../widgets/game_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../widgets/page_transitions.dart';
import '../theme/nhl_theme.dart';
import 'game_detail_screen.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _filterStatus; // null = all, 'live' = live only, etc.

  // Get the appropriate stream based on filter
  Stream<List<Game>> _getGamesStream() {
    return _filterStatus == null
        ? _firestoreService.getTodaysGamesStream()
        : _firestoreService.getGamesByStatusStream(_filterStatus!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_hockey,
              color: NHLTheme.nhlLightBlue,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(delay: 0.ms, duration: 2000.ms, begin: 0, end: 0.1)
                .then()
                .rotate(delay: 0.ms, duration: 2000.ms, begin: 0.1, end: -0.1)
                .then()
                .rotate(delay: 0.ms, duration: 2000.ms, begin: -0.1, end: 0),
            const SizedBox(width: 12),
            const Text('NHL Scores'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              setState(() {
                _filterStatus = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 12),
                    Text('All Games'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'live',
                child: Row(
                  children: [
                    Icon(Icons.live_tv, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Live Only'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'scheduled',
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 20),
                    SizedBox(width: 12),
                    Text('Scheduled'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'final',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    SizedBox(width: 12),
                    Text('Final'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Game>>(
        stream: _getGamesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return ErrorMessage(
              message: 'Error loading games: ${snapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_hockey,
                    size: 80,
                    color: NHLTheme.nhlLightGray,
                  )
                      .animate()
                      .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
                      .shimmer(delay: 800.ms, duration: 1200.ms, color: NHLTheme.nhlLightBlue.withOpacity(0.3)),
                  const SizedBox(height: 24),
                  Text(
                    'No games today',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for upcoming games',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            );
          }

          final games = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              // Stream will automatically update
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: NHLTheme.nhlLightBlue,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
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
              },
            ),
          );
        },
      ),
    );
  }
}

