import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/houses/map.dart';
import 'package:frontend/pages/auth/profile.dart';
import 'package:frontend/pages/houses/houseslist.dart';
import 'package:frontend/pages/auth/login.dart';
import 'package:frontend/pages/houses/your_properties.dart';
import 'package:frontend/pages/messages/messages_inbox.dart';
import 'package:frontend/pages/houses/favourites.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
              _NavItem(
                icon: Icons.search,
                label: 'Explore',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HousesList()),
                  );
                },
              ),
              _NavItem(
                icon: Icons.favorite_border,
                label: 'Favourites',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Favourites()),
                  );
                },
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Messages',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MessagesInbox()),
                  );
                },
              ),
              _NavItem(
                icon: Icons.map_outlined,
                label: 'Map',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Map()),
                  );
                },
              ),
              _NavItem(
                icon: Icons.home_work_outlined,
                label: 'Properties',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const YourProperties()),
                  );
                },
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Profile()),
                  );
                },
              ),
              _NavItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () async {
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'token');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                    (route) => false,
                  );
                },
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: const Color(0xFF717171),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF717171),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
