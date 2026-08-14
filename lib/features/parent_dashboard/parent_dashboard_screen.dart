import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
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
                        tr('parent_dashboard_title'),
                        style: AppTypography.heading3(color: Colors.white),
                      ),
                      Text(
                        tr('monitoring', args: [user.name]),
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
                title: tr('daily_study_time'),
                value: '${report.dailyStudyMinutes} ${tr('minutes_short')}',
                icon: CupertinoIcons.clock_fill,
                color: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                title: tr('games_played'),
                value: '${report.gamesPlayedToday} ${tr('games_short')}',
                icon: CupertinoIcons.gamecontroller_fill,
                color: AppColors.secondary,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Weekly Progress FL Chart
          Text(
            tr('weekly_activity'),
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
                          const dayKeys = [
                            'mon',
                            'tue',
                            'wed',
                            'thu',
                            'fri',
                            'sat',
                            'sun',
                          ];
                          if (value.toInt() < dayKeys.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                dayKeys[value.toInt()].tr(),
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
            tr('learning_breakdown'),
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
                  customBorderColor: AppColors.success.withValues(alpha: 0.5),
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
                            tr('strong_topics'),
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
                  customBorderColor: AppColors.danger.withValues(alpha: 0.5),
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
                            tr('needs_focus'),
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
            tr('wishlist_requests'),
            style: AppTypography.heading3(
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          Consumer(
            builder: (context, ref, child) {
              final shopItemsAsync = ref.watch(shopItemsProvider);
              
              return shopItemsAsync.when(
                data: (shopItems) {
                  final requestedItems = shopItems.where((item) => item.isRequested).toList();

                  if (requestedItems.isEmpty) {
                    return GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          tr('no_pending_requests', args: [user.name]),
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
                                    Text(tr('cost_coins', args: [item.coinCost.toString()]), 
                                      style: AppTypography.caption(color: Colors.grey)),
                                  ],
                                ),
                              ),
                              BouncyButton(
                                text: tr('gift'),
                                width: 90,
                                height: 36,
                                gradientStart: AppColors.success,
                                onTap: () {
                                  ref.read(userPurchasesProvider.notifier).addPurchase(item.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(tr('gift_success', args: [user.name, item.name])),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              );
            },
          ),

          const SizedBox(height: 20),

          // Screen Time Limits & Parental Control Settings
          Text(
            tr('parental_controls'),
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
                    tr('screen_time_limit'),
                    style: AppTypography.subtitle1(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    tr('limit_subtitle', args: [report.screenTimeLimitMinutes.toString()]),
                    style: AppTypography.caption(color: Colors.grey),
                  ),
                  value: report.isLimitEnabled,
                  activeThumbColor: AppColors.primary,
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
                color: color.withValues(alpha: 0.15),
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
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyBold(
                      color: isDark ? Colors.white : Colors.black87,
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
