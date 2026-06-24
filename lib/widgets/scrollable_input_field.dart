import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';

/// Input field yang dapat di-scroll horizontal ketika teks melebihi lebar container
/// Menampilkan overflow indicator visual seperti pada screenshot
class ScrollableInputField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool required;
  final int? maxLines;
  final int? minLines;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final double? maxWidth;
  final bool enableHorizontalScroll;
  final bool showOverflowIndicator;
  
  const ScrollableInputField({
    super.key,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.keyboardType,
    this.enabled = true,
    this.required = false,
    this.maxLines = 1,
    this.minLines,
    this.controller,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.maxWidth,
    this.enableHorizontalScroll = true,
    this.showOverflowIndicator = true,
  });

  @override
  State<ScrollableInputField> createState() => _ScrollableInputFieldState();
}

class _ScrollableInputFieldState extends State<ScrollableInputField> {
  late ScrollController _scrollController;
  late TextEditingController _textController;
  bool _isScrollable = false;
  bool _showOverflow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _textController = widget.controller ?? TextEditingController(text: widget.initialValue);
    
    // Monitor text changes to check if scrolling is needed
    _textController.addListener(_checkScrollable);
    _scrollController.addListener(_checkOverflow);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

  void _checkScrollable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        setState(() {
          _isScrollable = maxScrollExtent > 0;
          _showOverflow = _isScrollable && widget.showOverflowIndicator;
        });
      }
    });
  }

  void _checkOverflow() {
    if (mounted && _scrollController.hasClients) {
      final position = _scrollController.position;
      final showRight = position.pixels < position.maxScrollExtent - 10;
      final showLeft = position.pixels > 10;
      
      setState(() {
        _showOverflow = (showRight || showLeft) && widget.showOverflowIndicator;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main input field
        TextFormField(
          controller: _textController,
          scrollController: widget.enableHorizontalScroll ? _scrollController : null,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          scrollPhysics: widget.enableHorizontalScroll 
              ? const ClampingScrollPhysics() 
              : null,
          onChanged: (value) {
            widget.onChanged?.call(value);
            _checkScrollable();
          },
          validator: widget.validator ?? (widget.required ? (value) {
            if (value == null || value.trim().isEmpty) {
              return '${widget.labelText ?? 'Field'} wajib diisi';
            }
            return null;
          } : null),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
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
            labelStyle: AppTypography.labelMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
            hintStyle: AppTypography.bodySmall.copyWith(
              color: DesignColors.textMuted,
            ),
          ),
          style: AppTypography.bodyLarge.copyWith(
            color: widget.enabled ? DesignColors.textPrimary : DesignColors.textMuted,
          ),
        ),
        
        // Overflow indicator - matching screenshot style
        if (_showOverflow && widget.enableHorizontalScroll)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(Radii.medium),
                  bottomRight: Radius.circular(Radii.medium),
                ),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.yellow,
                      Colors.orange,
                    ],
                  ),
                ),
                width: 4,
                child: CustomPaint(
                  painter: _DiagonalStripePainter(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Custom painter untuk membuat garis diagonal seperti warning tape
class _DiagonalStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Membuat garis diagonal berulang
    for (double i = -size.height; i < size.height * 2; i += 8) {
      path.moveTo(0, i);
      path.lineTo(size.width, i + size.width);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
}

/// Dropdown field yang dapat di-scroll horizontal untuk option yang panjang
class ScrollableDropdownField<T> extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool required;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final double? maxWidth;

  const ScrollableDropdownField({
    super.key,
    this.labelText,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.required = false,
    this.prefixIcon,
    this.contentPadding,
    this.maxWidth,
  });

  @override
  State<ScrollableDropdownField<T>> createState() => _ScrollableDropdownFieldState<T>();
}

class _ScrollableDropdownFieldState<T> extends State<ScrollableDropdownField<T>> {
  @override
  Widget build(BuildContext context) {
    Widget dropdownField = DropdownButtonFormField<T>(
      value: widget.value,
      items: widget.items,
      onChanged: widget.enabled ? widget.onChanged : null,
      validator: widget.validator ?? (widget.required ? (value) {
        if (value == null) {
          return '${widget.labelText ?? 'Field'} wajib dipilih';
        }
        return null;
      } : null),
      decoration: InputDecoration(
        labelText: widget.labelText,
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
        labelStyle: AppTypography.labelMedium.copyWith(
          color: DesignColors.textSecondary,
        ),
        hintStyle: AppTypography.bodySmall.copyWith(
          color: DesignColors.textMuted,
        ),
      ),
      style: AppTypography.bodyLarge.copyWith(
        color: widget.enabled ? DesignColors.textPrimary : DesignColors.textMuted,
      ),
      icon: const Icon(Icons.arrow_drop_down),
      isExpanded: true,
      menuMaxHeight: 300,
    );

    // Jika ada maxWidth, wrap dengan Container
    if (widget.maxWidth != null) {
      dropdownField = Container(
        width: widget.maxWidth,
        child: dropdownField,
      );
    }

    return dropdownField;
  }
}

/// Form field dengan label yang dapat di-scroll horizontal
class ScrollableFormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool enableHorizontalScroll;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  const ScrollableFormSection({
    super.key,
    required this.title,
    required this.children,
    this.enableHorizontalScroll = true,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title section
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: AppTypography.h3.copyWith(
              color: DesignColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
        
        // Form fields
        ...children.map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: child,
        )),
      ],
    );

    // Apply padding
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    // Enable horizontal scroll if needed
    if (enableHorizontalScroll) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: maxWidth ?? MediaQuery.of(context).size.width,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Wrapper untuk form yang dapat di-scroll horizontal
class HorizontalScrollableForm extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double? minWidth;
  final CrossAxisAlignment crossAxisAlignment;

  const HorizontalScrollableForm({
    super.key,
    required this.children,
    this.padding,
    this.minWidth,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = minWidth ?? screenWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Container(
        width: formWidth > screenWidth ? formWidth : null,
        constraints: BoxConstraints(
          minWidth: screenWidth,
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      ),
    );
  }
}