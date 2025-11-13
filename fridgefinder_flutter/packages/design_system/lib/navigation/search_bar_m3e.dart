import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/elevation.dart';

/// Material 3 Expressive Search Bar
///
/// A fully animated search bar component that follows M3E design specifications
/// with expressive animations and smooth state transitions.
///
/// SPECIFICATIONS:
/// - Height: 56dp
/// - Corner radius: 28dp (extra-large, fully rounded pill shape)
/// - Shadow: Elevation level 2 (3dp)
/// - Background: surfaceContainerHigh color
///
/// STATES:
/// - Inactive (collapsed): Resting state
/// - Active (expanded): User interaction, text input
/// - Interactive: Hover, focus, press states
///
/// ANIMATIONS:
/// - Expand: 300ms with emphasizedDecelerate curve
/// - Collapse: 250ms with emphasizedAccelerate curve
/// - Icon slide: 30dp left translation during expand
/// - Clear button: Fade in/out (150ms)
///
/// Example usage:
/// ```dart
/// SearchBarM3E(
///   hintText: 'Search for fridges...',
///   onChanged: (value) => print('Search: $value'),
///   onSubmitted: (value) => performSearch(value),
///   autoFocus: false,
///   leadingIcon: Icons.search,
///   showVoiceSearch: true,
/// )
/// ```
class SearchBarM3E extends StatefulWidget {
  /// Controller for the search text field
  final TextEditingController? controller;

  /// Callback when the search text changes
  final ValueChanged<String>? onChanged;

  /// Callback when the user submits the search
  final ValueChanged<String>? onSubmitted;

  /// Hint text displayed when the search bar is empty
  final String? hintText;

  /// Leading icon (default: search icon)
  final IconData? leadingIcon;

  /// Custom trailing widget (replaces default trailing icons)
  final Widget? trailing;

  /// Whether to show the voice search button
  final bool showVoiceSearch;

  /// Callback when voice search is pressed
  final VoidCallback? onVoiceSearch;

  /// Whether the search bar should auto-focus on mount
  final bool autoFocus;

  /// Whether the search bar is enabled
  final bool enabled;

  /// Custom elevation (default: level2 = 3dp)
  final double? elevation;

  /// Callback when the search bar is tapped (collapsed state)
  final VoidCallback? onTap;

  /// Whether to show the search bar in expanded state by default
  final bool expandedByDefault;

  /// Custom background color (default: surfaceContainerHigh)
  final Color? backgroundColor;

  const SearchBarM3E({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.leadingIcon,
    this.trailing,
    this.showVoiceSearch = false,
    this.onVoiceSearch,
    this.autoFocus = false,
    this.enabled = true,
    this.elevation,
    this.onTap,
    this.expandedByDefault = false,
    this.backgroundColor,
  });

  @override
  State<SearchBarM3E> createState() => _SearchBarM3EState();
}

class _SearchBarM3EState extends State<SearchBarM3E>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _expandController;
  late AnimationController _iconMorphController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconSlideAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _clearButtonAnimation;

  // Text controller
  late TextEditingController _textController;
  bool _isInternalController = false;

  // Focus node
  late FocusNode _focusNode;

  // State
  bool _isExpanded = false;
  bool _isHovered = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    // Initialize text controller
    if (widget.controller != null) {
      _textController = widget.controller!;
    } else {
      _textController = TextEditingController();
      _isInternalController = true;
    }

    // Listen to text changes for clear button visibility
    _textController.addListener(_onTextChanged);

    // Initialize focus node
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);

    // Initialize animation controllers
    _expandController = AnimationController(
      vsync: this,
      duration: M3EMotion.getDuration(
        M3EMotion.medium4,
      ), // 400ms for smoother expand
      reverseDuration: M3EMotion.getDuration(
        M3EMotion.medium3,
      ), // 350ms for smoother collapse
    );

    _iconMorphController = AnimationController(
      vsync: this,
      duration: M3EMotion.getDuration(M3EMotion.medium3),
    );

    // Expand animation (for width/shape changes)
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: M3EMotion.emphasizedDecelerate,
      reverseCurve: M3EMotion.emphasizedAccelerate,
    );

    // Icon slide animation (8dp left translation)
    _iconSlideAnimation = Tween<double>(
      begin: 0.0,
      end: -8.0,
    ).animate(_expandAnimation);

    // Icon scale/morph animation
    _iconScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: M3EMotion.expressiveFastOvershoot)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: M3EMotion.emphasizedDecelerate)),
        weight: 50.0,
      ),
    ]).animate(_iconMorphController);

    // Clear button fade animation
    _clearButtonAnimation = CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      reverseCurve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    // Set initial state
    if (widget.expandedByDefault || widget.autoFocus) {
      _isExpanded = true;
      _expandController.value = 1.0;
    }

    // Auto focus if requested
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    if (_isInternalController) {
      _textController.dispose();
    }
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _expandController.dispose();
    _iconMorphController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isExpanded) {
      _expand();
    } else if (!_focusNode.hasFocus && _isExpanded) {
      _collapse();
    }
  }

  void _expand() {
    if (!_isExpanded && widget.enabled) {
      setState(() {
        _isExpanded = true;
      });
      _expandController.forward();
      _iconMorphController.forward(); // Trigger icon morph animation
    }
  }

  void _collapse() {
    if (_isExpanded && !_focusNode.hasFocus && !_hasText) {
      setState(() {
        _isExpanded = false;
      });
      _expandController.reverse();
    }
  }

  void _handleTap() {
    if (!_isExpanded) {
      _expand();
      _focusNode.requestFocus();
      widget.onTap?.call();
    }
  }

  void _handleClear() {
    _textController.clear();
    widget.onChanged?.call('');
    // Don't re-focus after clearing - just clear the text
  }

  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    _focusNode.unfocus();
    // Collapse if empty
    if (value.isEmpty) {
      _collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveElevation = widget.elevation ?? M3EElevation.level2;
    final effectiveBackgroundColor =
        widget.backgroundColor ?? colorScheme.surfaceContainerHigh;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            // Calculate current state-based elevation
            final currentElevation = _isHovered && !_isExpanded
                ? M3EElevation.searchBarHovered
                : effectiveElevation;

            return Container(
              height: 56.0,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: BorderRadius.circular(28.0),
                boxShadow: M3EElevation.getShadow(currentElevation),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(28.0),
                child: Row(
                  children: [
                    // Leading icon with slide and morph animations
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _iconSlideAnimation,
                        _iconScaleAnimation,
                      ]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_iconSlideAnimation.value, 0),
                          child: Transform.scale(
                            scale: _iconScaleAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: M3ESpacing.md,
                                right: M3ESpacing.xs,
                              ),
                              child: Icon(
                                widget.leadingIcon ?? Icons.search,
                                size: 24.0,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Text field (expands to fill available space)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _isExpanded
                            ? TextField(
                                controller: _textController,
                                focusNode: _focusNode,
                                onChanged: widget.onChanged,
                                onSubmitted: _handleSubmitted,
                                enabled: widget.enabled,
                                style: M3ETypography.bodyLarge.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: widget.hintText ?? 'Search',
                                  hintStyle: M3ETypography.bodyLarge.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  filled: false,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Text(
                                  widget.hintText ?? 'Search',
                                  style: M3ETypography.bodyLarge.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Trailing icons (clear button and optional voice search)
                    if (_isExpanded) ...[
                      // Clear button (fades in when text is present)
                      if (_hasText)
                        FadeTransition(
                          opacity: _clearButtonAnimation,
                          child: IconButton(
                            onPressed: _handleClear,
                            icon: const Icon(Icons.clear),
                            iconSize: 20.0,
                            color: colorScheme.onSurfaceVariant,
                            tooltip: 'Clear',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40.0,
                              minHeight: 40.0,
                            ),
                          ),
                        ),

                      // Custom trailing or voice search button
                      if (widget.trailing != null)
                        Padding(
                          padding: const EdgeInsets.only(right: M3ESpacing.xs),
                          child: widget.trailing!,
                        )
                      else if (widget.showVoiceSearch)
                        Padding(
                          padding: const EdgeInsets.only(right: M3ESpacing.xs),
                          child: IconButton(
                            onPressed: widget.onVoiceSearch,
                            icon: const Icon(Icons.mic),
                            iconSize: 24.0,
                            color: colorScheme.onSurfaceVariant,
                            tooltip: 'Voice search',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40.0,
                              minHeight: 40.0,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: M3ESpacing.md),
                    ] else
                      const SizedBox(width: M3ESpacing.md),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Compact Search Bar M3E
///
/// A smaller variant of the search bar for constrained spaces.
/// Height: 48dp instead of 56dp
///
/// Example usage:
/// ```dart
/// CompactSearchBarM3E(
///   hintText: 'Search...',
///   onChanged: (value) => print('Search: $value'),
/// )
/// ```
class CompactSearchBarM3E extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final IconData? leadingIcon;
  final Widget? trailing;
  final bool showVoiceSearch;
  final VoidCallback? onVoiceSearch;
  final bool autoFocus;
  final bool enabled;

  const CompactSearchBarM3E({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.leadingIcon,
    this.trailing,
    this.showVoiceSearch = false,
    this.onVoiceSearch,
    this.autoFocus = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: M3EElevation.getShadow(M3EElevation.level1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autoFocus,
        enabled: enabled,
        style: M3ETypography.bodyMedium.copyWith(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hintText ?? 'Search',
          hintStyle: M3ETypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            leadingIcon ?? Icons.search,
            size: 20.0,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon:
              trailing ??
              (showVoiceSearch
                  ? IconButton(
                      onPressed: onVoiceSearch,
                      icon: const Icon(Icons.mic),
                      iconSize: 20.0,
                      color: colorScheme.onSurfaceVariant,
                    )
                  : null),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: M3ESpacing.md,
            vertical: M3ESpacing.sm,
          ),
        ),
      ),
    );
  }
}

/// Search Bar with Suggestions
///
/// An extended search bar that displays a dropdown with search suggestions
/// or results below the search field.
///
/// Example usage:
/// ```dart
/// SearchBarWithSuggestionsM3E(
///   hintText: 'Search fridges...',
///   suggestions: ['Community Fridge A', 'Community Fridge B'],
///   onSuggestionSelected: (suggestion) => navigateToFridge(suggestion),
/// )
/// ```
class SearchBarWithSuggestionsM3E extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestionSelected;
  final Widget Function(BuildContext, String)? suggestionBuilder;
  final bool autoFocus;

  const SearchBarWithSuggestionsM3E({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.suggestions = const [],
    this.onSuggestionSelected,
    this.suggestionBuilder,
    this.autoFocus = false,
  });

  @override
  State<SearchBarWithSuggestionsM3E> createState() =>
      _SearchBarWithSuggestionsM3EState();
}

class _SearchBarWithSuggestionsM3EState
    extends State<SearchBarWithSuggestionsM3E>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  bool _isInternalController = false;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];
  late AnimationController _staggerController;
  static const Duration _staggerDelay = Duration(milliseconds: 30);

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }

    _controller.addListener(_onTextChanged);

    _staggerController = AnimationController(
      vsync: this,
      duration: M3EMotion.getDuration(M3EMotion.medium4),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    _staggerController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _controller.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _filteredSuggestions = [];
      });
      _staggerController.reset();
      return;
    }

    final filtered = widget.suggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query))
        .toList();

    setState(() {
      _showSuggestions = filtered.isNotEmpty;
      _filteredSuggestions = filtered;
    });

    if (filtered.isNotEmpty) {
      _staggerController.reset();
      _staggerController.forward();
    } else {
      _staggerController.reset();
    }

    widget.onChanged?.call(_controller.text);
  }

  void _handleSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    widget.onSuggestionSelected?.call(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchBarM3E(
          controller: _controller,
          onSubmitted: widget.onSubmitted,
          hintText: widget.hintText,
          autoFocus: widget.autoFocus,
          expandedByDefault: true,
        ),
        if (_showSuggestions) ...[
          M3ESpacing.verticalXS,
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: M3EElevation.getShadow(M3EElevation.level2),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: M3ESpacing.xs),
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                final delay = index * _staggerDelay.inMilliseconds;
                final animation = CurvedAnimation(
                  parent: _staggerController,
                  curve: Interval(
                    (delay / _staggerController.duration!.inMilliseconds).clamp(
                      0.0,
                      1.0,
                    ),
                    1.0,
                    curve: M3EMotion.emphasizedDecelerate,
                  ),
                );

                Widget suggestionWidget;
                if (widget.suggestionBuilder != null) {
                  suggestionWidget = widget.suggestionBuilder!(
                    context,
                    suggestion,
                  );
                } else {
                  suggestionWidget = ListTile(
                    leading: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    title: Text(suggestion),
                    dense: true,
                  );
                }

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: InkWell(
                      onTap: () => _handleSuggestionTap(suggestion),
                      child: suggestionWidget,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
