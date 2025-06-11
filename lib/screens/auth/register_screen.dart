import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/general_data_provider.dart';
// import '../../config/config.dart';
// import '../../models/specialization.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _yearsExperienceController = TextEditingController();
  final TextEditingController _consultationFeeController = TextEditingController();
  final TextEditingController _profilePictureUrlController = TextEditingController();

  String _selectedRole = 'patient';
  int? _selectedSpecializationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GeneralDataProvider>(context, listen: false).fetchAllSpecializations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final generalDataProvider = Provider.of<GeneralDataProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              ),
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
              TextField(
                controller: _passwordConfirmationController,
                decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                obscureText: true,
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف (اختياري)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'الدور'),
                items: const [
                  DropdownMenuItem(value: 'patient', child: Text('مريض')),
                  DropdownMenuItem(value: 'doctor', child: Text('طبيب')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              if (_selectedRole == 'doctor') ...[
                const SizedBox(height: 20),
                Text('تفاصيل الطبيب', style: Theme.of(context).textTheme.headlineSmall),
                generalDataProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<int>(
                        value: _selectedSpecializationId,
                        decoration: const InputDecoration(labelText: 'الاختصاص'),
                        items: generalDataProvider.specializations.map((spec) {
                          return DropdownMenuItem(
                            value: spec.id,
                            child: Text(spec.nameAr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecializationId = value;
                          });
                        },
                      ),
                TextField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'نبذة عن الطبيب (اختياري)'),
                  maxLines: 3,
                ),
                TextField(
                  controller: _yearsExperienceController,
                  decoration: const InputDecoration(labelText: 'سنوات الخبرة (اختياري)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _consultationFeeController,
                  decoration: const InputDecoration(labelText: 'رسوم الاستشارة (اختياري)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _profilePictureUrlController,
                  decoration: const InputDecoration(labelText: 'رابط صورة الملف الشخصي (اختياري)'),
                  keyboardType: TextInputType.url,
                ),
              ],
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
                        Map<String, dynamic> userData = {
                          'full_name': _fullNameController.text,
                          'email': _emailController.text,
                          'password': _passwordController.text,
                          'password_confirmation': _passwordConfirmationController.text,
                          'phone_number': _phoneNumberController.text.isNotEmpty ? _phoneNumberController.text : null,
                          'role': _selectedRole,
                        };

                        if (_selectedRole == 'doctor') {
                          userData.addAll({
                            'specialization_id': _selectedSpecializationId,
                            'bio': _bioController.text.isNotEmpty ? _bioController.text : null,
                            'years_experience': int.tryParse(_yearsExperienceController.text),
                            'consultation_fee': double.tryParse(_consultationFeeController.text),
                            'profile_picture_url': _profilePictureUrlController.text.isNotEmpty ? _profilePictureUrlController.text : null,
                          });
                        }

                        bool success = await authProvider.register(userData);
                        if (success) {
                          Navigator.of(context).pushReplacementNamed('/dashboard');
                        }
                      },
                      child: const Text('تسجيل'),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to login screen
                },
                child: const Text('لدي حساب بالفعل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
