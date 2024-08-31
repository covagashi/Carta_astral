import 'package:flutter/material.dart';
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SCR_01_perfil()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(22),

                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(avatarPath),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Si hay un error al cargar la imagen, usar un icono como respaldo
                        print('Error loading avatar image: $exception');
                      },
                      child: avatarPath.isEmpty
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                      radius: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      profileName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    // Implementar funcionalidad de notificaciones
                  },
                ),
                IconButton(
                  icon: Icon(Icons.dashboard, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SCR_01_HubTarot()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 20);
}