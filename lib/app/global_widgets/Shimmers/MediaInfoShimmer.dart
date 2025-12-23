// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MediaInfoShimmer extends StatelessWidget {
  final int rowCount;

  const MediaInfoShimmer({
    super.key,
    this.rowCount = 7,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = Get.width;

    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor =
        isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        rowCount,
        (index) => Padding(
          padding: EdgeInsets.symmetric(vertical: Get.height * 0.008),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label shimmer
              SizedBox(
                width: width * 0.3,
                child: _shimmer(
                  baseColor,
                  highlightColor,
                  child: Container(
                    height: width * 0.04,
                    width: width * 0.2,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              // Value shimmer
              Expanded(
                child: _shimmer(
                  baseColor,
                  highlightColor,
                  child: Container(
                    height: width * 0.04,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmer(Color base, Color highlight, {required Widget child}) {
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: child,
    );
  }
}