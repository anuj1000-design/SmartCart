import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// 🎨 GLASS & CARD WIDGETS
// ---------------------------------------------------------------------------

/// Glassmorphic card widget matching website design
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.border,
    this.boxShadow,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine card background: if not provided, try CardTheme color, fallback to darkCard
    final cardColor = backgroundColor ?? 
        Theme.of(context).cardTheme.color?.withValues(alpha: 0.6) ?? 
        AppTheme.darkCard.withValues(alpha: 0.6);
        
    final borderColor = border ?? 
        Border.all(color: Theme.of(context).dividerTheme.color ?? AppTheme.darkBorder);
    
    final shadow = boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), // Lighter shadow by default
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ];

    final widget = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: borderColor,
        boxShadow: shadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: widget);
    }
    return widget;
  }
}

/// Primary action button matching website
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppTheme.primary,
          borderRadius: BorderRadius.circular(50), // Fully rounded / Stadium
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: (widget.backgroundColor ?? AppTheme.primary).withValues(
                  alpha: 0.2, // Softer shadow for light mode
                ),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        transform: _isPressed ? Matrix4.diagonal3Values(0.98, 0.98, 1.0) : null,
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.textColor ?? Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.textColor ?? Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.textColor ?? Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Stat card for dashboard displays
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color, // Dynamic color
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ],
        ],
      ),
    );
  }
}

/// Category chip matching website design
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : Theme.of(context).cardColor, // Use theme card color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : Theme.of(context).dividerColor, // Use theme divider color
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.textPrimary
                    : AppTheme.textTertiary,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient text widget
class GradientText extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final TextStyle? baseStyle;

  const GradientText(
    this.text, {
    super.key,
    this.colors = const [AppTheme.primary, AppTheme.primaryDark],
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style:
            (baseStyle ??
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                .copyWith(color: AppTheme.textPrimary),
      ),
    );
  }
}

/// Subtle fade + slide animation for screen content
class ScreenFade extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;

  const ScreenFade({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.beginOffset = const Offset(0, 0.04),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      builder: (context, value, child) {
        final offset = Offset(
          beginOffset.dx * (1 - value),
          beginOffset.dy * (1 - value),
        );
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: offset, child: child),
        );
      },
      child: child,
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, size: 48, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textTertiary),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}
