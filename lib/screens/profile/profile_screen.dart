import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workline_app/constants/app_colors.dart';
import 'package:workline_app/models/profile_model.dart';
import 'package:workline_app/preferences/preferences_helper.dart';
import 'package:workline_app/screens/splash_screen.dart';
import 'package:workline_app/services/profile_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
        _futureProfile = ProfileService.fetchProfile(token);
      });
    }
  }

  Future<void> _logout() async {
    await PreferencesHelper.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> _updateName(ProfileData profile) async {
    String newName = profile.name;
    final token = await PreferencesHelper.getToken();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextFormField(
          initialValue: newName,
          onChanged: (value) => newName = value,
          decoration: const InputDecoration(labelText: 'New Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (token == null) return;
              Navigator.pop(context);

              final updated = await ProfileService.updateProfileName(token: token, name: newName);

              setState(() {
                _futureProfile = Future.value(ProfileData(
                  id: profile.id,
                  name: updated.name,
                  email: updated.email,
                  batchKe: profile.batchKe,
                  trainingTitle: profile.trainingTitle,
                  batch: profile.batch,
                  training: profile.training,
                  jenisKelamin: profile.jenisKelamin,
                  profilePhoto: profile.profilePhoto,
                ));
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Name updated successfully')),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadNewPhoto(ProfileData profile) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final token = await PreferencesHelper.getToken();
    if (token == null) return;

    setState(() => _isUploadingPhoto = true);

    final updated = await ProfileService.uploadProfilePhoto(token: token, imageFile: File(picked.path));

    setState(() {
      _futureProfile = Future.value(ProfileData(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        batchKe: profile.batchKe,
        trainingTitle: profile.trainingTitle,
        batch: profile.batch,
        training: profile.training,
        jenisKelamin: profile.jenisKelamin,
        profilePhoto: updated.profilePhoto,
      ));
      _isUploadingPhoto = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final profile = await _futureProfile;
              if (profile != null) _updateName(profile);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: FutureBuilder<ProfileData>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Failed to load profile", style: TextStyle(color: Colors.white)));
          }

          final profile = snapshot.data!;
          final photoUrl = profile.profilePhoto != null && profile.profilePhoto!.isNotEmpty
              ? (profile.profilePhoto!.startsWith('http')
                  ? profile.profilePhoto!
                  : 'https://appabsensi.mobileprojp.com/public/${profile.profilePhoto!}')
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      backgroundColor: AppColors.cream,
                      child: photoUrl == null ? const Icon(Icons.person, size: 40) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingPhoto ? null : () => _uploadNewPhoto(profile),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: _isUploadingPhoto
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.camera_alt, size: 18),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(profile.name, style: GoogleFonts.lexend(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 4),
                Text(profile.email, style: GoogleFonts.lexend(fontSize: 14, color: Colors.white70)),
                const Divider(height: 32, color: Colors.white24),

                _buildInfoRow(Icons.badge, "Batch", "Batch ${profile.batchKe}"),
                _buildInfoRow(Icons.school, "Training", profile.trainingTitle),
                _buildInfoRow(Icons.wc, "Gender", profile.jenisKelamin == 'L' ? 'Male' : 'Female'),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.cream),
      title: Text(label, style: GoogleFonts.lexend(color: Colors.white)),
      subtitle: Text(value, style: GoogleFonts.lexend(color: Colors.white70)),
    );
  }
}
