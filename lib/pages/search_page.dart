import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/blog_post.dart';
import '../services/blog_service.dart';
import './blog_post_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Constants
  static const double _kSpacing = 16.0;
  static const double _kBorderRadius = 12.0;
  static const int _kMaxRecentSearches = 4;
  static const int _kSuggestedRecipesLimit = 5;

  // Controllers & Services
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final BlogService _blogService = BlogService();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _error = ValueNotifier<String?>(null);

  // State
  late final ValueNotifier<List<BlogPost>> _suggestedRecipes;
  late final ValueNotifier<List<String>> _recentSearches;

  @override
  void initState() {
    super.initState();
    _suggestedRecipes = ValueNotifier<List<BlogPost>>([]);
    _recentSearches = ValueNotifier<List<String>>([
      'Basil Pesto Sauce',
      'Chicken Pesto Naan Pizza',
      'Pesto Pasta',
      'Panko Pesto Fish',
    ]);
    _loadSuggestedRecipes();
  }

  Future<void> _loadSuggestedRecipes() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    _error.value = null;

    try {
      final recipes = await _blogService.fetchInitialPosts();
      _suggestedRecipes.value = recipes.take(_kSuggestedRecipesLimit).toList();
    } catch (e) {
      _error.value = 'Failed to load recipes: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      _recentSearches.value = [
        query,
        ..._recentSearches.value.where((item) => item != query)
      ].take(_kMaxRecentSearches).toList();
    });

    // TODO: Implement search logic
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _SearchAppBar(
        onHelpPressed: () {
          // TODO: Implement help functionality
        },
      ),
      body: SafeArea(
        child: ValueListenableBuilder<String?>(
          valueListenable: _error,
          builder: (context, error, _) {
            if (error != null) {
              return _ErrorView(
                message: error,
                onRetry: _loadSuggestedRecipes,
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _SearchInput(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSearch: _handleSearch,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: _recentSearches,
                    builder: (context, searches, _) => _RecentSearches(
                      searches: searches,
                      onSearchSelected: (query) {
                        _searchController.text = query;
                        _handleSearch(query);
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(_kSpacing),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Suggested Recipes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, _) {
                    if (isLoading) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return ValueListenableBuilder<List<BlogPost>>(
                      valueListenable: _suggestedRecipes,
                      builder: (context, recipes, _) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) => _RecipeCard(
                              recipe: recipes[index],
                              onTap: () => _navigateToDetail(recipes[index]),
                            ),
                            childCount: recipes.length,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
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
    _isLoading.dispose();
    _error.dispose();
    _suggestedRecipes.dispose();
    _recentSearches.dispose();
    super.dispose();
  }
}

class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onHelpPressed;

  const _SearchAppBar({
    required this.onHelpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      centerTitle: true,
      title: Text(
        'Search',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onHelpPressed,
          child: Text(
            'Help',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSearch;

  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(_SearchPageState._kSpacing),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: 'Find your next recipe...',
            hintStyle: TextStyle(
              color: theme.hintColor.withOpacity(0.6),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.primaryColor,
              size: 22,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(_SearchPageState._kBorderRadius - 4),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.mic_rounded,
                  color: theme.primaryColor,
                  size: 20,
                ),
                onPressed: () {
                  // TODO: Implement voice search
                },
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_SearchPageState._kBorderRadius),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _SearchPageState._kSpacing,
              vertical: _SearchPageState._kSpacing / 1.2,
            ),
          ),
          onSubmitted: onSearch,
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onSearchSelected;

  const _RecentSearches({
    required this.searches,
    required this.onSearchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _SearchPageState._kSpacing,
        vertical: _SearchPageState._kSpacing / 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Recent Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.map((search) {
              return InkWell(
                onTap: () => onSearchSelected(search),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        search,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final BlogPost recipe;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: _SearchPageState._kSpacing,
        vertical: _SearchPageState._kSpacing / 2,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_SearchPageState._kBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(_SearchPageState._kSpacing),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(_SearchPageState._kBorderRadius),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RecipeImage(imageUrl: recipe.imageUrl),
              const SizedBox(width: _SearchPageState._kSpacing),
              Expanded(
                child: _RecipeInfo(recipe: recipe),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  final String imageUrl;

  const _RecipeImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_SearchPageState._kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_SearchPageState._kBorderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Theme.of(context).disabledColor.withOpacity(0.1),
            child: Icon(
              Icons.image_rounded,
              color: Theme.of(context).hintColor.withOpacity(0.3),
              size: 32,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
            child: Icon(
              Icons.error_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeInfo extends StatelessWidget {
  final BlogPost recipe;

  const _RecipeInfo({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              child: Text(
                recipe.author[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'By ${recipe.author}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 16,
              color: theme.hintColor,
            ),
            const SizedBox(width: 4),
            Text(
              _getCookingTime(recipe),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.local_fire_department_outlined,
              size: 16,
              color: theme.hintColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${_getCalories(recipe)} cal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _getCookingTime(BlogPost recipe) {
    final minTime = 45 + (recipe.id.hashCode % 15);
    final maxTime = 60 + (recipe.id.hashCode % 30);
    return '$minTime~${maxTime}min';
  }

  String _getCalories(BlogPost recipe) {
    return '${100 + (recipe.id.hashCode % 538)}';
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_SearchPageState._kSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.hintColor,
            ),
            const SizedBox(height: _SearchPageState._kSpacing),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: _SearchPageState._kSpacing),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}