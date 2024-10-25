// lib/services/blog_service.dart
import 'dart:math';
import '../models/blog_post.dart';
import '../models/comment.dart';

class BlogService {
  final Random _random = Random();

  final List<String> _sampleTitles = [
    'Hidden Gems: Secret Food Spots in the City',
    'Weekend Brunch: Best Cafes to Visit',
    'Food Review: Instagram-Worthy Restaurant Finds',
    'Sweet Tooth Guide: City\'s Best Dessert Places',
    'Late Night Eats: 24-Hour Food Guide',
    'Breakfast Chronicles: Local Morning Favorites',
    'Michelin Guide: Affordable Recommended Restaurants',
    'Food Vlog: Capturing Culinary Moments',
    'Restaurant Review: Top-Rated Dining Experiences',
    'This Week\'s Must-Try: New Restaurant Openings',
    'Farm to Table: Sustainable Dining Guide',
    'Street Food Adventures: Global Flavors',
    'Fusion Cuisine: Where East Meets West',
    'Rooftop Dining: Views and Vibes',
    'Vegetarian Delights: Plant-Based Paradise'
  ];

  final List<String> _sampleAuthors = [
    'The Food Explorer',
    'Culinary Chronicles',
    'Food Video Creator',
    'Urban Food Hunter',
    'Food Photographer',
    'Taste Adventures',
    'The Hungry Journalist',
    'Gastronomy Guide',
    'Kitchen Confidential',
    'The Flavor Seeker'
  ];

  final List<String> _sampleContents = [
    'Today, I\'m excited to share a hidden gem tucked away in the city\'s narrow lanes. While the location might be off the beaten path, this restaurant has gained a massive social media following thanks to its unique flavors and artistic plating. The chef, formerly of a Michelin-starred establishment, brings years of expertise...',
    'Nothing beats a peaceful Saturday morning at a quiet café, indulging in a perfectly crafted brunch. Their signature perfectly poached eggs on homemade sourdough, topped with fresh avocado spread and micro greens, paired with a single-origin pour-over coffee, truly captures life\'s simple pleasures...',
    'Late-night dining takes on a whole new meaning at this 24-hour establishment. Beyond traditional late-night fare, they offer an innovative fusion menu that surprises and delights. Their midnight dessert selection is particularly noteworthy...',
    'This Michelin-recommended spot proves that exceptional food doesn\'t always come with a hefty price tag. Despite its modest appearance, every dish showcases the chef\'s mastery. Their signature braised beef, slow-cooked for 48 hours, literally melts in your mouth...',
    'This week\'s visit took me to a newly opened hotspot specializing in modern American cuisine. The elegant ambiance and professional service complement their innovative take on classic dishes. Don\'t miss their unique spin on mac and cheese, featuring five artisanal cheeses and truffle breadcrumbs...',
    'Exploring the vibrant street food scene today revealed an amazing fusion taco stand. The combination of Korean BBQ with Mexican street food traditions creates an unforgettable flavor explosion. Their kimchi quesadillas are already becoming legendary in the local food scene...',
    'Today\'s farm-to-table experience showcased the best of seasonal produce. Working directly with local farmers, this restaurant changes its menu weekly based on available ingredients. The roasted root vegetable medley with honey-lavender glaze was a particular highlight...',
    'Venture into the world of molecular gastronomy at this innovative eatery. The chef\'s tasting menu is a journey through texture and flavor, featuring dishes like nitrogen-frozen olive oil drops and deconstructed classic desserts. Each course is a conversation starter...',
    'This rooftop garden restaurant offers more than just stunning city views. Their commitment to sustainability extends to their own herb garden and beehives. The house-made honey appears in both savory dishes and creative cocktails, adding a unique local touch...',
    'Discovered a charming family-owned bakery that\'s been operating for three generations. Their secret sourdough starter dates back 50 years, resulting in bread with unmatched depth of flavor. The morning queue for their croissants speaks volumes about their quality...'
  ];

  final List<String> _sampleCommentContents = [
    'Love this place! Can\'t wait to try it out! 😋',
    'The photos look amazing! Thanks for sharing 📸',
    'I\'ve been there last week, totally worth it! 👌',
    'Great review! Very detailed and helpful 👍',
    'The prices seem reasonable for the quality',
    'Do they accept reservations? Anyone knows?',
    'The ambiance looks fantastic!',
    'I\'m definitely adding this to my must-visit list',
    'Their desserts are to die for! 🍰',
    'Been following your reviews for a while, never disappoints!',
    'How\'s the parking situation there?',
    'The presentation is absolutely stunning',
    'Could you share more about their vegetarian options?',
    'Perfect timing! Planning to go there this weekend',
    'Your food photography skills are amazing! 📷'
  ];

  final List<String> _sampleCommentUserNames = [
    'Foodie Explorer',
    'Culinary Enthusiast',
    'Local Guide',
    'Food Lover',
    'Dining Expert',
    'Restaurant Hopper',
    'Cuisine Critic',
    'Taste Tester',
    'Food Photographer',
    'Gastronomy Fan'
  ];

  final List<String> _sampleReplyContents = [
    'Thanks for the info! 🙏',
    'Totally agree with you!',
    'Good to know, thanks for sharing',
    'Yes, I had the same experience',
    'Looking forward to trying it',
    'That\'s helpful, appreciate it',
    'Would you recommend going for dinner or lunch?',
    'Did you try their specialty dish?',
    'How long was the wait time?',
    'Great tip, thanks!'
  ];


  String _getRandomImageUrl() {
    const width = 500;
    final height = 300 + _random.nextInt(200);
    return 'https://picsum.photos/$width/$height';
  }

  List<Comment> _generateRandomComments(String postId) {
    // Generate 1 - 8 random comment
    final commentCount = _random.nextInt(7) + 1;

    return List<Comment>.from(
      List.generate(commentCount, (index) {
        final hasReplies = _random.nextBool();
        final List<Comment> replies = hasReplies ? _generateRandomReplies() : [];

        return Comment(
          id: '${postId}_comment_$index',
          userId: 'user_${_random.nextInt(100)}',
          userName: _sampleCommentUserNames[_random.nextInt(_sampleCommentUserNames.length)],
          userAvatar: 'https://i.pravatar.cc/150?u=${_random.nextInt(1000)}',
          content: _sampleCommentContents[_random.nextInt(_sampleCommentContents.length)],
          createdAt: DateTime.now().subtract(
            Duration(
              hours: _random.nextInt(72),
              minutes: _random.nextInt(60),
            ),
          ),
          likes: _random.nextInt(50),
          replies: replies,
        );
      }),
    );
  }

  List<Comment> _generateRandomReplies() {
    // Generate 0 - 3 random replies
    final replyCount = _random.nextInt(3);

    return List<Comment>.from(
      List.generate(replyCount, (index) {
        return Comment(
          id: 'reply_${_random.nextInt(1000)}',
          userId: 'user_${_random.nextInt(100)}',
          userName: _sampleCommentUserNames[_random.nextInt(_sampleCommentUserNames.length)],
          userAvatar: 'https://i.pravatar.cc/150?u=${_random.nextInt(1000)}',
          content: _sampleReplyContents[_random.nextInt(_sampleReplyContents.length)],
          createdAt: DateTime.now().subtract(
            Duration(
              hours: _random.nextInt(48),
              minutes: _random.nextInt(60),
            ),
          ),
          likes: _random.nextInt(20),
        );
      }),
    );
  }

  BlogPost _createRandomPost(int index, String prefix) {
    final titleIndex = _random.nextInt(_sampleTitles.length);
    final authorIndex = _random.nextInt(_sampleAuthors.length);
    final contentIndex = _random.nextInt(_sampleContents.length);
    final postId = '${prefix}_$index';

    return BlogPost(
      id: postId,
      title: _sampleTitles[titleIndex],
      author: _sampleAuthors[authorIndex],
      likes: _random.nextInt(9000) + 1000,
      imageUrl: _getRandomImageUrl(),
      content: _sampleContents[contentIndex],
      publishDate: DateTime.now().subtract(
        Duration(
          hours: _random.nextInt(24),
          minutes: _random.nextInt(60),
        ),
      ),
      comments: _generateRandomComments(postId),
    );
  }

  Future<List<Comment>> fetchComments(String postId) async {
    // simulate web request
    await Future.delayed(const Duration(milliseconds: 800));
    return _generateRandomComments(postId);
  }

  Future<List<Comment>> fetchMoreComments(String postId, int offset) async {
    // simulate web request
    await Future.delayed(const Duration(milliseconds: 800));
    return _generateRandomComments('${postId}_more_$offset');
  }

  Future<List<BlogPost>> fetchInitialPosts() async {
    // simulate web request
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(
      10,
          (index) => _createRandomPost(index, 'initial'),
    );
  }

  Future<List<BlogPost>> refreshPosts() async {
    // simulate web request
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(
      10,
          (index) => _createRandomPost(index, 'refresh'),
    );
  }

  Future<List<BlogPost>> fetchMorePosts(int offset) async {
    // simulate web request
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(
      5,
          (index) => _createRandomPost(offset + index, 'more'),
    );
  }
}