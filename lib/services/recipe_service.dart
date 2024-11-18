import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/recipe.dart';
import 'dart:developer';
import '../models/comment.dart';

class RecipeService {
  List<Recipe>? _cachedRecipes;

  Future<List<Recipe>> _loadRecipes() async {
    if (_cachedRecipes != null) {
      return _cachedRecipes!;
    }

    try {
      // Load JSON data from assets
      final jsonString = await rootBundle.loadString('assets/data/recipes.json');
      final jsonData = json.decode(jsonString);

      // Ensure 'recipes' key exists and is a list
      if (jsonData['recipes'] is! List) {
        throw Exception('Invalid data format: "recipes" is not a list');
      }

      _cachedRecipes = (jsonData['recipes'] as List).map((recipeJson) {
        return Recipe(
          id: int.parse(recipeJson['id'].toString()),
          name: recipeJson['name'] ?? 'Unknown Recipe', // 提供默認值
          author: recipeJson['author'] ?? 'Unknown Author',
          imageUrl: recipeJson['imageUrl'] ?? '',
          publishDate: DateTime.tryParse(recipeJson['publishDate'] ?? '') ?? DateTime.now(),
          ingredients: List<String>.from(recipeJson['ingredients'] ?? []),
          instructions: List<String>.from(recipeJson['instructions'] ?? []),
          likes: int.tryParse(recipeJson['likes']?.toString() ?? '0') ?? 0, // 確保 likes 是 int
          comments: (recipeJson['comments'] as List? ?? [])
              .map((commentJson) => _parseComment(commentJson))
              .toList(),
        );
      }).toList();

      log('Loaded recipes: ${_cachedRecipes!.length}');
      return _cachedRecipes!;
    } catch (e, stacktrace) {
      print('Error loading recipes: $e\n$stacktrace');
      throw Exception('Failed to load recipes');
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

  Future<List<Recipe>> fetchInitialRecipes() async {
    await Future.delayed(const Duration(seconds: 1));
    final recipes = await _loadRecipes();
    return recipes.take(10).toList();
  }

  Future<List<Recipe>> fetchUserRecipes(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    final recipes = await _loadRecipes();
    return recipes.where((recipe) => recipe.author == userId).toList();
  }

  Future<List<Recipe>> refreshRecipes() async {
    await Future.delayed(const Duration(seconds: 1));
    final recipes = await _loadRecipes();
    return recipes.take(10).toList();
  }

  Future<List<Recipe>> fetchMoreRecipes(int offset) async {
    await Future.delayed(const Duration(seconds: 1));
    final recipes = await _loadRecipes();
    final end = (offset + 5).clamp(0, recipes.length);
    return recipes.sublist(offset, end);
  }

  Future<List<Comment>> fetchComments(String recipeId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final recipes = await _loadRecipes();
    final recipe = recipes.firstWhere((recipe) => recipe.id == recipeId);
    return recipe.comments;
  }

  Future<List<Comment>> fetchMoreComments(String recipeId, int offset) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [];
  }
}