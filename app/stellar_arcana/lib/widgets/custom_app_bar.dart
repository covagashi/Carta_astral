import 'package:flutter/material.dart';
import 'dart:ui';
import '../screens/SCR_01_perfil.dart';
import '../screens/SCR_01_AstrosAhora.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileName;
  final String avatarPath;
  final Function(String)? onAvatarChanged;

  const CustomAppBar({
    super.key,
    required this.profileName,
    required this.avatarPath,
    this.onAvatarChanged,
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1B2E).withOpacity(0.85),
            const Color(0xFF0D0E1C).withOpacity(0.95),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.only(
              top: padding.top + 4,
              bottom: 4,
              left: 12,
              right: 12,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProfileButton(context),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scr01Perfil(
              profileName: profileName,
              onAvatarChanged: onAvatarChanged,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(avatarPath),
              radius: 14,
              child: avatarPath.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              profileName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildIconButton(
          icon: Icons.notifications_outlined,
          onPressed: () {
            // Implementar funcionalidad de notificaciones
          },
        ),
        const SizedBox(width: 2),
        _buildIconButton(
          icon: Icons.public_outlined,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AstrosAhora()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 18,
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        splashRadius: 20,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}