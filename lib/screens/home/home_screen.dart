import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../theme/app_colors.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/connectivity_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/gradient_card.dart';

/// Main home dashboard with summary cards, trip list, and navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTrips();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildDashboard(),
          _buildTripsTab(),
          _buildAITab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _navIndex <= 1
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/create-trip'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    final auth = context.watch<AuthProvider>();
    final trips = context.watch<TripProvider>();
    final connectivity = context.watch<ConnectivityService>();
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => trips.loadTrips(),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${auth.currentUser?.name.split(' ').first ?? 'Traveler'} 👋',
                            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: connectivity.isOnline ? AppColors.success : AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                connectivity.isOnline ? 'Online • Synced' : 'Offline Mode',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        auth.currentUser?.name.isNotEmpty == true
                            ? auth.currentUser!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Summary cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    SummaryCard(
                      title: 'Total Trips',
                      value: '${trips.trips.length}',
                      icon: Icons.flight_takeoff,
                      gradient: AppColors.primaryGradient,
                    ),
                    SummaryCard(
                      title: 'Upcoming',
                      value: '${trips.upcomingTrips.length}',
                      icon: Icons.schedule,
                      gradient: AppColors.coolGradient,
                    ),
                    SummaryCard(
                      title: 'Total Expenses',
                      value: Formatters.currencyShort(trips.totalExpensesAll, symbol: theme.currencySymbol),
                      icon: Icons.account_balance_wallet,
                      gradient: AppColors.warmGradient,
                    ),
                    SummaryCard(
                      title: 'Pending',
                      value: Formatters.currencyShort(trips.pendingBalancesAll, symbol: theme.currencySymbol),
                      icon: Icons.pending_actions,
                      gradient: AppColors.successGradient,
                    ),
                  ],
                ),
              ),
            ),

            // Quick AI tip card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GradientCard(
                  gradient: AppColors.primaryGradient,
                  onTap: () => setState(() => _navIndex = 2),
                  child: Row(
                    children: [
                      const Text('🤖', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Travel Assistant',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                            Text('Get smart travel tips & suggestions',
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Recent trips header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Trips', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () => setState(() => _navIndex = 1),
                      child: Text('View All', style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),

            // Trips list
            if (trips.isLoading)
              const SliverToBoxAdapter(child: SkeletonLoader())
            else if (trips.trips.isEmpty)
              SliverToBoxAdapter(
                child: EmptyStateWidget(
                  icon: '🌍',
                  title: 'No Trips Yet',
                  subtitle: 'Create your first trip and start planning!',
                  actionLabel: 'Create Trip',
                  onAction: () => Navigator.pushNamed(context, '/create-trip'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i >= 3) return null; // Show max 3 on dashboard
                      final trip = trips.trips[i];
                      final parts = trips.trips.length > i
                          ? context.read<TripProvider>().participants
                          : <dynamic>[];
                      return AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 40,
                          child: FadeInAnimation(
                            child: TripCard(
                              trip: trip,
                              onTap: () => Navigator.pushNamed(context, '/trip-detail', arguments: trip.id),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: trips.trips.length > 3 ? 3 : trips.trips.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsTab() {
    final trips = context.watch<TripProvider>();
    final filtered = _searchQuery.isEmpty ? trips.trips : trips.searchTrips(_searchQuery);

    return SafeArea(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => setState(() => _searchQuery = q),
              decoration: InputDecoration(
                hintText: 'Search trips...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateWidget(
                    icon: '🔍',
                    title: _searchQuery.isEmpty ? 'No Trips Yet' : 'No Results',
                    subtitle: _searchQuery.isEmpty
                        ? 'Tap + to create your first trip'
                        : 'Try a different search term',
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final trip = filtered[i];
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 40,
                            child: FadeInAnimation(
                              child: TripCard(
                                trip: trip,
                                onTap: () => Navigator.pushNamed(context, '/trip-detail', arguments: trip.id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITab() {
    // Redirect to AI screen
    return _AIQuickTab(onOpenFull: () => Navigator.pushNamed(context, '/ai-assistant'));
  }

  Widget _buildSettingsTab() {
    // Redirect to Settings screen
    return _SettingsQuickTab();
  }
}

/// Quick AI tab embedded in bottom nav.
class _AIQuickTab extends StatelessWidget {
  final VoidCallback onOpenFull;
  const _AIQuickTab({required this.onOpenFull});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Assistant', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Get smart travel tips powered by AI', style: GoogleFonts.poppins(color: Colors.grey)),
            const SizedBox(height: 24),
            _aiOptionCard(context, '🗺️', 'Travel Suggestions', 'Discover amazing destinations', () => Navigator.pushNamed(context, '/ai-assistant')),
            _aiOptionCard(context, '📋', 'Itinerary Ideas', 'Get day-by-day plans', () => Navigator.pushNamed(context, '/ai-assistant')),
            _aiOptionCard(context, '💰', 'Budget Tips', 'Smart spending advice', () => Navigator.pushNamed(context, '/ai-assistant')),
            _aiOptionCard(context, '💬', 'Chat Assistant', 'Ask anything about travel', () => Navigator.pushNamed(context, '/ai-assistant')),
          ],
        ),
      ),
    );
  }

  Widget _aiOptionCard(BuildContext context, String emoji, String title, String subtitle, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// Quick settings tab embedded in bottom nav.
class _SettingsQuickTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            // Profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Text(
                      auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.currentUser?.name ?? 'User',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(auth.currentUser?.email ?? '',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Theme toggle
            _settingsTile(
              context,
              Icons.dark_mode,
              'Dark Mode',
              trailing: Switch(
                value: theme.isDarkMode,
                onChanged: (_) => theme.toggleTheme(),
              ),
            ),
            // Currency
            _settingsTile(
              context,
              Icons.currency_exchange,
              'Currency',
              subtitle: '${theme.currencyCode} (${theme.currencySymbol})',
              onTap: () => _showCurrencyPicker(context),
            ),
            _settingsTile(context, Icons.download, 'Export Data', onTap: () {}),
            _settingsTile(context, Icons.info_outline, 'About App', subtitle: 'Version 1.0.0'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text('Logout', style: GoogleFonts.poppins(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(BuildContext context, IconData icon, String title,
      {String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
      onTap: onTap,
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Currency', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...['INR', 'USD', 'EUR', 'GBP'].map((code) {
              final symbols = {'INR': '₹', 'USD': '\$', 'EUR': '€', 'GBP': '£'};
              return ListTile(
                leading: Text(symbols[code]!, style: const TextStyle(fontSize: 20)),
                title: Text(code),
                trailing: theme.currencyCode == code ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                onTap: () {
                  theme.setCurrency(code);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
