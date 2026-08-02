import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Master Panel 👑'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildActivityChart(),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        _statCard('Total Kids', '1,284', Colors.blue),
        const SizedBox(width: 12),
        _statCard('Daily Active', '452', Colors.green),
        const SizedBox(width: 12),
        _statCard('Revenue', '\$4.2k', Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Activity (Last 7 Days)', style: AppTypography.subtitle1()),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 2), FlSpot(3, 5),
                      FlSpot(4, 3.5), FlSpot(5, 4.5), FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _actionTile('User Management', Icons.people, Colors.blue),
        _actionTile('Content Editor', Icons.edit_document, Colors.purple),
        _actionTile('Rewards & Inventory', Icons.inventory_2, Colors.orange),
        _actionTile('System Settings', Icons.settings, Colors.grey),
      ],
    );
  }

  Widget _actionTile(String title, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
