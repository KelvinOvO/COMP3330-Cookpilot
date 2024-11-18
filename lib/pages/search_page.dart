// lib/pages/search_page.dart
import 'package:app_controller_client/app_controller_client.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cookpilot/models/recipe.dart';
import 'package:cookpilot/pages/recipe_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../global/app_controller.dart';
import '../models/blog_post.dart';
import '../services/blog_service.dart';

class SearchPage extends StatefulWidget {
  final List<String>? initialIngredients;
  const SearchPage({Key? key, this.initialIngredients}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Constants
  static const double _kSpacing = 16.0;
  static const double _kBorderRadius = 12.0;
  static const int _kMaxRecentSearches = 4;
  static const int _kSuggestedRecipesLimit = 8;

  // Controllers & Services
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final BlogService _blogService = BlogService();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _searchError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _error = ValueNotifier<String?>(null);

  // State
  late final ValueNotifier<List<String>> _ingredients;
  late final ValueNotifier<List<Recipe>?> _foundRecipes;
  late final ValueNotifier<List<BlogPost>> _suggestedRecipes;
  late final ValueNotifier<List<String>> _recentSearches;

  @override
  void initState() {
    super.initState();
    _ingredients = ValueNotifier<List<String>>([]);
    _foundRecipes = ValueNotifier<List<Recipe>?>(null);
    _suggestedRecipes = ValueNotifier<List<BlogPost>>([]);
    _recentSearches = ValueNotifier<List<String>>([
      'Basil Pesto Sauce',
      'Chicken Pesto Naan Pizza',
      'Pesto Pasta',
      'Panko Pesto Fish',
    ]);
    if (widget.initialIngredients != null) {
      for (var ingredient in widget.initialIngredients!) {
        _handleIngredientAdd(ingredient);
      }
      _handleSearch('');
    }
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

  Future<void> _handleSearch(String ingredient) async {
    _handleIngredientAdd(ingredient);

    if (_ingredients.value.isEmpty) return;

    _searchFocusNode.unfocus();

    setState(() {
      _isLoading.value = true;
      _searchError.value = null;
    });

    try {
      final api = appController.getRecipeSearchApi();
      final searchResponse = await api.recipeSearchSearchRecipesPost(
          searchRecipesPostRequestModel: (SearchRecipesPostRequestModelBuilder()
                ..ingredients = ListBuilder(_ingredients.value)
                ..perPage = 10
                ..includeDetail = true
                ..page = 1)
              .build());
      final searchRecipes = searchResponse.data!.recipes;

      final List<Recipe> recipes = [];
      for (var recipe in searchRecipes) {
        const authors = [
          'John Doe',
          'Jane Doe',
          'Alice Smith',
          'Bob Johnson',
          'Charlie Brown',
          'David Lee',
          'Eve Wilson',
          'Frank White',
          'Grace Davis',
          'Henry Young',
        ];

        recipes.add(Recipe(
          id: recipe.id,
          name: recipe.name,
          author: authors[recipe.id % authors.length],
          imageUrl:
          recipe.name == 'Shrimp And Sweet Potato Gumbo'
              ? 'https://www.closetcooking.com/wp-content/uploads/2012/02/BlackenedShrimponKaleandMashedSweetPotatoeswithAndouilleCream5000002-1.jpg'
              : 'https://picsum.photos/500/400?${"${recipe.id}".hashCode % 10}',
          publishDate: DateTime(
            2020 + '${recipe.id}'.hashCode % 4,
            1 + '${recipe.id}'.hashCode % 12,
            1 + '${recipe.id}'.hashCode % 28,
          ),
          ingredients: recipe.ingredients.toList(),
          instructions: recipe.detail!.instructions.toList(),
        ));
      }

      if (mounted) {
        setState(() {
          _foundRecipes.value = recipes.take(_kSuggestedRecipesLimit).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchError.value = 'Failed to load recipes: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading.value = false;
        });
      }
    }
  }

  void _handleIngredientAdd(String ingredient) {
    if (ingredient.isEmpty) return;

    _searchController.clear();
    _searchFocusNode.requestFocus();

    setState(() {
      _recentSearches.value = [
        ingredient,
        ..._recentSearches.value.where((item) => item != ingredient)
      ].take(_kMaxRecentSearches).toList();

      _ingredients.value = [..._ingredients.value, ingredient];
    });
  }

  void _handleIngredientEdit(int index, String ingredient) {
    setState(() {
      _ingredients.value = [
        ..._ingredients.value.take(index),
        ingredient,
        ..._ingredients.value.skip(index + 1),
      ];
    });
  }

  void _handleIngredientRemove(int index) {
    setState(() {
      _ingredients.value = [
        ..._ingredients.value.take(index),
        ..._ingredients.value.skip(index + 1),
      ];

      if (_ingredients.value.isEmpty) {
        _foundRecipes.value = null;
        _searchError.value = null;
      }
    });
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

            return ValueListenableBuilder<List<String>>(
              valueListenable: _ingredients,
              builder: (context, ingredients, _) {
                if (ingredients.isEmpty) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _SearchInput(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onSearch: _handleSearch,
                          onIngredientAdd: _handleIngredientAdd,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: ValueListenableBuilder<List<String>>(
                          valueListenable: _recentSearches,
                          builder: (context, searches, _) => _RecentSearches(
                            searches: searches,
                            onSearchSelected: _handleIngredientAdd,
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
                                    recipe: Recipe(
                                      id: recipes[index].id.hashCode,
                                      name: recipes[index].title,
                                      author: recipes[index].author,
                                      imageUrl: recipes[index].imageUrl,
                                      publishDate: DateTime.utc(
                                        2020 + recipes[index].id.hashCode % 4,
                                        1 + recipes[index].id.hashCode % 12,
                                        1 + recipes[index].id.hashCode % 28,
                                      ),
                                      ingredients: [],
                                      instructions: [],
                                    ),
                                    onTap: () => _navigateToDetail(Recipe(
                                      id: recipes[index].id.hashCode,
                                      name: recipes[index].title,
                                      author: recipes[index].author,
                                      imageUrl: recipes[index].imageUrl,
                                      publishDate: DateTime.utc(
                                        2020 + recipes[index].id.hashCode % 4,
                                        1 + recipes[index].id.hashCode % 12,
                                        1 + recipes[index].id.hashCode % 28,
                                      ),
                                      ingredients: [],
                                      instructions: [],
                                    )),
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
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _SearchInput(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onSearch: _handleSearch,
                        onIngredientAdd: _handleIngredientAdd,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(_kSpacing),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Ingredients',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: _kSpacing),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _IngredientCard(
                            ingredient: _ingredients.value[index],
                            onEdit: (ingredient) =>
                                _handleIngredientEdit(index, ingredient),
                            onRemove: () => _handleIngredientRemove(index),
                          ),
                          childCount: _ingredients.value.length,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(_kSpacing),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Found Recipes',
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

                        return ValueListenableBuilder<String?>(
                          valueListenable: _searchError,
                          builder: (context, searchError, _) {
                            if (searchError != null) {
                              return SliverFillRemaining(
                                child: _ErrorView(
                                  message: searchError,
                                  onRetry: () => _handleSearch(''),
                                ),
                              );
                            }

                            return ValueListenableBuilder<List<Recipe>?>(
                              valueListenable: _foundRecipes,
                              builder: (context, recipes, _) {
                                if (recipes == null) {
                                  return const SliverFillRemaining(
                                    child: Center(
                                      child: Text(
                                          'Press the search button to find recipes!'),
                                    ),
                                  );
                                }

                                return SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return _RecipeCard(
                                        recipe: recipes[index],
                                        onTap: () =>
                                            _navigateToDetail(recipes[index]),
                                      );
                                    },
                                    childCount: recipes.length,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(
          recipe: recipe,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _isLoading.dispose();
    _searchError.dispose();
    _error.dispose();
    _ingredients.dispose();
    _foundRecipes.dispose();
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
      centerTitle: true,
      title: Text(
        'Search',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
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
  final ValueChanged<String> onIngredientAdd;

  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onIngredientAdd,
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
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: 'Try some ingredients...',
            hintStyle: TextStyle(
              color: theme.hintColor.withOpacity(0.6),
              fontSize: 16,
            ),
            // prefixIcon: Icon(
            //   Icons.search_rounded,
            //   color: theme.primaryColor,
            //   size: 22,
            // ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(_SearchPageState._kBorderRadius - 4),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  color: theme.primaryColor,
                  size: 20,
                ),
                onPressed: () {
                  onSearch(controller.text);
                },
              ),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(_SearchPageState._kBorderRadius),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _SearchPageState._kSpacing,
              vertical: _SearchPageState._kSpacing / 1.2,
            ),
          ),
          onSubmitted: onIngredientAdd,
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

class _IngredientCard extends StatefulWidget {
  final String ingredient;
  final ValueChanged<String> onEdit;
  final VoidCallback onRemove;

  const _IngredientCard({
    required this.ingredient,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  State<_IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<_IngredientCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _isEditing = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller.text = widget.ingredient;
  }

  void _handleOnConfirmEdit() {
    widget.onEdit(_controller.text);
    setState(() {
      _isEditing.value = false;
    });
  }

  void _handleOnStartEdit() {
    _focusNode.requestFocus();
    setState(() {
      _isEditing.value = true;
    });
  }

  void _handleOnRemove() {
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: _SearchPageState._kSpacing / 2,
        vertical: _SearchPageState._kSpacing / 4,
      ),
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
      child: ValueListenableBuilder<bool>(
          valueListenable: _isEditing,
          builder: (context, isEditing, _) {
            return TextField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: !isEditing,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surface,
                hintText: 'Try some ingredients...',
                hintStyle: TextStyle(
                  color: theme.hintColor.withOpacity(0.6),
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.category_rounded,
                  size: 22,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isEditing
                        ? Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  _SearchPageState._kBorderRadius - 4),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.check_rounded,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              onPressed: _handleOnConfirmEdit,
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.all(2),
                            child: IconButton(
                              icon: Icon(
                                Icons.edit_rounded,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              onPressed: _handleOnStartEdit,
                            ),
                          ),
                    Container(
                      margin: const EdgeInsets.all(2),
                      child: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        onPressed: _handleOnRemove,
                      ),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(_SearchPageState._kBorderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: _SearchPageState._kSpacing,
                  vertical: _SearchPageState._kSpacing / 1.2,
                ),
              ),
              onSubmitted: (value) {
                if (isEditing) {
                  _handleOnConfirmEdit();
                }
              },
            );
          }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _isEditing.dispose();
    super.dispose();
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
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
            borderRadius:
                BorderRadius.circular(_SearchPageState._kBorderRadius),
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
        child: imageUrl.startsWith('http://') || imageUrl.startsWith('https://')
            ? CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF999999)),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[100],
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFF999999),
            ),
          ),
        )
            : Image.asset(
          imageUrl, // Assuming imageUrl is a valid asset path
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFF999999),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecipeInfo extends StatelessWidget {
  final Recipe recipe;

  const _RecipeInfo({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.name,
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

  String _getCookingTime(Recipe recipe) {
    final minTime = 45 + ('${recipe.id}'.hashCode % 15);
    final maxTime = 60 + ('${recipe.id}'.hashCode % 30);
    return '$minTime~${maxTime}min';
  }

  String _getCalories(Recipe recipe) {
    return '${100 + ('${recipe.id}'.hashCode % 538)}';
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
