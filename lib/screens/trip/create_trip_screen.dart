import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/trip_provider.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../services/notification_service.dart';
import '../../constants/app_constants.dart';

class CreateTripScreen extends StatefulWidget {
  final String? editTripId;
  const CreateTripScreen({super.key, this.editTripId});
  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int _coverIndex = 0;
  bool _loading = false;
  bool get _isEditing => widget.editTripId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final trip = context.read<TripProvider>().trips.firstWhere((t) => t.id == widget.editTripId);
        _nameCtrl.text = trip.name;
        _destCtrl.text = trip.destination;
        _descCtrl.text = trip.description;
        _budgetCtrl.text = trip.budget.toStringAsFixed(0);
        _startDate = trip.startDate;
        _endDate = trip.endDate;
        _coverIndex = trip.coverImageIndex;
        setState(() {});
      });
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _destCtrl.dispose(); _descCtrl.dispose(); _budgetCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now), firstDate: now.subtract(const Duration(days: 365)), lastDate: now.add(const Duration(days: 730)));
    if (picked != null) setState(() { if (isStart) { _startDate = picked; if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null; } else { _endDate = picked; } });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) { NotificationService.showSnackBar(context, 'Please select dates', isError: true); return; }
    
    setState(() => _loading = true);
    final provider = context.read<TripProvider>();
    
    try {
      if (_isEditing) {
        final trip = provider.trips.firstWhere((t) => t.id == widget.editTripId);
        await provider.updateTrip(trip.copyWith(name: _nameCtrl.text.trim(), destination: _destCtrl.text.trim(), description: _descCtrl.text.trim(), startDate: _startDate, endDate: _endDate, budget: double.tryParse(_budgetCtrl.text) ?? 0, coverImageIndex: _coverIndex));
      } else {
        await provider.createTrip(name: _nameCtrl.text.trim(), destination: _destCtrl.text.trim(), description: _descCtrl.text.trim(), startDate: _startDate!, endDate: _endDate!, budget: double.tryParse(_budgetCtrl.text) ?? 0, coverImageIndex: _coverIndex, createdBy: 'user');
      }
      if (mounted) { NotificationService.showSnackBar(context, _isEditing ? 'Trip updated!' : 'Trip created!'); Navigator.pop(context); }
    } catch (e) {
      if (mounted) NotificationService.showSnackBar(context, 'Error saving trip: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Trip' : 'Create Trip')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cover Theme', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(height: 56, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: AppColors.tripCoverGradients.length, itemBuilder: (_, i) => GestureDetector(onTap: () => setState(() => _coverIndex = i), child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 10), width: 56, decoration: BoxDecoration(gradient: AppColors.tripCoverGradients[i], borderRadius: BorderRadius.circular(12), border: _coverIndex == i ? Border.all(color: Colors.white, width: 3) : null), child: _coverIndex == i ? const Icon(Icons.check, color: Colors.white) : null)))),
          const SizedBox(height: 20),
          TextFormField(controller: _nameCtrl, validator: (v) => Validators.required(v, 'Trip name'), decoration: const InputDecoration(labelText: 'Trip Name', prefixIcon: Icon(Icons.flight_takeoff))),
          const SizedBox(height: 16),
          TextFormField(controller: _destCtrl, validator: (v) => Validators.required(v, 'Destination'), decoration: InputDecoration(labelText: 'Destination', prefixIcon: const Icon(Icons.location_on_outlined), suffixIcon: PopupMenuButton<String>(icon: const Icon(Icons.arrow_drop_down), onSelected: (v) => setState(() => _destCtrl.text = v), itemBuilder: (_) => AppConstants.popularDestinations.map((d) => PopupMenuItem(value: d, child: Text(d))).toList()))),
          const SizedBox(height: 16),
          TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.description_outlined))),
          const SizedBox(height: 16),
          TextFormField(controller: _budgetCtrl, validator: Validators.budget, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Budget', prefixIcon: Icon(Icons.account_balance_wallet_outlined))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: InkWell(onTap: () => _pickDate(true), child: InputDecorator(decoration: const InputDecoration(labelText: 'Start Date', prefixIcon: Icon(Icons.calendar_today)), child: Text(_startDate != null ? Formatters.date(_startDate!) : 'Select')))),
            const SizedBox(width: 12),
            Expanded(child: InkWell(onTap: () => _pickDate(false), child: InputDecorator(decoration: const InputDecoration(labelText: 'End Date', prefixIcon: Icon(Icons.calendar_today)), child: Text(_endDate != null ? Formatters.date(_endDate!) : 'Select')))),
          ]),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isEditing ? 'Update Trip' : 'Create Trip'))),
        ])),
      ),
    );
  }
}
