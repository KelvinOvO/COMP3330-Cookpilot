// lib/models/blog_post.dart
import 'comment.dart';

class BlogPost {
  final String id;
  final String title;
  final String author;
  final int likes;
  final String imageUrl;
  final String content;
  final DateTime publishDate;
  final List<Comment> comments;  // List for comment

  const BlogPost({
    required this.id,
    required this.title,
    required this.author,
    required this.likes,
    required this.imageUrl,
    required this.content,
    required this.publishDate,
    this.comments = const [],  // Default
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      content: json['content'] as String? ?? '',
      publishDate: json['publishDate'] != null
          ? DateTime.parse(json['publishDate'] as String)
          : DateTime.now(),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'likes': likes,
      'imageUrl': imageUrl,
      'content': content,
      'publishDate': publishDate.toIso8601String(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  BlogPost copyWith({
    String? id,
    String? title,
    String? author,
    int? likes,
    String? imageUrl,
    String? content,
    DateTime? publishDate,
    List<Comment>? comments,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      likes: likes ?? this.likes,
      imageUrl: imageUrl ?? this.imageUrl,
      content: content ?? this.content,
      publishDate: publishDate ?? this.publishDate,
      comments: comments ?? this.comments,
    );
  }
}