// lib/services/blog_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/blog_post.dart';
import '../models/comment.dart';

class BlogService {
  List<BlogPost>? _cachedPosts;

  Future<List<BlogPost>> _loadPosts() async {
    if (_cachedPosts != null) {
      return _cachedPosts!;
    }

    try {
      // Load Json data from assets
      final jsonString = await rootBundle.loadString('assets/data/blog_posts.json');
      final jsonData = json.decode(jsonString);

      _cachedPosts = (jsonData['posts'] as List).map((postJson) {
        return BlogPost(
          id: postJson['id'],
          title: postJson['title'],
          author: postJson['author'],
          likes: postJson['likes'],
          imageUrl: postJson['imageUrl'],
          content: postJson['content'],
          publishDate: DateTime.parse(postJson['publishDate']),
          comments: (postJson['comments'] as List).map((commentJson) =>
              _parseComment(commentJson)
          ).toList(),
        );
      }).toList();

      return _cachedPosts!;
    } catch (e) {
      print('Error loading blog posts: $e');
      throw Exception('Failed to load blog posts');
    }
  }

  Comment _parseComment(Map<String, dynamic> commentJson) {
    return Comment(
      id: commentJson['id'],
      userId: commentJson['userId'],
      userName: commentJson['userName'],
      userAvatar: commentJson['userAvatar'],
      content: commentJson['content'],
      createdAt: DateTime.parse(commentJson['createdAt']),
      likes: commentJson['likes'],
      replies: commentJson['replies'] != null
          ? (commentJson['replies'] as List)
          .map((replyJson) => _parseComment(replyJson))
          .toList()
          : [],
    );
  }

  Future<List<BlogPost>> fetchInitialPosts() async {
    await Future.delayed(const Duration(seconds: 1));
    final posts = await _loadPosts();
    return posts.take(10).toList();
  }

  Future<List<BlogPost>> refreshPosts() async {
    await Future.delayed(const Duration(seconds: 1));
    final posts = await _loadPosts();
    return posts.take(10).toList();
  }

  Future<List<BlogPost>> fetchMorePosts(int offset) async {
    await Future.delayed(const Duration(seconds: 1));
    final posts = await _loadPosts();
    final end = (offset + 5).clamp(0, posts.length);
    return posts.sublist(offset, end);
  }

  Future<List<Comment>> fetchComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final posts = await _loadPosts();
    final post = posts.firstWhere((post) => post.id == postId);
    return post.comments;
  }

  Future<List<Comment>> fetchMoreComments(String postId, int offset) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [];
  }
}