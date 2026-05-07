import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../models/trip_model.dart';
import '../models/participant_model.dart';
import '../models/itinerary_model.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';

/// Hive-based local database service for complete offline support.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box _tripsBox;
  late Box _participantsBox;
  late Box _itineraryBox;
  late Box _expensesBox;
  late Box _usersBox;
  late Box _settingsBox;

  /// Initialize Hive and open all boxes.
  Future<void> init() async {
    await Hive.initFlutter();
    _tripsBox = await Hive.openBox(AppConstants.tripsBox);
    _participantsBox = await Hive.openBox(AppConstants.participantsBox);
    _itineraryBox = await Hive.openBox(AppConstants.itineraryBox);
    _expensesBox = await Hive.openBox(AppConstants.expensesBox);
    _usersBox = await Hive.openBox(AppConstants.usersBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // ─── USERS ───
  Future<void> saveUser(UserModel user) async =>
      await _usersBox.put(user.id, jsonEncode(user.toMap()));

  UserModel? getUser(String id) {
    final raw = _usersBox.get(id);
    if (raw == null) return null;
    return UserModel.fromMap(jsonDecode(raw));
  }

  UserModel? getUserByEmail(String email) {
    for (final raw in _usersBox.values) {
      final user = UserModel.fromMap(jsonDecode(raw));
      if (user.email == email) return user;
    }
    return null;
  }

  // ─── TRIPS ───
  Future<void> saveTrip(TripModel trip) async =>
      await _tripsBox.put(trip.id, jsonEncode(trip.toMap()));

  List<TripModel> getAllTrips() {
    return _tripsBox.values
        .map((raw) => TripModel.fromMap(jsonDecode(raw)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  TripModel? getTrip(String id) {
    final raw = _tripsBox.get(id);
    if (raw == null) return null;
    return TripModel.fromMap(jsonDecode(raw));
  }

  Future<void> deleteTrip(String id) async {
    await _tripsBox.delete(id);
    // Cascade delete related data
    final participants = getParticipantsForTrip(id);
    for (final p in participants) {
      await _participantsBox.delete(p.id);
    }
    final items = getItineraryForTrip(id);
    for (final item in items) {
      await _itineraryBox.delete(item.id);
    }
    final expenses = getExpensesForTrip(id);
    for (final e in expenses) {
      await _expensesBox.delete(e.id);
    }
  }

  // ─── PARTICIPANTS ───
  Future<void> saveParticipant(ParticipantModel p) async =>
      await _participantsBox.put(p.id, jsonEncode(p.toMap()));

  List<ParticipantModel> getParticipantsForTrip(String tripId) {
    return _participantsBox.values
        .map((raw) => ParticipantModel.fromMap(jsonDecode(raw)))
        .where((p) => p.tripId == tripId)
        .toList();
  }

  Future<void> deleteParticipant(String id) async =>
      await _participantsBox.delete(id);

  ParticipantModel? getParticipant(String id) {
    final raw = _participantsBox.get(id);
    if (raw == null) return null;
    return ParticipantModel.fromMap(jsonDecode(raw));
  }

  // ─── ITINERARY ───
  Future<void> saveItineraryItem(ItineraryModel item) async =>
      await _itineraryBox.put(item.id, jsonEncode(item.toMap()));

  List<ItineraryModel> getItineraryForTrip(String tripId) {
    return _itineraryBox.values
        .map((raw) => ItineraryModel.fromMap(jsonDecode(raw)))
        .where((i) => i.tripId == tripId)
        .toList()
      ..sort((a, b) {
        final cmp = a.date.compareTo(b.date);
        return cmp != 0 ? cmp : a.order.compareTo(b.order);
      });
  }

  Future<void> deleteItineraryItem(String id) async =>
      await _itineraryBox.delete(id);

  // ─── EXPENSES ───
  Future<void> saveExpense(ExpenseModel e) async =>
      await _expensesBox.put(e.id, jsonEncode(e.toMap()));

  List<ExpenseModel> getExpensesForTrip(String tripId) {
    return _expensesBox.values
        .map((raw) => ExpenseModel.fromMap(jsonDecode(raw)))
        .where((e) => e.tripId == tripId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<ExpenseModel> getAllExpenses() {
    return _expensesBox.values
        .map((raw) => ExpenseModel.fromMap(jsonDecode(raw)))
        .toList();
  }

  Future<void> deleteExpense(String id) async =>
      await _expensesBox.delete(id);

  // ─── SETTINGS ───
  Future<void> saveSetting(String key, dynamic value) async =>
      await _settingsBox.put(key, value);

  dynamic getSetting(String key, {dynamic defaultValue}) =>
      _settingsBox.get(key, defaultValue: defaultValue);
}
