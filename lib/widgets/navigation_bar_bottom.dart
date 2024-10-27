// lib/widgets/navigation_bar_bottom.dart
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, 'Home'),
                  _buildNavItem(1, 'Search'),
                  const SizedBox(width: 60),
                  _buildNavItem(3, 'History'),
                  _buildNavItem(4, 'Profile'),
                ],
              ),
              Positioned(
                top: -20,
                left: 0,
                right: 0,
                child: _buildScanButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(index, isSelected),
            const SizedBox(height: 6),
            _buildLabel(label, isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(int index, bool isSelected) {
    final String iconPath = _getIconPath(index, isSelected);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        iconPath,
        width: isSelected ? 28 : 24, // regular 24dp，selected 28dp
        height: isSelected ? 28 : 24,
        color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
      ),
    );
  }

  Widget _buildLabel(String label, bool isSelected) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
      ),
      child: Text(label),
    );
  }

  Widget _buildScanButton() {
    return Center(
      child: GestureDetector(
        onTap: () => onTap(2),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF007AFF),
                Color(0xFF007AFF),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/scan.png',
              width: 32,
              height: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _getIconPath(int index, bool isSelected) {
    switch (index) {
      case 0:
        return isSelected
            ? 'assets/icons/home_selected.png'
            : 'assets/icons/home.png';
      case 1:
        return isSelected
            ? 'assets/icons/search_selected.png'
            : 'assets/icons/search.png';
      case 3:
        return isSelected
            ? 'assets/icons/history_selected.png'
            : 'assets/icons/history.png';
      case 4:
        return isSelected
            ? 'assets/icons/profile_selected.png'
            : 'assets/icons/profile.png';
      default:
        return 'assets/icons/default.png';
    }
  }
}