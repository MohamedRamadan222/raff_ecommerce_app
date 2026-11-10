import 'package:flutter/material.dart';
import 'package:raff_app/core/theme/app_colors.dart';

class AppSearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final bool showFilter;
  final VoidCallback? onFilterTap;
  final bool isOutline;

  const AppSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.showFilter = false,
    this.onFilterTap,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fillColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final textColor = isDark ? AppColors.darkInk : AppColors.ink;
    final hintColor = isDark ? AppColors.darkMuted : AppColors.muted;
    final filterBgColor = isDark ? AppColors.darkPaper : AppColors.paper;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: hintColor),
        filled: !isOutline,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: isOutline
              ? BorderSide(color: borderColor)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: isOutline
              ? BorderSide(color: borderColor)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkInk : AppColors.ink,
          ),
        ),

        prefixIcon: Icon(Icons.search, color: hintColor),

        suffixIcon: showFilter
            ? _buildFilterButton(filterBgColor, textColor)
            : null,
      ),
    );
  }

  Widget _buildFilterButton(Color bgColor, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onFilterTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(Icons.tune_rounded, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
