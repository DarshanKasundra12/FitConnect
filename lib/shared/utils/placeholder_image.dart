import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const PlaceholderImage({
    super.key,
    required this.width,
    required this.height,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.image,
          size: width * 0.3,
          color: color.withOpacity(0.7),
        ),
      ),
    );
  }
}
