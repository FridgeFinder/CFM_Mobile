import 'package:flutter/material.dart';
import 'loading_m3e_morphing.dart';
import '../theme/spacing.dart';

/// Example usage of M3E Morphing Loading Indicators
///
/// This file demonstrates all variants and use cases for the morphing
/// loading indicators following Material 3 Expressive design philosophy.
class MorphingLoadingExamplesScreen extends StatelessWidget {
  const MorphingLoadingExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M3E Morphing Loading Indicators'),
      ),
      body: SingleChildScrollView(
        padding: M3ESpacing.all(M3ESpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Shape Morph'),
            _buildDescription(
                'Smooth transitions between circle → square → rounded square → circle'),
            _buildExampleCard(
              child: const MorphingLoadingIndicatorM3E.shapeMorph(
                message: 'Loading...',
              ),
            ),
            M3ESpacing.verticalXL,
            _buildSectionTitle('Blob Morph'),
            _buildDescription(
                'Organic blob that expands/contracts with bezier curves'),
            _buildExampleCard(
              child: const MorphingLoadingIndicatorM3E.blobMorph(
                message: 'Processing data...',
              ),
            ),
            M3ESpacing.verticalXL,
            _buildSectionTitle('Connected Dots'),
            _buildDescription(
                '4 dots that move and form geometric patterns with connecting lines'),
            _buildExampleCard(
              child: const MorphingLoadingIndicatorM3E.connectedDots(
                message: 'Syncing...',
              ),
            ),
            M3ESpacing.verticalXL,
            _buildSectionTitle('Breathing Shape'),
            _buildDescription(
                'Shape that "breathes" by morphing corners and pulsing size'),
            _buildExampleCard(
              child: const MorphingLoadingIndicatorM3E.breathing(
                message: 'Updating...',
              ),
            ),
            M3ESpacing.verticalXL,
            _buildSectionTitle('Liquid Flow'),
            _buildDescription(
                'Liquid-like flowing shapes with smooth, organic motion'),
            _buildExampleCard(
              child: const MorphingLoadingIndicatorM3E.liquidFlow(
                message: 'Preparing...',
              ),
            ),
            M3ESpacing.verticalXL,
            _buildSectionTitle('Size Variants'),
            _buildDescription(
                'Fullscreen (64dp) vs Inline (48dp) variants'),
            _buildExampleCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const MorphingLoadingIndicatorM3E.shapeMorph(
                        size: 64,
                      ),
                      M3ESpacing.verticalSM,
                      const Text('64dp'),
                    ],
                  ),
                  Column(
                    children: [
                      const MorphingLoadingIndicatorM3E.inlineShapeMorph(),
                      M3ESpacing.verticalSM,
                      const Text('48dp (inline)'),
                    ],
                  ),
                  Column(
                    children: [
                      const MorphingLoadingIndicatorM3E.shapeMorph(
                        size: 32,
                      ),
                      M3ESpacing.verticalSM,
                      const Text('32dp (small)'),
                    ],
                  ),
                ],
              ),
            ),
            M3ESpacing.verticalXL,
            _buildSectionTitle('Custom Colors'),
            _buildDescription(
                'All variants support custom colors with surface tint'),
            _buildExampleCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MorphingLoadingIndicatorM3E.blobMorph(
                    size: 48,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  MorphingLoadingIndicatorM3E.breathing(
                    size: 48,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  MorphingLoadingIndicatorM3E.liquidFlow(
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
            M3ESpacing.verticalXL,
            _buildSectionTitle('Use Cases'),
            _buildUseCase(
              'Fullscreen Loading',
              'Use fullscreen variants with messages for page loads',
              const MorphingLoadingIndicatorM3E.fullscreenBlobMorph(
                message: 'Loading your content...',
              ),
            ),
            M3ESpacing.verticalMD,
            _buildUseCase(
              'Inline Loading',
              'Use inline variants for component-level loading states',
              Row(
                children: [
                  const MorphingLoadingIndicatorM3E.inlineShapeMorph(),
                  M3ESpacing.horizontalMD,
                  const Expanded(
                    child: Text('Processing your request...'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) => Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Builder(
      builder: (context) => Padding(
        padding: M3ESpacing.only(top: M3ESpacing.xs, bottom: M3ESpacing.md),
        child: Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  Widget _buildExampleCard({required Widget child}) {
    return Card(
      elevation: 0,
      child: Container(
        padding: M3ESpacing.all(M3ESpacing.xl),
        constraints: const BoxConstraints(minHeight: 150),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildUseCase(String title, String description, Widget example) {
    return Builder(
      builder: (context) => Card(
        elevation: 0,
        child: Padding(
          padding: M3ESpacing.all(M3ESpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              M3ESpacing.verticalXS,
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              M3ESpacing.verticalMD,
              example,
            ],
          ),
        ),
      ),
    );
  }
}

/// Example integration in a real screen
class LoadingScreenExample extends StatefulWidget {
  const LoadingScreenExample({super.key});

  @override
  State<LoadingScreenExample> createState() => _LoadingScreenExampleState();
}

class _LoadingScreenExampleState extends State<LoadingScreenExample> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: MorphingLoadingIndicatorM3E.fullscreenBlobMorph(
          message: 'Loading your content...',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Loaded'),
      ),
      body: const Center(
        child: Text('Your content appears here'),
      ),
    );
  }
}

/// Example inline loading in a list
class InlineLoadingListExample extends StatelessWidget {
  const InlineLoadingListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inline Loading Example'),
      ),
      body: ListView(
        children: [
          _buildListItem('Item 1', isLoaded: true),
          _buildListItem('Item 2', isLoaded: true),
          _buildListItem('Item 3', isLoaded: false),
          _buildListItem('Item 4', isLoaded: false),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, {required bool isLoaded}) {
    return ListTile(
      leading: const Icon(Icons.article),
      title: Text(title),
      trailing: isLoaded
          ? const Icon(Icons.check, color: Colors.green)
          : const MorphingLoadingIndicatorM3E.inlineShapeMorph(),
    );
  }
}

/// Example button with loading state
class ButtonWithLoadingExample extends StatefulWidget {
  const ButtonWithLoadingExample({super.key});

  @override
  State<ButtonWithLoadingExample> createState() =>
      _ButtonWithLoadingExampleState();
}

class _ButtonWithLoadingExampleState extends State<ButtonWithLoadingExample> {
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Loading Example'),
      ),
      body: Center(
        child: FilledButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: MorphingLoadingIndicatorM3E.shapeMorph(
                    size: 24,
                  ),
                )
              : const Text('Submit'),
        ),
      ),
    );
  }
}
