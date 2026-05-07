import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/trip_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/trip_model.dart';
import '../../utils/formatters.dart';

import '../../services/export_service.dart';
import '../../widgets/participant_avatar.dart';
import 'trip_dashboard_tab.dart';
import '../expense/expense_filter_sheet.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});
  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _filterParticipantId;
  String _sortOption = 'latest';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTripData(widget.tripId);
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final theme = context.watch<ThemeProvider>();
    final trip = provider.trips.where((t) => t.id == widget.tripId).firstOrNull;
    if (trip == null) return const Scaffold(body: Center(child: Text('Trip not found')));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = AppColors.tripCoverGradients[trip.coverImageIndex % AppColors.tripCoverGradients.length];

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(trip.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              background: Container(
                decoration: BoxDecoration(gradient: gradient),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  const Text('✈️', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(trip.destination, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(Formatters.dateRange(trip.startDate, trip.endDate), style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                ])),
              ),
            ),
            actions: [
              PopupMenuButton(itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Trip')),
                const PopupMenuItem(value: 'export', child: Text('Export PDF')),
                const PopupMenuItem(value: 'delete', child: Text('Delete Trip')),
              ], onSelected: (v) async {
                if (v == 'edit') Navigator.pushNamed(context, '/edit-trip', arguments: widget.tripId);
                if (v == 'delete') { await provider.deleteTrip(widget.tripId); if (mounted) Navigator.pop(context); }
                if (v == 'export') {
                  await ExportService.exportTripReport(trip: trip, participants: provider.participants, expenses: provider.expenses, itinerary: provider.itineraryItems, currencySymbol: theme.currencySymbol);
                }
              }),
            ],
          ),
        ],
        body: Column(
          children: [
            // Summary row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                _miniStat('${trip.totalDays}', 'Days', Icons.schedule),
                _miniStat('${provider.participants.length}', 'Members', Icons.group),
                _miniStat(Formatters.currencyShort(provider.totalTripExpenses, symbol: theme.currencySymbol), 'Spent', Icons.receipt),
                _miniStat(Formatters.currencyShort(trip.budget, symbol: theme.currencySymbol), 'Budget', Icons.savings),
              ]),
            ),
            // Tab bar
            TabBar(controller: _tabCtrl, isScrollable: true, tabAlignment: TabAlignment.start, labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13), tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Itinerary'),
              Tab(text: 'Expenses'),
              Tab(text: 'Splits'),
              Tab(text: 'Members'),
            ]),
            // Tab views
            Expanded(child: TabBarView(controller: _tabCtrl, children: [
              TripDashboardTab(trip: trip),
              _buildItineraryTab(trip),
              _buildExpensesTab(trip),
              _buildSplitsTab(),
              _buildMembersTab(trip),
            ])),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabCtrl.index == 1) Navigator.pushNamed(context, '/add-itinerary', arguments: widget.tripId);
          else if (_tabCtrl.index == 2) Navigator.pushNamed(context, '/add-expense', arguments: widget.tripId);
          else if (_tabCtrl.index == 4) _showAddParticipantDialog(context, widget.tripId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _miniStat(String value, String label, IconData icon) {
    return Expanded(child: Column(children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
    ]));
  }

  Widget _buildItineraryTab(TripModel trip) {
    final items = context.watch<TripProvider>().itineraryItems;
    if (items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('📋', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('No itinerary yet', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
      Text('Add activities for your trip', style: GoogleFonts.poppins(color: Colors.grey)),
    ]));

    // Group by date
    final grouped = <String, List<dynamic>>{};
    for (final item in items) {
      final key = Formatters.date(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView(padding: const EdgeInsets.all(16), children: grouped.entries.map((entry) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(entry.key, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary))),
        ...entry.value.map((item) => _itineraryCard(item)),
      ]);
    }).toList());
  }

  Widget _itineraryCard(dynamic item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: item.isCompleted ? AppColors.success : AppColors.primary)),
          Container(width: 2, height: 50, color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (item.time != null) Text(item.time!, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.read<TripProvider>().toggleItineraryComplete(item.id),
                child: Icon(item.isCompleted ? Icons.check_circle : Icons.circle_outlined, color: item.isCompleted ? AppColors.success : Colors.grey, size: 20),
              ),
            ]),
            Text(item.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, decoration: item.isCompleted ? TextDecoration.lineThrough : null)),
            if (item.location != null) Row(children: [
              const Icon(Icons.location_on, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(item.location!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _buildExpensesTab(TripModel trip) {
    var expenses = context.watch<TripProvider>().expenses;
    final participants = context.watch<TripProvider>().participants;
    final theme = context.watch<ThemeProvider>();
    
    // Apply Filters and Sorting
    if (_filterParticipantId != null) {
      expenses = expenses.where((e) => e.paidById == _filterParticipantId || e.splitBetweenIds.contains(_filterParticipantId)).toList();
    }
    
    if (_sortOption == 'latest') {
      expenses.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortOption == 'oldest') {
      expenses.sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortOption == 'highest') {
      expenses.sort((a, b) => b.amount.compareTo(a.amount));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${expenses.length} Expenses', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey)),
              TextButton.icon(
                onPressed: () async {
                  final result = await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ExpenseFilterSheet(
                      participants: participants,
                      initialParticipantId: _filterParticipantId,
                      initialSortOption: _sortOption,
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _filterParticipantId = result['participantId'];
                      _sortOption = result['sortOption'];
                    });
                  }
                },
                icon: Icon(Icons.filter_list, size: 18, color: _filterParticipantId != null || _sortOption != 'latest' ? AppColors.primary : Colors.grey),
                label: Text('Filter', style: TextStyle(color: _filterParticipantId != null || _sortOption != 'latest' ? AppColors.primary : Colors.grey)),
              ),
            ],
          ),
        ),
        if (expenses.isEmpty) Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('💰', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No expenses found', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        ])))
        else Expanded(
          child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: expenses.length, itemBuilder: (_, i) {
      final e = expenses[i];
      final payer = participants.where((p) => p.id == e.paidById).firstOrNull;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.cardLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(10)), child: Text(e.category.emoji, style: const TextStyle(fontSize: 20))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.description.isNotEmpty ? e.description : e.category.label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
            Text('Paid by ${payer?.name ?? "Unknown"}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
          ])),
          Text(Formatters.currency(e.amount, symbol: theme.currencySymbol), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
      );
    }),
        ),
      ],
    );
  }

  Widget _buildSplitsTab() {
    final provider = context.watch<TripProvider>();
    final theme = context.watch<ThemeProvider>();
    final settlements = provider.settlements;
    final balances = provider.netBalances;

    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Balances', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ...provider.participants.map((p) {
        final bal = balances[p.id] ?? 0;
        final isPositive = bal >= 0;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ParticipantAvatar(name: p.name, colorIndex: p.avatarColorIndex),
          title: Text(p.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          trailing: Text('${isPositive ? '+' : ''}${Formatters.currency(bal, symbol: theme.currencySymbol)}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: isPositive ? AppColors.success : AppColors.error)),
        );
      }),
      const Divider(height: 32),
      Text('Settlements', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      if (settlements.isEmpty) Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('All settled! ✅', style: GoogleFonts.poppins(color: Colors.grey))))
      else ...settlements.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Text(s.fromName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(Formatters.currency(s.amount, symbol: theme.currencySymbol), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(s.toName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      )),
    ]));
  }

  Widget _buildMembersTab(TripModel trip) {
    final participants = context.watch<TripProvider>().participants;
    return ListView(padding: const EdgeInsets.all(16), children: [
      ...participants.map((p) => ListTile(
        leading: ParticipantAvatar(name: p.name, colorIndex: p.avatarColorIndex),
        title: Text(p.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        subtitle: Text(p.email ?? p.phone ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: () => context.read<TripProvider>().removeParticipant(p.id, trip.id)),
      )),
    ]);
  }

  void _showAddParticipantDialog(BuildContext context, String tripId) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Add Participant', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline))),
        const SizedBox(height: 12),
        TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email (optional)', prefixIcon: Icon(Icons.email_outlined))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (nameCtrl.text.trim().isEmpty) return;
          await context.read<TripProvider>().addParticipant(tripId: tripId, name: nameCtrl.text.trim(), email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null, avatarColorIndex: DateTime.now().millisecond % 10);
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text('Add')),
      ],
    ));
  }
}
