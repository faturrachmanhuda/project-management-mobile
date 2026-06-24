import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';

/// Input field sederhana dengan overflow indicator visual
/// Sesuai dengan screenshot yang menunjukkan garis kuning-hitam untuk overflow
class OverflowInputField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool required;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final bool enabled;
  final int maxLines;
  final EdgeInsetsGeometry? contentPadding;
  final double? fieldWidth;
  
  const OverflowInputField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.initialValue,
    this.required = false,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.contentPadding,
    this.fieldWidth,
  });

  @override
  State<OverflowInputField> createState() => _OverflowInputFieldState();
}

class _OverflowInputFieldState extends State<OverflowInputField> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  bool _hasOverflow = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _scrollController = ScrollController();
    
    _controller.addListener(_checkOverflow);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _checkOverflow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Check if text overflows the field width
      final textPainter = TextPainter(
        text: TextSpan(
          text: _controller.text,
          style: AppTypography.bodyLarge,
        ),
        textDirection: TextDirection.ltr,
        maxLines: widget.maxLines,
      );
      
      textPainter.layout();
      
      final fieldWidth = widget.fieldWidth ?? 
          (context.mounted ? MediaQuery.of(context).size.width - 80 : 300);
      final availableWidth = fieldWidth - 32; // Minus padding
      
      setState(() {
        _hasOverflow = textPainter.width > availableWidth;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                text: widget.labelText!,
                style: AppTypography.labelMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
                children: [
                  if (widget.required)
                    TextSpan(
                      text: ' *',
                      style: AppTypography.labelMedium.copyWith(
                        color: DesignColors.danger,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        
        // Input field with overflow indicator
        Stack(
          children: [
            // Main input field
            SizedBox(
              width: widget.fieldWidth,
              child: TextFormField(
                controller: _controller,
                scrollController: _scrollController,
                keyboardType: widget.keyboardType,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  _checkOverflow();
                },
                validator: widget.validator ?? (widget.required ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${widget.labelText ?? 'Field'} wajib diisi';
                  }
                  return null;
                } : null),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon,
                  contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.medium),
                    borderSide: const BorderSide(color: DesignColors.borderInput),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.medium),
                    borderSide: const BorderSide(color: DesignColors.borderInput),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.medium),
                    borderSide: const BorderSide(color: DesignColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.medium),
                    borderSide: const BorderSide(color: DesignColors.danger),
                  ),
                  filled: true,
                  fillColor: widget.enabled ? DesignColors.bg : DesignColors.surfaceSoft,
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: DesignColors.textMuted,
                  ),
                ),
                style: AppTypography.bodyLarge.copyWith(
                  color: widget.enabled ? DesignColors.textPrimary : DesignColors.textMuted,
                ),
              ),
            ),
            
            // Overflow indicator (seperti screenshot)
            if (_hasOverflow)
              Positioned(
                right: 1,
                top: 1,
                bottom: 1,
                child: Container(
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(Radii.medium - 1),
                      bottomRight: Radius.circular(Radii.medium - 1),
                    ),
                  ),
                  child: Container(
                    width: 6,
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFD700), // Gold/Yellow
                          Color(0xFFFF8C00), // Dark orange
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      painter: _OverflowStripePainter(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter untuk garis diagonal hitam pada indicator overflow
class _OverflowStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Membuat garis diagonal berulang seperti warning tape
    for (double i = -size.height; i < size.height * 2; i += 6) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i + size.width),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dropdown field dengan overflow indicator
class OverflowDropdownField<T> extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool required;
  final bool enabled;
  final Widget? prefixIcon;
  final double? fieldWidth;
  
  const OverflowDropdownField({
    super.key,
    this.labelText,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.required = false,
    this.enabled = true,
    this.prefixIcon,
    this.fieldWidth,
  });

  @override
  State<OverflowDropdownField<T>> createState() => _OverflowDropdownFieldState<T>();
}

class _OverflowDropdownFieldState<T> extends State<OverflowDropdownField<T>> {
  bool _hasOverflow = false;

  void _checkOverflow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Check if selected text is too long
      final selectedItem = widget.items.firstWhere(
        (item) => item.value == widget.value,
        orElse: () => widget.items.first,
      );
      
      if (selectedItem.child is Text) {
        final text = (selectedItem.child as Text).data ?? '';
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: AppTypography.bodyLarge,
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        
        final fieldWidth = widget.fieldWidth ?? 
            (context.mounted ? MediaQuery.of(context).size.width - 80 : 300);
        final availableWidth = fieldWidth - 60; // Minus padding and dropdown arrow
        
        setState(() {
          _hasOverflow = textPainter.width > availableWidth;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                text: widget.labelText!,
                style: AppTypography.labelMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
                children: [
                  if (widget.required)
                    TextSpan(
                      text: ' *',
                      style: AppTypography.labelMedium.copyWith(
                        color: DesignColors.danger,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        
        // Dropdown with overflow indicator
        Stack(
          children: [
            SizedBox(
              width: widget.fieldWidth,
              child: DropdownButtonFormField<T>(
                value: widget.value,
                items: widget.items,
                onChanged: widget.enabled ? (value) {
                  widget.onChanged?.call(value);
                  _checkOverflow();
                } : null,
                validator: widget.validator ?? (widget.required ? (value) {
                  if (value == null) {
                    return '${widget.labelText ?? 'Field'} wajib dipilih';
                  }
                  return null;
                } : null),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.medium),
                    borderSide: const BorderSide(color: DesignColors.borderInput),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.medium),
                    borderSide: const BorderSide(color: DesignColors.borderInput),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.medium),
                    borderSide: const BorderSide(color: DesignColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.medium),
                    borderSide: const BorderSide(color: DesignColors.danger),
                  ),
                  filled: true,
                  fillColor: widget.enabled ? DesignColors.bg : DesignColors.surfaceSoft,
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: DesignColors.textMuted,
                  ),
                ),
                style: AppTypography.bodyLarge.copyWith(
                  color: widget.enabled ? DesignColors.textPrimary : DesignColors.textMuted,
                ),
                isExpanded: true,
                menuMaxHeight: 300,
              ),
            ),
            
            // Overflow indicator
            if (_hasOverflow)
              Positioned(
                right: 25, // Account for dropdown arrow
                top: 1,
                bottom: 1,
                child: Container(
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Container(
                    width: 6,
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFD700), // Gold/Yellow
                          Color(0xFFFF8C00), // Dark orange
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      painter: _OverflowStripePainter(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}