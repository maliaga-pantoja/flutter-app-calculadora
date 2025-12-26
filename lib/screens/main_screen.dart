import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/app_drawer.dart';
import 'welcome_screen.dart';
import 'calculator_screen.dart';
import 'filaments_screen.dart';
import 'costs_screen.dart';
import 'taxes_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 0 = Home/Inicio (primera pantalla)
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await StorageService.getTheme();
    setState(() => _isDarkMode = isDark);
  }

  Future<void> _toggleTheme() async {
    setState(() => _isDarkMode = !_isDarkMode);
    await StorageService.saveTheme(_isDarkMode);
  }

  void _onNavigate(int index) {
    setState(() => _currentIndex = index);
  }

  String _getTitle() {
    const titles = [
      'Calculadora de Costos de Impresión 3D', // 0 - Home/Inicio
      'Configuración de Filamento',             // 1 - Filamentos
      'Costos Base',                            // 2 - Costos
      'Impuestos y Margenes de Ganancia',       // 3 - Impuestos
      'Calculo de Venta',                       // 4 - Calcular
    ];
    return titles[_currentIndex];
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return WelcomeScreen(onStart: () => _onNavigate(1)); // Al hacer clic va a Filamentos
      case 1:
        return const FilamentsScreen();
      case 2:
        return const CostsScreen();
      case 3:
        return const TaxesScreen();
      case 4:
        return const CalculatorScreen();
      default:
        return WelcomeScreen(onStart: () => _onNavigate(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle()),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: _isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
            ),
          ],
        ),
        drawer: AppDrawer(
          isDarkMode: _isDarkMode,
          currentIndex: _currentIndex,
          onNavigate: _onNavigate,
        ),
        body: _buildBody(),
        bottomNavigationBar: _currentIndex == 0 
            ? null // No mostrar bottom nav en la pantalla de inicio
            : BottomNavigationBar(
                currentIndex: _getBottomNavIndex(),
                onTap: (index) => _onNavigate(_getScreenIndexFromBottomNav(index)),
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Filamentos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.monetization_on),
                    label: 'Costos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.percent),
                    label: 'Impuestos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money),
                    label: 'Calcular',
                  ),
                ],
              ),
      ),
    );
  }

  int _getBottomNavIndex() {
    // Mapea el índice actual al índice del bottom nav
    switch (_currentIndex) {
      case 1: return 0; // Filamentos
      case 2: return 1; // Costos
      case 3: return 2; // Impuestos
      case 4: return 3; // Calcular
      default: return 0;
    }
  }

  int _getScreenIndexFromBottomNav(int bottomNavIndex) {
    // Mapea el índice del bottom nav al índice de la pantalla
    switch (bottomNavIndex) {
      case 0: return 1; // Filamentos
      case 1: return 2; // Costos
      case 2: return 3; // Impuestos
      case 3: return 4; // Calcular
      default: return 1;
    }
  }
}