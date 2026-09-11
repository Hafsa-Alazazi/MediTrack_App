import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';

class AddMedicationScreen extends StatefulWidget {
  final Medication? medication;

  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  late TextEditingController _notesController;
  List<String> _reminderTimes = [];

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    final m = widget.medication;
    _nameController = TextEditingController(text: m?.name ?? '');
    _dosageController = TextEditingController(text: m?.dosage ?? '');
    _frequencyController = TextEditingController(text: m?.frequency ?? '');
    _notesController = TextEditingController(text: m?.notes ?? '');
    _reminderTimes = List<String>.from(m?.reminderTimes ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      final formatted =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (!_reminderTimes.contains(formatted)) {
          _reminderTimes.add(formatted);
          _reminderTimes.sort();
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<MedicationProvider>(context, listen: false);

    if (_isEditing) {
      final updated = widget.medication!.copyWith(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        reminderTimes: _reminderTimes,
        notes: _notesController.text.trim(),
      );
      await provider.updateMedication(updated);
    } else {
      final newMedication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        reminderTimes: _reminderTimes,
        notes: _notesController.text.trim(),
      );
      await provider.addMedication(newMedication);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _isEditing ? 'تعديل الدواء' : 'إضافة دواء جديد',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeSlideIn(
                delay: const Duration(milliseconds: 40),
                child: TextFormField(
                  controller: _nameController,
                  decoration: _decoration('اسم الدواء', Icons.medication_outlined, AppColors.emerald),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل اسم الدواء' : null,
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 90),
                child: TextFormField(
                  controller: _dosageController,
                  decoration: _decoration('الجرعة (مثال: 500mg)', Icons.science_outlined, AppColors.coral),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل الجرعة' : null,
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: TextFormField(
                  controller: _frequencyController,
                  decoration: _decoration('التكرار (مثال: مرتين يومياً)', Icons.repeat, AppColors.plum),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل عدد مرات التكرار' : null,
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 190),
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: _decoration('ملاحظات (اختياري)', Icons.notes_outlined, AppColors.gold),
                ),
              ),
              const SizedBox(height: 24),
              FadeSlideIn(
                delay: const Duration(milliseconds: 230),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.alarm_rounded, color: AppColors.emerald),
                          const SizedBox(width: 8),
                          const Text('مواعيد التذكير', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const Spacer(),
                          TapScale(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_rounded, size: 16, color: AppColors.emerald),
                                  SizedBox(width: 4),
                                  Text('إضافة وقت', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w600, fontSize: 12.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_reminderTimes.isEmpty)
                        const Text('لم تُضف أي أوقات تذكير بعد', style: TextStyle(color: AppColors.textSecondary))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _reminderTimes
                              .map((t) => AnimatedContainer(
                                    duration: AppMotion.fast,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(t, style: const TextStyle(color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () => setState(() => _reminderTimes.remove(t)),
                                          child: const Icon(Icons.close_rounded, size: 15, color: AppColors.goldDark),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeSlideIn(
                delay: const Duration(milliseconds: 280),
                child: TapScale(
                  onTap: _save,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.emerald.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 10)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isEditing ? 'حفظ التعديلات' : 'إضافة الدواء',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon, Color color) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: color),
    );
  }
}
