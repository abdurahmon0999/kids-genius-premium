import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
// ❌ INCORRECT (This file does not exist)
// import 'package:cupertino_icons/cupertino_icons.dart';

// ✅ CORRECT (Import Flutter's cupertino library)
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/services/kids_providers.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(parentReportProvider);
    final user = ref.watch(userProfileProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parent Header Tile
          GlassCard(
            padding: const EdgeInsets.all(16),
            customGradient: AppColors.purpleGradient,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    CupertinoIcons.person_2_fill,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parental Control & Insights 🛡️',
                        style: AppTypography.heading3(color: Colors.white),
                      ),
                      Text(
                        'Monitoring: ${user.name}',
                        style: AppTypography.caption(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                // Switch back to Kid mode button
                IconButton(
                  icon: const Icon(CupertinoIcons.arrow_2_squarepath, color: Colors.white),
                  onPressed: () {
                    ref.read(selectedTabProvider.notifier).state = 0; // Go to Kid Dashboard
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Overview Metric Grid
          Row(
            children: [
              _buildMetricCard(
                title: 'Daily Study Time',
                value: '${report.dailyStudyMinutes} mins',
                icon: CupertinoIcons.clock_fill,
                color: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                title: 'Games Played',
                value: '${report.gamesPlayedToday} games',
                icon: CupertinoIcons.gamecontroller_fill,
                color: AppColors.secondary,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Weekly Progress FL Chart
          Text(
            '📊 Weekly Study Activity (Minutes)',
            style: AppTypography.heading3(
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 60,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                          if (value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                days[value.toInt()],
                                style: AppTypography.caption(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeBarGroup(0, (report.dailyStudyMinutes * 0.7).clamp(0, 60), AppColors.primary),
                    _makeBarGroup(1, (report.dailyStudyMinutes * 0.9).clamp(0, 60), AppColors.secondary),
                    _makeBarGroup(2, (report.dailyStudyMinutes * 0.5).clamp(0, 60), AppColors.purpleMagic),
                    _makeBarGroup(3, report.dailyStudyMinutes.toDouble().clamp(0, 60), AppColors.success),
                    _makeBarGroup(4, (report.dailyStudyMinutes * 0.8).clamp(0, 60), AppColors.accent),
                    _makeBarGroup(5, (report.dailyStudyMinutes * 0.6).clamp(0, 60), AppColors.primary),
                    _makeBarGroup(6, (report.dailyStudyMinutes * 0.4).clamp(0, 60), AppColors.secondary),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Subject Strengths vs Weaknesses
          Text(
            '🧠 Learning Progress Breakdown',
            style: AppTypography.heading3(
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Strong Subjects Card
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  customBorderColor: AppColors.success.withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            color: AppColors.success,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Strong Topics',
                            style: AppTypography.bodyBold(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...report.strongSubjects.map(
                        (subject) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• $subject',
                            style: AppTypography.parentReport(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Weak Subjects Card
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  customBorderColor: AppColors.danger.withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle_fill,
                            color: AppColors.danger,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Needs Focus',
                            style: AppTypography.bodyBold(
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...report.weakSubjects.map(
                        (subject) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• $subject',
                            style: AppTypography.parentReport(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Wishlist Requests Section
          Text(
            '🎁 Wishlist Requests',
            style: AppTypography.heading3(
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          Consumer(
            builder: (context, ref, child) {
              final shopItems = ref.watch(shopItemsProvider);
              final requestedItems = shopItems.where((item) => item.isRequested).toList();

              if (requestedItems.isEmpty) {
                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No pending requests from ${user.name}.',
                      style: AppTypography.caption(color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requestedItems.length,
                itemBuilder: (context, index) {
                  final item = requestedItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, 
                                  style: AppTypography.bodyBold(color: isDark ? Colors.white : Colors.black)),
                                Text('Cost: ${item.coinCost} Coins', 
                                  style: AppTypography.caption(color: Colors.grey)),
                              ],
                            ),
                          ),
                          BouncyButton(
                            text: 'Gift ✅',
                            width: 90,
                            height: 36,
                            gradientStart: AppColors.success,
                            onTap: () {
                              ref.read(shopItemsProvider.notifier).buyItem(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gifted ${item.name} to ${user.name}! 🎁'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),

          // Screen Time Limits & Parental Control Settings
          Text(
            '⚙️ Parental Controls',
            style: AppTypography.heading3(
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Daily Screen Time Limit',
                    style: AppTypography.subtitle1(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Limit app usage to ${report.screenTimeLimitMinutes} minutes daily',
                    style: AppTypography.caption(color: Colors.grey),
                  ),
                  value: report.isLimitEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) =>
                      ref.read(parentReportProvider.notifier).toggleLimit(val),
                ),
                if (report.isLimitEnabled) ...[
                  Slider(
                    value: report.screenTimeLimitMinutes.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 7,
                    activeColor: AppColors.primary,
                    label: '${report.screenTimeLimitMinutes} mins',
                    onChanged: (val) => ref
                        .read(parentReportProvider.notifier)
                        .updateScreenTimeLimit(val.round()),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(12), // Reduced padding for better fit
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyBold(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}
