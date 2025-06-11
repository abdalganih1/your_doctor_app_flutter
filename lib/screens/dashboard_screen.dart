import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import 'auth/login_screen.dart';
import 'dashboards/patient_dashboard_screen.dart';
import 'dashboards/doctor_dashboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? currentUser = authProvider.user;

    // --- التعديل هنا: إضافة التحقق من context.mounted ---
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) { // <--- أضف هذا التحقق
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً بك, ${currentUser.name} (${currentUser.role})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) { // <--- أضف هذا التحقق
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _buildBodyForRole(context, currentUser),
    );
  }

  Widget _buildBodyForRole(BuildContext context, User user) {
    switch (user.role) {
      case 'patient':
        return const PatientDashboardScreen();
      case 'doctor':
        return const DoctorDashboardScreen();
      case 'admin':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('لوحة تحكم المدير', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              const Text('يمكن للمدير الوصول إلى لوحة التحكم عبر الويب.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (context.mounted) { // <--- أضف هذا التحقق
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        );
      default:
        return const Center(child: Text('دور غير معروف.'));
    }
  }
}