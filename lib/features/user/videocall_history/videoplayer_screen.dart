import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String doctorName;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.doctorName,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() => isLoading = false);
        controller.play();
      });

    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Call - ${widget.doctorName}"),
        backgroundColor: const Color(0xFF01312F),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),

                // ---------------- Slider / Seekbar ----------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Slider(
                        value: controller.value.position.inSeconds.toDouble(),
                        min: 0,
                        max: controller.value.duration.inSeconds.toDouble(),
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          controller.seekTo(Duration(seconds: value.toInt()));
                        },
                      ),

                      // Time (current / total)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatTime(controller.value.position),
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Text(
                            formatTime(controller.value.duration),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.value.isPlaying ? controller.pause() : controller.play();
          setState(() {});
        },
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
