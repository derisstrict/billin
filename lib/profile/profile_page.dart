import 'package:billin/main_screen.dart';
import 'package:billin/profile/about_apps.dart';
import 'package:billin/profile/change_pass_page.dart';
import 'package:billin/profile/edit_profile_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _blue = Color(0xFF2F80ED);
  static const _red = Color(0xFFEB3B4A);

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

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ), //arahkan ke halaman login
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 130),
        child: Column(
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 16),
            _MenuTile(
              icon: Icons.manage_accounts_outlined,
              label: 'Edit Profile',
              onTap: () => Navigator.push(
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
              ),
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
    );
  }
}

/// Kartu putih berisi avatar, username, dan email
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
                'Username',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'emailuser@gmail.com',
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
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD9D9D9),
                ),
                child: const Icon(
                  Icons.person,
                  size: 64,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 6,
                child: GestureDetector(
                  onTap: () {}, //ganti foto profil
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
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      size: 17,
                      color: ProfilePage._blue,
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
    this.color = ProfilePage._blue,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = color == ProfilePage._blue;

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
