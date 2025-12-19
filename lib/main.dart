import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Impresión 3D',
      theme: _isDarkMode ? _darkTheme() : _lightTheme(),
      home: MainScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF111827),
      primaryColor: const Color(0xFF9333EA),
      cardColor: const Color(0xFF1F2937),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F2937),
        selectedItemColor: Color(0xFF9333EA),
        unselectedItemColor: Colors.white,
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      primaryColor: const Color(0xFF9333EA),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF9333EA),
        unselectedItemColor: Colors.black54,
        elevation: 8,
      ),
    );
  }
}

class Filament {
  final int id;
  final String name;
  final double costPerKg;
  final String brand;

  Filament({
    required this.id,
    required this.name,
    required this.costPerKg,
    required this.brand,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'costPerKg': costPerKg,
        'brand': brand,
      };

  factory Filament.fromJson(Map<String, dynamic> json) => Filament(
        id: json['id'],
        name: json['name'],
        costPerKg: json['costPerKg'].toDouble(),
        brand: json['brand'],
      );
}

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  String igvPercentage = '';
  String profitMargin = '';
  
  List<Filament> filaments = [
    Filament(id: 1, name: 'Filamento PLA', costPerKg: 25, brand: 'XYZ'),
    Filament(id: 2, name: 'Filamento ABS', costPerKg: 30, brand: 'ABC'),
    Filament(id: 3, name: 'Filamento PETG', costPerKg: 40, brand: 'DEF'),
  ];
  
  String electricityCost = '';
  String suppliesCost = '';
  String operatorCost = '';
  String depreciationCost = '';
  
  String printHours = '';
  Filament? selectedFilament;
  String gramsUsed = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      igvPercentage = prefs.getString('igvPercentage') ?? '';
      profitMargin = prefs.getString('profitMargin') ?? '';
      electricityCost = prefs.getString('electricityCost') ?? '';
      suppliesCost = prefs.getString('suppliesCost') ?? '';
      operatorCost = prefs.getString('operatorCost') ?? '';
      depreciationCost = prefs.getString('depreciationCost') ?? '';
      
      final filamentsJson = prefs.getString('filaments');
      if (filamentsJson != null) {
        final List<dynamic> decoded = json.decode(filamentsJson);
        filaments = decoded.map((e) => Filament.fromJson(e)).toList();
      }
    });
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('igvPercentage', igvPercentage);
    await prefs.setString('profitMargin', profitMargin);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada correctamente')),
      );
    }
  }

  Future<void> _saveCosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('electricityCost', electricityCost);
    await prefs.setString('suppliesCost', suppliesCost);
    await prefs.setString('operatorCost', operatorCost);
    await prefs.setString('depreciationCost', depreciationCost);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Costos guardados correctamente')),
      );
    }
  }

  Future<void> _saveFilaments() async {
    final prefs = await SharedPreferences.getInstance();
    final filamentsJson = json.encode(filaments.map((e) => e.toJson()).toList());
    await prefs.setString('filaments', filamentsJson);
  }

  void _addFilament(String name, String costStr, String brand) {
    if (name.isNotEmpty && costStr.isNotEmpty && brand.isNotEmpty) {
      setState(() {
        filaments.add(Filament(
          id: DateTime.now().millisecondsSinceEpoch,
          name: name,
          costPerKg: double.tryParse(costStr) ?? 0,
          brand: brand,
        ));
      });
      _saveFilaments();
    }
  }

  void _deleteFilament(int id) {
    setState(() {
      filaments.removeWhere((f) => f.id == id);
    });
    _saveFilaments();
  }

  Map<String, double> _calculatePrices() {
    final hours = double.tryParse(printHours) ?? 0;
    final grams = double.tryParse(gramsUsed) ?? 0;
    final electricity = double.tryParse(electricityCost) ?? 0;
    final supplies = double.tryParse(suppliesCost) ?? 0;
    final operator = double.tryParse(operatorCost) ?? 0;
    final depreciation = double.tryParse(depreciationCost) ?? 0;
    final igv = double.tryParse(igvPercentage) ?? 0;
    final margin = double.tryParse(profitMargin) ?? 0;

    final filamentCost = selectedFilament != null
        ? (selectedFilament!.costPerKg * grams) / 1000
        : 0;

    final baseCost = (electricity + depreciation) * hours + filamentCost + supplies + operator;
    final profit = baseCost * (margin / 100);
    final taxes = (baseCost + profit) * (igv / 100);
    final finalPrice = baseCost + profit + taxes;

    return {
      'baseCost': baseCost,
      'profit': profit,
      'taxes': taxes,
      'finalPrice': finalPrice,
    };
  }

  Color _getDrawerColor() {
    return widget.isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
  }

  Color _getDrawerHeaderColor() {
    return widget.isDarkMode ? const Color(0xFF1F2937) : Colors.white;
  }

  Color _getTextColor() {
    return widget.isDarkMode ? Colors.white : Colors.black87;
  }

  Color _getSecondaryTextColor() {
    return widget.isDarkMode ? Colors.grey : Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: _getDrawerColor(),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: _getDrawerHeaderColor()),
                    child: Text(
                      'Menú',
                      style: TextStyle(color: _getTextColor(), fontSize: 24),
                    ),
                  ),
                  _buildDrawerItem(Icons.home, 'Inicio', 0),
                  _buildDrawerItem(Icons.attach_money, 'Calcular Venta', 1),
                  _buildDrawerItem(Icons.settings, 'Filamentos', 2),
                  _buildDrawerItem(Icons.monetization_on, 'Costos Base', 3),
                  _buildDrawerItem(Icons.percent, 'Impuestos y Márgenes', 4),
                ],
              ),
            ),
            Divider(color: _getSecondaryTextColor(), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Síguenos en redes sociales',
                    style: TextStyle(
                      color: _getSecondaryTextColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialIcon(Icons.facebook, 'https://facebook.com', const Color(0xFF1877F2)),
                      _buildSocialIcon(Icons.camera_alt, 'https://instagram.com', const Color(0xFFE4405F)),
                      _buildSocialIcon(Icons.play_arrow, 'https://youtube.com', const Color(0xFFFF0000)),
                      _buildSocialIcon(Icons.alternate_email, 'https://twitter.com', const Color(0xFF1DA1F2)),
                      _buildSocialIcon(Icons.web, 'https://tusitio.com', const Color(0xFF9333EA)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _currentIndex == 0 ? null : BottomNavigationBar(
        currentIndex: _getBottomNavIndex(),
        onTap: (index) => setState(() => _currentIndex = _getScreenIndexFromBottomNav(index)),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.percent), label: ''),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'Calculadora de Costos de Impresión 3D';
      case 1: return 'Calculo de Venta';
      case 2: return 'Configuración de Filamento';
      case 3: return 'Costos Base';
      case 4: return 'Impuestos y Margenes de Ganancia';
      default: return '';
    }
  }

  int _getBottomNavIndex() {
    switch (_currentIndex) {
      case 1: return 0;
      case 2: return 1;
      case 4: return 2;
      default: return 0;
    }
  }

  int _getScreenIndexFromBottomNav(int bottomNavIndex) {
    switch (bottomNavIndex) {
      case 0: return 1;
      case 1: return 2;
      case 2: return 4;
      default: return 1;
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: _getTextColor()),
      title: Text(title, style: TextStyle(color: _getTextColor())),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSocialIcon(IconData icon, String url, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abriendo: $url'), duration: const Duration(seconds: 1)),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildWelcomeScreen();
      case 1: return _buildCalculatorScreen();
      case 2: return _buildFilamentsScreen();
      case 3: return _buildCostsScreen();
      case 4: return _buildTaxesScreen();
      default: return Container();
    }
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido a la Calculadora de Costos de Impresión 3D',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _getTextColor()),
            ),
            const SizedBox(height: 16),
            Text(
              'Calcula tus costos de impresión 3D con facilidad. ¡Comienza ahora!',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getSecondaryTextColor(), fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _currentIndex = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Comenzar', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxesScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Porcentaje de IGV', style: TextStyle(fontSize: 14, color: _getTextColor(), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => igvPercentage = value),
            decoration: const InputDecoration(hintText: 'Ej: 18'),
            controller: TextEditingController.fromValue(
              TextEditingValue(text: igvPercentage, selection: TextSelection.collapsed(offset: igvPercentage.length)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Margen de Ganancia', style: TextStyle(fontSize: 14, color: _getTextColor(), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => profitMargin = value),
            decoration: const InputDecoration(hintText: 'Ej: 40'),
            controller: TextEditingController.fromValue(
              TextEditingValue(text: profitMargin, selection: TextSelection.collapsed(offset: profitMargin.length)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorScreen() {
    final prices = _calculatePrices();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horas de Impresión', style: TextStyle(fontSize: 14, color: _getTextColor())),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => printHours = value),
            decoration: const InputDecoration(hintText: '0'),
            controller: TextEditingController.fromValue(
              TextEditingValue(text: printHours, selection: TextSelection.collapsed(offset: printHours.length)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Filamento', style: TextStyle(fontSize: 14, color: _getTextColor())),
          const SizedBox(height: 8),
          DropdownButtonFormField<Filament>(
            value: selectedFilament,
            decoration: const InputDecoration(),
            hint: const Text('Seleccionar'),
            items: filaments.map((f) => DropdownMenuItem(value: f, child: Text(f.name))).toList(),
            onChanged: (value) => setState(() => selectedFilament = value),
          ),
          const SizedBox(height: 16),
          Text('Gramos a Usar', style: TextStyle(fontSize: 14, color: _getTextColor())),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => gramsUsed = value),
            decoration: const InputDecoration(hintText: '0'),
            controller: TextEditingController.fromValue(
              TextEditingValue(text: gramsUsed, selection: TextSelection.collapsed(offset: gramsUsed.length)),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.isDarkMode ? [] : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getTextColor())),
                const SizedBox(height: 16),
                _buildPriceRow('Costo Base Total', prices['baseCost']!),
                _buildPriceRow('Ganancia', prices['profit']!),
                _buildPriceRow('Impuestos', prices['taxes']!),
                Divider(color: _getSecondaryTextColor(), height: 24),
                _buildPriceRow('Precio Final de Venta', prices['finalPrice']!, isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? _getTextColor() : _getSecondaryTextColor(),
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: isTotal ? const Color(0xFF9333EA) : _getTextColor(),
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilamentsScreen() {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final brandController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('Añadir Filamento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getTextColor())),
          // const SizedBox(height: 16),
          Text('Nombre del Filamento', style: TextStyle(fontSize: 14, color: _getTextColor(), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Ej: PLA Premium')),
          const SizedBox(height: 16),
          Text('Costo por Kilogramo', style: TextStyle(fontSize: 14, color: _getTextColor(), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(controller: costController, decoration: const InputDecoration(hintText: 'Ej: 25')),
          const SizedBox(height: 16),
          Text('Marca', style: TextStyle(fontSize: 14, color: _getTextColor(), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(controller: brandController, decoration: const InputDecoration(hintText: 'Ej: XYZ')),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _addFilament(nameController.text, costController.text, brandController.text);
                nameController.clear();
                costController.clear();
                brandController.clear();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Añadir', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Filamentos Existentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getTextColor())),
          const SizedBox(height: 16),
          ...filaments.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: widget.isDarkMode ? [] : [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _getTextColor())),
                          const SizedBox(height: 4),
                          Text('Costo: \${f.costPerKg}/kg, Marca: ${f.brand}', style: TextStyle(color: _getSecondaryTextColor(), fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteFilament(f.id)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCostsScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Costo por hora de energía eléctrica', style: TextStyle(fontSize: 14, color: _getTextColor(), fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => setState(() => electricityCost = value),
                decoration: const InputDecoration(hintText: 'Ej: 0.5'),
                controller: TextEditingController.fromValue(
                  TextEditingValue(text: electricityCost, selection: TextSelection.collapsed(offset: electricityCost.length)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Costo de insumos para postprocesado (único)', style: TextStyle(fontSize: 14, color: _getTextColor(), fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => setState(() => suppliesCost = value),
                decoration: const InputDecoration(hintText: 'Ej: 2'),
                controller: TextEditingController.fromValue(
                  TextEditingValue(text: suppliesCost, selection: TextSelection.collapsed(offset: suppliesCost.length)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Costo de operario (único)', style: TextStyle(fontSize: 14, color: _getTextColor(), fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => setState(() => operatorCost = value),
                decoration: const InputDecoration(hintText: 'Ej: 5'),
                controller: TextEditingController.fromValue(
                  TextEditingValue(text: operatorCost, selection: TextSelection.collapsed(offset: operatorCost.length)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Costo por hora de depreciación del equipo', style: TextStyle(fontSize: 14, color: _getTextColor(), fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => setState(() => depreciationCost = value),
                decoration: const InputDecoration(hintText: 'Ej: 0.3'),
                controller: TextEditingController.fromValue(
                  TextEditingValue(text: depreciationCost, selection: TextSelection.collapsed(offset: depreciationCost.length)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveCosts,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}