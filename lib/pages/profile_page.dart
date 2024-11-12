// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/blog_post.dart';
import '../pages/blog_post_detail_page.dart';
import '../services/blog_service.dart';
import '../widgets/blog_post_card.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
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
      });
    } catch (e) {
      // Handle error
      print('Error loading user posts: $e');
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
      // Handle error
      print('Error refreshing posts: $e');
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
      // Handle error
      print('Error loading more posts: $e');
    } finally {
      _refreshController.loadComplete();
    }
  }

  // Function to show the edit profile dialog
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
                // Update the profile with the new values
                _name = nameController.text;
                _bio = bioController.text;
              });
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.black,
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProgressBar(),
            const SizedBox(height: 10),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Posts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 5),
            // Posts Section
            _isLoading
                ? _buildLoadingView()
                : _buildPostsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child:
        Column(children:[
          Row(children:[
            // Profile Picture
            const CircleAvatar(
                radius :40,
                backgroundImage :AssetImage('assets/profile/profile_picture.jpg') // Replace with actual image path
            ),

            const SizedBox(width :20),

            Expanded(child :Column(crossAxisAlignment :CrossAxisAlignment.start, children:[
              Row(children:[
                // Username and Badge
                Text(_name, style :const TextStyle(fontSize :24, fontWeight :FontWeight.bold)),

                const SizedBox(width :8),

                // Badge
                Container(padding :const EdgeInsets.symmetric(horizontal :8, vertical :4), decoration :
                BoxDecoration(color :Colors.black, borderRadius :BorderRadius.circular(12)), child :
                const Text('MasterChef', style :TextStyle(color :Colors.white, fontSize :12)))
              ]),

              // Stats Section (Centered)
              const SizedBox(height :8),
              Row(mainAxisAlignment :MainAxisAlignment.spaceEvenly, children:[
                // Posts Count
                Column(children:[
                  Text('1', style :const TextStyle(fontSize :20, fontWeight :FontWeight.bold)),
                  const Text('Posts')
                ]),

                // padding
                const SizedBox(width :44),

                // Followers Count
                Column(children:[
                  Text('3330', style :const TextStyle(fontSize :20, fontWeight :FontWeight.bold)),
                  const Text('Followers')
                ]),

                // padding
                const SizedBox(width :44),

                // Following Count
                Column(children:[
                  Text('3330', style :const TextStyle(fontSize :20, fontWeight :FontWeight.bold)),
                  const Text('Following')
                ])
              ])

            ]))
          ]),

          // Bio Section Below Stats
          const SizedBox(height :16),
          Row(mainAxisAlignment :
          MainAxisAlignment.start, children:[
            Expanded(child :
            Padding(padding:
            EdgeInsets.symmetric(horizontal:
            8.0), child:
            Text(_bio)))
          ]),

          // Edit Profile Button Below Bio
          Padding(padding:
          EdgeInsets.only(top:
          8), child:
          ElevatedButton(onPressed:
              () {
            // Show edit dialog when pressed
            _showEditProfileDialog();
          }, style:
          ElevatedButton.styleFrom(backgroundColor:
          Colors.grey[200], shape:
          RoundedRectangleBorder(borderRadius:
          BorderRadius.circular(20))), child:
          Padding(padding:
          EdgeInsets.symmetric(vertical:
          10, horizontal: 130), child:
          Text('Edit Profile', style:
          TextStyle(color:
          Colors.black)))))

        ]
        )
    );
  }


  Widget _buildProgressBar() {
    return Padding(
        padding:
        const EdgeInsets.symmetric(horizontal:
        16.0),
        child:
        Column(crossAxisAlignment:
        CrossAxisAlignment.start, children:[

          // Progress Title and Icon
          Row(mainAxisAlignment:
          MainAxisAlignment.spaceBetween, children:[
            const Text("Your progress"),

            IconButton(onPressed :
                () {}, icon :
            Icon(Icons.bar_chart))

          ]),

          // Progress Bar Description and Value
          Row(mainAxisAlignment :
          MainAxisAlignment.spaceBetween, children:[
            const Text("25% to next level"),
            const Text("3750/5000")
          ]),

          // Progress Bar Indicator
          LinearProgressIndicator(value :
          0.75)

        ]
        )
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