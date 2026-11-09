import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view),
            label: l10n.navCategories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: l10n.navCart,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            label: l10n.navFavorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.navAccount,
          ),
        ],
      ),
    );
  }
}
