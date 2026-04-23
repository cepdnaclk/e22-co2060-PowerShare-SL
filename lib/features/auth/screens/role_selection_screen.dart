import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../map/screens/map_screen.dart';
import '../../host/screens/host_dashboard_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  static const Color _primary = Color(0xFF1E3A5F);

  Future<void> _selectRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);

    if (!mounted) return;

    if (role == 'driver') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HostDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Icon(Icons.ev_station, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'PowerShare SL',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ඔබ කවුද?',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 60),

              // EV Driver card
              _buildRoleCard(
                icon: Icons.electric_car,
                title: 'EV Driver',
                subtitle: 'Charger සොයාගෙන book කරන්න',
                color: Colors.green,
                onTap: () => _selectRole('driver'),
              ),
              const SizedBox(height: 20),

              // Charger Host card
              _buildRoleCard(
                icon: Icons.home_filled,
                title: 'Charger Host',
                subtitle: 'ඔබේ charger register කරලා ආදායම් ලබන්න',
                color: Colors.orange,
                onTap: () => _selectRole('host'),
              ),

              const SizedBox(height: 40),
              const Text(
                'ඔබට දෙකම use කරන්න පුළුවන් —\nආයෙ login කළ විට role change කරන්න.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
