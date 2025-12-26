import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final bool isDarkMode;
  final int currentIndex;
  final Function(int) onNavigate;

  const AppDrawer({
    super.key,
    required this.isDarkMode,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final headerColor = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryColor = isDarkMode ? Colors.grey : Colors.black54;

    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: headerColor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Menú',
                        style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Calculadora 3D',
                        style: TextStyle(color: secondaryColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(context, Icons.settings, 'Filamentos', 0, textColor),
                _buildDrawerItem(context, Icons.monetization_on, 'Costos Base', 1, textColor),
                _buildDrawerItem(context, Icons.percent, 'Impuestos y Márgenes', 2, textColor),
                _buildDrawerItem(context, Icons.attach_money, 'Calcular Venta', 3, textColor),
                const Divider(),
                _buildDrawerItem(context, Icons.home, 'Inicio', 4, textColor),
              ],
            ),
          ),
          Divider(color: secondaryColor, height: 1),
          _buildSocialSection(secondaryColor),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    int index,
    Color textColor,
  ) {
    final isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF9333EA) : textColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF9333EA) : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF9333EA).withOpacity(0.1),
      onTap: () {
        onNavigate(index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSocialSection(Color secondaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Síguenos en redes sociales',
            style: TextStyle(
              color: secondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialIcon(Icons.facebook, const Color(0xFF1877F2)),
              _buildSocialIcon(Icons.camera_alt, const Color(0xFFE4405F)),
              _buildSocialIcon(Icons.play_arrow, const Color(0xFFFF0000)),
              _buildSocialIcon(Icons.tiktok, const Color.fromARGB(255, 46, 45, 48)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}