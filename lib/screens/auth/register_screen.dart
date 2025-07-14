import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/constants/app_style.dart';
import 'package:workline_app/api/user_api.dart';
import 'package:workline_app/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedGender;
  int? _selectedBatchId;
  int? _selectedTrainingId;
  File? _selectedImage;

  bool _isLoading = false;

  List<DropdownMenuItem<int>> _batchItems = [];
  List<DropdownMenuItem<int>> _trainingItems = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final batches = await UserApi.getBatchList();
    final trainings = await UserApi.getTrainingList();

    debugPrint("Batches fetched: ${batches.length}");
    debugPrint("Trainings fetched: ${trainings.length}");

    setState(() {
      _batchItems = batches.map((b) {
        return DropdownMenuItem<int>(
          value: b.id,
          child: Text("Batch ${b.batchKe}"),
        );
      }).toList();

      _trainingItems = trainings.map((t) {
        return DropdownMenuItem<int>(
          value: t.id,
          child: Text(t.title),
        );
      }).toList();
    });
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

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedGender == null ||
        _selectedBatchId == null ||
        _selectedTrainingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("Please complete all fields."),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await UserApi.register(
      name: name,
      email: email,
      password: password,
      gender: _selectedGender!,
      batchId: _selectedBatchId!,
      trainingId: _selectedTrainingId!,
      profilePhoto: _selectedImage,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.error("Registration failed. Please try again."),
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
              Text("Register", style: AppTextStyle.heading1.copyWith(color: Colors.white)),
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
                            ? const Icon(Icons.add_a_photo, color: Colors.white)
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

                    TextField(
                      controller: _passwordController,
                      decoration: AppInputStyle.textField("Password"),
                      obscureText: true,
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
                              )
                            ]
                          : _batchItems,
                      onChanged: (value) => setState(() => _selectedBatchId = value),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      value: _selectedTrainingId,
                      decoration: AppInputStyle.textField("Training"),
                      items: _trainingItems.isEmpty
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("Loading..."),
                              )
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
                            ? const CircularProgressIndicator(color: Colors.white)
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
                  Text("Already have an account?",
                      style: AppTextStyle.body.copyWith(color: Colors.white)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.cream,
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(
                        AppColors.cream.withAlpha((0.1 * 255).toInt()),
                      ),
                    ),
                    child: Text("Login", style: AppTextStyle.button),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
