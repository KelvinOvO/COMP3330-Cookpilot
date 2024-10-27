// lib/pages/search_page.dart
import 'package:flutter/material.dart';
import '../models/blog_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/blog_service.dart';
import './blog_post_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final BlogService _blogService = BlogService();
  final ScrollController _scrollController = ScrollController();

  List<BlogPost> _suggestedRecipes = [];
  final List<String> _recentSearches = [
    'Basil Pesto Sauce',
    'Checken Pesto Naan Pizza',
    'Pesto Pasta',
    'Panko Pesto Fish',
  ];

  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSuggestedRecipes();
  }

  Future<void> _loadSuggestedRecipes() async {
    if (_isLoading) return;

    _setLoadingState(true);

    try {
      final recipes = await _blogService.fetchInitialPosts();
      if (mounted) {
        setState(() {
          _suggestedRecipes = recipes.take(4).toList();
        });
      }
    } catch (e) {
      _handleError('Failed to load recipes: ${e.toString()}');
    } finally {
      _setLoadingState(false);
    }
  }

  void _setLoadingState(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
        if (loading) {
          _clearError();
        }
      });
    }
  }

  void _clearError() {
    setState(() {
      _isError = false;
      _errorMessage = '';
    });
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _isError = true;
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildMainContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Search',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Implement help functionality
          },
          child: const Text(
            'Help',
            style: TextStyle(
              color: Color(0xFF007AFF),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_isError) {
      return _buildErrorView();
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildRecentSearches(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Suggested Recipe',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _isLoading
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                strokeWidth: 2,
              ),
            ),
          )
              : Column(
            children: _suggestedRecipes
                .map((recipe) => _buildRecipeCard(recipe))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          hintText: 'pesto',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF999999)),
            onPressed: () {
              // Implement voice search
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          // Implement search functionality
        },
        onSubmitted: (value) {
          // Implement search execution
          if (value.isNotEmpty) {
            setState(() {
              if (!_recentSearches.contains(value)) {
                _recentSearches.insert(0, value);
                if (_recentSearches.length > 4) {
                  _recentSearches.removeLast();
                }
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _recentSearches.map((search) {
        return ListTile(
          leading: const Icon(
            Icons.search,
            color: Color(0xFF999999),
            size: 20,
          ),
          title: Text(
            search,
            style: const TextStyle(
              fontSize: 16,
              decoration: TextDecoration.underline,
              color: Color(0xFF1A1A1A),
            ),
          ),
          onTap: () {
            _searchController.text = search;
            // Execute search
          },
        );
      }).toList(),
    );
  }

  Widget _buildRecipeCard(BlogPost recipe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(recipe),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: recipe.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By User ${recipe.author} ${recipe.publishDate.day.toString().padLeft(2, '0')}/${recipe.publishDate.month.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cooking time: ${45 + (recipe.id.hashCode % 15)}~${60 + (recipe.id.hashCode % 30)}mins',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '${100 + (recipe.id.hashCode % 538)} Calories per serving',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Color(0xFF999999),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadSuggestedRecipes,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BlogPost recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogPostDetailPage(post: recipe),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}