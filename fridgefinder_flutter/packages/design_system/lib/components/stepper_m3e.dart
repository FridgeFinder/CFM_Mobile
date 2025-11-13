import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/transitions.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'buttons_m3e.dart';

/// Material 3 Expressive Stepper Component
///
/// A stepper displays progress through a sequence of steps.
/// Supports both horizontal and vertical layouts with smooth animations.
///
/// Example:
/// ```dart
/// StepperM3E(
///   currentStep: 0,
///   steps: [
///     StepperStepM3E(
///       title: 'Volunteer',
///       content: VolunteerStepContent(),
///     ),
///     StepperStepM3E(
///       title: 'Zip Code',
///       content: ZipCodeStepContent(),
///     ),
///   ],
///   onStepTapped: (index) => setState(() => currentStep = index),
///   onStepContinue: () => setState(() => currentStep++),
///   onStepCancel: () => setState(() => currentStep--),
/// )
/// ```
class StepperM3E extends StatefulWidget {
  /// Current active step index (0-based)
  final int currentStep;

  /// List of steps to display
  final List<StepperStepM3E> steps;

  /// Called when a step is tapped
  final ValueChanged<int>? onStepTapped;

  /// Called when continue button is pressed
  final VoidCallback? onStepContinue;

  /// Called when cancel/back button is pressed
  final VoidCallback? onStepCancel;

  /// Stepper orientation
  final StepperType type;

  /// Controls whether steps can be tapped to navigate
  final bool stepsTappable;

  /// Controls whether step content is expanded
  final bool stepExpansion;

  /// Custom controls builder
  final ControlsBuilder? controlsBuilder;

  /// Physics for step content scrolling
  final ScrollPhysics? physics;

  const StepperM3E({
    super.key,
    required this.currentStep,
    required this.steps,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.type = StepperType.horizontal,
    this.stepsTappable = true,
    this.stepExpansion = true,
    this.controlsBuilder,
    this.physics,
  }) : assert(currentStep >= 0 && currentStep < steps.length);

  @override
  State<StepperM3E> createState() => _StepperM3EState();
}

class _StepperM3EState extends State<StepperM3E>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  late AnimationController _indicatorController;
  late List<AnimationController> _stepControllers;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium4), // 400ms for smoother content transitions
      vsync: this,
    );
    _indicatorController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for smoother indicator
      vsync: this,
    );
    _stepControllers = List.generate(
      widget.steps.length,
      (index) => AnimationController(
        duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for smoother step transitions
        vsync: this,
      ),
    );
    _contentController.forward();
    _indicatorController.forward();
    for (var controller in _stepControllers) {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(StepperM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      // Animate step transition
      _contentController.reset();
      _contentController.forward();
      _indicatorController.reset();
      _indicatorController.forward();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _indicatorController.dispose();
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == StepperType.horizontal) {
      return _buildHorizontalStepper();
    } else {
      return _buildVerticalStepper();
    }
  }

  Widget _buildHorizontalStepper() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Step indicators with connector lines
        Padding(
          padding: M3ESpacing.symmetric(horizontal: M3ESpacing.md),
          child: Row(
            children: List.generate(
              widget.steps.length * 2 - 1, // Include connector lines
              (index) {
                if (index.isEven) {
                  // Step indicator
                  final stepIndex = index ~/ 2;
                  return Expanded(
                    flex: 2,
                    child: _buildHorizontalStepIndicator(stepIndex),
                  );
                } else {
                  // Connector line between steps
                  final stepIndex = index ~/ 2;
                  final isCompleted = stepIndex < widget.currentStep;
                  return Expanded(
                    flex: 1,
                    child: Padding(
                      padding: M3ESpacing.only(
                        left: M3ESpacing.xs,
                        right: M3ESpacing.xs,
                        top: 32, // Align with step circles
                      ),
                      child: AnimatedContainer(
                        duration: M3EMotion.getDuration(M3EMotion.medium3),
                        curve: M3EMotion.emphasizedDecelerate,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                          // Subtle gradient for completed connectors
                          gradient: isCompleted
                              ? LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primary.withValues(alpha: 0.8),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        M3ESpacing.verticalXXL, // More breathing room
        // Step content with SharedAxisZ transition
        Expanded(
          child: M3ETransitions.sharedAxisZ(
            animation: _contentController,
            secondaryAnimation: _contentController,
            child: widget.steps[widget.currentStep].content,
          ),
        ),
        // Controls
        if (widget.controlsBuilder != null)
          widget.controlsBuilder!(
            context,
            ControlsDetails(
              onStepContinue: widget.onStepContinue,
              onStepCancel: widget.onStepCancel,
              stepIndex: widget.currentStep,
            ),
          )
        else
          _buildDefaultControls(),
      ],
    );
  }

  Widget _buildVerticalStepper() {
    return ListView(
      physics: widget.physics,
      children: List.generate(
        widget.steps.length,
        (index) => _buildVerticalStep(index),
      ),
    );
  }

  Widget _buildHorizontalStepIndicator(int index) {
    final step = widget.steps[index];
    final isActive = index == widget.currentStep;
    final isCompleted = index < widget.currentStep;
    final isError = step.state == StepState.error;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.stepsTappable && (isCompleted || isActive)
          ? () => widget.onStepTapped?.call(index)
          : null,
      child: Column(
        children: [
          // Step circle with enhanced animations and visual states
          AnimatedBuilder(
            animation: _stepControllers[index],
            builder: (context, child) {
              // Enhanced scale animation for active state
              final scale = isActive
                  ? 1.0 + (_indicatorController.value * 0.15) // More pronounced scale
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: M3EMotion.getDuration(M3EMotion.medium3),
                  curve: M3EMotion.emphasizedDecelerate,
                  width: isActive ? 40 : 32, // Larger when active
                  height: isActive ? 40 : 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStepColor(isActive, isCompleted, isError),
                    // Enhanced elevation for active state
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : isCompleted
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                    // Subtle border for inactive steps
                    border: !isActive && !isCompleted && !isError
                        ? Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: M3EMotion.getDuration(M3EMotion.medium2),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              key: ValueKey('check_$index'),
                              color: colorScheme.onPrimary,
                              size: isActive ? 24 : 20,
                            )
                          : isError
                              ? Icon(
                                  Icons.error_rounded,
                                  key: ValueKey('error_$index'),
                                  color: colorScheme.onError,
                                  size: isActive ? 24 : 20,
                                )
                              : Text(
                                  '${index + 1}',
                                  key: ValueKey('number_$index'),
                                  style: M3ETypography.labelLarge.copyWith(
                                    color: !isActive && !isCompleted
                                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                                        : colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isActive ? 18 : 16,
                                  ),
                                ),
                    ),
                  ),
                ),
              );
            },
          ),
          M3ESpacing.verticalXS, // More breathing room
          // Step label with enhanced typography
          AnimatedDefaultTextStyle(
            duration: M3EMotion.getDuration(M3EMotion.medium2),
            curve: M3EMotion.emphasizedDecelerate,
            style: M3ETypography.labelMedium.copyWith(
              color: isActive
                  ? colorScheme.primary
                  : isCompleted
                      ? colorScheme.primary.withValues(alpha: 0.7)
                      : colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: isActive ? 13 : 12,
            ),
            child: Text(
              step.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalStep(int index) {
    final step = widget.steps[index];
    final isActive = index == widget.currentStep;
    final isCompleted = index < widget.currentStep;
    final isError = step.state == StepState.error;
    final isExpanded = widget.stepExpansion && isActive;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Step header with enhanced interactivity
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.stepsTappable && (isCompleted || isActive)
                ? () => widget.onStepTapped?.call(index)
                : null,
            borderRadius: BorderRadius.circular(M3ESpacing.md),
            child: Padding(
              padding: M3ESpacing.symmetric(
                horizontal: M3ESpacing.sm,
                vertical: M3ESpacing.sm,
              ),
              child: Row(
                children: [
                  // Step circle with enhanced animations
                  AnimatedBuilder(
                    animation: _stepControllers[index],
                    builder: (context, child) {
                      return AnimatedContainer(
                        duration: M3EMotion.getDuration(M3EMotion.medium3),
                        curve: M3EMotion.emphasizedDecelerate,
                        width: isActive ? 48 : 40,
                        height: isActive ? 48 : 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStepColor(isActive, isCompleted, isError),
                          // Enhanced elevation and glow for active state
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : isCompleted
                                  ? [
                                      BoxShadow(
                                        color: colorScheme.primary.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                          // Border for inactive steps
                          border: !isActive && !isCompleted && !isError
                              ? Border.all(
                                  color: colorScheme.outline.withValues(alpha: 0.3),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: M3EMotion.getDuration(M3EMotion.medium2),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: isCompleted
                                ? Icon(
                                    Icons.check_rounded,
                                    key: ValueKey('check_$index'),
                                    color: colorScheme.onPrimary,
                                    size: isActive ? 28 : 24,
                                  )
                                : isError
                                    ? Icon(
                                        Icons.error_rounded,
                                        key: ValueKey('error_$index'),
                                        color: colorScheme.onError,
                                        size: isActive ? 28 : 24,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        key: ValueKey('number_$index'),
                                        style: M3ETypography.titleMedium.copyWith(
                                          color: !isActive && !isCompleted
                                              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                                              : colorScheme.onPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: isActive ? 20 : 18,
                                        ),
                                      ),
                          ),
                        ),
                      );
                    },
                  ),
                  M3ESpacing.horizontalLG, // More breathing room
                  // Step title and subtitle with better typography
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: M3EMotion.getDuration(M3EMotion.medium2),
                          curve: M3EMotion.emphasizedDecelerate,
                          style: M3ETypography.titleMedium.copyWith(
                            color: isActive
                                ? colorScheme.onSurface
                                : isCompleted
                                    ? colorScheme.onSurface.withValues(alpha: 0.8)
                                    : colorScheme.onSurfaceVariant,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            fontSize: isActive ? 17 : 16,
                          ),
                          child: Text(step.title),
                        ),
                        if (step.subtitle != null) ...[
                          M3ESpacing.verticalXXS,
                          AnimatedOpacity(
                            duration: M3EMotion.getDuration(M3EMotion.medium2),
                            opacity: isActive ? 1.0 : 0.7,
                            child: Text(
                              step.subtitle!,
                              style: M3ETypography.bodyMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Active indicator chevron
                  if (isActive)
                    AnimatedRotation(
                      duration: M3EMotion.getDuration(M3EMotion.medium2),
                      turns: isExpanded ? 0.25 : 0,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Step content (expandable) with smooth animation
        if (isExpanded) ...[
          M3ESpacing.verticalLG,
          Padding(
            padding: M3ESpacing.only(left: 72), // Align with title
            child: M3ETransitions.sharedAxisZ(
              animation: _contentController,
              secondaryAnimation: _contentController,
              child: step.content,
            ),
          ),
          // Controls for this step
          Padding(
            padding: M3ESpacing.only(left: 72),
            child: widget.controlsBuilder != null
                ? widget.controlsBuilder!(
                    context,
                    ControlsDetails(
                      onStepContinue: widget.onStepContinue,
                      onStepCancel: widget.onStepCancel,
                      stepIndex: index,
                    ),
                  )
                : _buildDefaultControls(),
          ),
        ],
        // Enhanced connector line (except last step)
        if (index < widget.steps.length - 1) ...[
          M3ESpacing.verticalLG,
          Padding(
            padding: M3ESpacing.only(left: 43), // Center of circle
            child: AnimatedContainer(
              duration: M3EMotion.getDuration(M3EMotion.medium3),
              curve: M3EMotion.emphasizedDecelerate,
              width: 3, // Slightly thicker for better visibility
              height: 32, // More space between steps
              decoration: BoxDecoration(
                color: isCompleted
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
                // Subtle gradient for completed connectors
                gradient: isCompleted
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      )
                    : null,
              ),
            ),
          ),
          M3ESpacing.verticalLG,
        ],
      ],
    );
  }

  Widget _buildDefaultControls() {
    return Padding(
      padding: M3ESpacing.all(M3ESpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.currentStep > 0)
            OutlinedButtonM3E(
              onPressed: widget.onStepCancel,
              child: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          FilledButtonM3E(
            onPressed: widget.onStepContinue,
            child: Text(
              widget.currentStep == widget.steps.length - 1
                  ? 'Complete'
                  : 'Next',
            ),
          ),
        ],
      ),
    );
  }

  Color _getStepColor(bool isActive, bool isCompleted, bool isError) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isError) {
      return colorScheme.error;
    } else if (isCompleted || isActive) {
      return colorScheme.primary;
    } else {
      return colorScheme.surfaceContainerHighest;
    }
  }
}

/// Individual step in a stepper
class StepperStepM3E {
  /// Step title
  final String title;

  /// Optional step subtitle
  final String? subtitle;

  /// Step content widget
  final Widget content;

  /// Step state
  final StepState state;

  const StepperStepM3E({
    required this.title,
    this.subtitle,
    required this.content,
    this.state = StepState.indexed,
  });
}

/// Stepper orientation
enum StepperType {
  /// Horizontal layout (steps side-by-side)
  horizontal,

  /// Vertical layout (steps stacked)
  vertical,
}

/// Step state
enum StepState {
  /// Step is indexed (not yet reached)
  indexed,

  /// Step is active (current step)
  active,

  /// Step is complete
  complete,

  /// Step has error
  error,

  /// Step is disabled
  disabled,
}

/// Controls builder callback
typedef ControlsBuilder = Widget Function(
  BuildContext context,
  ControlsDetails details,
);

/// Controls details passed to controls builder
class ControlsDetails {
  /// Continue callback
  final VoidCallback? onStepContinue;

  /// Cancel callback
  final VoidCallback? onStepCancel;

  /// Current step index
  final int stepIndex;

  const ControlsDetails({
    this.onStepContinue,
    this.onStepCancel,
    required this.stepIndex,
  });
}

