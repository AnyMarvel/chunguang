import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyRouterEnterDirRightToLft implements CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeInOut;

    var moveTween = Tween(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).chain(
      CurveTween(curve: curve),
    );

    var opacityTween = Tween(
      begin: 0.0,
      end: 1.0,
    ).chain(
      CurveTween(curve: curve),
    );

    return Stack(
      children: [
        FadeTransition(
          opacity: animation.drive(opacityTween),
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.7),
          ),
        ),
        SlideTransition(
          position: animation.drive(moveTween),
          child: child,
        ),
      ],
    );
  }
}

class MyRouterEnterDirBottomToTop implements CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeInOut;

    var moveTween = Tween(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).chain(
      CurveTween(curve: curve),
    );

    var opacityTween = Tween(
      begin: 0.0,
      end: 1.0,
    ).chain(
      CurveTween(curve: curve),
    );

    return Stack(
      children: [
        FadeTransition(
          opacity: animation.drive(opacityTween),
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.7),
          ),
        ),
        SlideTransition(
          position: animation.drive(moveTween),
          child: child,
        ),
      ],
    );
  }
}
