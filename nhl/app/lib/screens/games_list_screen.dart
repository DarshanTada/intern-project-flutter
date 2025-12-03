/// Games list screen showing today's games
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';
import '../widgets/game_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import 'game_detail_screen.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _filterStatus; // null = all, 'live' = live only, etc.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NHL Scores'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Games')),
              const PopupMenuItem(value: 'live', child: Text('Live Only')),
              const PopupMenuItem(value: 'scheduled', child: Text('Scheduled')),
              const PopupMenuItem(value: 'final', child: Text('Final')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Game>>(
        stream: _filterStatus == null
            ? _firestoreService.getTodaysGamesStream()
            : _firestoreService.getGamesByStatusStream(_filterStatus!),
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
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No games today',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return GameCard(
                  game: game,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailScreen(gameId: game.gameId),
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

