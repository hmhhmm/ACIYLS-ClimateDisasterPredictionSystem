import 'package:flutter/material.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';
import 'utils/responsive_utils.dart';
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
        themeMode: ThemeMode.dark,
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
            background: Color(0xFFF2F2F7),
            onBackground: Color(0xFF000000),
          ),
          useMaterial3: true,
          fontFamily: '.SF Pro Text',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(fontSize: 17),
            bodyMedium: TextStyle(fontSize: 15),
            labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
        darkTheme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF0A84FF),
            onPrimary: Colors.white,
            secondary: Color(0xFF5E5CE6),
            onSecondary: Colors.white,
            error: Color(0xFFFF453A),
            onError: Colors.white,
            surface: Color(0xFF1C1C1E),
            onSurface: Colors.white,
            background: Color(0xFF000000),
            onBackground: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: '.SF Pro Text',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            titleLarge: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(fontSize: 17, color: Colors.white),
            bodyMedium: TextStyle(fontSize: 15, color: Colors.white70),
            labelLarge: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            color: Color(0xFF1A1A1A),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shadowColor: Color(0x44000000),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 1,
              backgroundColor: const Color(0xFF0A84FF),
              foregroundColor: Colors.black,
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
              foregroundColor: const Color(0xFF0A84FF),
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Color(0xFF0A84FF)),
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
