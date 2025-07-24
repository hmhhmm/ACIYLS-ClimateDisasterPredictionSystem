import '../models/alert.dart';

class AlertService {
  final List<Alert> _alerts = [];

  List<Alert> getAlerts() => List.unmodifiable(_alerts);

  void addAlert(Alert alert) {
    _alerts.insert(0, alert);
  }

  void clearAlerts() {
    _alerts.clear();
  }
} 