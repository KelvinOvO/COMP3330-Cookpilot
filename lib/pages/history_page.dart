import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/history_service.dart';
import '../models/blog_post.dart';
import './blog_post_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewedPosts = Provider.of<HistoryService>(context).viewedPosts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF6F6F6), Colors.white],
            ),
          ),
        ),
        title: Text(
          'History',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF6F6F6), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Viewed Posts History',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (viewedPosts.isEmpty)
                    const Center(
                      child: Text(
                        'No viewed posts yet.',
                        style: TextStyle(color: Color(0xFF999999)),
                      ),
                    )
                  else
                    Column(
                      children: viewedPosts.map((post) => _buildHistoryItem(context, post)).toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, BlogPost post) {
    return ListTile(
      title: Text(post.title),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlogPostDetailPage(post: post),
        ),
      ),
    );
  }
}