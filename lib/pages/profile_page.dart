// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:developer';
import '../models/blog_post.dart';
import '../pages/blog_post_detail_page.dart';
import '../services/blog_service.dart';
import '../widgets/blog_post_card.dart';
import '../widgets/progress_bar.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin{
  final BlogService _blogService = BlogService();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  List<BlogPost> posts = [];
  bool _isLoading = false;
  bool _hasMore = true;

  // Variables to store user information
  String _name = 'Ray';
  String _bio = 'Write a bio...';

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _loginAnimationController;
  late Animation<double> _fadeAnimation;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _loginAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _loginAnimationController,
      curve: Curves.easeOutCubic,
    );

    if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn) {
      _loadUserPosts().then((_) {
        _loginAnimationController.forward();
      });
    }
  }


  @override
  void dispose() {
    _loginAnimationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newPosts = await _blogService.fetchUserPosts(_name);
      setState(() {
        posts = newPosts;
        _hasMore = newPosts.isNotEmpty;
        log('Loaded ${posts.length} user posts');
      });
    } catch (e) {
      log('Error loading user posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    try {
      final newPosts = await _blogService.refreshPosts();
      setState(() {
        posts = newPosts;
        _hasMore = newPosts.isNotEmpty;
      });
    } catch (e) {
      log('Error refreshing posts: $e');
    } finally {
      _refreshController.refreshCompleted();
    }
  }

  Future<void> _onLoading() async {
    if (!_hasMore || _isLoading) return;

    try {
      final newPosts = await _blogService.fetchMorePosts(posts.length);
      setState(() {
        posts.addAll(newPosts);
        _hasMore = newPosts.isNotEmpty;
      });
    } catch (e) {
      log('Error loading more posts: $e');
    } finally {
      _refreshController.loadComplete();
    }
  }

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (username == 'Ray' && password == 'raywong1234') {
        _loginAnimationController.reset();
        context.read<AuthProvider>().login(username);
        await _loadUserPosts();
        await Future.microtask(() {});
        await _loginAnimationController.forward();
        setState(() {
          _isLoggingIn = false;
        });
      } else {
        setState(() {
          _isLoggingIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  Widget _buildLoginForm() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo Animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: const Icon(
                                Icons.lock_outlined,
                                size: 50,
                                color: Color(0xFF2196F3),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Welcome Text
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please sign in to continue',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Username TextField
                        _buildAnimatedTextField(
                          controller: _usernameController,
                          icon: Icons.person_outline,
                          hintText: 'Username',
                          delay: 200,
                        ),
                        const SizedBox(height: 16),
                        // Password TextField
                        _buildAnimatedTextField(
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          hintText: 'Password',
                          isPassword: true,
                          delay: 400,
                        ),
                        // Forgot Password Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Add forgot password functionality
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2196F3),
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Login Button
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoggingIn ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: _isLoggingIn
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                      : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Register Link
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Add register functionality
                                    },
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Color(0xFF2196F3),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool isPassword = false,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              enabled: !_isLoggingIn,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Icon(icon, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                // Add error border style
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                // Add focused border style
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1),
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F1F1F),
              ),
              onChanged: (value) {
                // Add validation logic here
              },
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(text: _name);
    TextEditingController bioController = TextEditingController(text: _bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _name = nameController.text;
                _bio = bioController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        actions: authProvider.isLoggedIn
            ? [
          IconButton(
            icon: const Icon(Icons.logout),
            color: const Color(0xFF1A1A1A),
            onPressed: () => _showLogoutDialog(context),
          ),
        ]
            : [],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: authProvider.isLoggedIn
            ? Container(
          key: const ValueKey<String>('profile_content'),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF6F6F6), Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _loginAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        (1 - _loginAnimationController.value) * 20,
                      ),
                      child: Opacity(
                        opacity: _loginAnimationController.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 2),
                      ProgressBar(progressValue: 0.75),
                      const SizedBox(height: 4),
                      _buildPostsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
            : Stack(
          key: const ValueKey<String>('login_content'),
          children: [
            _buildLoginForm(),
            if (_isLoggingIn)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }


  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('assets/profile/profile_picture.jpg'),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            '✵ MasterChef',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('1', 'Posts'),
                        _buildStatDivider(),
                        _buildStatColumn('3,330', 'Followers'),
                        _buildStatDivider(),
                        _buildStatColumn('3,330', 'Following'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _bio,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: _showEditProfileDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Posts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _isLoading ? _buildLoadingView() : _buildPostsGrid(),
      ],
    );
  }

  Widget _buildPostsGrid() {
    return SizedBox(
      height: 500, // Set a specific height or any desired height constraint
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
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
      ),
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

  void _navigateToDetail(BlogPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogPostDetailPage(post: post),
      ),
    );
  }
}