import '../models/weather.dart';
import '../models/climate_risk.dart';

class PredictionService {
  // Mock prediction logic for demo
  Future<ClimateRisk> predictRisk(List<Weather> forecast) async {
    double avgRain = forecast.map((w) => w.rainfall).fold(0.0, (a, b) => a + b) / forecast.length;
    double avgTemp = forecast.map((w) => w.temperature).fold(0.0, (a, b) => a + b) / forecast.length;

    if (avgRain > 30) {
      return ClimateRisk(
        type: ClimateRiskType.flood,
        riskLevel: (avgRain / 100).clamp(0.0, 1.0),
        description: 'High flood risk due to heavy rainfall.',
      );
    } else if (avgTemp > 38) {
      return ClimateRisk(
        type: ClimateRiskType.heatwave,
        riskLevel: (avgTemp - 35) / 15.0,
        description: 'Extreme heatwave risk.',
      );
    } else if (avgRain < 2) {
      return ClimateRisk(
        type: ClimateRiskType.drought,
        riskLevel: (2 - avgRain) / 2.0,
        description: 'Drought risk due to low rainfall.',
      );
    }
    return ClimateRisk(
      type: ClimateRiskType.none,
      riskLevel: 0.0,
      description: 'No significant climate risk detected.',
    );
  }
} 