import 'package:flutter/material.dart';
import 'screens/water_source_map_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/issue_reporting_screen.dart';
import 'screens/offline_queue_screen.dart';
import 'screens/notifications_screen.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget home = const MainNavigation();
    if (kDebugMode) {
      home = DeviceFrame(device: Devices.ios.iPhone16ProMax, screen: home);
    }
    return MaterialApp(
      title: 'Water & Sanitation Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF1976D2), // Blue
          onPrimary: Colors.white,
          secondary: Color(0xFF26A69A), // Teal
          onSecondary: Colors.white,
          error: Color(0xFFD32F2F), // Red
          onError: Colors.white,
          background: Color(0xFFF5F7FA),
          onBackground: Color(0xFF222B45),
          surface: Colors.white,
          onSurface: Color(0xFF222B45),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF1976D2),
          unselectedItemColor: Color(0xFFB0BEC5),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: home,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  static final List<Widget> _screens = <Widget>[
    WaterSourceMapScreen(),
    QRScannerScreen(),
    IssueReportingScreen(),
    OfflineQueueScreen(),
    NotificationsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: 'Offline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
}
