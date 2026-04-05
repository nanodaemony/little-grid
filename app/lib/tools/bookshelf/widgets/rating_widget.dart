// app/lib/tools/bookshelf/widgets/rating_widget.dart

import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int? rating; // 1-10
  final void Function(int?) onRatingChanged;
  final int maxRating;
  final bool allowHalf;
  final double iconSize;
  final bool readonly;

  const RatingWidget({
    super.key,
    this.rating,
    required this.onRatingChanged,
    this.maxRating = 10,
    this.allowHalf = true,
    this.iconSize = 24,
    this.readonly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (readonly) {
      return _buildReadonlyRating(context);
    }
    return _buildInteractiveRating(context);
  }

  Widget _buildReadonlyRating(BuildContext context) {
    if (rating == null || rating == 0) {
      return Text(
        '未评分',
        style: TextStyle(
          fontSize: iconSize * 0.6,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate((maxRating / 2).ceil(), (index) {
        final starValue = (index + 1) * 2;
        final isFilled = rating! >= starValue;
        final isHalf = allowHalf && rating! >= starValue - 1 && rating! < starValue;

        if (isHalf) {
          return _buildHalfStar(context);
        }
        return _buildStar(context, isFilled);
      }),
    );
  }

  Widget _buildInteractiveRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate((maxRating / 2).ceil(), (index) {
        final starValue = (index + 1) * 2;
        final isSelected = rating != null && rating! >= starValue;

        return GestureDetector(
          onTap: () => onRatingChanged(starValue),
          onLongPress: allowHalf ? () => onRatingChanged(starValue - 1) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildStar(context, isSelected),
          ),
        );
      }),
    );
  }

  Widget _buildStar(BuildContext context, bool filled) {
    return Icon(
      filled ? Icons.star : Icons.star_border,
      size: iconSize,
      color: filled ? Colors.amber : Colors.grey.shade400,
    );
  }

  Widget _buildHalfStar(BuildContext context) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Stack(
        children: [
          Icon(
            Icons.star_border,
            size: iconSize,
            color: Colors.grey.shade400,
          ),
          ClipRect(
            clipper: _HalfClipper(),
            child: Icon(
              Icons.star,
              size: iconSize,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}

// 简化版评分组件，只显示当前分数
class RatingDisplay extends StatelessWidget {
  final int? rating;
  final double fontSize;
  final bool showIcon;

  const RatingDisplay({
    super.key,
    this.rating,
    this.fontSize = 14,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (rating == null || rating == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(Icons.star_border, size: fontSize, color: Colors.grey.shade400),
          if (showIcon) const SizedBox(width: 4),
          Text(
            '未评分',
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon)
          Icon(Icons.star, size: fontSize, color: Colors.amber),
        if (showIcon) const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade700,
          ),
        ),
        Text(
          '/10',
          style: TextStyle(
            fontSize: fontSize * 0.8,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
