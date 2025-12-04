// ignore_for_file: deprecated_member_use, file_names, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class InvitedUsersShimmer extends StatelessWidget {
  final double width;
  final int count; // shimmer count driven by API result

  const InvitedUsersShimmer({
    super.key,
    required this.width,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return ListView.separated(
      itemCount: count,
      separatorBuilder:
          (_, __) => Divider(
            color: baseColor.withOpacity(0.4),
            thickness: 0.6,
            height: width * 0.08,
          ),
      itemBuilder: (_, __) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: width * 0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Avatar loading shimmer
              _shimmer(
                baseColor,
                highlight,
                child: Container(
                  width: width * 0.10,
                  height: width * 0.10,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              SizedBox(width: width * 0.04),

              /// Name shimmer bar
              Expanded(
                flex: 2,
                child: _shimmer(
                  baseColor,
                  highlight,
                  child: Container(
                    height: width * 0.04,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              SizedBox(width: width * 0.05),

              /// Admin badge shimmer (smaller)
              _shimmer(
                baseColor,
                highlight,
                child: Container(
                  height: width * 0.032,
                  width: width * 0.18,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Reusable shimmer wrapper
  Widget _shimmer(Color base, Color highlight, {required Widget child}) {
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: child,
    );
  }
}
