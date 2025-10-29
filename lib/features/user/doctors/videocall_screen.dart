import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMuted = false;
  bool isCameraOn = true;
  bool isSpeakerOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background (Doctor's Video)
          Positioned.fill(
            child: Image.network(
              "https://cdn-icons-png.flaticon.com/512/3774/3774299.png",
              fit: BoxFit.cover,
            ),
          ),

          // User’s small video preview (top-right)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white54, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/4140/4140048.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Floating call timer
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text("00:12", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),

          // Doctor info at bottom
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Logesh",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Psychology",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          // Control buttons
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlButton(
                  icon: isMuted ? Icons.mic_off : Icons.mic,
                  color: isMuted ? Colors.red : Colors.white,
                  onTap: () => setState(() => isMuted = !isMuted),
                ),
                const SizedBox(width: 20),
                _controlButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  size: 70,
                  onTap: () {
                    Navigator.pop(context);
                    GFToast.showToast(
                      "Call Ended",
                      context,
                      toastPosition: GFToastPosition.BOTTOM,
                    );
                  },
                ),
                const SizedBox(width: 20),
                _controlButton(
                  icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                  color: isCameraOn ? Colors.white : Colors.red,
                  onTap: () => setState(() => isCameraOn = !isCameraOn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    double size = 60,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
