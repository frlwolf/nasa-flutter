import 'package:flutter/material.dart';
import 'screens/apod_list_screen.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.init();
  
  runApp(const NasaApodApp());
}

class NasaApodApp extends StatelessWidget {
  const NasaApodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA APOD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // NASA blue
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const ApodListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
