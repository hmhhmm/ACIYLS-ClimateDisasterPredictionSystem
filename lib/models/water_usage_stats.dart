import 'package:flutter/material.dart';

class WaterUsageStats {
  final String unitId;
  final List<DailyUsage> dailyUsage;
  final List<MaintenanceRecord> maintenanceRecords;
  final List<QualityRecord> qualityRecords;
  final List<IssueReport> issueReports;

  const WaterUsageStats({
    required this.unitId,
    required this.dailyUsage,
    required this.maintenanceRecords,
    required this.qualityRecords,
    required this.issueReports,
  });

  // Factory method to create mock data
  factory WaterUsageStats.mock(String unitId) {
    final now = DateTime.now();
    return WaterUsageStats(
      unitId: unitId,
      dailyUsage: List.generate(
        7,
        (index) => DailyUsage(
          unitId: unitId,
          date: now.subtract(Duration(days: index)),
          amount: 2000 + (index * 100),
          userId: 'User${100 + index}',
          purpose: index % 2 == 0 ? 'Community Usage' : 'Irrigation',
        ),
      ),
      maintenanceRecords: [
        MaintenanceRecord(
          unitId: unitId,
          date: now.subtract(const Duration(days: 30)),
          type: 'Filter Change',
          technician: 'John Doe',
          description: 'Regular maintenance and filter replacement',
          partsReplaced: ['Main Filter', 'O-rings'],
          cost: 150.0,
          status: MaintenanceStatus.completed,
        ),
        MaintenanceRecord(
          unitId: unitId,
          date: now.add(const Duration(days: 15)),
          type: 'Scheduled Service',
          technician: 'Jane Smith',
          description: 'Regular scheduled maintenance',
          partsReplaced: [],
          cost: 100.0,
          status: MaintenanceStatus.scheduled,
        ),
      ],
      qualityRecords: [
        QualityRecord(
          unitId: unitId,
          timestamp: now.subtract(const Duration(days: 1)),
          ph: 7.2,
          turbidity: 0.5,
          dissolvedOxygen: 8.5,
          temperature: 22.0,
          conductivity: 250.0,
          testedBy: 'Lab Tech 1',
          contaminants: [],
          passesStandards: true,
        ),
        QualityRecord(
          unitId: unitId,
          timestamp: now.subtract(const Duration(days: 7)),
          ph: 7.1,
          turbidity: 0.6,
          dissolvedOxygen: 8.3,
          temperature: 23.0,
          conductivity: 255.0,
          testedBy: 'Lab Tech 2',
          contaminants: ['Trace Minerals'],
          passesStandards: true,
        ),
      ],
      issueReports: [
        IssueReport(
          unitId: unitId,
          reportId: 'ISS001',
          reportedAt: now.subtract(const Duration(days: 5)),
          reportedBy: 'Field Inspector',
          type: 'Mechanical',
          description: 'Minor vibration in pump',
          images: [],
          status: IssueStatus.resolved,
          priority: Priority.medium,
          resolvedAt: now.subtract(const Duration(days: 3)),
          resolvedBy: 'Maintenance Team',
          resolution: 'Adjusted pump alignment and tightened mounting bolts',
        ),
      ],
    );
  }

  // Helper method to get latest quality record
  QualityRecord? get latestQualityRecord {
    if (qualityRecords.isEmpty) return null;
    return qualityRecords.reduce(
      (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
    );
  }

  // Helper method to get active issues
  List<IssueReport> get activeIssues {
    return issueReports
        .where(
          (issue) =>
              issue.status != IssueStatus.resolved &&
              issue.status != IssueStatus.closed,
        )
        .toList();
  }

  // Helper method to get upcoming maintenance
  List<MaintenanceRecord> get upcomingMaintenance {
    final now = DateTime.now();
    return maintenanceRecords
        .where(
          (record) =>
              record.date.isAfter(now) &&
              record.status == MaintenanceStatus.scheduled,
        )
        .toList();
  }

  // Helper method to calculate average daily usage
  double get averageDailyUsage {
    if (dailyUsage.isEmpty) return 0;
    final total = dailyUsage.fold(0.0, (sum, usage) => sum + usage.amount);
    return total / dailyUsage.length;
  }
}

class DailyUsage {
  final String unitId;
  final DateTime date;
  final double amount;
  final String userId;
  final String purpose;

  const DailyUsage({
    required this.unitId,
    required this.date,
    required this.amount,
    required this.userId,
    required this.purpose,
  });

  // Factory method for creating a copy with updated fields
  DailyUsage copyWith({
    String? unitId,
    DateTime? date,
    double? amount,
    String? userId,
    String? purpose,
  }) {
    return DailyUsage(
      unitId: unitId ?? this.unitId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      userId: userId ?? this.userId,
      purpose: purpose ?? this.purpose,
    );
  }
}

class MaintenanceRecord {
  final String unitId;
  final DateTime date;
  final String type;
  final String technician;
  final String description;
  final List<String> partsReplaced;
  final double cost;
  final MaintenanceStatus status;

  const MaintenanceRecord({
    required this.unitId,
    required this.date,
    required this.type,
    required this.technician,
    required this.description,
    required this.partsReplaced,
    required this.cost,
    required this.status,
  });

  // Factory method for creating a copy with updated fields
  MaintenanceRecord copyWith({
    String? unitId,
    DateTime? date,
    String? type,
    String? technician,
    String? description,
    List<String>? partsReplaced,
    double? cost,
    MaintenanceStatus? status,
  }) {
    return MaintenanceRecord(
      unitId: unitId ?? this.unitId,
      date: date ?? this.date,
      type: type ?? this.type,
      technician: technician ?? this.technician,
      description: description ?? this.description,
      partsReplaced: partsReplaced ?? this.partsReplaced,
      cost: cost ?? this.cost,
      status: status ?? this.status,
    );
  }
}

class QualityRecord {
  final String unitId;
  final DateTime timestamp;
  final double ph;
  final double turbidity;
  final double dissolvedOxygen;
  final double temperature;
  final double conductivity;
  final String testedBy;
  final List<String> contaminants;
  final bool passesStandards;

  const QualityRecord({
    required this.unitId,
    required this.timestamp,
    required this.ph,
    required this.turbidity,
    required this.dissolvedOxygen,
    required this.temperature,
    required this.conductivity,
    required this.testedBy,
    required this.contaminants,
    required this.passesStandards,
  });

  // Factory method for creating a copy with updated fields
  QualityRecord copyWith({
    String? unitId,
    DateTime? timestamp,
    double? ph,
    double? turbidity,
    double? dissolvedOxygen,
    double? temperature,
    double? conductivity,
    String? testedBy,
    List<String>? contaminants,
    bool? passesStandards,
  }) {
    return QualityRecord(
      unitId: unitId ?? this.unitId,
      timestamp: timestamp ?? this.timestamp,
      ph: ph ?? this.ph,
      turbidity: turbidity ?? this.turbidity,
      dissolvedOxygen: dissolvedOxygen ?? this.dissolvedOxygen,
      temperature: temperature ?? this.temperature,
      conductivity: conductivity ?? this.conductivity,
      testedBy: testedBy ?? this.testedBy,
      contaminants: contaminants ?? this.contaminants,
      passesStandards: passesStandards ?? this.passesStandards,
    );
  }

  // Helper method to check if pH is within safe range
  bool get isPhSafe => ph >= 6.5 && ph <= 8.5;

  // Helper method to check if turbidity is within safe range
  bool get isTurbiditySafe => turbidity <= 1.0;

  // Helper method to check if dissolved oxygen is within safe range
  bool get isDissolvedOxygenSafe => dissolvedOxygen >= 6.0;

  // Helper method to get overall quality status
  String get qualityStatus {
    if (!passesStandards) return 'Failed';
    if (contaminants.isNotEmpty) return 'Warning';
    if (isPhSafe && isTurbiditySafe && isDissolvedOxygenSafe)
      return 'Excellent';
    return 'Good';
  }
}

class IssueReport {
  final String unitId;
  final String reportId;
  final DateTime reportedAt;
  final String reportedBy;
  final String type;
  final String description;
  final List<String> images;
  final IssueStatus status;
  final Priority priority;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolution;

  const IssueReport({
    required this.unitId,
    required this.reportId,
    required this.reportedAt,
    required this.reportedBy,
    required this.type,
    required this.description,
    required this.images,
    required this.status,
    required this.priority,
    this.resolvedAt,
    this.resolvedBy,
    this.resolution,
  });

  // Factory method for creating a copy with updated fields
  IssueReport copyWith({
    String? unitId,
    String? reportId,
    DateTime? reportedAt,
    String? reportedBy,
    String? type,
    String? description,
    List<String>? images,
    IssueStatus? status,
    Priority? priority,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolution,
  }) {
    return IssueReport(
      unitId: unitId ?? this.unitId,
      reportId: reportId ?? this.reportId,
      reportedAt: reportedAt ?? this.reportedAt,
      reportedBy: reportedBy ?? this.reportedBy,
      type: type ?? this.type,
      description: description ?? this.description,
      images: images ?? this.images,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolution: resolution ?? this.resolution,
    );
  }

  // Helper method to check if issue is resolved
  bool get isResolved =>
      status == IssueStatus.resolved || status == IssueStatus.closed;

  // Helper method to get time to resolution
  Duration? get timeToResolution {
    if (resolvedAt == null) return null;
    return resolvedAt!.difference(reportedAt);
  }

  // Helper method to get status display text
  String get statusDisplay {
    switch (status) {
      case IssueStatus.reported:
        return 'New';
      case IssueStatus.underInvestigation:
        return 'Investigating';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.resolved:
        return 'Resolved';
      case IssueStatus.closed:
        return 'Closed';
    }
  }
}

enum MaintenanceStatus { completed, inProgress, scheduled, cancelled }

enum IssueStatus { reported, underInvestigation, inProgress, resolved, closed }

enum Priority { low, medium, high, critical }

extension PriorityColor on Priority {
  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.critical:
        return Colors.purple;
    }
  }

  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.critical:
        return 'Critical';
    }
  }
}

extension IssueStatusColor on IssueStatus {
  Color get color {
    switch (this) {
      case IssueStatus.reported:
        return Colors.orange;
      case IssueStatus.underInvestigation:
        return Colors.blue;
      case IssueStatus.inProgress:
        return Colors.yellow;
      case IssueStatus.resolved:
        return Colors.green;
      case IssueStatus.closed:
        return Colors.grey;
    }
  }
}
