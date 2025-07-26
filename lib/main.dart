import 'package:flutter/material.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'services/offline_queue_service.dart';
import 'screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => OfflineQueueService())],
      child: MaterialApp(
        title: 'Water & Sanitation Tracker',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF007AFF),
            onPrimary: Colors.white,
            secondary: Color(0xFF5856D6),
            onSecondary: Colors.white,
            error: Color(0xFFFF3B30),
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF000000),
            background: Color(0xFFFFFFFF),
            onBackground: Color(0xFF000000),
          ),
          useMaterial3: true,
          fontFamily: '.SF Pro Text',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            titleLarge: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(fontSize: 17, color: Colors.black),
            bodyMedium: TextStyle(fontSize: 15, color: Colors.black87),
            labelLarge: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shadowColor: Color(0x22000000),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 1,
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF007AFF),
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Color(0xFF007AFF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        builder: (context, child) {
          if (kIsWeb) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 390,
                  maxHeight: 844,
                ),
                child: DeviceFrame(
                  device: Devices.ios.iPhone13,
                  screen: child!,
                  isFrameVisible: true,
                ),
              ),
            );
          }
          return child!;
        },
        home: const MainNavigation(),
      ),
    );
  }
}
