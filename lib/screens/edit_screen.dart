import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/photo_filter.dart';
import '../services/photo_service.dart';
import '../widgets/editing_toolbar.dart';
import '../widgets/filter_preview_card.dart';


class EditScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const EditScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> with TickerProviderStateMixin {
  late Uint8List _currentImageBytes;
  late Uint8List _originalImageBytes;

  // Editing values
  double _brightness = 0;
  double _contrast = 100;
  double _saturation = 1;
  double _hue = 0;
  FilterType _selectedFilter = FilterType.none;
  EditingTool? _selectedTool;

  // UI Controllers
  late AnimationController _appBarController;
  late AnimationController _filtersController;
  late Animation<double> _appBarAnimation;
  late Animation<Offset> _filtersSlideAnimation;

  bool _showFilters = false;
  bool _isProcessing = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _originalImageBytes = Uint8List.fromList(widget.imageBytes);
    _currentImageBytes = Uint8List.fromList(widget.imageBytes);

    _initializeAnimations();
  }

  void _initializeAnimations() {
    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _filtersController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _appBarAnimation = CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeInOut,
    );

    _filtersSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filtersController,
      curve: Curves.easeOutCubic,
    ));

    // Start with app bar visible
    _appBarController.forward();
  }

  @override
  void dispose() {
    _appBarController.dispose();
    _filtersController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      _selectedTool = null;
    });

    if (_showFilters) {
      _filtersController.forward();
    } else {
      _filtersController.reverse();
    }
  }

  void _applyFilter(FilterType filterType) {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _selectedFilter = filterType;
      _hasUnsavedChanges = true;
    });

    HapticFeedback.mediumImpact();

    // Apply filter in background
    Future.microtask(() {
      final filteredBytes = PhotoFilter.applyFilter(_originalImageBytes, filterType);

      if (mounted) {
        setState(() {
          _currentImageBytes = filteredBytes;
          _isProcessing = false;
        });
      }
    });
  }

  void _applyAdjustment() {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _hasUnsavedChanges = true;
    });

    Future.microtask(() {
      Uint8List adjustedBytes = Uint8List.fromList(_originalImageBytes);

      // Apply filter first if selected
      if (_selectedFilter != FilterType.none) {
        adjustedBytes = PhotoFilter.applyFilter(adjustedBytes, _selectedFilter);
      }

      // Apply adjustments
      if (_brightness != 0) {
        adjustedBytes = PhotoService.adjustBrightness(adjustedBytes, _brightness);
      }
      if (_contrast != 100) {
        adjustedBytes = PhotoService.adjustContrast(adjustedBytes, _contrast);
      }
      if (_saturation != 1) {
        adjustedBytes = PhotoService.adjustSaturation(adjustedBytes, _saturation);
      }
      if (_hue != 0) {
        adjustedBytes = PhotoService.adjustHue(adjustedBytes, _hue);
      }

      if (mounted) {
        setState(() {
          _currentImageBytes = adjustedBytes;
          _isProcessing = false;
        });
      }
    });
  }

  void _resetAll() {
    HapticFeedback.mediumImpact();

    setState(() {
      _currentImageBytes = Uint8List.fromList(_originalImageBytes);
      _brightness = 0;
      _contrast = 100;
      _saturation = 1;
      _hue = 0;
      _selectedFilter = FilterType.none;
      _selectedTool = null;
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _saveImage() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final filename = 'edited_\${DateTime.now().millisecondsSinceEpoch}';
      final savedPath = await PhotoService.saveImageToGallery(_currentImageBytes, filename);

      if (savedPath != null && mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Photo saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving photo: \$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _rotateImage() {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _hasUnsavedChanges = true;
    });

    HapticFeedback.lightImpact();

    Future.microtask(() {
      final rotatedBytes = PhotoService.rotateImage(_currentImageBytes, 90);

      if (mounted) {
        setState(() {
          _currentImageBytes = rotatedBytes;
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text('You have unsaved changes. Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Main image area
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Toggle app bar visibility
                  if (_appBarController.isCompleted) {
                    _appBarController.reverse();
                  } else {
                    _appBarController.forward();
                  }
                },
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Stack(
                      children: [
                        Image.memory(
                          _currentImageBytes,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        if (_isProcessing)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top app bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _appBarAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -60 * (1 - _appBarAnimation.value)),
                    child: Opacity(
                      opacity: _appBarAnimation.value,
                      child: _buildAppBar(theme),
                    ),
                  );
                },
              ),
            ),

            // Filters panel
            AnimatedBuilder(
              animation: _filtersSlideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _filtersSlideAnimation,
                  child: _buildFiltersPanel(theme),
                );
              },
            ),

            // Bottom editing toolbar
            if (!_showFilters)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: EditingToolbar(
                  selectedTool: _selectedTool,
                  brightness: _brightness,
                  contrast: _contrast,
                  saturation: _saturation,
                  hue: _hue,
                  onToolSelected: (tool) {
                    setState(() {
                      _selectedTool = _selectedTool == tool ? null : tool;
                    });
                  },
                  onBrightnessChanged: (value) {
                    setState(() {
                      _brightness = value;
                    });
                    _applyAdjustment();
                  },
                  onContrastChanged: (value) {
                    setState(() {
                      _contrast = value;
                    });
                    _applyAdjustment();
                  },
                  onSaturationChanged: (value) {
                    setState(() {
                      _saturation = value;
                    });
                    _applyAdjustment();
                  },
                  onHueChanged: (value) {
                    setState(() {
                      _hue = value;
                    });
                    _applyAdjustment();
                  },
                  onFiltersPressed: _toggleFilters,
                  onRotatePressed: _rotateImage,
                  onCropPressed: () {
                    // TODO: Implement crop functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Crop feature coming soon!')),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Title
              Text(
                'Edit Photo',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Action buttons
              Row(
                children: [
                  // Reset button
                  if (_hasUnsavedChanges)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _resetAll,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                  if (_hasUnsavedChanges) const SizedBox(width: 8),

                  // Save button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _saveImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.save_alt,
                              color: theme.colorScheme.onPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Save',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersPanel(ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleFilters,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filters list
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: PhotoFilter.filters.length,
                  itemBuilder: (context, index) {
                    final filter = PhotoFilter.filters[index];
                    return FilterPreviewCard(
                      filter: filter,
                      isSelected: _selectedFilter == filter.type,
                      onTap: () => _applyFilter(filter.type),
                      previewImage: FilterPreviewThumbnail(
                        originalImage: Image.memory(
                          _originalImageBytes,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        ),
                        filter: filter,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}