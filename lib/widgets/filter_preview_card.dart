import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/photo_filter.dart';

class FilterPreviewCard extends StatefulWidget {
  final PhotoFilter filter;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget previewImage;

  const FilterPreviewCard({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
    required this.previewImage,
  });

  @override
  State<FilterPreviewCard> createState() => _FilterPreviewCardState();
}

class _FilterPreviewCardState extends State<FilterPreviewCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(FilterPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(
                        0.4 * _glowAnimation.value,
                      ),
                      blurRadius: 12 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                      offset: const Offset(0, 2),
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Preview image container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: widget.isSelected
                          ? Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      )
                          : Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        children: [
                          // Preview image
                          Positioned.fill(
                            child: widget.previewImage,
                          ),

                          // Selected overlay
                          if (widget.isSelected)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1 * _glowAnimation.value,
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                            ),

                          // Selected checkmark
                          if (widget.isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: AnimatedScale(
                                scale: _glowAnimation.value,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: theme.colorScheme.onPrimary,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Filter name
                  Text(
                    widget.filter.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: widget.isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper widget for creating filter preview thumbnails
class FilterPreviewThumbnail extends StatelessWidget {
  final Widget originalImage;
  final PhotoFilter filter;

  const FilterPreviewThumbnail({
    super.key,
    required this.originalImage,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (filter.type == FilterType.none) {
      return originalImage;
    }

    // For demo purposes, we\'ll use ColorFilter to simulate different filters
    // In a real app, you\'d apply the actual image processing
    return ColorFiltered(
      colorFilter: _getColorFilterForType(filter.type),
      child: originalImage,
    );
  }

  ColorFilter _getColorFilterForType(FilterType type) {
    switch (type) {
      case FilterType.blackAndWhite:
        return const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.sepia:
        return const ColorFilter.matrix([
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.vintage:
        return const ColorFilter.matrix([
          0.9, 0.5, 0.1, 0, 0,
          0.3, 0.8, 0.1, 0, 0,
          0.2, 0.3, 0.5, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.cool:
        return const ColorFilter.matrix([
          0.8, 0, 0, 0, 0,
          0, 0.9, 0, 0, 0,
          0, 0, 1.2, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.warm:
        return const ColorFilter.matrix([
          1.2, 0, 0, 0, 0,
          0, 1.1, 0, 0, 0,
          0, 0, 0.8, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.dramatic:
        return const ColorFilter.matrix([
          1.5, 0, 0, 0, -0.2,
          0, 1.5, 0, 0, -0.2,
          0, 0, 1.5, 0, -0.2,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.bright:
        return const ColorFilter.matrix([
          1, 0, 0, 0, 0.1,
          0, 1, 0, 0, 0.1,
          0, 0, 1, 0, 0.1,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.contrast:
        return const ColorFilter.matrix([
          1.2, 0, 0, 0, -0.1,
          0, 1.2, 0, 0, -0.1,
          0, 0, 1.2, 0, -0.1,
          0, 0, 0, 1, 0,
        ]);
      case FilterType.saturated:
        return const ColorFilter.matrix([
          1.3, -0.15, -0.15, 0, 0,
          -0.15, 1.3, -0.15, 0, 0,
          -0.15, -0.15, 1.3, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      default:
        return const ColorFilter.matrix([
          1, 0, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 0,
          0, 0, 0, 1, 0,
        ]);
    }
  }
}