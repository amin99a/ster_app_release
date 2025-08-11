import 'package:flutter/material.dart';

class TransitionService {
  static final TransitionService _instance = TransitionService._internal();
  factory TransitionService() => _instance;
  TransitionService._internal();

  // Slide transition from bottom
  static PageRouteBuilder slideFromBottom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Slide transition from right
  static PageRouteBuilder slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Slide transition from left
  static PageRouteBuilder slideFromLeft(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Fade transition
  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  // Scale transition
  static PageRouteBuilder scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);
        return ScaleTransition(scale: scaleAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Hero transition with custom curve
  static PageRouteBuilder heroTransition(Widget page, {String? heroTag}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Custom transition with multiple effects
  static PageRouteBuilder customTransition(
    Widget page, {
    Offset begin = const Offset(0.0, 1.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeInOutCubic,
    Duration duration = const Duration(milliseconds: 300),
    bool enableFade = true,
    bool enableScale = false,
    double scaleBegin = 0.8,
    double scaleEnd = 1.0,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Widget transitionChild = child;

        // Add slide transition
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        transitionChild = SlideTransition(position: offsetAnimation, child: transitionChild);

        // Add fade transition
        if (enableFade) {
          transitionChild = FadeTransition(opacity: animation, child: transitionChild);
        }

        // Add scale transition
        if (enableScale) {
          var scaleTween = Tween(begin: scaleBegin, end: scaleEnd).chain(CurveTween(curve: curve));
          var scaleAnimation = animation.drive(scaleTween);
          transitionChild = ScaleTransition(scale: scaleAnimation, child: transitionChild);
        }

        return transitionChild;
      },
      transitionDuration: duration,
    );
  }

  // Modal bottom sheet transition
  static PageRouteBuilder modalBottomSheet(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
      barrierColor: Colors.black54,
      barrierDismissible: true,
    );
  }

  // Card flip transition
  static PageRouteBuilder cardFlipTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(animation.value * 3.14159),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  // Elastic transition
  static PageRouteBuilder elasticTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.elasticOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }

  // Bounce transition
  static PageRouteBuilder bounceTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.bounceOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  // Zoom transition
  static PageRouteBuilder zoomTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);
        
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Navigate with transition
  static Future<T?> navigateWithTransition<T extends Object?>(
    BuildContext context,
    Widget page, {
    TransitionType transitionType = TransitionType.slideFromBottom,
    Duration? duration,
    bool fullscreenDialog = false,
  }) {
    PageRoute<T> route;
    
    switch (transitionType) {
      case TransitionType.slideFromBottom:
        route = slideFromBottom(page) as PageRoute<T>;
        break;
      case TransitionType.slideFromRight:
        route = slideFromRight(page) as PageRoute<T>;
        break;
      case TransitionType.slideFromLeft:
        route = slideFromLeft(page) as PageRoute<T>;
        break;
      case TransitionType.fade:
        route = fadeTransition(page) as PageRoute<T>;
        break;
      case TransitionType.scale:
        route = scaleTransition(page) as PageRoute<T>;
        break;
      case TransitionType.hero:
        route = heroTransition(page) as PageRoute<T>;
        break;
      case TransitionType.modalBottomSheet:
        route = modalBottomSheet(page) as PageRoute<T>;
        break;
      case TransitionType.cardFlip:
        route = cardFlipTransition(page) as PageRoute<T>;
        break;
      case TransitionType.elastic:
        route = elasticTransition(page) as PageRoute<T>;
        break;
      case TransitionType.bounce:
        route = bounceTransition(page) as PageRoute<T>;
        break;
      case TransitionType.zoom:
        route = zoomTransition(page) as PageRoute<T>;
        break;
    }

    return Navigator.of(context).push<T>(route);
  }

  // Animated widget transitions
  static Widget animatedContainer({
    required Widget child,
    required bool isVisible,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Offset? slideOffset,
    double? scale,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: duration,
        child: slideOffset != null
            ? AnimatedSlide(
                offset: isVisible ? Offset.zero : slideOffset,
                duration: duration,
                child: scale != null
                    ? AnimatedScale(
                        scale: isVisible ? 1.0 : scale,
                        duration: duration,
                        child: child,
                      )
                    : child,
              )
            : scale != null
                ? AnimatedScale(
                    scale: isVisible ? 1.0 : scale,
                    duration: duration,
                    child: child,
                  )
                : child,
      ),
    );
  }

  // Staggered animation for lists
  static List<Animation<double>> createStaggeredAnimations(
    AnimationController controller,
    int itemCount, {
    Duration interval = const Duration(milliseconds: 100),
  }) {
    final animations = <Animation<double>>[];
    
    for (int i = 0; i < itemCount; i++) {
      final delay = i * interval.inMilliseconds;
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            delay / controller.duration!.inMilliseconds,
            (delay + interval.inMilliseconds) / controller.duration!.inMilliseconds,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
      animations.add(animation);
    }
    
    return animations;
  }
}

enum TransitionType {
  slideFromBottom,
  slideFromRight,
  slideFromLeft,
  fade,
  scale,
  hero,
  modalBottomSheet,
  cardFlip,
  elastic,
  bounce,
  zoom,
}