// ignore_for_file: file_names, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ContactsListShimmer extends StatelessWidget {
  final int count;

  const ContactsListShimmer({
    super.key,
    this.count = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Avatar shimmer
              _shimmer(
                baseColor,
                highlightColor,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Name shimmer
              Expanded(
                child: _shimmer(
                  baseColor,
                  highlightColor,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Checkbox shimmer
              _shimmer(
                baseColor,
                highlightColor,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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