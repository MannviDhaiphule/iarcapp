import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'features/commands/presentation/screens/commands_screen.dart';
import 'features/map/presentation/screens/map_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/voice_command/presentation/screens/voice_debug_screen.dart';

/// Root shell widget that holds the bottom nav and manages tab state.
class AppShell extends ConsumerStatefulWidget {
  /// Creates an [AppShell].
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    VoiceDebugScreen(),
    CommandsScreen(),
    MapScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.colorBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.colorSurfaceElevated,
          selectedItemColor: AppTheme.colorAccent,
          unselectedItemColor: AppTheme.colorTextSecondary,
          selectedLabelStyle: GoogleFonts.spaceMono(fontSize: 11),
          unselectedLabelStyle: GoogleFonts.spaceMono(fontSize: 11),
          iconSize: 28,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            _buildNavItem(0, 'VOICE', Icons.mic_none, Icons.mic),
            _buildNavItem(1, 'COMMANDS', Icons.gamepad_outlined, Icons.gamepad),
            _buildNavItem(2, 'MAP', Icons.map_outlined, Icons.map),
            _buildNavItem(3, 'SETTINGS', Icons.settings_outlined, Icons.settings),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    int index,
    String label,
    IconData unselectedIcon,
    IconData selectedIcon,
  ) {
    final isSelected = _currentIndex == index;
    final icon = Icon(isSelected ? selectedIcon : unselectedIcon);

    return BottomNavigationBarItem(
      icon: isSelected
          ? icon.animate().scaleXY(end: 1.15, duration: 150.ms, curve: Curves.easeOut)
          : icon,
      label: label,
    );
  }
}
