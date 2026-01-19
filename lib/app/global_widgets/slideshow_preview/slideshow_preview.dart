// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../core/constants/app_colors.dart';
import '../Loader/global_loader.dart';

class SlideshowPreview extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? eventTitle;
  final int slideshowDuration; // Duration in seconds for each slide

  const SlideshowPreview({
    required this.images,
    this.initialIndex = 0,
    this.eventTitle,
    this.slideshowDuration = 5,
  });

  @override
  State<SlideshowPreview> createState() => _SlideshowPreviewState();
}

class _SlideshowPreviewState extends State<SlideshowPreview>
    with SingleTickerProviderStateMixin {
  late CarouselSliderController _carouselController;
  late AnimationController _progressController;

  final RxInt _currentIndex = 0.obs;
  final RxBool _isPlaying = true.obs;
  Timer? _slideshowTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex.value = widget.initialIndex;
    _remainingSeconds = widget.slideshowDuration;
    _carouselController = CarouselSliderController();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.slideshowDuration),
    );

    // Enable screenshot protection
    ScreenProtector.preventScreenshotOn();

    // Start slideshow automatically after a short delay to let carousel initialize
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSlideshow();
    });
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _progressController.dispose();
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  void _startSlideshow() {
    _isPlaying.value = true;
    _remainingSeconds = widget.slideshowDuration;
    _progressController.forward(from: 0);

    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _goToNextSlide();
      }
    });
  }

  void _pauseSlideshow() {
    _isPlaying.value = false;
    _slideshowTimer?.cancel();
    _progressController.stop();
  }

  void _togglePlayPause() {
    if (_isPlaying.value) {
      _pauseSlideshow();
    } else {
      _resumeSlideshow();
    }
  }

  void _resumeSlideshow() {
    _isPlaying.value = true;
    _progressController.forward();

    _slideshowTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _goToNextSlide();
      }
    });
  }

  void _goToNextSlide() {
    _carouselController.nextPage(
      duration: const Duration(milliseconds: 500),
    );
  }

  void _goToPreviousSlide() {
    _carouselController.previousPage(
      duration: const Duration(milliseconds: 500),
    );
  }

  void _onPageChanged(int index, CarouselPageChangedReason reason) {
    _currentIndex.value = index;
    _remainingSeconds = widget.slideshowDuration;
    _progressController.forward(from: 0);

    // If user manually swiped while paused, keep it paused
    if (!_isPlaying.value) {
      _progressController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(size),

            // Photo View with Navigation
            Expanded(
              child: Stack(
                children: [
                  // Carousel Slider
                  CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: widget.images.length,
                    options: CarouselOptions(
                      initialPage: widget.initialIndex,
                      height: double.infinity,
                      viewportFraction: 0.85,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.2,
                      enableInfiniteScroll: true,
                      onPageChanged: _onPageChanged,
                    ),
                    itemBuilder: (context, index, realIndex) => _buildPhotoItem(index),
                  ),

                  // Photo Counter Badge
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex.value + 1} / ${widget.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                    ),
                  ),

                  // Left Navigation Arrow
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _buildNavigationButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: _goToPreviousSlide,
                      ),
                    ),
                  ),

                  // Right Navigation Arrow
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _buildNavigationButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: _goToNextSlide,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            _buildProgressBar(),

            // Bottom Controls
            _buildBottomControls(size),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // App Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.eventTitle ?? 'Shared Gallery',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Public Shared Link',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Close Button
          IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: widget.images[index],
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (_, __) => Container(
            color: Colors.grey[900],
            child: const Center(
              child: Global_Loader(size: 32, color: Colors.white),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: Colors.grey[900],
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.grey,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    // Instagram Stories-style segmented progress indicator
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() => Row(
        children: List.generate(
          widget.images.length,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.symmetric(horizontal: widget.images.length > 20 ? 1 : 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: index < _currentIndex.value
                    // Completed segments - fully filled
                    ? Container(color: AppColors.primaryColor)
                    : index == _currentIndex.value
                        // Current segment - animated progress
                        ? AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _progressController.value,
                                backgroundColor: Colors.grey[700],
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                                minHeight: 3,
                              );
                            },
                          )
                        // Upcoming segments - empty
                        : Container(color: Colors.grey[700]),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildBottomControls(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Play/Pause Button - smaller and cleaner
          Obx(() => GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          )),
        ],
      ),
    );
  }
}
