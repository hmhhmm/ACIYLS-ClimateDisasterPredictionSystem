import 'package:flutter/foundation.dart';

class OfflineQueueService extends ChangeNotifier {
  final List<Map<String, dynamic>> _queue = [];
  bool _isOnline = true;

  List<Map<String, dynamic>> get queue => List.unmodifiable(_queue);
  bool get isOnline => _isOnline;

  void addToQueue(Map<String, dynamic> action) {
    _queue.add(action);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      notifyListeners();
    }
  }

  void clearQueue() {
    _queue.clear();
    notifyListeners();
  }

  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  Future<void> processQueue() async {
    if (_queue.isEmpty) return;

    for (int i = _queue.length - 1; i >= 0; i--) {
      try {
        // Simulate processing
        await Future.delayed(const Duration(milliseconds: 100));
        _queue.removeAt(i);
      } catch (e) {
        if (kDebugMode) {
          print('Error processing queue item: $e');
        }
      }
    }
    notifyListeners();
  }
}
