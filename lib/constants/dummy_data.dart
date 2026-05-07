import 'package:uuid/uuid.dart';
import '../models/trip_model.dart';
import '../models/participant_model.dart';
import '../models/expense_model.dart';
import '../models/itinerary_model.dart';

/// Generates sample/dummy data for demonstration purposes.
class DummyData {
  DummyData._();
  static const _uuid = Uuid();

  static final String _tripId1 = _uuid.v4();
  static final String _tripId2 = _uuid.v4();

  static final String _p1 = _uuid.v4();
  static final String _p2 = _uuid.v4();
  static final String _p3 = _uuid.v4();
  static final String _p4 = _uuid.v4();

  static List<TripModel> get trips => [
        TripModel(
          id: _tripId1,
          name: 'Goa Beach Adventure',
          destination: 'Goa',
          description: 'A fun beach trip with friends to explore beaches and nightlife.',
          startDate: DateTime.now().add(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 9)),
          budget: 25000,
          coverImageIndex: 0,
          participantIds: [_p1, _p2, _p3],
          createdBy: 'user',
        ),
        TripModel(
          id: _tripId2,
          name: 'Manali Snow Trip',
          destination: 'Manali',
          description: 'Winter trip to experience snowfall and adventure sports.',
          startDate: DateTime.now().add(const Duration(days: 20)),
          endDate: DateTime.now().add(const Duration(days: 25)),
          budget: 35000,
          coverImageIndex: 2,
          participantIds: [_p1, _p2, _p4],
          createdBy: 'user',
        ),
      ];

  static List<ParticipantModel> get participants => [
        ParticipantModel(id: _p1, name: 'Rahul Sharma', email: 'rahul@email.com', phone: '9876543210', avatarColorIndex: 0, tripId: _tripId1),
        ParticipantModel(id: _p2, name: 'Amit Patel', email: 'amit@email.com', phone: '9876543211', avatarColorIndex: 1, tripId: _tripId1),
        ParticipantModel(id: _p3, name: 'Priya Singh', email: 'priya@email.com', avatarColorIndex: 2, tripId: _tripId1),
        ParticipantModel(id: _p4, name: 'Neha Gupta', email: 'neha@email.com', avatarColorIndex: 3, tripId: _tripId2),
      ];

  static List<ExpenseModel> get expenses => [
        ExpenseModel(id: _uuid.v4(), tripId: _tripId1, amount: 1500, paidById: _p1, splitBetweenIds: [_p1, _p2, _p3], category: ExpenseCategory.food, description: 'Dinner at beach shack', date: DateTime.now()),
        ExpenseModel(id: _uuid.v4(), tripId: _tripId1, amount: 6000, paidById: _p2, splitBetweenIds: [_p1, _p2, _p3], category: ExpenseCategory.hotel, description: 'Hotel room for 2 nights', date: DateTime.now()),
        ExpenseModel(id: _uuid.v4(), tripId: _tripId1, amount: 2400, paidById: _p3, splitBetweenIds: [_p1, _p2, _p3], category: ExpenseCategory.travel, description: 'Taxi to airport', date: DateTime.now()),
        ExpenseModel(id: _uuid.v4(), tripId: _tripId1, amount: 800, paidById: _p1, splitBetweenIds: [_p1, _p2], category: ExpenseCategory.shopping, description: 'Souvenirs', date: DateTime.now()),
      ];

  static List<ItineraryModel> get itineraryItems => [
        ItineraryModel(id: _uuid.v4(), tripId: _tripId1, date: DateTime.now().add(const Duration(days: 5)), time: '09:00 AM', title: 'Arrive in Goa', description: 'Flight lands at Dabolim Airport', location: 'Dabolim Airport', order: 0),
        ItineraryModel(id: _uuid.v4(), tripId: _tripId1, date: DateTime.now().add(const Duration(days: 5)), time: '12:00 PM', title: 'Hotel Check-in', description: 'Check into beach resort', location: 'Baga Beach Resort', order: 1),
        ItineraryModel(id: _uuid.v4(), tripId: _tripId1, date: DateTime.now().add(const Duration(days: 5)), time: '04:00 PM', title: 'Beach Visit', description: 'Relax at Baga Beach', location: 'Baga Beach', order: 2),
        ItineraryModel(id: _uuid.v4(), tripId: _tripId1, date: DateTime.now().add(const Duration(days: 6)), time: '10:00 AM', title: 'Water Sports', description: 'Parasailing and jet ski', location: 'Calangute Beach', order: 0),
        ItineraryModel(id: _uuid.v4(), tripId: _tripId1, date: DateTime.now().add(const Duration(days: 6)), time: '07:00 PM', title: 'Night Market', description: 'Visit the Saturday night market', location: 'Arpora', order: 1),
      ];
}
