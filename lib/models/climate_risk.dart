enum ClimateRiskType { flood, drought, heatwave, none }

class ClimateRisk {
  final ClimateRiskType type;
  final double riskLevel; // 0.0 - 1.0
  final String description;

  ClimateRisk({
    required this.type,
    required this.riskLevel,
    required this.description,
  });

  factory ClimateRisk.fromJson(Map<String, dynamic> json) {
    return ClimateRisk(
      type: ClimateRiskType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'none'),
        orElse: () => ClimateRiskType.none,
      ),
      riskLevel: (json['riskLevel'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.toString().split('.').last,
        'riskLevel': riskLevel,
        'description': description,
      };
} 