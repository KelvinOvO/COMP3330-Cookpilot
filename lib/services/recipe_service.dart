import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/recipe.dart';
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

      _cachedRecipes = (jsonData['recipes'] as List).map((recipeJson) {
        return Recipe(
          id: recipeJson['id'],
          name: recipeJson['name'],
          author: recipeJson['author'],
          imageUrl: recipeJson['imageUrl'],
          publishDate: DateTime.parse(recipeJson['publishDate']),
          ingredients: List<String>.from(recipeJson['ingredients']),
          instructions: List<String>.from(recipeJson['instructions']),
          likes: recipeJson['likes'],
          comments: (recipeJson['comments'] as List)
              .map((commentJson) => _parseComment(commentJson))
              .toList(),
        );
      }).toList();

      return _cachedRecipes!;
    } catch (e) {
      print('Error loading recipes: $e');
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