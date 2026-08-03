import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Products'),
    _NavItem(icon: Icons.point_of_sale_outlined, activeIcon: Icons.point_of_sale, label: 'Billing'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Reports'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: _items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
