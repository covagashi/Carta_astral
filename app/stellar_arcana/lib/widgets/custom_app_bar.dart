import 'package:flutter/material.dart';
import 'dart:ui';
import '../screens/SCR_01_perfil.dart';
import '../screens/SCR_01_HubTarot.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileName;
  final String avatarPath;

  CustomAppBar({
    Key? key,
    required this.profileName,
    required this.avatarPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1B2E).withOpacity(0.85),
            Color(0xFF0D0E1C).withOpacity(0.95),
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.only(
              top: padding.top + 4, // Reducido de 8 a 4
              bottom: 4, // Reducido de 8 a 4
              left: 12, // Reducido de 16 a 12
              right: 12, // Reducido de 16 a 12
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
          MaterialPageRoute(builder: (context) => SCR_01_perfil()),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reducido de 12,6 a 8,4
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20), // Reducido de 25 a 20
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(avatarPath),
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading avatar image: $exception');
              },
              child: avatarPath.isEmpty
                  ? Icon(Icons.person, color: Colors.white, size: 16) // Reducido tamaño del icono
                  : null,
              radius: 14, // Reducido de 18 a 14
            ),
            SizedBox(width: 6), // Reducido de 8 a 6
            Text(
              profileName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13, // Reducido de 15 a 13
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
        SizedBox(width: 2), // Reducido de 4 a 2
        _buildIconButton(
          icon: Icons.dashboard_outlined,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SCR_01_HubTarot()),
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
          size: 18, // Reducido de 22 a 18
        ),
        onPressed: onPressed,
        padding: EdgeInsets.all(8), // Reducido padding del IconButton
        constraints: BoxConstraints(
          minWidth: 36, // Reducido de 48 a 36
          minHeight: 36, // Reducido de 48 a 36
        ),
        splashRadius: 20, // Reducido de 24 a 20
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Quitado el +20 extra
}