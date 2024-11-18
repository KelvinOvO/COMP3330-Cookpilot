// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../widgets/blog_post_card.dart';
import '../models/blog_post.dart';
import '../models/recipe.dart';
import './blog_post_detail_page.dart';
import '../services/blog_service.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/app_drawer.dart';
import './post_blog.dart';
import '../services/history_service.dart';
import 'package:provider/provider.dart';
import '../pages/recipe_detail_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  // Initialize a list to store viewed post history
  List<BlogPost> viewedPosts = [];

  static const _tabCount = 3;
  static const _loadThreshold = 200.0;

  late final TabController _tabController;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  final BlogService _blogService = BlogService();
  final List<GlobalKey> _tabKeys = List.generate(_tabCount, (index) => GlobalKey());

  List<BlogPost> posts = [];
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  bool _hasMore = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _tabController = TabController(
      length: _tabCount,
      initialIndex: 1,
      vsync: this,
    )..addListener(_handleTabChange);

    _scrollController.addListener(_handleScroll);
    _loadInitialPosts();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _handleScroll() {
    if (_shouldLoadMore) {
      _onLoading();
    }
  }

  bool get _shouldLoadMore => !_isLoading &&
      !_isError &&
      _hasMore &&
      _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - _loadThreshold;

  Future<void> _loadInitialPosts() async {
    if (_isLoading) return;

    _setLoadingState(true);

    try {
      final newPosts = await _blogService.fetchInitialPosts();
      if (mounted) {
        setState(() {
          posts = newPosts;
          _hasMore = newPosts.isNotEmpty;
        });
      }
    } catch (e) {
      _handleError('Failed to load posts: ${e.toString()}');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> _onRefresh() async {
    if (_isLoading) return;

    _clearError();

    try {
      final newPosts = await _blogService.refreshPosts();
      if (mounted) {
        setState(() {
          posts = newPosts;
          _hasMore = newPosts.isNotEmpty;
        });
      }
    } catch (e) {
      _handleError('Failed to refresh: ${e.toString()}');
    } finally {
      _refreshController.refreshCompleted();
      if (_hasMore) {
        _refreshController.resetNoData();
      }
    }
  }

  Future<void> _onLoading() async {
    if (_isLoading || !_hasMore) return;

    _setLoadingState(true);

    try {
      final newPosts = await _blogService.fetchMorePosts(posts.length);
      if (mounted) {
        setState(() {
          posts.addAll(newPosts);
          _hasMore = newPosts.isNotEmpty;
        });
      }
    } catch (e) {
      _handleError('Failed to load more: ${e.toString()}');
    } finally {
      _setLoadingState(false);
      _refreshController.loadComplete();
      if (!_hasMore) {
        _refreshController.loadNoData();
      }
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
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _tabController.index,
        children: [
          _buildEmptyTab('Following'),
          _buildMainContent(), // Discover tab
          _buildRecipesContent(), // Recipes tab
        ],
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Following';
      case 1:
        return 'Discover';
      case 2:
        return 'Recipe';
      default:
        return '';
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF1A1A1A)),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      centerTitle: true,
      title: _buildTabBar(),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.add,
            color: Color(0xFF007AFF),
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PostBlogPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.center,
      tabs: [
        for (int i = 0; i < _tabCount; i++)
          Tab(text: _getTabTitle(i)),
      ],
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2.0,
          color: Color(0xFF007AFF),
        ),
        insets: EdgeInsets.symmetric(horizontal: 16.0),
      ),
      labelColor: const Color(0xFF007AFF),
      unselectedLabelColor: const Color(0xFF999999),
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildEmptyTab(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isError && posts.isEmpty) {
      return _buildErrorView();
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: _hasMore,
      header: const WaterDropHeader(
        waterDropColor: Color(0xFF007AFF),
      ),
      footer: _buildCustomFooter(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: posts.isEmpty && _isLoading
          ? _buildLoadingView()
          : _buildPostsGrid(),
    );
  }

  Widget _buildRecipesContent() {
    return FutureBuilder<List<Recipe>>(
      future: RecipeService().fetchInitialRecipes(), // Load recipes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
            ),
          );
        } else if (snapshot.hasError) {
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
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No Recipes Available',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF999999),
              ),
            ),
          );
        }

        final recipes = snapshot.data!;
        return MasonryGridView.count(
          key: const PageStorageKey('recipes_grid'),
          crossAxisCount: 2,
          itemCount: recipes.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(3.0),
            child: RecipeCard(
              recipe: recipes[index],
              onTap: () => _navigateToRecipeDetail(recipes[index]),
            ),
          ),
          mainAxisSpacing: 3.0,
          crossAxisSpacing: 3.0,
        );
      },
    );
  }

  Widget _buildCustomFooter() {
    return CustomFooter(
      builder: (context, mode) {
        if (mode == null) {
          return const SizedBox.shrink();
        }

        final Widget body;
        switch (mode) {
          case LoadStatus.idle:
            body = const Text("Pull up load more");
          case LoadStatus.loading:
            body = const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
              ),
            );
          case LoadStatus.failed:
            body = const Text("Load failed, tap to retry");
          case LoadStatus.canLoading:
            body = const Text("Release to load more");
          case LoadStatus.noMore:
            body = const Text("No more data");
        }

        return Container(
          height: 55.0,
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(color: Color(0xFF999999)),
              child: body,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
        strokeWidth: 2,
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
            onPressed: _loadInitialPosts,
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

  Widget _buildPostsGrid() {
    return MasonryGridView.count(
      key: const PageStorageKey('posts_grid'),
      controller: _scrollController,
      crossAxisCount: 2,
      itemCount: posts.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(3.0),
        child: BlogPostCard(
          key: ValueKey('post_${posts[index].id}_$index'),
          post: posts[index],
          onTap: () => _navigateToDetail(posts[index]),
        ),
      ),
      mainAxisSpacing: 3.0,
      crossAxisSpacing: 3.0,
    );
  }

  void _navigateToDetail(BlogPost post) {
    // Record the view in the history service
    final historyService = Provider.of<HistoryService>(context, listen: false);
    historyService.addViewedPost(post);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogPostDetailPage(post: post),
      ),
    );
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipe: recipe), // Placeholder for RecipeDetailPage
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}