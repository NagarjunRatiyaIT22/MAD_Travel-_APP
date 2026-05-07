import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/trip_model.dart';
import '../models/participant_model.dart';
import '../models/expense_model.dart';
import '../models/itinerary_model.dart';

import '../utils/expense_splitter.dart';
import '../utils/formatters.dart';

/// Service to generate PDF trip reports.
class ExportService {
  ExportService._();

  static Future<void> exportTripReport({
    required TripModel trip,
    required List<ParticipantModel> participants,
    required List<ExpenseModel> expenses,
    required List<ItineraryModel> itinerary,
    String currencySymbol = '₹',
  }) async {
    final pdf = pw.Document();
    final settlements = ExpenseSplitter.generateSettlements(expenses, participants);
    final totalExp = ExpenseSplitter.totalExpenses(expenses);
    final catExpenses = ExpenseSplitter.expensesByCategory(expenses);
    final paid = ExpenseSplitter.totalPaidByEach(expenses, participants);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(trip.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('${trip.destination} | ${Formatters.dateRange(trip.startDate, trip.endDate)}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            pw.Divider(),
          ],
        ),
        build: (ctx) => [
          // Trip summary
          pw.Text('Trip Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Budget: $currencySymbol${trip.budget.toStringAsFixed(2)}'),
          pw.Text('Total Expenses: $currencySymbol${totalExp.toStringAsFixed(2)}'),
          pw.Text('Participants: ${participants.length}'),
          pw.Text('Duration: ${trip.totalDays} days'),
          pw.SizedBox(height: 16),

          // Participants
          pw.Text('Participants', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ['Name', 'Email', 'Total Paid'],
            data: participants.map((p) => [
              p.name,
              p.email ?? '-',
              '$currencySymbol${(paid[p.id] ?? 0).toStringAsFixed(2)}',
            ]).toList(),
          ),
          pw.SizedBox(height: 16),

          // Expenses
          pw.Text('Expenses', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ['Description', 'Category', 'Amount', 'Paid By'],
            data: expenses.map((e) {
              final payer = participants.where((p) => p.id == e.paidById).firstOrNull;
              return [
                e.description,
                e.category.label,
                '$currencySymbol${e.amount.toStringAsFixed(2)}',
                payer?.name ?? 'Unknown',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 16),

          // Category breakdown
          pw.Text('Category Breakdown', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...catExpenses.entries.map((e) =>
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text('${e.key.emoji} ${e.key.label}: $currencySymbol${e.value.toStringAsFixed(2)}'),
            ),
          ),
          pw.SizedBox(height: 16),

          // Settlements
          pw.Text('Settlements', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (settlements.isEmpty)
            pw.Text('All settled! No pending settlements.')
          else
            ...settlements.map((s) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text('${s.fromName} pays $currencySymbol${s.amount.toStringAsFixed(2)} to ${s.toName}'),
            )),
          pw.SizedBox(height: 16),

          // Itinerary
          if (itinerary.isNotEmpty) ...[
            pw.Text('Itinerary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...itinerary.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 80,
                    child: pw.Text(item.time ?? '', style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        if (item.location != null) pw.Text(item.location!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: '${trip.name}_Report',
    );
  }
}
