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
import '../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  @override
  void initState() {
    super.initState();
    if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn) {
      _loadUserPosts();
    }
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

  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username == 'Ray' && password == 'raywong1234') {
      context.read<AuthProvider>().login(username);
      _loadUserPosts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 50), // Fixed margin
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outlined,
                  size: 50,
                  color: Color(0xFF2196F3),
                ),
                const SizedBox(height: 24),
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
                _buildTextField(
                  controller: _usernameController,
                  icon: Icons.person_outline,
                  hintText: 'Username',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  hintText: 'Password',
                  isPassword: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
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
      ),
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
      body: authProvider.isLoggedIn
          ? Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F6F6), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildProgressBar(),
              const SizedBox(height: 16),
              _buildPostsSection(),
            ],
          ),
        ),
      )
          : _buildLoginForm(),
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
                            'MasterChef',
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

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Action for chart or more progress details
                },
                icon: const Icon(Icons.bar_chart),
                color: Color(0xFF1A1A1A),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Progress to Next Level",
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                ),
              ),
              Text(
                "3750 / 5000",
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.75,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A1A1A)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "75% Complete",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
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
    return Container(
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