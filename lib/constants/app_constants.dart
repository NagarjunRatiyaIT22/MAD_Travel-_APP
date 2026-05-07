/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'TripMate';
  static const String appTagline = 'Plan. Travel. Split. Repeat.';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String usersBox = 'users';
  static const String tripsBox = 'trips';
  static const String participantsBox = 'participants';
  static const String itineraryBox = 'itinerary';
  static const String expensesBox = 'expenses';
  static const String settingsBox = 'settings';

  // SharedPreferences keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyDarkMode = 'dark_mode';
  static const String keyCurrency = 'currency';

  // Currency options
  static const List<Map<String, String>> currencies = [
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
  ];

  static const List<Map<String, String>> onboardingPages = [
    {
      'title': 'Plan Together',
      'description': 'Create trips and build amazing itineraries for your group adventures.',
      'icon': '✈️',
    },
    {
      'title': 'Track Expenses',
      'description': 'Log every shared expense on the go. Never lose track of who paid what.',
      'icon': '💰',
    },
    {
      'title': 'Split Fairly',
      'description': 'Automatically calculate balances and generate optimized settlements.',
      'icon': '🤝',
    },
  ];

  static const List<String> popularDestinations = [
    'Goa', 'Manali', 'Jaipur', 'Udaipur', 'Rishikesh',
    'Leh Ladakh', 'Kerala', 'Shimla', 'Ooty', 'Andaman',
  ];
}
