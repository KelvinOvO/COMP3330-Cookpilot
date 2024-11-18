// lib/widgets/recipe_card.dart
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'package:cached_network_image/cached_network_image.dart';


class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }

  Widget _buildImage() {
    // Check if the imageUrl starts with http or https
    bool isNetworkImage = recipe.imageUrl.startsWith('http://') || recipe.imageUrl.startsWith('https://');

    return Hero(
      tag: 'recipe_image_${recipe.id}',
      child: isNetworkImage
          ? CachedNetworkImage(
        imageUrl: recipe.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF999999)),
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
      )
          : Image.asset(
        recipe.imageUrl, // Assuming imageUrl is a valid asset path
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return Container(
            color: Colors.grey[100],
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFF999999),
            ),
          );
        },
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
            recipe.name,
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
              Expanded(
                child: Text(
                  recipe.author,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildLikesCounter(),
            ],
          ),
        ],
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
          _formatLikes(recipe.likes),
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