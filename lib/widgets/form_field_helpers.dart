import 'package:flutter/material.dart';
import 'overflow_input_field.dart';
import '../utils/design_tokens.dart';

/// Helper class untuk membuat form fields dengan overflow detection
class FormFieldHelpers {
  
  /// Membuat input field dengan overflow indicator
  static Widget createOverflowTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    String? hint,
    IconData? icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    double? fieldWidth,
  }) {
    return OverflowInputField(
      labelText: label,
      controller: controller,
      initialValue: initialValue,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      required: required,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      fieldWidth: fieldWidth,
    );
  }
  
  /// Membuat dropdown field dengan overflow detection
  static Widget createOverflowDropdown<T>({
    required String label,
    required List<DropdownMenuItem<T>> items,
    T? value,
    ValueChanged<T?>? onChanged,
    String? hint,
    IconData? icon,
    bool required = false,
    bool enabled = true,
    String? Function(T?)? validator,
    double? fieldWidth,
  }) {
    return OverflowDropdownField<T>(
      labelText: label,
      hintText: hint,
      items: items,
      value: value,
      onChanged: onChanged,
      required: required,
      enabled: enabled,
      validator: validator,
      prefixIcon: icon != null ? Icon(icon) : null,
      fieldWidth: fieldWidth,
    );
  }
  
  /// Membuat date field dengan overflow detection
  static Widget createOverflowDateField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool required = false,
    double? fieldWidth,
  }) {
    return OverflowInputField(
      labelText: label,
      controller: controller,
      hintText: hint ?? 'YYYY-MM-DD',
      prefixIcon: const Icon(Icons.calendar_today_outlined),
      required: required,
      keyboardType: TextInputType.datetime,
      fieldWidth: fieldWidth,
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
        try {
          DateTime.parse(value);
          return null;
        } catch (e) {
          return 'Format tanggal tidak valid (YYYY-MM-DD)';
        }
      } : null,
    );
  }
  
  /// Membuat form section dengan title
  static Widget createFormSection({
    required String title,
    required List<Widget> fields,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ...fields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: field,
          )),
        ],
      ),
    );
  }
  
  /// Membuat row dengan 2 field yang responsive
  static Widget createTwoFieldRow({
    required Widget leftField,
    required Widget rightField,
    double spacing = 16,
    double breakpoint = 600,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Jika layar kecil, stack vertically
        if (constraints.maxWidth < breakpoint) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: leftField),
            SizedBox(width: spacing),
            Expanded(child: rightField),
          ],
        );
      },
    );
  }
  
  /// Membuat action buttons untuk form
  static Widget createActionButtons({
    required VoidCallback onSave,
    VoidCallback? onCancel,
    String saveLabel = 'Simpan',
    String cancelLabel = 'Batal',
    bool isLoading = false,
    MainAxisAlignment alignment = MainAxisAlignment.end,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: alignment,
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
  
  /// Membuat info panel
  static Widget createInfoPanel({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
    Color? color,
  }) {
    final panelColor = color ?? DesignColors.primary;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: panelColor,
                  ),
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

/// Extension untuk memudahkan penggunaan pada existing widgets
extension OverflowFieldExtensions on Widget {
  
  /// Membungkus widget dalam form section dengan title
  Widget wrapInFormSection({
    required String title,
    EdgeInsetsGeometry? padding,
  }) {
    return FormFieldHelpers.createFormSection(
      title: title,
      fields: [this],
      padding: padding,
    );
  }
  
  /// Membuat widget menjadi bagian dari two-field row
  Widget pairedWith({
    required Widget otherField,
    double spacing = 16,
    double breakpoint = 600,
    bool thisFieldFirst = true,
  }) {
    return FormFieldHelpers.createTwoFieldRow(
      leftField: thisFieldFirst ? this : otherField,
      rightField: thisFieldFirst ? otherField : this,
      spacing: spacing,
      breakpoint: breakpoint,
    );
  }
}

/// Mixin untuk page yang menggunakan overflow form fields
mixin OverflowFormMixin<T extends StatefulWidget> on State<T> {
  
  /// Helper untuk validasi form
  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }
  
  /// Helper untuk menampilkan pesan
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
  
  /// Helper untuk membuat form dengan overflow fields
  Widget buildOverflowForm({
    required List<Widget> children,
    GlobalKey<FormState>? formKey,
    EdgeInsetsGeometry? padding,
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
    
    return SingleChildScrollView(
      padding: padding ?? const EdgeInsets.all(16),
      child: content,
    );
  }
  
  /// Helper untuk menampilkan dialog form
  Future<T?> showOverflowFormDialog<T>({
    required Widget child,
    double? width,
    double? height,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: width ?? 400,
          height: height,
          constraints: BoxConstraints(
            maxHeight: height ?? MediaQuery.of(context).size.height * 0.8,
          ),
          child: child,
        ),
      ),
    );
  }
}