import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
        leading: const Icon(
          Icons.arrow_back,
          color: Color.fromARGB(255, 73, 120, 89),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Color.fromARGB(255, 73, 120, 89)),
        ),
        backgroundColor: Color.fromARGB(255, 73, 120, 89),
        elevation: 0,
      ),*/
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Avatar Circolare
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFC8E6C9),
              child: Icon(Icons.person_outline, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Rango Utente
            const Text(
              'Utente',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 73, 120, 89),
              ),
            ),
            const SizedBox(height: 20),

            // Bottone Upload Photo
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Text(
                'Upload Photo',
                style: TextStyle(color: Colors.black87),
              ),
              label: const Icon(Icons.arrow_upward, color: Colors.black87),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Lista delle Cornici (Cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildStatTile(
                    label: 'Traguardi',
                    value: '3 / 11',
                    icon: Icons.map_outlined,
                    color: Colors.green[800]!,
                  ),
                  _buildStatTile(
                    label: 'Esperienza',
                    value: '67 XP',
                    icon: Icons.stars,
                    color: Colors.indigo[900]!,
                  ),
                  _buildStatTile(
                    label: 'Pos. Classifica',
                    value: '1',
                    icon: Icons.emoji_events_outlined,
                    color: Colors.orange[700]!,
                  ),
                  _buildStatTile(
                    label: 'Siti Visitati',
                    value: '67',
                    icon: Icons.account_balance_outlined,
                    color: Colors.cyan[600]!,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontSize: 18)),
        ],
      ),
    );
  }
}
