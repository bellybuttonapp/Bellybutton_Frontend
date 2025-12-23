// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EventCardShimmer extends StatelessWidget {
  final int itemCount;

  const EventCardShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: EdgeInsets.all(width * 0.035),
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: width * 0.02,
              ),
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1.2, // subtle stroke
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ Image placeholder
                  Container(
                    width: width * 0.14,
                    height: width * 0.14,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  SizedBox(width: width * 0.03),

                  // ✅ Text placeholders
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: width * 0.035,
                          width: width * 0.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: width * 0.02),
                        Container(
                          height: width * 0.03,
                          width: width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: width * 0.02),
                        Container(
                          height: width * 0.03,
                          width: width * 0.25,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: width * 0.03),

                  // ✅ Time placeholder
                  Container(
                    height: width * 0.03,
                    width: width * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
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
