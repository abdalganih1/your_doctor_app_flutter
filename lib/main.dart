import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_doctor_app_flutter/providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/general_data_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/doctor_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GeneralDataProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider(Provider.of<AuthProvider>(context, listen: false))), // <<< التعديل هنا

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Doctor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const LoadingScreen();
          } else if (authProvider.user != null) {
            return const DashboardScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // Define other routes here as needed
      },
    );
  }
}