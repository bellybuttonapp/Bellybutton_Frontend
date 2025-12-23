// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TermsContentShimmer extends StatelessWidget {
  const TermsContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor =
        isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.02,
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            Container(
              height: width * 0.06,
              width: width * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: height * 0.025),

            // Paragraph lines
            ...List.generate(4, (index) => _buildParagraphShimmer(width, height)),

            // Subheading
            SizedBox(height: height * 0.015),
            Container(
              height: width * 0.045,
              width: width * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: height * 0.015),

            // More paragraph lines
            ...List.generate(3, (index) => _buildParagraphShimmer(width, height)),

            // Another subheading
            SizedBox(height: height * 0.015),
            Container(
              height: width * 0.045,
              width: width * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: height * 0.015),

            // List items shimmer
            ...List.generate(5, (index) => _buildListItemShimmer(width, height)),

            // Final paragraph
            SizedBox(height: height * 0.01),
            ...List.generate(2, (index) => _buildParagraphShimmer(width, height)),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraphShimmer(double width, double height) {
    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: width * 0.035,
            width: width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: height * 0.008),
          Container(
            height: width * 0.035,
            width: width * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: height * 0.008),
          Container(
            height: width * 0.035,
            width: width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItemShimmer(double width, double height) {
    return Padding(
      padding: EdgeInsets.only(left: width * 0.04, bottom: height * 0.012),
      child: Row(
        children: [
          Container(
            height: width * 0.02,
            width: width * 0.02,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Container(
              height: width * 0.033,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(width: width * 0.1),
        ],
      ),
    );
  }
}
