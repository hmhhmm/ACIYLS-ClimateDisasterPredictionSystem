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
        theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF007AFF), // iOS Blue
            onPrimary: Colors.white,
            secondary: Color(0xFF5856D6), // iOS Purple
            onSecondary: Colors.white,
            error: Color(0xFFFF3B30), // iOS Red
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF000000),
            background: Color(0xFFF2F2F7), // iOS Light Gray
            onBackground: Color(0xFF000000),
          ),
          useMaterial3: true,
          fontFamily: '.SF Pro Text', // iOS System Font
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
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF007AFF),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF007AFF),
            unselectedItemColor: Color(0xFF8E8E93),
            selectedLabelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: TextStyle(fontSize: 11),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
          ),
          scaffoldBackgroundColor: const Color(0xFFF2F2F7),
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(12),
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
