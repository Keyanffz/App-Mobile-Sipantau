import 'package:flutter/material.dart';

// PASTIKAN ADA NAMA FOLDERNYA SEPERTI INI:
import 'home/home_screen.dart'; // Masuk folder home
import 'service/service_screen.dart'; // Masuk folder service
import 'car/car_screen.dart'; // Masuk folder car
import 'profile/profile_screen.dart'; // Masuk folder profile

class MainNavigation extends StatefulWidget {
  // ...
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _screens = [
    const HomeScreen(),
    const ServiceScreen(), // Panggil ServiceScreen dari foldernya
    const CarScreen(), // Panggil CarScreen dari foldernya
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        indicatorColor: const Color(0xFF5CB85C).withOpacity(0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Service',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Car',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
