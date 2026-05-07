import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import '../models/trip_model.dart';
import '../models/participant_model.dart';
import '../models/itinerary_model.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart';
import '../utils/expense_splitter.dart';

/// Central trip provider managing trips, participants, itinerary & expenses.
class TripProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  static const _uuid = Uuid();

  List<TripModel> _trips = [];
  List<ParticipantModel> _participants = [];
  List<ItineraryModel> _itineraryItems = [];
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  List<TripModel> get trips => _trips;
  List<TripModel> get upcomingTrips => _trips.where((t) => t.isUpcoming).toList();
  List<TripModel> get ongoingTrips => _trips.where((t) => t.isOngoing).toList();
  List<TripModel> get completedTrips => _trips.where((t) => t.isCompleted).toList();
  bool get isLoading => _isLoading;

  // ─── Current trip context ───
  List<ParticipantModel> get participants => _participants;
  List<ItineraryModel> get itineraryItems => _itineraryItems;
  List<ExpenseModel> get expenses => _expenses;

  double get totalExpensesAll {
    final allExpenses = _db.getAllExpenses();
    return allExpenses.fold(0.0, (s, e) => s + e.amount);
  }

  double get pendingBalancesAll {
    double total = 0;
    for (final trip in _trips) {
      final exps = _db.getExpensesForTrip(trip.id);
      final parts = _db.getParticipantsForTrip(trip.id);
      final settlements = ExpenseSplitter.generateSettlements(exps, parts);
      total += settlements.fold(0.0, (s, st) => s + st.amount);
    }
    return total;
  }

  /// Load all trips from database.
  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300)); // simulate
    _trips = _db.getAllTrips();
    _isLoading = false;
    notifyListeners();
  }

  /// Load data for a specific trip.
  void loadTripData(String tripId) {
    _participants = _db.getParticipantsForTrip(tripId);
    _itineraryItems = _db.getItineraryForTrip(tripId);
    _expenses = _db.getExpensesForTrip(tripId);
    notifyListeners();
  }

  // ═══ TRIP CRUD ═══
  Future<TripModel> createTrip({
    required String name,
    required String destination,
    String description = '',
    required DateTime startDate,
    required DateTime endDate,
    double budget = 0,
    int coverImageIndex = 0,
    required String createdBy,
  }) async {
    final trip = TripModel(
      id: _uuid.v4(),
      name: name,
      destination: destination,
      description: description,
      startDate: startDate,
      endDate: endDate,
      budget: budget,
      coverImageIndex: coverImageIndex,
      createdBy: createdBy,
    );
    await _db.saveTrip(trip);
    _trips.insert(0, trip);
    notifyListeners();
    return trip;
  }

  Future<void> updateTrip(TripModel trip) async {
    await _db.saveTrip(trip);
    final idx = _trips.indexWhere((t) => t.id == trip.id);
    if (idx >= 0) _trips[idx] = trip;
    notifyListeners();
  }

  Future<void> deleteTrip(String tripId) async {
    await _db.deleteTrip(tripId);
    _trips.removeWhere((t) => t.id == tripId);
    notifyListeners();
  }

  // ═══ PARTICIPANT CRUD ═══
  Future<ParticipantModel> addParticipant({
    required String tripId,
    required String name,
    String? email,
    String? phone,
    int avatarColorIndex = 0,
  }) async {
    final p = ParticipantModel(
      id: _uuid.v4(),
      name: name,
      email: email,
      phone: phone,
      avatarColorIndex: avatarColorIndex,
      tripId: tripId,
    );
    await _db.saveParticipant(p);
    _participants.add(p);
    // Update trip participant IDs
    final trip = _db.getTrip(tripId);
    if (trip != null) {
      final updated = trip.copyWith(
        participantIds: [...trip.participantIds, p.id],
      );
      await _db.saveTrip(updated);
      final idx = _trips.indexWhere((t) => t.id == tripId);
      if (idx >= 0) _trips[idx] = updated;
    }
    notifyListeners();
    return p;
  }

  Future<void> updateParticipant(ParticipantModel p) async {
    await _db.saveParticipant(p);
    final idx = _participants.indexWhere((x) => x.id == p.id);
    if (idx >= 0) _participants[idx] = p;
    notifyListeners();
  }

  Future<void> removeParticipant(String id, String tripId) async {
    await _db.deleteParticipant(id);
    _participants.removeWhere((p) => p.id == id);
    final trip = _db.getTrip(tripId);
    if (trip != null) {
      final updated = trip.copyWith(
        participantIds: trip.participantIds.where((pid) => pid != id).toList(),
      );
      await _db.saveTrip(updated);
      final idx = _trips.indexWhere((t) => t.id == tripId);
      if (idx >= 0) _trips[idx] = updated;
    }
    notifyListeners();
  }

  ParticipantModel? getParticipantById(String id) {
    try {
      return _participants.firstWhere((p) => p.id == id);
    } catch (_) {
      return _db.getParticipant(id);
    }
  }

  // ═══ ITINERARY CRUD ═══
  Future<void> addItineraryItem({
    required String tripId,
    required DateTime date,
    String? time,
    required String title,
    String description = '',
    String? location,
    String? notes,
  }) async {
    final item = ItineraryModel(
      id: _uuid.v4(),
      tripId: tripId,
      date: date,
      time: time,
      title: title,
      description: description,
      location: location,
      notes: notes,
      order: _itineraryItems.where((i) =>
        i.date.year == date.year && i.date.month == date.month && i.date.day == date.day
      ).length,
    );
    await _db.saveItineraryItem(item);
    _itineraryItems.add(item);
    _itineraryItems.sort((a, b) {
      final cmp = a.date.compareTo(b.date);
      return cmp != 0 ? cmp : a.order.compareTo(b.order);
    });
    notifyListeners();
  }

  Future<void> updateItineraryItem(ItineraryModel item) async {
    await _db.saveItineraryItem(item);
    final idx = _itineraryItems.indexWhere((i) => i.id == item.id);
    if (idx >= 0) _itineraryItems[idx] = item;
    notifyListeners();
  }

  Future<void> toggleItineraryComplete(String id) async {
    final idx = _itineraryItems.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      final updated = _itineraryItems[idx].copyWith(
        isCompleted: !_itineraryItems[idx].isCompleted,
      );
      await _db.saveItineraryItem(updated);
      _itineraryItems[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteItineraryItem(String id) async {
    await _db.deleteItineraryItem(id);
    _itineraryItems.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // ═══ EXPENSE CRUD ═══
  Future<void> addExpense({
    required String tripId,
    required double amount,
    required String paidById,
    required List<String> splitBetweenIds,
    ExpenseCategory category = ExpenseCategory.other,
    String description = '',
    required DateTime date,
  }) async {
    final expense = ExpenseModel(
      id: _uuid.v4(),
      tripId: tripId,
      amount: amount,
      paidById: paidById,
      splitBetweenIds: splitBetweenIds,
      category: category,
      description: description,
      date: date,
    );
    await _db.saveExpense(expense);
    _expenses.insert(0, expense);
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ═══ ANALYTICS ═══
  double get totalTripExpenses => ExpenseSplitter.totalExpenses(_expenses);

  Map<ExpenseCategory, double> get expensesByCategory =>
      ExpenseSplitter.expensesByCategory(_expenses);

  Map<String, double> get paidByEach =>
      ExpenseSplitter.totalPaidByEach(_expenses, _participants);

  Map<String, double> get netBalances =>
      ExpenseSplitter.netBalances(_expenses, _participants);

  List<SettlementModel> get settlements =>
      ExpenseSplitter.generateSettlements(_expenses, _participants);

  // ═══ SEARCH ═══
  List<TripModel> searchTrips(String query) {
    if (query.isEmpty) return _trips;
    final q = query.toLowerCase();
    return _trips.where((t) =>
      t.name.toLowerCase().contains(q) ||
      t.destination.toLowerCase().contains(q)
    ).toList();
  }
}
