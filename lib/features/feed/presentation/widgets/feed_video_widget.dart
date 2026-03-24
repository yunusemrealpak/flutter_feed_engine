import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_event.dart';
import 'package:flutter_feed_engine/features/feed/presentation/managers/video_player_pool.dart';
import 'package:flutter_feed_engine/features/feed/presentation/widgets/feed_image_widget.dart';
import 'package:flutter_feed_engine/features/feed/presentation/widgets/video_progress_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Video player widget — VisibilityDetector ile sarılmış.
///
/// Görünürlük değiştiğinde BLoC'a event gönderir. Aktifse video oynatır,
/// değilse thumbnail gösterir. Üzerinde mute/unmute toggle butonu bulunur.
class FeedVideoWidget extends StatefulWidget {
  final String postId;
  final String videoUrl;
  final String thumbnailUrl;
  final bool isActive;
  final VideoPlayerPool videoPlayerPool;

  const FeedVideoWidget({
    super.key,
    required this.postId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isActive,
    required this.videoPlayerPool,
  });

  @override
  State<FeedVideoWidget> createState() => _FeedVideoWidgetState();
}

class _FeedVideoWidgetState extends State<FeedVideoWidget> {
  bool _isMuted = false;

  @override
  void didUpdateWidget(covariant FeedVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      // Aktif oldu — play başlat
      widget.videoPlayerPool.setActive(widget.postId);
      _isMuted = false;
    } else if (!widget.isActive && oldWidget.isActive) {
      // Deaktif oldu — pool zaten pause eder
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video_${widget.postId}'),
      onVisibilityChanged: (info) {
        context.read<FeedBloc>().add(
              FeedVideoVisibilityChanged(
                postId: widget.postId,
                visibilityFraction: info.visibleFraction,
              ),
            );
      },
      child: AspectRatio(
        aspectRatio: 1, // 1:1 kare format (Instagram tarzı)
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video veya thumbnail
            _buildMedia(),

            // Mute/unmute butonu (sadece aktifken)
            if (widget.isActive)
              Positioned(
                right: 12,
                bottom: 20,
                child: _MuteButton(
                  isMuted: _isMuted,
                  onToggle: _toggleMute,
                ),
              ),

            // Video yüklenirken loading indicator
            if (widget.isActive && !_isControllerReady)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),

            // Progress bar (altta)
            if (widget.isActive && _isControllerReady)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoProgressIndicatorBar(
                  controller:
                      widget.videoPlayerPool.getController(widget.postId)!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.isActive && _isControllerReady) {
      final controller =
          widget.videoPlayerPool.getController(widget.postId)!;
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }

    // Aktif değilse veya controller hazır değilse thumbnail göster
    return FeedImageWidget(
      imageUrl: widget.thumbnailUrl,
      fit: BoxFit.cover,
    );
  }

  bool get _isControllerReady =>
      widget.videoPlayerPool.isReady(widget.postId);

  void _toggleMute() {
    final controller =
        widget.videoPlayerPool.getController(widget.postId);
    if (controller == null) return;

    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0 : 1);
    });
  }
}

class _MuteButton extends StatelessWidget {
  final bool isMuted;
  final VoidCallback onToggle;

  const _MuteButton({required this.isMuted, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isMuted ? Icons.volume_off : Icons.volume_up,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
