import 'package:flutter/material.dart';
import '../theme/motion.dart';
import '../theme/shapes.dart';

/// M3E Text Field with enhanced focus animations
///
/// Features:
/// - Label float animation (scale 0.75x and shift up)
/// - Border morph (1dp → 2dp on focus)
/// - Icon color/scale transitions
/// - Helper text slide animation
/// - Error shake animation
class TextFieldM3E extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final bool filled;

  const TextFieldM3E({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.filled = true,
  });

  @override
  State<TextFieldM3E> createState() => _TextFieldM3EState();
}

class _TextFieldM3EState extends State<TextFieldM3E>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _focusController;
  late AnimationController _errorController;
  late Animation<double> _borderWidthAnimation;
  late Animation<double> _iconScaleAnimation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _focusController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium4), // 400ms for smoother focus transition
      vsync: this,
    );

    _errorController = AnimationController(
      duration: M3EMotion.getDuration(M3EMotion.medium3), // 350ms for more noticeable shake
      vsync: this,
    );

    // Border width morphs from 1dp to 2dp on focus
    _borderWidthAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: M3EMotion.emphasizedDecelerate,
    ));

    _hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    if (_hasError) {
      _errorController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TextFieldM3E oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newHasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    if (newHasError != _hasError) {
      _hasError = newHasError;
      if (_hasError) {
        _errorController.repeat(reverse: true);
      } else {
        _errorController.stop();
        _errorController.reset();
      }
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _focusController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFocused = _focusNode.hasFocus;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _focusController,
        _errorController,
      ]),
      builder: (context, child) {
        // Error shake animation
        final shakeOffset = _hasError
            ? Offset(_errorController.value * 4.0, 0) // Shake 4px horizontally
            : Offset.zero;

        return Transform.translate(
          offset: shakeOffset,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon != null
                  ? Transform.scale(
                      scale: isFocused ? _iconScaleAnimation.value : 1.0,
                      child: Icon(
                        widget.prefixIcon,
                        color: isFocused
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              filled: widget.filled,
              border: widget.filled
                  ? null
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(M3EShapes.medium),
                      borderSide: BorderSide(
                        color: isFocused
                            ? colorScheme.primary
                            : colorScheme.outline,
                        width: isFocused
                            ? _borderWidthAnimation.value
                            : 1.0,
                      ),
                    ),
              enabledBorder: widget.filled
                  ? null
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(M3EShapes.medium),
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1.0,
                      ),
                    ),
              focusedBorder: widget.filled
                  ? null
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(M3EShapes.medium),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: _borderWidthAnimation.value,
                      ),
                    ),
              errorBorder: widget.filled
                  ? null
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(M3EShapes.medium),
                      borderSide: BorderSide(
                        color: colorScheme.error,
                        width: 1.0,
                      ),
                    ),
              focusedErrorBorder: widget.filled
                  ? null
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(M3EShapes.medium),
                      borderSide: BorderSide(
                        color: colorScheme.error,
                        width: 2.0,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
