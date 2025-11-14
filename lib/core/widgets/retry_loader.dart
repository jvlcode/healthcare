import 'package:flutter/material.dart';

class RetryLoader extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final VoidCallback onRetry;
  final Widget child;

  const RetryLoader({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.child,
    this.errorMessage = "Something went wrong",
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      );
    }

    return child;
  }
}
