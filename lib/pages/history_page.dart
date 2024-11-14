import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/history_service.dart';
import '../models/blog_post.dart';
import './blog_post_detail_page.dart';
import 'package:intl/intl.dart';

class SizeFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const SizeFadeTransition({Key? key, required this.animation, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1.0,
        child: child,
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryService>(
      builder: (context, historyService, child) {
        final viewedPosts = historyService.viewedPosts;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(context, historyService, viewedPosts.isNotEmpty),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF8F9FF),
                  Colors.white.withOpacity(0.95),
                ],
              ),
            ),
            child: SafeArea(
              child: viewedPosts.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(context, viewedPosts, historyService),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, HistoryService historyService, bool hasHistory) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F9FF),
              Colors.white.withOpacity(0.95),
            ],
          ),
        ),
      ),
      title: Text(
        'History',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      centerTitle: true,
      actions: [
        if (hasHistory)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF2C3E50)),
            onPressed: () => _showClearHistoryDialog(context, historyService),
          ),
      ],
    );
  }

  Widget _buildHistoryList(
      BuildContext context,
      List<BlogPost> posts,
      HistoryService historyService,
      ) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        return Dismissible(
          key: Key(post.id),
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(),
          onDismissed: (direction) {
            // Remove the post from history and update listeners
            historyService.removeFromHistory(post);

            // Optionally show a SnackBar with an Undo action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Post removed from history'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    historyService.addViewedPost(post);
                  },
                ),
              ),
            );
          },
          child: _buildHistoryItem(context, post),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.red.shade700),
          const SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(color: Colors.red.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, BlogPost post) {
    return Hero(
      tag: 'post_${post.id}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToDetail(context, post),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl,  // unique post id,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.content.length > 100
                            ? '${post.content.substring(0, 100)}...'
                            : post.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey[200],
                            child: CachedNetworkImage(
                              imageUrl: 'https://i.pravatar.cc/100?u=${post.id}',  // Unique post ID for avatar
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Text(
                                post.author[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                              ),
                              errorWidget: (context, url, error) => Text(
                                post.author[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post.author,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.red[300],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likes}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.comment,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.comments.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 160,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildEmptyState() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Reading History Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your reading history will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, BlogPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogPostDetailPage(post: post),
      ),
    );
  }

  Future<void> _showClearHistoryDialog(
      BuildContext context, HistoryService historyService) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Clear History'),
          content: const Text(
              'Are you sure you want to clear all your reading history?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                historyService.clearHistory();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}