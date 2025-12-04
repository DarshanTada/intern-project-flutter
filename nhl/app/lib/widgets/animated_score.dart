/// Animated score widget that pulses when score changes
library;
import 'package:flutter/material.dart';

class AnimatedScore extends StatefulWidget {
  final int? score;
  final TextStyle? style;
  final bool isLive;

  const AnimatedScore({
    super.key,
    required this.score,
    this.style,
    this.isLive = false,
  });

  @override
  State<AnimatedScore> createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<AnimatedScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score && widget.score != null) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For null scores, show "-" instead of "N/A"
    final scoreText = widget.score != null ? widget.score.toString() : '-';
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            scoreText,
            style: widget.style?.copyWith(
              color: widget.isLive && widget.score != null
                  ? Colors.red
                  : widget.style?.color,
            ) ?? const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

