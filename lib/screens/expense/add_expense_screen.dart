import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/trip_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/expense_model.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../services/notification_service.dart';
import '../../widgets/participant_avatar.dart';

class AddExpenseScreen extends StatefulWidget {
  final String tripId;
  const AddExpenseScreen({super.key, required this.tripId});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.other;
  String? _paidById;
  List<String> _splitBetween = [];
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parts = context.read<TripProvider>().participants;
      if (parts.isNotEmpty) {
        setState(() {
          _paidById = parts.first.id;
          _splitBetween = parts.map((p) => p.id).toList();
        });
      }
    });
  }

  @override
  void dispose() { _amountCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_paidById == null) { NotificationService.showSnackBar(context, 'Add participants first', isError: true); return; }
    if (_splitBetween.isEmpty) { NotificationService.showSnackBar(context, 'Select at least one person to split', isError: true); return; }
    setState(() => _loading = true);
    await context.read<TripProvider>().addExpense(tripId: widget.tripId, amount: double.parse(_amountCtrl.text.trim()), paidById: _paidById!, splitBetweenIds: _splitBetween, category: _category, description: _descCtrl.text.trim(), date: _date);
    setState(() => _loading = false);
    if (mounted) { NotificationService.showSnackBar(context, 'Expense added!'); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    final participants = context.watch<TripProvider>().participants;
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(controller: _amountCtrl, validator: Validators.amount, keyboardType: TextInputType.number, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700), decoration: InputDecoration(labelText: 'Amount', prefixText: '${theme.currencySymbol} ', prefixIcon: const Icon(Icons.attach_money))),
        const SizedBox(height: 16),
        TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined))),
        const SizedBox(height: 16),
        // Category selector
        Text('Category', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: ExpenseCategory.values.map((c) => ChoiceChip(
          selected: _category == c,
          label: Text('${c.emoji} ${c.label}'),
          onSelected: (_) => setState(() => _category = c),
          selectedColor: AppColors.primary.withAlpha(30),
        )).toList()),
        const SizedBox(height: 16),
        // Paid by
        Text('Paid By', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (participants.isEmpty) Text('Add participants first', style: GoogleFonts.poppins(color: Colors.grey))
        else Wrap(spacing: 8, runSpacing: 8, children: participants.map((p) => ChoiceChip(
          selected: _paidById == p.id,
          avatar: ParticipantAvatar(name: p.name, colorIndex: p.avatarColorIndex, size: 24),
          label: Text(p.name),
          onSelected: (_) => setState(() => _paidById = p.id),
          selectedColor: AppColors.primary.withAlpha(30),
        )).toList()),
        const SizedBox(height: 16),
        // Split between
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Split Between', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          TextButton(onPressed: () => setState(() => _splitBetween = participants.map((p) => p.id).toList()), child: const Text('Select All')),
        ]),
        ...participants.map((p) => CheckboxListTile(
          value: _splitBetween.contains(p.id),
          onChanged: (v) => setState(() { if (v == true) _splitBetween.add(p.id); else _splitBetween.remove(p.id); }),
          title: Text(p.name, style: GoogleFonts.poppins(fontSize: 14)),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        )),
        const SizedBox(height: 16),
        InkWell(onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
          if (picked != null) setState(() => _date = picked);
        }, child: InputDecorator(decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today)), child: Text(Formatters.date(_date)))),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Add Expense'))),
      ]))),
    );
  }
}
