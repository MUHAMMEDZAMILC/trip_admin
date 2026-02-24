import 'package:flutter/material.dart';
import 'package:trip_admin/pages/vendor_home.dart';
import 'package:trip_admin/pages/add_package.dart';
import 'package:trip_admin/pages/vendor_bookings.dart';
import 'package:trip_admin/pages/vendor_profile.dart';

class VendorBottomNavBar extends StatefulWidget {
  const VendorBottomNavBar({super.key});

  @override
  State<VendorBottomNavBar> createState() => _VendorBottomNavBarState();
}

class _VendorBottomNavBarState extends State<VendorBottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    VendorHome(),       // Home
    AddPackagePage(),   // Add Package
    VendorBookings(),   // Bookings
    VendorProfile(),    // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepOrange,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: "Add",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online_outlined),
              activeIcon: Icon(Icons.book_online),
              label: "Bookings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
