import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workline_app/api/profile_service.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/models/profile_model.dart';
import 'package:workline_app/preferences/preferences_helper.dart';
import 'package:workline_app/screens/splash/splash_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<ProfileData>? _futureProfile;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await PreferencesHelper.getToken();
    if (token != null) {
      setState(() {
        _futureProfile = ProfileService.fetchProfile();
      });
    }
  }

  Future<void> _logout() async {
    await PreferencesHelper.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> _pickAndUploadPhoto(ProfileData profile) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final token = await PreferencesHelper.getToken();
    if (token == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final bytes = await picked.readAsBytes();
      final base64Image = base64Encode(bytes);
      final updated = await ProfileService.uploadProfilePhotoBase64(
        token: token,
        base64Image: base64Image,
      );

      setState(() {
        _futureProfile = Future.value(updated);
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile photo updated"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to upload photo: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editNameDialog(ProfileData profile) async {
    String newName = profile.name;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Name"),
            content: TextFormField(
              initialValue: profile.name,
              onChanged: (value) => newName = value,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'New Name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final token = await PreferencesHelper.getToken();
                  if (token == null) return;
                  try {
                    final updated = await ProfileService.updateProfileName(
                      token: token,
                      name: newName,
                    );
                    setState(() {
                      _futureProfile = Future.value(updated);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Name updated"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to update name: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGreen,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: AppColors.success,
      ),
      body: FutureBuilder<ProfileData>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load profile"));
          }

          final profile = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.paleYellow,
                      backgroundImage:
                          profile.profilePhoto != null
                              ? NetworkImage(
                                profile.profilePhoto.startsWith("http")
                                    ? profile.profilePhoto
                                    : "https://appabsensi.mobileprojp.com/public/${profile.profilePhoto}",
                              )
                              : null,
                      child:
                          profile.profilePhoto == null
                              ? const Icon(Icons.person, size: 48)
                              : null,
                    ),
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: InkWell(
                    //     onTap: _isUploadingPhoto
                    //         ? null
                    //         => _pickAndUploadPhoto(profile),
                    //     child: CircleAvatar(
                    //       radius: 16,
                    //       backgroundColor: AppColors.success,
                    //       child: _isUploadingPhoto
                    //           ? const SizedBox(
                    //               height: 16,
                    //               width: 16,
                    //               child: CircularProgressIndicator(
                    //                 strokeWidth: 2,
                    //                 color: Colors.white,
                    //               ),
                    //             )
                    //           : const Icon(Icons.camera_alt, size: 18),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  profile.name,
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(child: Text(profile.email)),
              const Divider(height: 32),

              _infoTile(Icons.badge, "Batch", "Batch ${profile.batchKe}"),
              _infoTile(Icons.school, "Training", profile.trainingTitle),
              _infoTile(Icons.wc, "Gender", _genderLabel(profile.jenisKelamin)),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _editNameDialog(profile),
                icon: const Icon(Icons.edit),
                label: const Text("Edit Name"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.paleYellow,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.paleYellow),
      title: Text(label, style: GoogleFonts.lexend()),
      subtitle: Text(value),
    );
  }

  String _genderLabel(String? code) {
    switch (code) {
      case "L":
        return "Male";
      case "P":
        return "Female";
      default:
        return "Not Specified";
    }
  }
}
