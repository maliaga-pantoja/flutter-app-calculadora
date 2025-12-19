import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Impresión 3D',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111827),
        primaryColor: const Color(0xFF9333EA),
        cardColor: const Color(0xFF1F2937),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1F2937),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
      home: const MainScreen(),
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
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // Configuración
  String igvPercentage = '';
  String profitMargin = '';
  
  // Filamentos
  List<Filament> filaments = [
    Filament(id: 1, name: 'Filamento PLA', costPerKg: 25, brand: 'XYZ'),
    Filament(id: 2, name: 'Filamento ABS', costPerKg: 30, brand: 'ABC'),
    Filament(id: 3, name: 'Filamento PETG', costPerKg: 40, brand: 'DEF'),
  ];
  
  // Costos base
  String electricityCost = '';
  String suppliesCost = '';
  String operatorCost = '';
  String depreciationCost = '';
  
  // Cálculo de venta
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

    final baseCost = (electricity + supplies + operator + depreciation) * hours + filamentCost;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: Text(_getTitle()),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF111827),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1F2937)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
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
      body: _buildBody(),
      bottomNavigationBar: _currentIndex == 0 ? null : BottomNavigationBar(
        currentIndex: _getBottomNavIndex(),
        onTap: (index) => setState(() => _currentIndex = _getScreenIndexFromBottomNav(index)),
        backgroundColor: const Color(0xFF1F2937),
        selectedItemColor: const Color(0xFF9333EA),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.percent), label: ''),
        ],
      ),
    );
  }

  int _getBottomNavIndex() {
    // Mapear el índice de pantalla al índice de la barra de navegación
    switch (_currentIndex) {
      case 1: return 0; // Calcular Venta
      case 2: return 1; // Filamentos
      case 4: return 2; // Impuestos y Márgenes
      default: return 0;
    }
  }

  int _getScreenIndexFromBottomNav(int bottomNavIndex) {
    // Mapear el índice de la barra de navegación al índice de pantalla
    switch (bottomNavIndex) {
      case 0: return 1; // Calcular Venta
      case 1: return 2; // Filamentos
      case 2: return 4; // Impuestos y Márgenes
      default: return 1;
    }
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Calculadora de Costos de Impresión 3D';
      case 1:
        return 'Calculo de Venta';
      case 2:
        return 'Configuración de Filamento';
      case 3:
        return 'Costos Base';
      case 4:
        return 'Impuestos y Margenes de Ganancia';
      default:
        return '';
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildWelcomeScreen();
      case 1:
        return _buildCalculatorScreen();
      case 2:
        return _buildFilamentsScreen();
      case 3:
        return _buildCostsScreen();
      case 4:
        return _buildTaxesScreen();
      default:
        return Container();
    }
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido a la Calculadora de Costos de Impresión 3D',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Calcula tus costos de impresión 3D con facilidad. ¡Comienza ahora!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _currentIndex = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Comenzar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxesScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Porcentaje de IGV', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => igvPercentage = value),
            decoration: InputDecoration(
              hintText: 'Ej: 18',
            ),
            keyboardType: TextInputType.text,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: igvPercentage,
                selection: TextSelection.collapsed(offset: igvPercentage.length),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Margen de Ganancia', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => profitMargin = value),
            decoration: InputDecoration(
              hintText: 'Ej: 40',
            ),
            keyboardType: TextInputType.text,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: profitMargin,
                selection: TextSelection.collapsed(offset: profitMargin.length),
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
          const Text('Horas de Impresión', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => printHours = value),
            decoration: const InputDecoration(hintText: '0'),
            keyboardType: TextInputType.text,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: printHours,
                selection: TextSelection.collapsed(offset: printHours.length),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Filamento', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<Filament>(
            value: selectedFilament,
            decoration: const InputDecoration(),
            hint: const Text('Seleccionar'),
            items: filaments.map((f) => DropdownMenuItem(
              value: f,
              child: Text(f.name),
            )).toList(),
            onChanged: (value) => setState(() => selectedFilament = value),
          ),
          const SizedBox(height: 16),
          const Text('Gramos a Usar', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => gramsUsed = value),
            decoration: const InputDecoration(hintText: '0'),
            keyboardType: TextInputType.text,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: gramsUsed,
                selection: TextSelection.collapsed(offset: gramsUsed.length),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildPriceRow('Costo Base Total', prices['baseCost']!),
                _buildPriceRow('Ganancia', prices['profit']!),
                _buildPriceRow('Impuestos', prices['taxes']!),
                const Divider(color: Colors.grey, height: 24),
                _buildPriceRow(
                  'Precio Final de Venta',
                  prices['finalPrice']!,
                  isTotal: true,
                ),
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
              color: isTotal ? Colors.white : Colors.grey,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: isTotal ? const Color(0xFF9333EA) : Colors.white,
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
          const Text(
            'Añadir Filamento',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nombre del Filamento'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: costController,
            decoration: const InputDecoration(hintText: 'Costo por Kilogramo'),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: brandController,
            decoration: const InputDecoration(hintText: 'Marca'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _addFilament(
                  nameController.text,
                  costController.text,
                  brandController.text,
                );
                nameController.clear();
                costController.clear();
                brandController.clear();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Añadir', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Filamentos Existentes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...filaments.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Costo: \$${f.costPerKg}/kg, Marca: ${f.brand}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFilament(f.id),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCostsScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => electricityCost = value),
            decoration: const InputDecoration(
              hintText: 'Costo por hora de energía eléctrica',
            ),
            keyboardType: TextInputType.text,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: electricityCost,
                selection: TextSelection.collapsed(offset: electricityCost.length),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => suppliesCost = value),
            decoration: const InputDecoration(
              hintText: 'Costo por hora de insumos para postprocesado',
            ),
            keyboardType: TextInputType.text,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: suppliesCost,
                selection: TextSelection.collapsed(offset: suppliesCost.length),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => operatorCost = value),
            decoration: const InputDecoration(
              hintText: 'Costo por hora de operario',
            ),
            keyboardType: TextInputType.text,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: operatorCost,
                selection: TextSelection.collapsed(offset: operatorCost.length),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => depreciationCost = value),
            decoration: const InputDecoration(
              hintText: 'Costo por hora de depreciación del equipo',
            ),
            keyboardType: TextInputType.text,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: depreciationCost,
                selection: TextSelection.collapsed(offset: depreciationCost.length),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveCosts,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}