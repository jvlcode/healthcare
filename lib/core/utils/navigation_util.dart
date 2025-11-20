import 'package:flutter/material.dart';

enum SlideNavType { push, replace, pushAndRemoveUntil }

Future<dynamic> navigateSlideLeft(
  BuildContext context, {
  Widget? page,
  String? routeName,
  Object? arguments,
  SlideNavType type = SlideNavType.push,
  bool removeAllPrevious = false,
}) {
  if (page == null && routeName == null) {
    throw ArgumentError('Either page or routeName must be provided');
  }

  final route = page != null
      ? PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: Curves.easeInOut));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        )
      : null;

  switch (type) {
    case SlideNavType.push:
      if (page != null) return Navigator.push(context, route!);
      return Navigator.pushNamed(context, routeName!, arguments: arguments);

    case SlideNavType.replace:
      if (page != null) return Navigator.pushReplacement(context, route!);
      return Navigator.pushReplacementNamed(
        context,
        routeName!,
        arguments: arguments,
      );

    case SlideNavType.pushAndRemoveUntil:
      if (page != null) {
        return Navigator.pushAndRemoveUntil(
          context,
          route!,
          removeAllPrevious ? (_) => false : (route) => true,
        );
      } else {
        return Navigator.pushNamedAndRemoveUntil(
          context,
          routeName!,
          removeAllPrevious ? (_) => false : (route) => true,
          arguments: arguments,
        );
      }
  }
}
