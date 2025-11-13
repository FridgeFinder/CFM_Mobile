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
    return Column(
      children: [
        // Step indicators
        Row(
          children: List.generate(
            widget.steps.length,
            (index) => Expanded(
              child: _buildHorizontalStepIndicator(index),
            ),
          ),
        ),
        M3ESpacing.verticalXL,
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

    return GestureDetector(
      onTap: widget.stepsTappable && (isCompleted || isActive)
          ? () => widget.onStepTapped?.call(index)
          : null,
      child: Column(
        children: [
          // Step circle
          AnimatedBuilder(
            animation: _stepControllers[index],
            builder: (context, child) {
              return Transform.scale(
                scale: isActive
                    ? 1.0 + (_indicatorController.value * 0.1)
                    : 1.0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStepColor(isActive, isCompleted, isError),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : isError
                            ? Icon(
                                Icons.error,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                '${index + 1}',
                                style: M3ETypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  ),
                ),
              );
            },
          ),
          M3ESpacing.verticalXXS,
          // Step label
          Text(
            step.title,
            style: M3ETypography.labelSmall.copyWith(
              color: isActive || isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
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

    return Column(
      children: [
        // Step header
        InkWell(
          onTap: widget.stepsTappable && (isCompleted || isActive)
              ? () => widget.onStepTapped?.call(index)
              : null,
          child: Row(
            children: [
              // Step circle
              AnimatedBuilder(
                animation: _stepControllers[index],
                builder: (context, child) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStepColor(isActive, isCompleted, isError),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : isError
                              ? Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: M3ETypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                    ),
                  );
                },
              ),
              M3ESpacing.horizontalMD,
              // Step title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: M3ETypography.titleMedium.copyWith(
                        color: isActive || isCompleted
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (step.subtitle != null) ...[
                      M3ESpacing.verticalXXS,
                      Text(
                        step.subtitle!,
                        style: M3ETypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Step content (expandable)
        if (isExpanded) ...[
          M3ESpacing.verticalMD,
          M3ETransitions.sharedAxisZ(
            animation: _contentController,
            secondaryAnimation: _contentController,
            child: step.content,
          ),
          // Controls for this step
          if (widget.controlsBuilder != null)
            widget.controlsBuilder!(
              context,
              ControlsDetails(
                onStepContinue: widget.onStepContinue,
                onStepCancel: widget.onStepCancel,
                stepIndex: index,
              ),
            )
          else
            _buildDefaultControls(),
        ],
        // Connector line (except last step)
        if (index < widget.steps.length - 1) ...[
          M3ESpacing.verticalMD,
          Container(
            margin: EdgeInsets.only(left: 20),
            width: 2,
            height: 24,
            color: isCompleted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          M3ESpacing.verticalMD,
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

