import 'package:flutter/material.dart';
import '../models/blog_post.dart';

class HistoryService extends ChangeNotifier {
  final List<BlogPost> _viewedPosts = [];

  List<BlogPost> get viewedPosts => List.unmodifiable(_viewedPosts);

  void addViewedPost(BlogPost post) {
    if (!_viewedPosts.any((p) => p.id == post.id)) {
      _viewedPosts.insert(0, post);
      notifyListeners();
    }
  }

  void addToHistory(BlogPost post) {
    addViewedPost(post);
  }


  void removeFromHistory(BlogPost post) {
    _viewedPosts.removeWhere((p) => p.id == post.id);
    notifyListeners();
  }

  void clearHistory() {
    _viewedPosts.clear();
    notifyListeners();
  }
}