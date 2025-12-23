// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class EventGalleryShimmer extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;

  const EventGalleryShimmer({
    super.key,
    this.itemCount = 20,
    this.crossAxisCount = 3,
    this.mainAxisSpacing = 6.0,
    this.crossAxisSpacing = 6.0,
    this.padding,
  });

  // Generate varying heights for Pinterest-like effect
  double _getItemHeight(int index) {
    // Create a pattern of varying heights for visual interest
    final heights = [120.0, 180.0, 140.0, 200.0, 160.0, 220.0, 130.0, 190.0];
    return heights[index % heights.length];
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(8),
        child: MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Container(
              height: _getItemHeight(index),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        ),
      ),
    );
  }
}