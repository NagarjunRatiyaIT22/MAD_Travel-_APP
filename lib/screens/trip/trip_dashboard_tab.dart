import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../providers/trip_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/trip_model.dart';
import '../../models/expense_model.dart';
import '../../utils/formatters.dart';
import '../../widgets/summary_card.dart';

class TripDashboardTab extends StatelessWidget {
  final TripModel trip;
  
  const TripDashboardTab({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final totalExpenses = provider.totalTripExpenses;
    final pendingBalances = provider.netBalances.values.where((b) => b > 0).fold(0.0, (s, b) => s + b);
    final catExpenses = provider.expensesByCategory;
    final paidByEach = provider.paidByEach;
    final activitiesCount = provider.itineraryItems.length;

    return RefreshIndicator(
      onRefresh: () async {
        provider.loadTripData(trip.id);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                SummaryCard(
                  title: 'Total Expenses',
                  value: Formatters.currencyShort(totalExpenses, symbol: theme.currencySymbol),
                  icon: Icons.account_balance_wallet,
                  gradient: AppColors.primaryGradient,
                ),
                SummaryCard(
                  title: 'Pending Balances',
                  value: Formatters.currencyShort(pendingBalances, symbol: theme.currencySymbol),
                  icon: Icons.pending_actions,
                  gradient: AppColors.warmGradient,
                ),
                SummaryCard(
                  title: 'Participants',
                  value: '${provider.participants.length}',
                  icon: Icons.group,
                  gradient: AppColors.coolGradient,
                ),
                SummaryCard(
                  title: 'Activities',
                  value: '$activitiesCount',
                  icon: Icons.local_activity,
                  gradient: AppColors.successGradient,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Budget Usage
            Text('Budget Usage', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Formatters.currency(totalExpenses, symbol: theme.currencySymbol), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: totalExpenses > trip.budget && trip.budget > 0 ? AppColors.error : AppColors.primary)),
                      Text('of ${Formatters.currency(trip.budget, symbol: theme.currencySymbol)}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: trip.budget > 0 ? (totalExpenses / trip.budget).clamp(0, 1) : 0,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      color: totalExpenses > trip.budget && trip.budget > 0 ? AppColors.error : AppColors.success,
                      minHeight: 12,
                    ),
                  ),
                  if (trip.budget > 0 && totalExpenses > trip.budget)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Over budget by ${Formatters.currency(totalExpenses - trip.budget, symbol: theme.currencySymbol)}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Expense Category Pie Chart
            Text('Expense Breakdown', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (catExpenses.isEmpty)
              Container(
                height: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('No expenses yet', style: GoogleFonts.poppins(color: Colors.grey)),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _buildPieSections(catExpenses, totalExpenses),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: catExpenses.entries.map((e) {
                        final color = _catColor(e.key);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                            const SizedBox(width: 4),
                            Text('${e.key.emoji} ${e.key.label}', style: GoogleFonts.poppins(fontSize: 12)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Participant Contribution
            Text('Participant Contributions', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (paidByEach.isEmpty || provider.participants.isEmpty)
              Container(
                height: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('No contributions yet', style: GoogleFonts.poppins(color: Colors.grey)),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                ),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < provider.participants.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    provider.participants[idx].name.split(' ').first,
                                    style: GoogleFonts.poppins(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      barGroups: provider.participants.asMap().entries.map((e) {
                        final paid = paidByEach[e.value.id] ?? 0;
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: paid,
                              color: AppColors.avatarColors[e.value.avatarColorIndex % AppColors.avatarColors.length],
                              width: 20,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      ),
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
