import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class SafeAvatar extends StatefulWidget {
  final String? imageUrl;
  final File? localFile;
  final double size;

  const SafeAvatar({super.key, this.imageUrl, this.localFile, this.size = 60});

  @override
  State<SafeAvatar> createState() => _SafeAvatarState();
}

class _SafeAvatarState extends State<SafeAvatar> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      // ignore: unrelated_type_equality_checks
      _isOnline = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;

    Widget imageWidget;

    if (widget.localFile != null) {
      imageWidget = Image.file(
        widget.localFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (_isOnline && widget.imageUrl != null) {
      imageWidget = Image.network(
        widget.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/user_avatar.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/user_avatar.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return ClipOval(child: imageWidget);
  }
}
