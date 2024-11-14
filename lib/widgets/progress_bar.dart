import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  final double progressValue;

  const ProgressBar({
    super.key,
    this.progressValue = 0.75, // 75 by default
  });

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.bar_chart_rounded,
                  color: Color(0xFF1A1A1A),
                ),
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
                  color: Color(0xFF888888),
                  fontSize: 14,
                ),
              ),
              Text(
                "3750 / 5000",
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: 10,
                width: MediaQuery.of(context).size.width * widget.progressValue * 0.8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6DC7EF), Color(0xFF007AFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${(widget.progressValue * 100).toInt()}% Complete",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstChild: Container(),
            secondChild: _buildExpandedStats(),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedStats() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detailed Statistics",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18),
              SizedBox(width: 8),
              Text(
                "Blog Posted: 30",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.access_time, color: Color(0xFF4CAF50), size: 18),
              SizedBox(width: 8),
              Text(
                "Time Spent: 12 hours",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.show_chart, color: Color(0xFF4CAF50), size: 18),
              SizedBox(width: 8),
              Text(
                "Weekly Goal: 10%",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}