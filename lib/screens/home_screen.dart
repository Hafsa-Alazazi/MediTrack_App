import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../providers/dose_log_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/medication_card.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/tap_scale.dart';
import 'add_medication_screen.dart';
import 'medication_details_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);
    final doseLogProvider = Provider.of<DoseLogProvider>(context);
    final medications = medicationProvider.medications;
    final rate = doseLogProvider.overallAdherenceRate;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(rate: rate, count: medications.length)),
          if (medications.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final medication = medications[index];
                    return FadeSlideIn(
                      delay: Duration(milliseconds: 60 * index),
                      child: MedicationCard(
                        medication: medication,
                        colorIndex: index,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MedicationDetailsScreen(medication: medication),
                            ),
                          );
                        },
                        onDelete: () => _confirmDelete(context, medication.id),
                      ),
                    );
                  },
                  childCount: medications.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: TapScale(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            gradient: AppColors.vibrantGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('إضافة دواء', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication_liquid_outlined, size: 44, color: AppColors.emerald),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد أدوية مضافة بعد',
              style: TextStyle(fontSize: 17, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'اضغط على "إضافة دواء" لبدء تتبع جرعاتك ومواعيدك',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الدواء'),
        content: const Text('هل أنت متأكد من حذف هذا الدواء وإلغاء تذكيراته؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<MedicationProvider>(context, listen: false)
                  .deleteMedication(id);
              if (context.mounted) {
                await Provider.of<DoseLogProvider>(context, listen: false).refresh();
              }
              if (context.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final double rate;
  final int count;

  const _Header({required this.rate, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 46),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(36),
          bottomLeft: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أهلاً بك 👋', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text(
                    'MediTrack',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TapScale(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: AppColors.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                _ProgressRing(rate: rate),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نسبة الالتزام الإجمالية',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count ${count == 1 ? "دواء" : "أدوية"} قيد التتبع',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double rate;
  const _ProgressRing({required this.rate});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: rate.clamp(0, 100)),
      duration: AppMotion.slow,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
              Text(
                '${value.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}
