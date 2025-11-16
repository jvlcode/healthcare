import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/app/session/reachability_controller.dart';

class ServerGuard extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRetry;

  const ServerGuard({super.key, required this.child, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final reachability = context.watch<ReachabilityController>();

    // 1) offline screen
    if (!reachability.isServerReachable) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Server unreachable",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await reachability.checkServer();
                  if (onRetry != null && reachability.isServerReachable) {
                    await onRetry!();
                  }
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // 2) normal content
    return child;
  }
}
