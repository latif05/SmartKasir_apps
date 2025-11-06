import 'package:flutter/material.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/products/presentation/pages/products_placeholder_page.dart';
import '../features/reports/presentation/pages/reports_placeholder_page.dart';
import '../features/settings/presentation/pages/settings_placeholder_page.dart';
import '../features/transactions/presentation/pages/transactions_placeholder_page.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  late final List<_NavigationDestination> _destinations = [
    _NavigationDestination(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      builder: () => const DashboardPage(),
    ),
    _NavigationDestination(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Produk',
      builder: () => const ProductsPlaceholderPage(),
    ),
    _NavigationDestination(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Transaksi',
      builder: () => const TransactionsPlaceholderPage(),
    ),
    _NavigationDestination(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Laporan',
      builder: () => const ReportsPlaceholderPage(),
    ),
    _NavigationDestination(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Pengaturan',
      builder: () => const SettingsPlaceholderPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      body: Row(
        children: [
          if (isWide) _buildNavigationRail(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _destinations[_currentIndex].builder(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide ? null : _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
      },
      destinations: [
        for (final destination in _destinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.activeIcon),
            label: destination.label,
          ),
      ],
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
      },
      labelType: NavigationRailLabelType.all,
      destinations: [
        for (final destination in _destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.activeIcon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}

class _NavigationDestination {
  const _NavigationDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget Function() builder;
}
