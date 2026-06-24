import 'package:flutter/material.dart';
import 'scrollable_input_field.dart';
import '../utils/design_tokens.dart';

/// Utility class untuk membuat form field yang responsive dan scrollable
class FormUtils {
  
  /// Membuat input field yang otomatis scrollable jika teks panjang
  static Widget createScrollableTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    double? maxWidth,
  }) {
    return ScrollableInputField(
      labelText: label,
      hintText: hint,
      controller: controller,
      required: required,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      maxWidth: maxWidth,
      prefixIcon: icon != null ? Icon(icon) : null,
      enableHorizontalScroll: maxLines == 1, // Only single line gets horizontal scroll
    );
  }
  
  /// Membuat dropdown field yang responsive
  static Widget createScrollableDropdown<T>({
    required String label,
    required List<DropdownMenuItem<T>> items,
    T? value,
    ValueChanged<T?>? onChanged,
    String? hint,
    IconData? icon,
    bool required = false,
    bool enabled = true,
    String? Function(T?)? validator,
    double? maxWidth,
  }) {
    return ScrollableDropdownField<T>(
      labelText: label,
      hintText: hint,
      items: items,
      value: value,
      onChanged: onChanged,
      required: required,
      enabled: enabled,
      validator: validator,
      maxWidth: maxWidth,
      prefixIcon: icon != null ? Icon(icon) : null,
    );
  }
  
  /// Membuat date picker field yang scrollable
  static Widget createDateField({
    required String label,
    required TextEditingController controller,
    required BuildContext context,
    String? hint,
    bool required = false,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    double? maxWidth,
  }) {
    return ScrollableInputField(
      labelText: label,
      hintText: hint ?? 'YYYY-MM-DD',
      controller: controller,
      required: required,
      keyboardType: TextInputType.datetime,
      maxWidth: maxWidth,
      prefixIcon: const Icon(Icons.calendar_today_outlined),
      onChanged: (value) {
        // Auto format date as user types
        if (value.length == 4 && !value.contains('-')) {
          controller.text = '$value-';
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        } else if (value.length == 7 && value.split('-').length == 2) {
          controller.text = '$value-';
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
      },
      validator: required ? (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        // Validate date format
        try {
          DateTime.parse(value);
          return null;
        } catch (e) {
          return 'Format tanggal tidak valid (YYYY-MM-DD)';
        }
      } : null,
    );
  }
  
  /// Membuat section form dengan title dan fields
  static Widget createFormSection({
    required String title,
    required List<Widget> fields,
    bool enableHorizontalScroll = true,
    EdgeInsetsGeometry? padding,
    double? maxWidth,
  }) {
    return ScrollableFormSection(
      title: title,
      enableHorizontalScroll: enableHorizontalScroll,
      padding: padding,
      maxWidth: maxWidth,
      children: fields,
    );
  }
  
  /// Membuat row dengan 2 field yang responsive
  static Widget createTwoColumnRow({
    required Widget leftField,
    required Widget rightField,
    double spacing = 16,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Jika layar kecil, stack vertically
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              leftField,
              SizedBox(height: spacing),
              rightField,
            ],
          );
        }
        
        // Jika layar besar, row horizontally
        return Row(
          children: [
            Expanded(child: leftField),
            SizedBox(width: spacing),
            Expanded(child: rightField),
          ],
        );
      },
    );
  }
  
  /// Membuat button group untuk form actions
  static Widget createActionButtons({
    required VoidCallback onSave,
    VoidCallback? onCancel,
    String saveLabel = 'Simpan',
    String cancelLabel = 'Batal',
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onCancel != null) ...[
            TextButton(
              onPressed: isLoading ? null : onCancel,
              child: Text(cancelLabel),
            ),
            const SizedBox(width: 16),
          ],
          ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(saveLabel),
          ),
        ],
      ),
    );
  }
  
  /// Membuat info panel dengan tips
  static Widget createInfoPanel({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
    Color? color,
  }) {
    final panelColor = color ?? DesignColors.primary;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Radii.medium),
        border: Border.all(
          color: panelColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: panelColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: panelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension untuk memudahkan penggunaan ScrollableInputField pada form yang sudah ada
extension FormFieldExtensions on Widget {
  
  /// Membungkus widget dengan container yang dapat di-scroll horizontal
  Widget makeHorizontallyScrollable({
    double? maxWidth,
    EdgeInsetsGeometry? padding,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Container(
        width: maxWidth,
        padding: padding,
        child: this,
      ),
    );
  }
  
  /// Membungkus widget dengan section yang memiliki title
  Widget wrapWithSection({
    required String title,
    bool enableHorizontalScroll = true,
    EdgeInsetsGeometry? padding,
    double? maxWidth,
  }) {
    return ScrollableFormSection(
      title: title,
      enableHorizontalScroll: enableHorizontalScroll,
      padding: padding,
      maxWidth: maxWidth,
      children: [this],
    );
  }
}

/// Mixin untuk page yang menggunakan scrollable form
mixin ScrollableFormMixin<T extends StatefulWidget> on State<T> {
  
  /// Membuat form wrapper yang responsive
  Widget buildScrollableForm({
    required List<Widget> children,
    GlobalKey<FormState>? formKey,
    EdgeInsetsGeometry? padding,
    double? minWidth,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch,
  }) {
    Widget content = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
    
    if (formKey != null) {
      content = Form(
        key: formKey,
        child: content,
      );
    }
    
    return HorizontalScrollableForm(
      minWidth: minWidth,
      padding: padding,
      crossAxisAlignment: crossAxisAlignment,
      children: [content],
    );
  }
  
  /// Helper untuk menampilkan SnackBar
  void showFormMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? DesignColors.danger : DesignColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Helper untuk validasi form
  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }
}