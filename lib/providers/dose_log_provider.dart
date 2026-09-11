import 'package:flutter/material.dart';
import '../models/dose_log.dart';
import '../services/database_helper.dart';

class DoseLogProvider with ChangeNotifier {
  List<DoseLog> _logs = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<DoseLog> get logs => _logs;

  DoseLogProvider() {
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    _logs = await _dbHelper.getAllDoseLogs();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadLogs();
  }

  Future<void> logDose({
    required String medicationId,
    required String medicationName,
    required bool taken,
  }) async {
    final log = DoseLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: medicationId,
      medicationName: medicationName,
      status: taken ? 'taken' : 'missed',
    );
    await _dbHelper.insertDoseLog(log);
    await _loadLogs();
  }

  Future<void> updateDoseLogStatus(String id, bool taken) async {
    final index = _logs.indexWhere((l) => l.id == id);
    if (index == -1) return;
    final existing = _logs[index];
    final updated = DoseLog(
      id: existing.id,
      medicationId: existing.medicationId,
      medicationName: existing.medicationName,
      status: taken ? 'taken' : 'missed',
      timestamp: existing.timestamp,
    );
    await _dbHelper.updateDoseLog(updated);
    await _loadLogs();
  }

  Future<void> deleteDoseLog(String id) async {
    await _dbHelper.deleteDoseLog(id);
    await _loadLogs();
  }

  int get totalTaken => _logs.where((l) => l.isTaken).length;
  int get totalMissed => _logs.where((l) => l.isMissed).length;

  double get overallAdherenceRate {
    final total = totalTaken + totalMissed;
    if (total == 0) return 0;
    return (totalTaken / total) * 100;
  }

  Map<String, Map<String, int>> get statsByMedication {
    final Map<String, Map<String, int>> result = {};
    for (final log in _logs) {
      result.putIfAbsent(log.medicationName, () => {'taken': 0, 'missed': 0});
      if (log.isTaken) {
        result[log.medicationName]!['taken'] =
            result[log.medicationName]!['taken']! + 1;
      } else {
        result[log.medicationName]!['missed'] =
            result[log.medicationName]!['missed']! + 1;
      }
    }
    return result;
  }
}