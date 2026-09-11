import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dose_log_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doseLogProvider = Provider.of<DoseLogProvider>(context);
    final stats = doseLogProvider.statsByMedication;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('إحصائيات الالتزام', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: doseLogProvider.logs.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                FadeSlideIn(child: _buildOverallCard(doseLogProvider)),
                const SizedBox(height: 22),
                const Text('تفصيل حسب الدواء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                ...stats.entries.toList().asMap().entries.map((e) => FadeSlideIn(
                      delay: Duration(milliseconds: 50 * e.key),
                      child: _buildMedicationStatCard(
                        name: e.value.key,
                        taken: e.value.value['taken']!,
                        missed: e.value.value['missed']!,
                        colorIndex: e.key,
                      ),
                    )),
              ],
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
              decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.bar_chart_rounded, size: 44, color: AppColors.emerald),
            ),
            const SizedBox(height: 20),
            const Text('لا توجد بيانات التزام بعد', style: TextStyle(fontSize: 17, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'افتح أي دواء وسجّل جرعاتك لتظهر لك إحصائياتك هنا',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallCard(DoseLogProvider provider) {
    final rate = provider.overallAdherenceRate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.emerald.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text('نسبة الالتزام الإجمالية', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14)),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: rate),
            duration: AppMotion.slow,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '${value.toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statChip(Icons.check_circle, 'أُخذت', provider.totalTaken, AppColors.gold),
              _statChip(Icons.cancel, 'فاتت', provider.totalMissed, AppColors.coral),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, int count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text('$count', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildMedicationStatCard({
    required String name,
    required int taken,
    required int missed,
    required int colorIndex,
  }) {
    final total = taken + missed;
    final rate = total == 0 ? 0.0 : (taken / total) * 100;
    final accent = AppColors.capsuleColorFor(colorIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
              Text('${rate.toStringAsFixed(0)}%', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: total == 0 ? 0 : taken / total),
            duration: AppMotion.slow,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 9,
                backgroundColor: accent.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('أُخذت $taken جرعة • فاتت $missed جرعة', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
