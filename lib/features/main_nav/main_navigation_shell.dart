import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_pallete.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppPallete.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            height: 64,
            elevation: 0,
            backgroundColor: Colors.transparent,
            indicatorColor: AppPallete.primary.withValues(alpha: isDark ? 0.25 : 0.12),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppPallete.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups_rounded, color: AppPallete.primary),
                label: 'Circles',
              ),
              NavigationDestination(
                icon: Icon(Icons.flight_takeoff_outlined),
                selectedIcon: Icon(Icons.flight_takeoff_rounded, color: AppPallete.primary),
                label: 'Trips',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: AppPallete.primary),
                label: 'Expenses',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: AppPallete.primary),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
