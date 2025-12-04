/// Custom page transitions for NHL app
library;
import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            Offset startOffset;
            switch (direction) {
              case SlideDirection.right:
                startOffset = const Offset(1.0, 0.0);
                break;
              case SlideDirection.left:
                startOffset = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.up:
                startOffset = const Offset(0.0, 1.0);
                break;
              case SlideDirection.down:
                startOffset = const Offset(0.0, -1.0);
                break;
            }

            var tween = Tween(begin: startOffset, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

enum SlideDirection {
  right,
  left,
  up,
  down,
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
}

