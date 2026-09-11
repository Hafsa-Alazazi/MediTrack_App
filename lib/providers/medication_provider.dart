import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  List<Medication> get medications => _medications;

  MedicationProvider() {
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    _medications = await _dbHelper.getAllMedications();
    notifyListeners();
  }

  Future<void> addMedication(Medication medication) async {
    await _dbHelper.insertMedication(medication);
    await _scheduleReminders(medication);
    await _loadMedications();
  }

  Future<void> updateMedication(Medication medication) async {
    await _cancelReminders(medication);
    await _dbHelper.updateMedication(medication);
    await _scheduleReminders(medication);
    await _loadMedications();
  }

  Future<void> deleteMedication(String id) async {
    final medication = _medications.firstWhere((m) => m.id == id);
    await _cancelReminders(medication);
    await _dbHelper.deleteMedication(id);
    await _loadMedications();
  }

  Future<void> _scheduleReminders(Medication medication) async {
    for (int i = 0; i < medication.reminderTimes.length; i++) {
      final notificationId = _generateNotificationId(medication.id, i);
      try {
        await _notificationService.scheduleDailyReminder(
          id: notificationId,
          medicationName: medication.name,
          dosage: medication.dosage,
          time: medication.reminderTimes[i],
        );
      } catch (e) {
        debugPrint('تعذر جدولة تذكير للدواء ${medication.name}: $e');
      }
    }
  }

  Future<void> _cancelReminders(Medication medication) async {
    for (int i = 0; i < medication.reminderTimes.length; i++) {
      final notificationId = _generateNotificationId(medication.id, i);
      try {
        await _notificationService.cancelReminder(notificationId);
      } catch (e) {
        debugPrint('تعذر إلغاء تذكير للدواء ${medication.name}: $e');
      }
    }
  }

  int _generateNotificationId(String medicationId, int index) {
    return (medicationId.hashCode + index).abs() % 2147483647;
  }
}
