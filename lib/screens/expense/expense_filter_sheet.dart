import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/participant_model.dart';

class ExpenseFilterSheet extends StatefulWidget {
  final List<ParticipantModel> participants;
  final String? initialParticipantId;
  final String initialSortOption;

  const ExpenseFilterSheet({
    super.key,
    required this.participants,
    this.initialParticipantId,
    required this.initialSortOption,
  });

  @override
  State<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends State<ExpenseFilterSheet> {
  String? _selectedParticipantId;
  String _sortOption = 'latest'; // 'latest', 'oldest', 'highest'

  @override
  void initState() {
    super.initState();
    _selectedParticipantId = widget.initialParticipantId;
    _sortOption = widget.initialSortOption;
  }

  void _apply() {
    Navigator.pop(context, {
      'participantId': _selectedParticipantId,
      'sortOption': _sortOption,
    });
  }

  void _clear() {
    setState(() {
      _selectedParticipantId = null;
      _sortOption = 'latest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter & Sort', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
              TextButton(onPressed: _clear, child: const Text('Clear')),
            ],
          ),
          const Divider(height: 32),
          
          Text('Sort By', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('Latest First', 'latest'),
              _buildSortChip('Oldest First', 'oldest'),
              _buildSortChip('Highest Amount', 'highest'),
            ],
          ),
          const SizedBox(height: 24),
          
          Text('Filter by Payer', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.participants.map((p) {
              final isSelected = _selectedParticipantId == p.id;
              return ChoiceChip(
                label: Text(p.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedParticipantId = selected ? p.id : null);
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _apply,
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortOption == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _sortOption = value);
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
    );
  }
}
