import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final int starCount;
  final double rating;
  final void Function(double rating)? onRatingChanged;
  final Color? color;
  final double size;

  const StarRating({
    super.key,
    this.starCount = 5,
    this.rating = 0,
    this.onRatingChanged,
    this.color,
    this.size = 40,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _displayRating;

  @override
  void initState() {
    super.initState();
    _displayRating = widget.rating;
  }

  void _updateRatingFromPosition(Offset localPosition, double maxWidth) {
    if (maxWidth == double.infinity) {
      throw Exception(
        "The star rating widget will not work with an infinite width. Please limit the widget's width",
      );
    }
    
    if (widget.onRatingChanged == null) return; // Desativa se não for interativo

    final starWidth = maxWidth / widget.starCount;
    double rawRating = localPosition.dx / starWidth;
    double newRating = (rawRating * 2).ceil() / 2; // Round to nearest 0.5
    newRating = newRating.clamp(0.0, widget.starCount.toDouble());

    setState(() {
      _displayRating = newRating;
    });

    if (widget.onRatingChanged != null) {
      widget.onRatingChanged!(newRating);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) => GestureDetector(
            onHorizontalDragUpdate: (details) {
              _updateRatingFromPosition(
                details.localPosition,
                constraints.maxWidth,
              );
            },
            onTapDown: (details) {
              _updateRatingFromPosition(
                details.localPosition,
                constraints.maxWidth,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(widget.starCount, (index) {
                print('NEW RATING $_displayRating');
                final currentRating = _displayRating - index;
                Icon icon;

                if (currentRating >= 1) {
                  icon = Icon(
                    Icons.star,
                    size: widget.size,
                    color: widget.color ?? Colors.amber,
                  );
                } else if (currentRating >= 0.5) {
                  icon = Icon(
                    Icons.star_half,
                    size: widget.size,
                    color: widget.color ?? Colors.amber,
                  );
                } else {
                  icon = Icon(
                    Icons.star_border,
                    size: widget.size,
                    color: widget.color ?? Colors.amber,
                  );
                }

                return Semantics(
                  label: 'Rating star ${index + 1}',
                  child: icon,
                );
              }),
            ),
          ),
    );
  }
}
