// lib/widgets/blog_post_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/blog_post.dart';

class BlogPostCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback? onTap;
  final double? height;

  const BlogPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              _buildContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: 'post_image_${post.id}',
      child: CachedNetworkImage(
        imageUrl: post.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF999999)),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[100],
          child: const Icon(
            Icons.error_outline,
            color: Color(0xFF999999),
          ),
        ),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        placeholderFadeInDuration: const Duration(milliseconds: 300),
        memCacheWidth: 800,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildAuthorAvatar(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post.author,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildLikesCounter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorAvatar() {
    return ClipOval(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CachedNetworkImage(
          imageUrl: 'https://i.pravatar.cc/100?u=${post.id}',  // unique post id
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[100],
            child: const Icon(
              Icons.person_outline,
              size: 16,
              color: Color(0xFF999999),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[100],
            child: const Icon(
              Icons.person_outline,
              size: 16,
              color: Color(0xFF999999),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikesCounter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.favorite_border,
          size: 16,
          color: Color(0xFF999999),
        ),
        const SizedBox(width: 4),
        Text(
          _formatLikes(post.likes),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF999999),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _formatLikes(int likes) {
    if (likes >= 10000) {
      return '${(likes / 1000).floor()}K+';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    }
    return likes.toString();
  }
}