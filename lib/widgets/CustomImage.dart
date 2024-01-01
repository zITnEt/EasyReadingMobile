import 'package:flutter/material.dart';

class CustomGradientImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final double borderRadius;
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final Alignment begin;
  final Alignment end;
  final GradientTransform? transform;
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static bool _isInitialized = false;

  const CustomGradientImage({super.key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.borderRadius = 0,
    this.gradientColors = const [],
    this.gradientStops = const [],
    this.begin = Alignment.bottomRight,
    this.end = Alignment.topLeft,
    this.transform,
  });

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized){
      if (MediaQuery.of(context).size.width < MediaQuery.of(context).size.height){
        _screenWidth = MediaQuery.of(context).size.width;
        _screenHeight = MediaQuery.of(context).size.height;
      }
      else{
        _screenWidth = MediaQuery.of(context).size.height;
        _screenHeight = MediaQuery.of(context).size.width;
      }
      _isInitialized = true;
    }

    return Container(
      width: ((width > _screenWidth) ? _screenWidth: width/360)*_screenWidth,
      height: (height/672)*_screenHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: gradientStops,
          transform: transform
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}