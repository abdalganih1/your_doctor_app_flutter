import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/config.dart'; // For default password
import 'register_screen.dart'; // For navigation to register screen

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        // حفظ مرجع لـ context قبل بدء العملية غير المتزامنة
                        // والتأكد من أنه لا يزال mounted بعد العودة.
                        if (!context.mounted) return; // إضافة هذا التحقق هنا
                        bool success = await authProvider.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                        if (success) {
                          if (!context.mounted) return; // إضافة هذا التحقق مرة أخرى قبل Navigator
                          Navigator.of(context).pushReplacementNamed('/dashboard');
                        }
                      },
                      child: const Text('تسجيل الدخول'),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterScreen()));
                },
                child: const Text('إنشاء حساب جديد'),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const Text('تسجيل دخول سريع للتجربة (للتطوير فقط)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildQuickLoginButton(context, 'مدير', 'admin@yourdoctor.com', AppConfig.defaultPassword),
              _buildQuickLoginButton(context, 'طبيب (خالد)', 'dr.khaled@yourdoctor.com', AppConfig.defaultPassword),
              _buildQuickLoginButton(context, 'مريض (أحمد)', 'ahmad.patient@yourdoctor.com', AppConfig.defaultPassword),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginButton(BuildContext context, String label, String email, String password) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () async {
          _emailController.text = email;
          _passwordController.text = password;

          // إضافة التحقق من context.mounted هنا أيضاً
          if (!context.mounted) return;
          bool success = await authProvider.login(email, password);
          if (success) {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacementNamed('/dashboard');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: label.contains('مدير') ? Colors.red : (label.contains('طبيب') ? Colors.amber : Colors.blue),
          foregroundColor: label.contains('طبيب') ? Colors.black : Colors.white,
          minimumSize: const Size(double.infinity, 45),
        ),
        child: Text(label),
      ),
    );
  }
}