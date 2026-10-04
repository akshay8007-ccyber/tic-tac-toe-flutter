import 'package:flutter/material.dart';

import '../../../core/utils/haptic_utility.dart';

/// Modal dialog explaining the interactive 3-Mark Select & Move mechanic
/// with modern page view animations.
class HowToPlayModal extends StatefulWidget {
  const HowToPlayModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HowToPlayModal(),
    );
  }

  @override
  State<HowToPlayModal> createState() => _HowToPlayModalState();
}

class _HowToPlayModalState extends State<HowToPlayModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Phase 1: Place 3 Marks',
      'subtitle':
          'Each player starts by placing up to 3 marks on the grid. Tap any empty tile to drop your mark.',
      'icon': Icons.grid_view_rounded,
      'badge': 'Step 1 of 3',
      'color': const Color(0xFF6750A4),
      'visual': _buildStep1Visual(),
    },
    {
      'title': 'Phase 2: Select & Move',
      'subtitle':
          'Once all 3 marks are placed, you cannot add more! Tap one of your marks to select it, then tap an empty tile to move it.',
      'icon': Icons.touch_app_rounded,
      'badge': 'Step 2 of 3',
      'color': const Color(0xFFE8873A),
      'visual': _buildStep2Visual(),
    },
    {
      'title': 'Phase 3: Line Up 3 to Win',
      'subtitle':
          'Align 3 of your marks horizontally, vertically, or diagonally. Be strategic — your opponent will try to block your moves!',
      'icon': Icons.emoji_events_rounded,
      'badge': 'Step 3 of 3',
      'color': const Color(0xFF2E7D32),
      'visual': _buildStep3Visual(),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1B26) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'How to Play',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 24, indent: 24, endIndent: 24),

          // Page View Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _steps.length,
              onPageChanged: (index) {
                HapticUtility.selection(enabled: true);
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final step = _steps[index];
                final stepColor = step['color'] as Color;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: stepColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: stepColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          step['badge'] as String,
                          style: TextStyle(
                            color: stepColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        step['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step['subtitle'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      step['visual'] as Widget,
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),

          // Footer Controls & Indicators
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(_steps.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                FilledButton.icon(
                  onPressed: () {
                    HapticUtility.light(enabled: true);
                    if (_currentPage < _steps.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(
                    _currentPage == _steps.length - 1
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    _currentPage == _steps.length - 1
                        ? 'Got it!'
                        : 'Next Step',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStep1Visual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6750A4).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _miniCell('X', color: const Color(0xFF6750A4)),
          const SizedBox(width: 8),
          _miniCell('O', color: const Color(0xFFE8873A)),
          const SizedBox(width: 8),
          _miniCell('X', color: const Color(0xFF6750A4)),
        ],
      ),
    );
  }

  static Widget _buildStep2Visual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8873A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _miniCell('X',
                  color: const Color(0xFF6750A4),
                  isSelected: true,
                  badge: 'Tap to Select'),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_rounded,
                  color: Color(0xFFE8873A)),
              const SizedBox(width: 12),
              _miniCell('',
                  color: Colors.transparent,
                  isEmptyTarget: true,
                  badge: 'Tap to Move'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildStep3Visual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _miniCell('X', color: const Color(0xFF2E7D32), isWinner: true),
          const SizedBox(width: 8),
          _miniCell('X', color: const Color(0xFF2E7D32), isWinner: true),
          const SizedBox(width: 8),
          _miniCell('X', color: const Color(0xFF2E7D32), isWinner: true),
        ],
      ),
    );
  }

  static Widget _miniCell(
    String symbol, {
    required Color color,
    bool isSelected = false,
    bool isEmptyTarget = false,
    bool isWinner = false,
    String? badge,
  }) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isWinner
                ? color.withValues(alpha: 0.25)
                : (isSelected
                    ? color.withValues(alpha: 0.2)
                    : (isEmptyTarget
                        ? Colors.amber.withValues(alpha: 0.15)
                        : Colors.white)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected || isWinner
                  ? color
                  : (isEmptyTarget
                      ? Colors.amber
                      : Colors.grey.withValues(alpha: 0.3)),
              width: isSelected || isWinner ? 2.5 : 1.2,
            ),
          ),
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isWinner ? color : color,
            ),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(height: 6),
          Text(
            badge,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isSelected ? color : Colors.amber.shade800,
            ),
          ),
        ],
      ],
    );
  }
}
