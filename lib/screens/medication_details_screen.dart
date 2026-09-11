import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../providers/dose_log_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';
import 'add_medication_screen.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final doseLogProvider = Provider.of<DoseLogProvider>(context);
    final logs = doseLogProvider.logs
        .where((l) => l.medicationId == medication.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(medication.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddMedicationScreen(medication: medication),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          FadeSlideIn(child: _buildInfoCard()),
          const SizedBox(height: 22),
          const Text('تسجيل جرعة جديدة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: Row(
              children: [
                Expanded(
                  child: TapScale(
                    onTap: () => doseLogProvider.logDose(
                      medicationId: medication.id,
                      medicationName: medication.name,
                      taken: true,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('أخذتها', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TapScale(
                    onTap: () => doseLogProvider.logDose(
                      medicationId: medication.id,
                      medicationName: medication.name,
                      taken: false,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cancel_outlined, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('فاتتني', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('سجل الجرعات (${logs.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'لا يوجد سجل جرعات بعد لهذا الدواء',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...logs.asMap().entries.map((e) => FadeSlideIn(
                  delay: Duration(milliseconds: 40 * e.key),
                  child: _buildLogTile(context, e.value, doseLogProvider),
                )),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.emerald.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow(Icons.medication_outlined, 'الجرعة', medication.dosage),
          Divider(height: 22, color: Colors.white.withValues(alpha: 0.15)),
          _detailRow(Icons.repeat, 'التكرار', medication.frequency),
          Divider(height: 22, color: Colors.white.withValues(alpha: 0.15)),
          _detailRow(
            Icons.alarm,
            'مواعيد التذكير',
            medication.reminderTimes.isEmpty ? 'لا توجد مواعيد' : medication.reminderTimes.join(' • '),
          ),
          if (medication.notes.isNotEmpty) ...[
            Divider(height: 22, color: Colors.white.withValues(alpha: 0.15)),
            _detailRow(Icons.notes_outlined, 'ملاحظات', medication.notes),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogTile(BuildContext context, dynamic log, DoseLogProvider provider) {
    final color = log.isTaken ? AppColors.success : AppColors.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(log.isTaken ? Icons.check_rounded : Icons.close_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              log.timestamp.toString().substring(0, 16),
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz, size: 20, color: AppColors.plum),
            onPressed: () => provider.updateDoseLogStatus(log.id, !log.isTaken),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
            onPressed: () => provider.deleteDoseLog(log.id),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الدواء'),
        content: const Text('هل أنت متأكد من حذف هذا الدواء وكل سجلاته؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<MedicationProvider>(context, listen: false)
                  .deleteMedication(medication.id);
              if (context.mounted) {
                await Provider.of<DoseLogProvider>(context, listen: false).refresh();
              }
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
