import 'package:flutter/material.dart';

class RiskDetailScreen extends StatelessWidget {
  final String type;
  final String description;
  final Color color;
  final IconData icon;

  const RiskDetailScreen({
    super.key,
    required this.type,
    required this.description,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // background outside phone frame
      alignment: Alignment.topCenter,
      child: Container(
        width: 390, // iPhone 14 Pro width
        height: 844, // iPhone 14 Pro height
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.black12, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$type Risk Details',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // for symmetry with back button
                    ],
                  ),
                ),
              ),
            ),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 350),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  color: color.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 36,
                            child: Icon(icon, color: Colors.white, size: 40),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            type,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          description,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'How is this disaster predicted?',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                        ),
                        const SizedBox(height: 10),
                        _predictionExplanation(type),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _predictionExplanation(String type) {
    switch (type) {
      case 'Flood':
        return const Text(
          'Flood risk is predicted based on recent and forecasted rainfall amounts, river levels, and weather patterns. High rainfall over a short period increases the risk.',
          style: TextStyle(fontSize: 15),
        );
      case 'Typhoon':
        return const Text(
          'Typhoon risk is predicted using meteorological data such as wind speed, pressure, and satellite imagery. Weather models forecast the likelihood and path of typhoons.',
          style: TextStyle(fontSize: 15),
        );
      case 'Heatwave':
        return const Text(
          'Heatwave risk is predicted by analyzing temperature trends, humidity, and forecasted high temperatures over several days.',
          style: TextStyle(fontSize: 15),
        );
      case 'Drought':
        return const Text(
          'Drought risk is predicted by monitoring rainfall deficits, soil moisture, and long-term weather forecasts.',
          style: TextStyle(fontSize: 15),
        );
      default:
        return const Text(
          'This risk is predicted using weather data and climate models.',
          style: TextStyle(fontSize: 15),
        );
    }
  }
} 