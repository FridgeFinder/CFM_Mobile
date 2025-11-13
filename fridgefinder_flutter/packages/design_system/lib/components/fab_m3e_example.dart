import 'package:flutter/material.dart';
import 'fab_m3e.dart';

/// Example showcase for Material 3 Expressive FAB components
///
/// This file demonstrates all FAB variants and features including:
/// - Regular, Small, and Large FABs
/// - Extended FABs with expand/collapse animation
/// - FAB Menu with staggered animations
/// - Icon Buttons (Standard, Filled, Tonal, Outlined)
/// - Toggle buttons with animations
///
/// Run this example to see all components in action.
class FABExampleScreen extends StatefulWidget {
  const FABExampleScreen({super.key});

  @override
  State<FABExampleScreen> createState() => _FABExampleScreenState();
}

class _FABExampleScreenState extends State<FABExampleScreen> {
  bool _extendedFABExpanded = true;
  bool _fabVisible = true;
  bool _iconButtonSelected = false;
  int _selectedVariant = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAB M3E Examples'),
        actions: [
          IconButtonM3E(
            icon: Icons.palette,
            onPressed: () {
              // Toggle theme
            },
            tooltip: 'Change theme',
          ),
          const SizedBox(width: 8),
          IconButtonM3E(
            icon: Icons.settings,
            onPressed: () {
              // Open settings
            },
            variant: IconButtonVariant.filled,
            tooltip: 'Settings',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ============================================================
          // SECTION: Regular FABs
          // ============================================================
          _buildSectionTitle('Regular FABs'),
          const Text('Standard floating action buttons in three sizes'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                children: [
                  FABM3E(
                    icon: Icons.add,
                    onPressed: () {},
                    size: FABSize.small,
                    tooltip: 'Small FAB',
                  ),
                  const SizedBox(height: 8),
                  const Text('Small (40x40)'),
                ],
              ),
              Column(
                children: [
                  FABM3E(
                    icon: Icons.add,
                    onPressed: () {},
                    size: FABSize.regular,
                    tooltip: 'Regular FAB',
                  ),
                  const SizedBox(height: 8),
                  const Text('Regular (56x56)'),
                ],
              ),
              Column(
                children: [
                  FABM3E(
                    icon: Icons.add,
                    onPressed: () {},
                    size: FABSize.large,
                    tooltip: 'Large FAB',
                  ),
                  const SizedBox(height: 8),
                  const Text('Large (96x96)'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // ============================================================
          // SECTION: Tonal FABs
          // ============================================================
          _buildSectionTitle('Tonal FABs'),
          const Text('Secondary container background variant'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              FABM3E(
                icon: Icons.edit,
                onPressed: () {},
                size: FABSize.small,
                tonal: true,
                tooltip: 'Small Tonal FAB',
              ),
              FABM3E(
                icon: Icons.edit,
                onPressed: () {},
                size: FABSize.regular,
                tonal: true,
                tooltip: 'Regular Tonal FAB',
              ),
              FABM3E(
                icon: Icons.edit,
                onPressed: () {},
                size: FABSize.large,
                tonal: true,
                tooltip: 'Large Tonal FAB',
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // ============================================================
          // SECTION: Extended FAB
          // ============================================================
          _buildSectionTitle('Extended FAB'),
          const Text('FAB with icon + label'),
          const SizedBox(height: 16),
          Row(
            children: [
              FABM3E(
                icon: Icons.add,
                label: 'Create',
                onPressed: () {},
                tooltip: 'Create new item',
              ),
              const SizedBox(width: 16),
              FABM3E(
                icon: Icons.favorite,
                label: 'Favorite',
                onPressed: () {},
                tonal: true,
                tooltip: 'Add to favorites',
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // ============================================================
          // SECTION: Extended FAB with Animation
          // ============================================================
          _buildSectionTitle('Extended FAB with Expand/Collapse'),
          const Text('Animates between icon-only and extended states'),
          const SizedBox(height: 16),
          Row(
            children: [
              ExtendedFABM3E(
                icon: Icons.edit,
                label: 'Edit',
                expanded: _extendedFABExpanded,
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _extendedFABExpanded = !_extendedFABExpanded;
                  });
                },
                child: Text(_extendedFABExpanded ? 'Collapse' : 'Expand'),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // ============================================================
          // SECTION: FAB Visibility Animation
          // ============================================================
          _buildSectionTitle('FAB Entrance/Exit Animation'),
          const Text('Scale animation with expressive spring'),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_fabVisible)
                FABM3E(
                  icon: Icons.add,
                  onPressed: () {},
                  visible: _fabVisible,
                ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _fabVisible = !_fabVisible;
                  });
                },
                child: Text(_fabVisible ? 'Hide FAB' : 'Show FAB'),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // ============================================================
          // SECTION: Icon Buttons - All Variants
          // ============================================================
          _buildSectionTitle('Icon Button Variants'),
          const Text('Standard, Filled, Tonal, and Outlined'),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                children: [
                  IconButtonM3E(
                    icon: Icons.favorite_border,
                    onPressed: () {},
                    variant: IconButtonVariant.standard,
                    tooltip: 'Standard',
                  ),
                  const SizedBox(height: 8),
                  const Text('Standard'),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  IconButtonM3E(
                    icon: Icons.favorite,
                    onPressed: () {},
                    variant: IconButtonVariant.filled,
                    tooltip: 'Filled',
                  ),
                  const SizedBox(height: 8),
                  const Text('Filled'),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  IconButtonM3E(
                    icon: Icons.favorite,
                    onPressed: () {},
                    variant: IconButtonVariant.tonal,
                    tooltip: 'Tonal',
                  ),
                  const SizedBox(height: 8),
                  const Text('Tonal'),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  IconButtonM3E(
                    icon: Icons.favorite_border,
                    onPressed: () {},
                    variant: IconButtonVariant.outlined,
                    tooltip: 'Outlined',
                  ),
                  const SizedBox(height: 8),
                  const Text('Outlined'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // ============================================================
          // SECTION: Toggle Icon Button
          // ============================================================
          _buildSectionTitle('Toggle Icon Button'),
          const Text('Icon button with selected state animation'),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButtonM3E(
                icon: Icons.favorite_border,
                selectedIcon: Icons.favorite,
                selected: _iconButtonSelected,
                onSelectedChanged: (selected) {
                  setState(() {
                    _iconButtonSelected = selected;
                  });
                },
                variant: IconButtonVariant.filled,
                tooltip: _iconButtonSelected ? 'Remove from favorites' : 'Add to favorites',
              ),
              const SizedBox(width: 16),
              Text(_iconButtonSelected ? 'Selected' : 'Not selected'),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // ============================================================
          // SECTION: Icon Button Group
          // ============================================================
          _buildSectionTitle('Icon Button Group'),
          const Text('Multiple icon buttons for common actions'),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButtonM3E(
                icon: Icons.share,
                onPressed: () {},
                tooltip: 'Share',
              ),
              IconButtonM3E(
                icon: Icons.bookmark_border,
                onPressed: () {},
                tooltip: 'Bookmark',
              ),
              IconButtonM3E(
                icon: Icons.more_vert,
                onPressed: () {},
                tooltip: 'More options',
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // ============================================================
          // SECTION: Custom Colors
          // ============================================================
          _buildSectionTitle('Custom Colors'),
          const Text('FABs and icon buttons with custom colors'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              FABM3E(
                icon: Icons.add,
                onPressed: () {},
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                tooltip: 'Green FAB',
              ),
              FABM3E(
                icon: Icons.star,
                onPressed: () {},
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                tooltip: 'Orange FAB',
              ),
              IconButtonM3E(
                icon: Icons.favorite,
                onPressed: () {},
                variant: IconButtonVariant.filled,
                backgroundColor: Colors.pink,
                color: Colors.white,
                tooltip: 'Pink icon button',
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          // ============================================================
          // SECTION: Variant Selector
          // ============================================================
          _buildSectionTitle('Interactive Variant Selector'),
          const Text('Switch between different icon button variants'),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButtonM3E(
                icon: Icons.star,
                onPressed: () {},
                variant: IconButtonVariant.values[_selectedVariant],
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _selectedVariant,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Standard')),
                  DropdownMenuItem(value: 1, child: Text('Filled')),
                  DropdownMenuItem(value: 2, child: Text('Tonal')),
                  DropdownMenuItem(value: 3, child: Text('Outlined')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedVariant = value ?? 0;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 80), // Space for FAB Menu
        ],
      ),
      floatingActionButton: FABMenuM3E(
        icon: Icons.add,
        openIcon: Icons.close,
        tooltip: 'Create new',
        items: [
          FABMenuItem(
            icon: Icons.photo,
            label: 'Photo',
            onPressed: () {
              _showSnackBar(context, 'Photo selected');
            },
          ),
          FABMenuItem(
            icon: Icons.video_library,
            label: 'Video',
            onPressed: () {
              _showSnackBar(context, 'Video selected');
            },
          ),
          FABMenuItem(
            icon: Icons.article,
            label: 'Document',
            onPressed: () {
              _showSnackBar(context, 'Document selected');
            },
          ),
          FABMenuItem(
            icon: Icons.audiotrack,
            label: 'Audio',
            onPressed: () {
              _showSnackBar(context, 'Audio selected');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Example app entry point
class FABExampleApp extends StatelessWidget {
  const FABExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAB M3E Examples',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const FABExampleScreen(),
    );
  }
}

void main() {
  runApp(const FABExampleApp());
}
