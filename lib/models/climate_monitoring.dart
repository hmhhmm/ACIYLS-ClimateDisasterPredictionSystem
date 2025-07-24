import 'package:flutter/material.dart';

enum ClimateRiskLevel { low, moderate, high, severe, extreme }

enum WeatherCondition { sunny, cloudy, rainy, stormy }

enum AlertType { flood, drought, quality, infrastructure }

enum SensorType { rainfall, temperature, humidity, waterLevel, soilMoisture }

class ClimateData {
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final double rainfall;
  final double windSpeed;
  final WeatherCondition condition;
  final Map<String, double> additionalMetrics;

  const ClimateData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    required this.condition,
    this.additionalMetrics = const {},
  });

  // Factory method for mock data
  factory ClimateData.mock() {
    return ClimateData(
      timestamp: DateTime.now(),
      temperature: 28.5,
      humidity: 65.0,
      rainfall: 2.5,
      windSpeed: 12.0,
      condition: WeatherCondition.cloudy,
      additionalMetrics: {
        'soilMoisture': 45.0,
        'groundwaterLevel': 120.5,
        'evaporationRate': 3.2,
      },
    );
  }
}

class ClimateRiskAssessment {
  final String locationId;
  final DateTime assessmentDate;
  final ClimateRiskLevel floodRisk;
  final ClimateRiskLevel droughtRisk;
  final ClimateRiskLevel qualityRisk;
  final ClimateRiskLevel infrastructureRisk;
  final List<String> riskFactors;
  final Map<String, double> riskScores;
  final String recommendations;

  const ClimateRiskAssessment({
    required this.locationId,
    required this.assessmentDate,
    required this.floodRisk,
    required this.droughtRisk,
    required this.qualityRisk,
    required this.infrastructureRisk,
    required this.riskFactors,
    required this.riskScores,
    required this.recommendations,
  });

  // Factory method for mock data
  factory ClimateRiskAssessment.mock() {
    return ClimateRiskAssessment(
      locationId: 'LOC001',
      assessmentDate: DateTime.now(),
      floodRisk: ClimateRiskLevel.moderate,
      droughtRisk: ClimateRiskLevel.low,
      qualityRisk: ClimateRiskLevel.high,
      infrastructureRisk: ClimateRiskLevel.low,
      riskFactors: [
        'Heavy rainfall predicted',
        'Aging infrastructure',
        'Historical flooding patterns',
      ],
      riskScores: {'overall': 0.65, 'shortTerm': 0.45, 'longTerm': 0.75},
      recommendations:
          'Implement flood prevention measures and monitor water quality closely.',
    );
  }

  Color getRiskColor(ClimateRiskLevel risk) {
    switch (risk) {
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
}

class EnvironmentalMetrics {
  final String locationId;
  final DateTime timestamp;
  final double waterTableLevel;
  final double soilMoisture;
  final double evaporationRate;
  final double watershedHealth;
  final Map<String, double> qualityIndicators;
  final List<String> environmentalConcerns;

  const EnvironmentalMetrics({
    required this.locationId,
    required this.timestamp,
    required this.waterTableLevel,
    required this.soilMoisture,
    required this.evaporationRate,
    required this.watershedHealth,
    required this.qualityIndicators,
    required this.environmentalConcerns,
  });

  // Factory method for mock data
  factory EnvironmentalMetrics.mock() {
    return EnvironmentalMetrics(
      locationId: 'LOC001',
      timestamp: DateTime.now(),
      waterTableLevel: 125.5,
      soilMoisture: 42.0,
      evaporationRate: 3.5,
      watershedHealth: 0.78,
      qualityIndicators: {'pH': 7.2, 'turbidity': 0.8, 'dissolvedOxygen': 8.5},
      environmentalConcerns: [
        'Increased urban runoff',
        'Seasonal variation in rainfall',
        'Agricultural activities impact',
      ],
    );
  }
}

class ClimateAlert {
  final String alertId;
  final AlertType type;
  final ClimateRiskLevel severity;
  final DateTime timestamp;
  final String title;
  final String description;
  final List<String> affectedAreas;
  final Map<String, dynamic> metadata;
  final List<String> recommendedActions;
  final bool isActive;

  const ClimateAlert({
    required this.alertId,
    required this.type,
    required this.severity,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.affectedAreas,
    required this.metadata,
    required this.recommendedActions,
    required this.isActive,
  });

  // Factory method for mock data
  factory ClimateAlert.mock() {
    return ClimateAlert(
      alertId: 'ALERT001',
      type: AlertType.flood,
      severity: ClimateRiskLevel.high,
      timestamp: DateTime.now(),
      title: 'Flood Risk Alert',
      description:
          'Heavy rainfall expected in the next 24 hours. Potential flooding in low-lying areas.',
      affectedAreas: ['Zone A', 'Zone B', 'Zone C'],
      metadata: {
        'expectedRainfall': '150mm',
        'duration': '24h',
        'confidenceLevel': 0.85,
      },
      recommendedActions: [
        'Move to higher ground',
        'Store clean water',
        'Follow evacuation routes if necessary',
      ],
      isActive: true,
    );
  }

  Color getAlertColor() {
    switch (type) {
      case AlertType.flood:
        return Colors.blue;
      case AlertType.drought:
        return Colors.orange;
      case AlertType.quality:
        return Colors.red;
      case AlertType.infrastructure:
        return Colors.purple;
    }
  }
}

class SensorReading {
  final String sensorId;
  final SensorType type;
  final DateTime timestamp;
  final double value;
  final String unit;
  final bool isOperational;
  final Map<String, dynamic> metadata;

  const SensorReading({
    required this.sensorId,
    required this.type,
    required this.timestamp,
    required this.value,
    required this.unit,
    required this.isOperational,
    required this.metadata,
  });

  // Factory method for mock data
  factory SensorReading.mock() {
    return SensorReading(
      sensorId: 'SENSOR001',
      type: SensorType.rainfall,
      timestamp: DateTime.now(),
      value: 25.5,
      unit: 'mm',
      isOperational: true,
      metadata: {
        'location': {'lat': 3.123, 'lng': 101.456},
        'accuracy': 0.95,
        'batteryLevel': 85,
      },
    );
  }
}

class ClimateReport {
  final String reportId;
  final DateTime generatedAt;
  final String locationId;
  final Map<String, ClimateRiskLevel> risks;
  final List<Map<String, dynamic>> trends;
  final List<String> recommendations;
  final Map<String, dynamic> statistics;

  const ClimateReport({
    required this.reportId,
    required this.generatedAt,
    required this.locationId,
    required this.risks,
    required this.trends,
    required this.recommendations,
    required this.statistics,
  });

  // Factory method for mock data
  factory ClimateReport.mock() {
    return ClimateReport(
      reportId: 'REPORT001',
      generatedAt: DateTime.now(),
      locationId: 'LOC001',
      risks: {
        'flood': ClimateRiskLevel.moderate,
        'drought': ClimateRiskLevel.low,
        'quality': ClimateRiskLevel.high,
      },
      trends: [
        {
          'metric': 'rainfall',
          'trend': 'increasing',
          'changeRate': 0.15,
          'period': '3months',
        },
        {
          'metric': 'temperature',
          'trend': 'stable',
          'changeRate': 0.02,
          'period': '3months',
        },
      ],
      recommendations: [
        'Implement water conservation measures',
        'Upgrade drainage systems',
        'Monitor water quality more frequently',
      ],
      statistics: {
        'averageRainfall': 125.5,
        'temperatureRange': {'min': 22.5, 'max': 32.5},
        'waterQualityIndex': 0.85,
      },
    );
  }
}
