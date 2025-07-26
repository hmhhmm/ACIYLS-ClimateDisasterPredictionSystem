import 'package:flutter/material.dart';
import 'dart:math'; // Added for Random

enum ClimateRiskLevel {
  low,
  moderate,
  high,
  severe,
  extreme;

  Color get color {
    switch (this) {
      case ClimateRiskLevel.low:
        return Colors.green;
      case ClimateRiskLevel.moderate:
        return Colors.yellow;
      case ClimateRiskLevel.high:
        return Colors.orange;
      case ClimateRiskLevel.severe:
        return Colors.red;
      case ClimateRiskLevel.extreme:
        return Colors.purple;
    }
  }

  String get description {
    switch (this) {
      case ClimateRiskLevel.low:
        return 'Normal conditions, no immediate risks';
      case ClimateRiskLevel.moderate:
        return 'Minor concerns, monitor situation';
      case ClimateRiskLevel.high:
        return 'Significant risks, prepare for impact';
      case ClimateRiskLevel.severe:
        return 'Serious conditions, take immediate action';
      case ClimateRiskLevel.extreme:
        return 'Critical situation, emergency measures required';
    }
  }
}

class ClimateData {
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final double rainfall;
  final double windSpeed;
  final double soilMoisture;
  final double waterTableLevel;
  final ClimateRiskLevel floodRisk;
  final ClimateRiskLevel droughtRisk;
  final List<String> activeAlerts;

  const ClimateData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    required this.soilMoisture,
    required this.waterTableLevel,
    required this.floodRisk,
    required this.droughtRisk,
    required this.activeAlerts,
  });

  // Mock data generator
  static ClimateData getMockData() {
    final now = DateTime.now();
    return ClimateData(
      timestamp: now,
      temperature: 28.5,
      humidity: 65.0,
      rainfall: 12.5,
      windSpeed: 15.0,
      soilMoisture: 35.0,
      waterTableLevel: -2.5,
      floodRisk: ClimateRiskLevel.moderate,
      droughtRisk: ClimateRiskLevel.low,
      activeAlerts: [
        'Heavy rainfall expected in next 24 hours',
        'High temperature warning for agricultural areas',
      ],
    );
  }

  // Mock historical data
  static List<ClimateData> getMockHistoricalData(int days) {
    final random = Random(42); // Seeded for repeatability
    double temp = 26.0;
    double humidity = 70.0;
    double rainfall = 2.0;
    double windSpeed = 8.0;
    double soilMoisture = 35.0;
    double waterTableLevel = -2.0;
    return List.generate(days, (index) {
      final date = DateTime.now().subtract(Duration(days: days - index - 1));
      // Add plausible daily variation
      temp += random.nextDouble() * 1.5 - 0.7; // small up/down
      humidity += random.nextDouble() * 2.0 - 1.0;
      rainfall = random.nextDouble() < 0.2
          ? random.nextDouble() * 30
          : random.nextDouble() * 3; // occasional heavy rain
      windSpeed += random.nextDouble() * 0.8 - 0.4;
      soilMoisture += (rainfall - 2.0) * 0.2 + random.nextDouble() * 0.5 - 0.25;
      soilMoisture = soilMoisture.clamp(20.0, 60.0);
      waterTableLevel +=
          (rainfall > 10 ? 0.05 : -0.01) + random.nextDouble() * 0.02 - 0.01;
      // Risk levels based on actual values
      final floodRisk = rainfall > 20
          ? ClimateRiskLevel.high
          : rainfall > 10
          ? ClimateRiskLevel.moderate
          : ClimateRiskLevel.low;
      final droughtRisk = soilMoisture < 25
          ? ClimateRiskLevel.high
          : soilMoisture < 32
          ? ClimateRiskLevel.moderate
          : ClimateRiskLevel.low;
      return ClimateData(
        timestamp: date,
        temperature: temp.clamp(22.0, 38.0),
        humidity: humidity.clamp(40.0, 95.0),
        rainfall: rainfall,
        windSpeed: windSpeed.clamp(2.0, 18.0),
        soilMoisture: soilMoisture,
        waterTableLevel: waterTableLevel,
        floodRisk: floodRisk,
        droughtRisk: droughtRisk,
        activeAlerts:
            floodRisk == ClimateRiskLevel.high ||
                droughtRisk == ClimateRiskLevel.high
            ? ['Severe Alert']
            : [],
      );
    });
  }
}

class WaterSourceImpact {
  final String sourceId;
  final String sourceName;
  final ClimateRiskLevel riskLevel;
  final List<String> vulnerabilities;
  final List<String> recommendations;
  final double impactScore;

  const WaterSourceImpact({
    required this.sourceId,
    required this.sourceName,
    required this.riskLevel,
    required this.vulnerabilities,
    required this.recommendations,
    required this.impactScore,
  });

  // Mock data generator
  static List<WaterSourceImpact> getMockImpacts() {
    return [
      WaterSourceImpact(
        sourceId: 'WS001',
        sourceName: 'Central Reservoir',
        riskLevel: ClimateRiskLevel.moderate,
        vulnerabilities: [
          'Exposed to direct sunlight',
          'Limited natural barriers',
          'High evaporation risk',
        ],
        recommendations: [
          'Install shade structures',
          'Implement water conservation measures',
          'Monitor water quality regularly',
        ],
        impactScore: 65.0,
      ),
      WaterSourceImpact(
        sourceId: 'WS002',
        sourceName: 'Community Well A',
        riskLevel: ClimateRiskLevel.low,
        vulnerabilities: [
          'Seasonal water level fluctuation',
          'Limited filtration system',
        ],
        recommendations: [
          'Install water level sensors',
          'Upgrade filtration system',
          'Develop backup water source',
        ],
        impactScore: 35.0,
      ),
      WaterSourceImpact(
        sourceId: 'WS003',
        sourceName: 'Agricultural Canal',
        riskLevel: ClimateRiskLevel.high,
        vulnerabilities: [
          'Open water exposure',
          'Agricultural runoff risk',
          'High sediment content',
          'Flood vulnerability',
        ],
        recommendations: [
          'Install protective barriers',
          'Implement runoff control measures',
          'Regular water quality testing',
          'Develop flood management plan',
        ],
        impactScore: 85.0,
      ),
    ];
  }
}

class ClimateAlert {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final ClimateRiskLevel severity;
  final List<String> affectedAreas;
  final List<String> recommendations;
  final bool isActive;

  const ClimateAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    required this.affectedAreas,
    required this.recommendations,
    required this.isActive,
  });

  // Mock data generator
  static List<ClimateAlert> getMockAlerts() {
    return [
      ClimateAlert(
        id: 'CA001',
        title: 'Flood Warning',
        description:
            'Heavy rainfall expected to cause flooding in low-lying areas',
        timestamp: DateTime.now(),
        severity: ClimateRiskLevel.severe,
        affectedAreas: [
          'Riverside District',
          'Valley Region',
          'Lower Township',
        ],
        recommendations: [
          'Move to higher ground',
          'Store drinking water',
          'Follow evacuation orders',
          'Monitor local news',
        ],
        isActive: true,
      ),
      ClimateAlert(
        id: 'CA002',
        title: 'Drought Advisory',
        description: 'Extended dry period affecting water availability',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        severity: ClimateRiskLevel.high,
        affectedAreas: ['Agricultural Zone', 'Eastern District'],
        recommendations: [
          'Implement water conservation',
          'Reduce non-essential usage',
          'Check for leaks',
          'Follow restriction guidelines',
        ],
        isActive: true,
      ),
      ClimateAlert(
        id: 'CA003',
        title: 'Water Quality Alert',
        description: 'Increased turbidity due to recent weather conditions',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        severity: ClimateRiskLevel.moderate,
        affectedAreas: ['Central District', 'Northern Region'],
        recommendations: [
          'Boil water before use',
          'Use filtered water',
          'Monitor for changes',
        ],
        isActive: true,
      ),
    ];
  }
}
