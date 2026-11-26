import 'package:billin/common/c_colors.dart';
import 'package:billin/profile/about_apps.dart';
import 'package:billin/profile/change_pass_page.dart';
import 'package:billin/profile/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:billin/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final bool withNavbar;
  const ProfilePage({super.key, this.withNavbar = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  String _username = '';
  String _email = '';
  String? _avatarUrl;
  bool _loading = true;

  late final StreamSubscription<AuthState> _sub;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _sub = supabase.auth.onAuthStateChange.listen((_) {
      if (mounted) _loadProfile();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _loadProfile() {
    if (!mounted) return;
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final meta = user.userMetadata;
    final email = user.email ?? '';
    final name = (meta?['username'] as String?)?.trim();

    setState(() {
      _email = email;
      _username = (name != null && name.isNotEmpty)
          ? name
          : email.split('@').first;
      _avatarUrl = meta?['avatar_url'] as String?;
      _loading = false;
    });
  }

  static const _blue = Color(0xFF2F80ED);
  static const _red = Color(0xFFEB3B4A);
  bool _uploading = false;

  Future<void> _changePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _uploading = true);
    try {
      final path = '${user.id}/avatar.jpg';

      await supabase.storage
          .from('foto_profile')
          .upload(
            path,
            File(picked.path),
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final url =
          '${supabase.storage.from('foto_profile').getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}';

      await supabase.auth.updateUser(UserAttributes(data: {'avatar_url': url}));

      if (!mounted) return;
      setState(() => _avatarUrl = url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengganti foto: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Keluar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun?',
          style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!context.mounted) return;
    await AuthService().signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 130),
          child: Column(
            children: [
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _ProfileHeader(
                      username: _username,
                      email: _email,
                      avatarUrl: _avatarUrl,
                      uploading: _uploading,
                      onChangePhoto: _changePhoto,
                    ),
              const SizedBox(height: 16),
              _MenuTile(
                icon: Icons.manage_accounts_outlined,
                label: 'Edit Profile',
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const EditProfilePage(),
                      transitionsBuilder: (_, animation, __, child) {
                        final tween = Tween(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeOutCubic));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                  if (mounted) _loadProfile();
                },
              ),
              const SizedBox(height: 8),
              _MenuTile(
                icon: Icons.lock_outline,
                label: 'Ubah Kata Sandi',
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const ChangePasswordPage(),
                    transitionsBuilder: (_, animation, __, child) {
                      final tween = Tween(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutCubic));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _MenuTile(
                icon: Icons.info_outline,
                label: 'Tentang Aplikasi',
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const AboutPage(),
                    transitionsBuilder: (_, animation, __, child) {
                      final tween = Tween(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutCubic));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _MenuTile(
                icon: Icons.logout,
                label: 'Keluar',
                color: _red,
                showChevron: false,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu putih berisi avatar, username, dan email
class _ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String? avatarUrl;
  final bool uploading;
  final VoidCallback onChangePhoto;

  const _ProfileHeader({
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.uploading,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    const avatarSize = 110.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: avatarSize / 2),
          padding: EdgeInsets.fromLTRB(16, avatarSize / 2 + 16, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                username,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: TextStyle(fontSize: 13, color: const Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),

        // Foto profile
        SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: const Color(0xFFD9D9D9),
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 64,
                        color: Color(0xFF9E9E9E),
                      )
                    : null,
              ),
              Positioned(
                right: 2,
                bottom: 6,
                child: GestureDetector(
                  onTap: uploading ? null : onChangePhoto, //ganti foto profil
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: uploading
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.photo_camera_outlined,
                            size: 17,
                            color: CColors.accent,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool showChevron;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = _ProfilePageState._blue,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = color == _ProfilePageState._blue;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDefault ? Colors.black : color,
                  ),
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFBDBDBD),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
