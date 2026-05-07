import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../providers/trip_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/expense_model.dart';
import '../../utils/formatters.dart';

class AnalyticsScreen extends StatelessWidget {
  final String tripId;
  const AnalyticsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trip = provider.trips.where((t) => t.id == tripId).firstOrNull;
    final catExpenses = provider.expensesByCategory;
    final total = provider.totalTripExpenses;
    final paidByEach = provider.paidByEach;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Budget vs Spent
        if (trip != null) Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Spent', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
              Text(Formatters.currency(total, symbol: theme.currencySymbol), style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Budget: ${Formatters.currency(trip.budget, symbol: theme.currencySymbol)}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                value: trip.budget > 0 ? (total / trip.budget).clamp(0, 1) : 0,
                backgroundColor: Colors.white24,
                color: total > trip.budget ? AppColors.error : Colors.white,
                minHeight: 6,
              )),
            ])),
            const SizedBox(width: 16),
            SizedBox(width: 80, height: 80, child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: trip.budget > 0 ? (total / trip.budget).clamp(0, 1) : 0,
                backgroundColor: Colors.white24,
                color: Colors.white,
                strokeWidth: 8,
              ),
              Text('${trip.budget > 0 ? ((total / trip.budget) * 100).toStringAsFixed(0) : 0}%', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ])),
          ]),
        ),
        const SizedBox(height: 24),

        // Pie chart
        Text('By Category', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        if (catExpenses.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('No data yet', style: GoogleFonts.poppins(color: Colors.grey))))
        else SizedBox(height: 200, child: PieChart(PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _buildPieSections(catExpenses, total),
        ))),
        const SizedBox(height: 12),
        // Legend
        Wrap(spacing: 12, runSpacing: 8, children: catExpenses.entries.map((e) {
          final color = _catColor(e.key);
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Text('${e.key.emoji} ${e.key.label}', style: GoogleFonts.poppins(fontSize: 12)),
          ]);
        }).toList()),
        const SizedBox(height: 24),

        // Contribution bar chart
        Text('Contributions', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        if (paidByEach.isEmpty)
          Center(child: Text('No data', style: GoogleFonts.poppins(color: Colors.grey)))
        else SizedBox(height: 200, child: BarChart(BarChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
              final idx = v.toInt();
              if (idx < provider.participants.length) {
                return Padding(padding: const EdgeInsets.only(top: 8), child: Text(provider.participants[idx].name.split(' ').first, style: GoogleFonts.poppins(fontSize: 10)));
              }
              return const Text('');
            })),
          ),
          barGroups: provider.participants.asMap().entries.map((e) {
            final paid = paidByEach[e.value.id] ?? 0;
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(toY: paid, color: AppColors.avatarColors[e.value.avatarColorIndex % AppColors.avatarColors.length], width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
            ]);
          }).toList(),
        ))),
        const SizedBox(height: 32),
      ])),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<ExpenseCategory, double> data, double total) {
    return data.entries.map((e) {
      final pct = total > 0 ? (e.value / total * 100) : 0;
      return PieChartSectionData(
        value: e.value,
        title: '${pct.toStringAsFixed(0)}%',
        color: _catColor(e.key),
        radius: 50,
        titleStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      );
    }).toList();
  }

  Color _catColor(ExpenseCategory cat) {
    const map = {
      ExpenseCategory.food: Color(0xFFFF6B6B),
      ExpenseCategory.hotel: Color(0xFF54A0FF),
      ExpenseCategory.travel: Color(0xFF5F27CD),
      ExpenseCategory.shopping: Color(0xFFFF9FF3),
      ExpenseCategory.fuel: Color(0xFFFFBE21),
      ExpenseCategory.entertainment: Color(0xFF2ED573),
      ExpenseCategory.other: Color(0xFF9CA3AF),
    };
    return map[cat] ?? AppColors.primary;
  }
}
