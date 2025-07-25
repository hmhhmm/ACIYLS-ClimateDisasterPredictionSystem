import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlong;

class HeatMapPoint {
  final latlong.LatLng latLng;
  final double intensity;

  HeatMapPoint({required this.latLng, required this.intensity});
}

class HeatMapLayer extends StatelessWidget {
  final List<HeatMapPoint> heatMapDataPoints;
  final double radius;
  final double blur;
  final Color color;

  const HeatMapLayer({
    Key? key,
    required this.heatMapDataPoints,
    this.radius = 20,
    this.blur = 15,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapState = fmap.MapCamera.of(context);
    return CustomPaint(
      painter: _HeatMapPainter(
        points: heatMapDataPoints,
        mapState: mapState,
        radius: radius,
        blur: blur,
        color: color,
      ),
      size: Size(mapState.nonRotatedSize.x, mapState.nonRotatedSize.y),
    );
  }
}

class _HeatMapPainter extends CustomPainter {
  final List<HeatMapPoint> points;
  final fmap.MapCamera mapState;
  final double radius;
  final double blur;
  final Color color;

  _HeatMapPainter({
    required this.points,
    required this.mapState,
    required this.radius,
    required this.blur,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
      ..color = color;

    for (final point in points) {
      final pixelPoint = mapState.project(point.latLng);
      final screenPoint = mapState.pixelBounds.topLeft + pixelPoint;
      
      if (!Rect.fromLTWH(0, 0, mapState.nonRotatedSize.x, mapState.nonRotatedSize.y)
          .contains(Offset(screenPoint.x.toDouble(), screenPoint.y.toDouble()))) continue;

      final gradient = RadialGradient(
        colors: [
          color.withOpacity(point.intensity),
          color.withOpacity(0),
        ],
      );

      final rect = Rect.fromCircle(
        center: Offset(screenPoint.x.toDouble(), screenPoint.y.toDouble()),
        radius: radius,
      );

      paint.shader = gradient.createShader(rect);
      canvas.drawCircle(
        Offset(screenPoint.x.toDouble(), screenPoint.y.toDouble()),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
