import 'package:flutter/material.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:provider/provider.dart';

class NetworkAwareScaffold extends StatelessWidget {
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final Widget child;
  final Widget? floatingActionButton;

  const NetworkAwareScaffold({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final reachable = context.watch<ReachabilityController>().isServerReachable;

    Widget body;

    if (!reachable) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              "Server not reachable",
              style: TextStyle(color: Colors.grey),
            ),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      );
    } else if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = Center(
        child: Text(
          "Something went wrong",
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else {
      body = child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF9),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
