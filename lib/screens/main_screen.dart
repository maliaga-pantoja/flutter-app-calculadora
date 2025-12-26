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
  int _currentIndex = 0; // Ahora 0 = Filamentos (primera pantalla)
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
      'Configuración de Filamento',      // 0 - Primera pantalla
      'Costos Base',                      // 1 - Segunda pantalla
      'Impuestos y Margenes de Ganancia', // 2 - Tercera pantalla
      'Calculo de Venta',                 // 3 - Cuarta pantalla
      'Inicio',                           // 4 - Pantalla de bienvenida (opcional)
    ];
    return titles[_currentIndex];
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const FilamentsScreen();
      case 1:
        return const CostsScreen();
      case 2:
        return const TaxesScreen();
      case 3:
        return const CalculatorScreen();
      case 4:
        return WelcomeScreen(onStart: () => _onNavigate(0));
      default:
        return const FilamentsScreen();
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _getBottomNavIndex(),
          onTap: (index) => _onNavigate(index),
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
    if (_currentIndex >= 0 && _currentIndex <= 3) {
      return _currentIndex;
    }
    return 0;
  }
}