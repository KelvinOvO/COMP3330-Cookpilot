import 'comment.dart';

class Recipe {
  final int id;
  final String name;
  final String author;
  final String imageUrl;
  final DateTime publishDate;
  final List<String> ingredients;
  final List<String> instructions;
  final int likes;
  final List<Comment> comments;

  const Recipe({
    required this.id,
    required this.name,
    required this.author,
    required this.imageUrl,
    required this.publishDate,
    required this.ingredients,
    required this.instructions,
    this.likes = 0,
    this.comments = const [],
  });
}