import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;         
  final int starCount;        
  final double size;           
  final Color color;           
  const StarRating({
    Key? key,
    required this.rating,
    this.starCount = 5,
    this.size = 20.0,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: color, size: size);
        } else if (index < rating && rating % 1 != 0) {
          return Icon(Icons.star_half, color: color, size: size);
        } else {
          return Icon(Icons.star_border, color: color, size: size);
        }
      }),
    );
  }
}
