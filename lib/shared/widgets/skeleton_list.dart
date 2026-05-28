import 'package:core/core.dart';
import 'package:flutter/material.dart';

class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 8});

  final int count;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.count,
      itemBuilder: (context, index) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final alpha = 0.25 + _controller.value * 0.35;
          final color = AppColors.surfaceAlt.withValues(alpha: alpha);
          Widget bar(double widthFactor, double height) => FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(0.6, 13),
                      const SizedBox(height: 8),
                      bar(0.4, 11),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
