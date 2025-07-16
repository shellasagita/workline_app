// lib/screens/auth/register_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workline_app/api/user_api.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';
import 'package:workline_app/routes/app_routes.dart';
import 'package:workline_app/widgets/%20copyright_footer.dart.dart';
// Asumsi AppSnackBar ada di suatu tempat, misal constants/app_snack_bar.dart
// import 'package:workline_app/constants/app_snack_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // New controller for retype password

  String? _selectedGender;
  int? _selectedBatchId;
  int? _selectedTrainingId;
  File? _selectedImage;

  bool _isLoading = false;
  bool _isPasswordVisible = false; // New state for password visibility
  bool _isConfirmPasswordVisible = false; // New state for confirm password visibility

  List<DropdownMenuItem<int>> _batchItems = [];
  List<DropdownMenuItem<int>> _trainingItems = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Dispose the new controller
    super.dispose();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final batches = await UserApi.getBatchList();
      final trainings = await UserApi.getTrainingList();

      debugPrint("Batches fetched: ${batches.length}");
      debugPrint("Trainings fetched: ${trainings.length}");

      if (mounted) {
        setState(() {
          _batchItems = batches.map((b) {
            return DropdownMenuItem<int>(
              value: b.id,
              child: Text("Batch ${b.batchKe}"),
            );
          }).toList();

          _trainingItems = trainings.map((t) {
            return DropdownMenuItem<int>(value: t.id, child: Text(t.title));
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching dropdown data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackBar.error("Failed to load registration options."),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim(); // Get confirm password

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty || // Check if confirm password is empty
        _selectedGender == null ||
        _selectedBatchId == null ||
        _selectedTrainingId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackBar.error("Please complete all fields."));
      return;
    }

    // Password matching validation
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("Passwords do not match. Please re-enter."),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final String? errorMessage = await UserApi.register(
      name: name,
      email: email,
      password: password,
      gender: _selectedGender!,
      batchId: _selectedBatchId!,
      trainingId: _selectedTrainingId!,
      profilePhoto: _selectedImage,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (errorMessage == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.success("Registration Success. Please Login."),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("Registration failed: $errorMessage"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                "Register",
                style: AppTextStyle.heading1.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.cream,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                        child: _selectedImage == null
                            ? const Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: AppInputStyle.textField("Name"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: AppInputStyle.textField("Email"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Password Field with Visibility Toggle
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible, // Control visibility
                      decoration: AppInputStyle.textField("Password").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.darkBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Retype Password Field with Visibility Toggle
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible, // Control visibility
                      decoration: AppInputStyle.textField("Retype Password").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.darkBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: AppInputStyle.textField("Gender"),
                      items: const [
                        DropdownMenuItem(value: "L", child: Text("Male")),
                        DropdownMenuItem(value: "P", child: Text("Female")),
                      ],
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedBatchId,
                      decoration: AppInputStyle.textField("Batch"),
                      items: _batchItems.isEmpty
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("Loading..."),
                              ),
                            ]
                          : _batchItems,
                      onChanged: (value) => setState(() => _selectedBatchId = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedTrainingId,
                      isExpanded: true,
                      decoration: AppInputStyle.textField("Training"),
                      items: _trainingItems.isEmpty
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("Loading..."),
                              ),
                            ]
                          : _trainingItems,
                      onChanged: (value) => setState(() => _selectedTrainingId = value),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          textStyle: AppTextStyle.button,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Register"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: AppTextStyle.body.copyWith(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.cream,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(
                        AppColors.cream.withAlpha((0.1 * 255).toInt()),
                      ),
                    ),
                    child: Text("Login", style: AppTextStyle.button),
                  ),
                ],
              ),
               const CopyrightFooter(),

            ],
          ),
        ),
      ),
    );
  }
}