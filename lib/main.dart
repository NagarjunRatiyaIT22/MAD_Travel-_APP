import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Database
import 'database/database_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trip_provider.dart';

// Services
import 'services/connectivity_service.dart';

// Theme
import 'theme/app_theme.dart';

// Screens
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/trip/create_trip_screen.dart';
import 'screens/trip/trip_detail_screen.dart';
import 'screens/itinerary/add_itinerary_screen.dart';
import 'screens/expense/add_expense_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/ai/ai_assistant_screen.dart';
import 'screens/settings/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await DatabaseService().init();

  runApp(const TripMateApp());
}

class TripMateApp extends StatelessWidget {
  const TripMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'TripMate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            onGenerateRoute: _generateRoute,
          );
        },
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/init':
        return MaterialPageRoute(builder: (_) => const _InitRouter());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/create-trip':
        return MaterialPageRoute(builder: (_) => const CreateTripScreen());
      case '/edit-trip':
        final tripId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CreateTripScreen(editTripId: tripId),
        );
      case '/trip-detail':
        final tripId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => TripDetailScreen(tripId: tripId),
        );
      case '/add-itinerary':
        final tripId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AddItineraryScreen(tripId: tripId),
        );
      case '/add-expense':
        final tripId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AddExpenseScreen(tripId: tripId),
        );
      case '/analytics':
        final tripId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AnalyticsScreen(tripId: tripId),
        );
      case '/ai-assistant':
        return MaterialPageRoute(
          builder: (_) => const AIAssistantScreen(),
        );
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}

/// Router widget that decides where to navigate based on auth state.
class _InitRouter extends StatelessWidget {
  const _InitRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Wait for auth to initialize
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (!auth.onboardingDone) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/onboarding');
          });
        } else if (!auth.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
