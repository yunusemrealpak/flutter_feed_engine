import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feed_engine/core/cache/feed_image_cache_manager.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/feed_post.dart';
import 'package:flutter_feed_engine/features/feed/domain/entities/media_type.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:flutter_feed_engine/features/feed/presentation/bloc/feed_event.dart';
import 'package:flutter_feed_engine/features/feed/presentation/managers/video_player_pool.dart';
import 'package:flutter_feed_engine/features/feed/presentation/widgets/feed_image_widget.dart';
import 'package:flutter_feed_engine/features/feed/presentation/widgets/feed_video_widget.dart';

/// Post kartı container.
///
/// Profil resmi, kullanıcı adı, medya (image/video), like butonu + sayacı,
/// caption ve zaman damgasını gösterir.
class FeedPostCard extends StatelessWidget {
  final FeedPost post;
  final bool isVideoActive;
  final VideoPlayerPool videoPlayerPool;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.isVideoActive,
    required this.videoPlayerPool,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: avatar + username
        _PostHeader(post: post),

        // Media
        if (post.mediaType == MediaType.image)
          FeedImageWidget(imageUrl: post.mediaUrl)
        else
          FeedVideoWidget(
            postId: post.id,
            videoUrl: post.mediaUrl,
            thumbnailUrl: post.thumbnailUrl,
            isActive: isVideoActive,
            videoPlayerPool: videoPlayerPool,
          ),

        // Action bar: like butonu
        _ActionBar(post: post),

        // Caption
        if (post.caption != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: post.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),

        // Zaman damgası
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            _formatTimeAgo(post.createdAt),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}g önce';
    if (diff.inHours > 0) return '${diff.inHours}s önce';
    if (diff.inMinutes > 0) return '${diff.inMinutes}dk önce';
    return 'Az önce';
  }
}

class _PostHeader extends StatelessWidget {
  final FeedPost post;

  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade300,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl:
                    'https://picsum.photos/seed/${post.userId}/100/100',
                cacheManager: AvatarCacheManager(),
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Username
          Text(
            post.userName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatefulWidget {
  final FeedPost post;

  const _ActionBar({required this.post});

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Like butonu — animasyonlu
          GestureDetector(
            onTap: () {
              context
                  .read<FeedBloc>()
                  .add(FeedLikeToggled(postId: widget.post.id));
              _animController.forward(from: 0);
            },
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                widget.post.isLikedByMe
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: widget.post.isLikedByMe ? Colors.red : Colors.black,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Like sayısı
          Text(
            _formatCount(widget.post.likeCount),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
