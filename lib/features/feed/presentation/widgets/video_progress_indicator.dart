import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Video'nun oynatma ilerlemesini gösteren ince progress bar.
class VideoProgressIndicatorBar extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoProgressIndicatorBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return VideoProgressIndicator(
      controller,
      allowScrubbing: false,
      padding: EdgeInsets.zero,
      colors: VideoProgressColors(
        playedColor: Colors.white,
        bufferedColor: Colors.white.withValues(alpha: 0.3),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }
}
