import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/app/session/reachability_controller.dart';

class ServerGuard extends StatelessWidget {
  final Widget child;

  const ServerGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final reachable = context.watch<ReachabilityController>().isServerReachable;

    if (!reachable) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6FAF9),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "Server not reachable",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
