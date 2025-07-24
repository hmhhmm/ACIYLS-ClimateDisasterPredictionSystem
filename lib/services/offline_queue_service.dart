import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class OfflineQueueService extends ChangeNotifier {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal() {
    _initConnectivity();
  }

  final List<Map<String, dynamic>> _offlineReports = [];
  bool _isOnline = true;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool get isOnline => _isOnline;
  List<Map<String, dynamic>> get offlineReports =>
      List.unmodifiable(_offlineReports);
  int get queueLength => _offlineReports.length;

  void _initConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline && _offlineReports.isNotEmpty) {
        syncReports();
      }
      notifyListeners();
    });
  }

  Future<void> addReport({
    required String type,
    required String title,
    required String location,
    required String description,
    List<String> images = const [],
  }) async {
    final report = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'title': title,
      'location': location,
      'description': description,
      'images': images,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    if (_isOnline) {
      await _submitReport(report);
    } else {
      _offlineReports.add(report);
      notifyListeners();
    }
  }

  Future<void> syncReports() async {
    if (!_isOnline || _offlineReports.isEmpty) return;

    // Create a copy of the reports to sync
    final reportsToSync = List<Map<String, dynamic>>.from(_offlineReports);

    for (final report in reportsToSync) {
      try {
        await _submitReport(report);
        _offlineReports.remove(report);
      } catch (e) {
        print('Error syncing report: $e');
        // Keep the report in the queue if sync fails
      }
    }

    notifyListeners();
  }

  Future<void> _submitReport(Map<String, dynamic> report) async {
    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Implement actual API call to submit report
    print('Report submitted: $report');
  }

  void removeReport(String id) {
    _offlineReports.removeWhere((report) => report['id'] == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
