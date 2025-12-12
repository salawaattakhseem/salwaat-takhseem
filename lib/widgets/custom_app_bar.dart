import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.elevation = 0,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: backgroundColor ?? AppColors.darkBrown,
      elevation: elevation,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null),
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

// Dashboard App Bar with profile
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onProfileTap;
  final bool transparent;

  const DashboardAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onProfileTap,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transparent ? Colors.transparent : AppColors.darkBrown,
      elevation: transparent ? 0 : 0,
      forceMaterialTransparency: transparent,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
        ],
      ),
      actions: [
        if (onProfileTap != null)
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.mediumBrown,
              child: const Icon(
                Icons.person,
                color: AppColors.white,
                size: 20,
              ),
            ),
            onPressed: onProfileTap,
          ),
        ...?actions,
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}