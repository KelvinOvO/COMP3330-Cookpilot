// lib/pages/camera_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/upload_photo.dart';
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool isExpanded = false;

  final ImagePicker _picker = ImagePicker();
  final Random _random = Random();
  XFile? _image;
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  List<Map<String, dynamic>> _history = [];

  // Simulated ingredient data
  final List<Map<String, dynamic>> _mockIngredients = [
    {
      'name': 'Apple',
      'calories': 52,
      'protein': 0.3,
      'fat': 0.2,
      'carbs': 14,
      'freshness': 'Fresh',
      'suggestions': ['Can make apple pie', 'Recommend refrigeration', 'Suitable for raw consumption']
    },
    {
      'name': 'Chicken',
      'calories': 165,
      'protein': 31,
      'fat': 3.6,
      'carbs': 0,
      'freshness': 'Fresh',
      'suggestions': ['Can be grilled, fried, or sautéed', 'Recommend freezing', 'Suitable for various cooking methods']
    },
    {
      'name': 'Tomato',
      'calories': 18,
      'protein': 0.9,
      'fat': 0.2,
      'carbs': 3.9,
      'freshness': 'Fresh',
      'suggestions': ['Can make salads', 'Room temperature storage', 'Suitable for raw or cooked']
    },
    {
      'name': 'Salmon',
      'calories': 208,
      'protein': 22,
      'fat': 13,
      'carbs': 0,
      'freshness': 'Fresh',
      'suggestions': ['Recommended for sashimi', 'Keep refrigerated', 'Suitable for grilling']
    },
    {
      'name': 'Carrot',
      'calories': 41,
      'protein': 0.9,
      'fat': 0.2,
      'carbs': 10,
      'freshness': 'Fresh',
      'suggestions': ['Can make salads', 'Keep refrigerated', 'Suitable for raw or cooked']
    }
  ];
  // Retrieved ingredient data from photo recognition
  late List<Map<String, dynamic>> _Ingredients ;

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _image = image;
          _isLoading = true;
        });
        // await _simulateAnalysis();
        _Ingredients = await UploadPhotoService.callMainFunction(_image!.path);
        await _AIAnalysis();
      }
    } catch (e) {
      _showErrorDialog('Failed to get image: $e');
    }
  }

  Future<void> _AIAnalysis() async {
    // Simulate analysis delay
    //await Future.delayed(const Duration(seconds: 2));

    // Randomly select an ingredient
    List<Map<String, dynamic>> results = _Ingredients.map((ingredient) {
      return {
        ...ingredient,
        'confidence': (85 + _random.nextInt(15)).toString() + '%',
        'timestamp': DateTime.now().toString(),
        'image': _image!.path,
      };
    }).toList();

    setState(() {
      _result = results.isNotEmpty ? results[0] : null;
      _history.insertAll(0, results);
      _isLoading = false;
    });
  }

  //TODO: Delete this function
  Future<void> _simulateAnalysis() async {
    // Simulate analysis delay
    await Future.delayed(const Duration(seconds: 2));

    // Randomly select an ingredient
    final ingredient = _mockIngredients[_random.nextInt(_mockIngredients.length)];

    // Add some random variations
    final result = {
      ...ingredient,
      'confidence': (85 + _random.nextInt(15)).toString() + '%',
      'timestamp': DateTime.now().toString(),
      'image': _image!.path,
    };

    setState(() {
      _result = result;
      _history.insert(0, result);
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F6F6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Ingredient Analysis',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  collapseMode: CollapseMode.none,
                  background: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePreview(),
                      const SizedBox(height: 16),
                      _buildActionButtons(), // Gallery and Camera Button
                      const SizedBox(height: 24),
                      if (_result != null) _buildSearchButton(), // Search Button
                      const SizedBox(height: 24),
                      if (_result != null) _buildAnalysisResult(),
                      const SizedBox(height: 16),
                      _buildHistory(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_image != null)
              Image.file(
                File(_image!.path),
                fit: BoxFit.cover,
              )
            else
              Container(
                color: Colors.grey[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 60,
                      color: Color(0xFF007AFF),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Take or upload a photo of the ingredient',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    List<Map<String, dynamic>> displayResults =
    isExpanded ? _history : _history.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayResults.map((result) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    Text(
                      result['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        result['confidence'],
                        style: const TextStyle(
                          color: Color(0xFF34C759),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildNutritionInfo(result),
                const SizedBox(height: 20),
                _buildSuggestions(result),
              ],
            ),
          );
        }).toList(),
        if (_history.length > 3)
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(isExpanded ? 'Show Less' : 'Show All'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNutritionInfo(Map<String, dynamic> result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutrition Facts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNutritionItem('Calories', '${result['calories']}kcal'),
            _buildNutritionItem('Protein', '${result['protein']}g'),
            _buildNutritionItem('Fat', '${result['fat']}g'),
            _buildNutritionItem('Carbs', '${result['carbs']}g'),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007AFF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(Map<String, dynamic> result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggestions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...(result['suggestions'] as List).map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: Color(0xFF34C759),
              ),
              const SizedBox(width: 8),
              Text(suggestion),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.photo_library,
            label: 'Gallery',
            color: const Color(0xFF007AFF),
            onTap: () => _getImage(ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.camera_alt,
            label: 'Camera',
            color: const Color(0xFF34C759),
            onTap: () => _getImage(ImageSource.camera),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return _buildActionButton(
      icon: Icons.search,
      label: 'Search',
      color: const Color(0xFFFF9500),
      onTap: () {
        //TODO: Implement search function
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _history.length,
          itemBuilder: (context, index) {
            final item = _history[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(item['image']),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Calories: ${item['calories']}kcal',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    item['confidence'],
                    style: const TextStyle(
                      color: Color(0xFF34C759),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
