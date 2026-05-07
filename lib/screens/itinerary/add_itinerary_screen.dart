import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/formatters.dart';
import '../../services/notification_service.dart';

class AddItineraryScreen extends StatefulWidget {
  final String tripId;
  const AddItineraryScreen({super.key, required this.tripId});
  @override
  State<AddItineraryScreen> createState() => _AddItineraryScreenState();
}

class _AddItineraryScreenState extends State<AddItineraryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _time;
  bool _loading = false;

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _locationCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 730)));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _time = picked.format(context));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await context.read<TripProvider>().addItineraryItem(tripId: widget.tripId, date: _date, time: _time, title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(), location: _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : null, notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null);
    setState(() => _loading = false);
    if (mounted) { NotificationService.showSnackBar(context, 'Activity added!'); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Activity')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(children: [
        TextFormField(controller: _titleCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Title required' : null, decoration: const InputDecoration(labelText: 'Activity Title', prefixIcon: Icon(Icons.title))),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: InkWell(onTap: _pickDate, child: InputDecorator(decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today)), child: Text(Formatters.date(_date))))),
          const SizedBox(width: 12),
          Expanded(child: InkWell(onTap: _pickTime, child: InputDecorator(decoration: const InputDecoration(labelText: 'Time', prefixIcon: Icon(Icons.access_time)), child: Text(_time ?? 'Optional')))),
        ]),
        const SizedBox(height: 16),
        TextFormField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined))),
        const SizedBox(height: 16),
        TextFormField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on_outlined))),
        const SizedBox(height: 16),
        TextFormField(controller: _notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.note_outlined))),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Add Activity'))),
      ]))),
    );
  }
}
