import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum EditingTool {
  brightness,
  contrast,
  saturation,
  hue,
  filters,
  rotate,
  crop,
}

class EditingToolbar extends StatefulWidget {
  final EditingTool? selectedTool;
  final double brightness;
  final double contrast;
  final double saturation;
  final double hue;
  final Function(EditingTool) onToolSelected;
  final Function(double) onBrightnessChanged;
  final Function(double) onContrastChanged;
  final Function(double) onSaturationChanged;
  final Function(double) onHueChanged;
  final VoidCallback onFiltersPressed;
  final VoidCallback onRotatePressed;
  final VoidCallback onCropPressed;

  const EditingToolbar({
    super.key,
    this.selectedTool,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.hue,
    required this.onToolSelected,
    required this.onBrightnessChanged,
    required this.onContrastChanged,
    required this.onSaturationChanged,
    required this.onHueChanged,
    required this.onFiltersPressed,
    required this.onRotatePressed,
    required this.onCropPressed,
  });

  @override
  State<EditingToolbar> createState() => _EditingToolbarState();
}

class _EditingToolbarState extends State<EditingToolbar> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(EditingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTool != oldWidget.selectedTool) {
      if (widget.selectedTool != null) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Adjustment slider (shown when tool is selected)
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SizeTransition(
                  sizeFactor: _slideAnimation,
                  child: _buildAdjustmentSlider(theme),
                );
              },
            ),

            // Tool buttons
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolButton(
                    context: context,
                    tool: EditingTool.brightness,
                    icon: Icons.brightness_6,
                    label: 'Brightness',
                  ),
                  _buildToolButton(
                    context: context,
                    tool: EditingTool.contrast,
                    icon: Icons.contrast,
                    label: 'Contrast',
                  ),
                  _buildToolButton(
                    context: context,
                    tool: EditingTool.saturation,
                    icon: Icons.color_lens,
                    label: 'Saturation',
                  ),
                  _buildToolButton(
                    context: context,
                    tool: EditingTool.hue,
                    icon: Icons.palette,
                    label: 'Hue',
                  ),
                  _buildToolButton(
                    context: context,
                    tool: EditingTool.filters,
                    icon: Icons.filter,
                    label: 'Filters',
                    onTap: widget.onFiltersPressed,
                  ),
                  _buildToolButton(
                    context: context,
                    tool: EditingTool.rotate,
                    icon: Icons.rotate_right,
                    label: 'Rotate',
                    onTap: widget.onRotatePressed,
                  ),
                  _buildToolButton(
                    context: context,
                    tool: EditingTool.crop,
                    icon: Icons.crop,
                    label: 'Crop',
                    onTap: widget.onCropPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentSlider(ThemeData theme) {
    if (widget.selectedTool == null) return const SizedBox.shrink();

    String label;
    double value;
    double min;
    double max;
    Function(double) onChanged;

    switch (widget.selectedTool!) {
      case EditingTool.brightness:
        label = 'Brightness';
        value = widget.brightness;
        min = -100;
        max = 100;
        onChanged = widget.onBrightnessChanged;
        break;
      case EditingTool.contrast:
        label = 'Contrast';
        value = widget.contrast;
        min = 50;
        max = 200;
        onChanged = widget.onContrastChanged;
        break;
      case EditingTool.saturation:
        label = 'Saturation';
        value = widget.saturation;
        min = 0;
        max = 2;
        onChanged = widget.onSaturationChanged;
        break;
      case EditingTool.hue:
        label = 'Hue';
        value = widget.hue;
        min = -180;
        max = 180;
        onChanged = widget.onHueChanged;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toStringAsFixed(0),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.outline.withOpacity(0.3),
              thumbColor: theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (newValue) {
                HapticFeedback.lightImpact();
                onChanged(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required EditingTool tool,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedTool == tool;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (onTap != null) {
              onTap();
            } else {
              widget.onToolSelected(tool);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1,
              )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}