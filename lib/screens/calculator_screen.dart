import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../services/storage_service.dart';
import '../utils/calculator.dart';
import '../widgets/price_summary_card.dart';
import '../widgets/custom_text_field.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String printHours = '';
  String gramsUsed = '';
  Filament? selectedFilament;
  List<Filament> filaments = [];
  
  Map<String, String> config = {};
  Map<String, String> costs = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedFilaments = await StorageService.loadFilaments();
    final loadedConfig = await StorageService.loadConfig();
    final loadedCosts = await StorageService.loadCosts();
    
    setState(() {
      filaments = loadedFilaments;
      config = loadedConfig;
      costs = loadedCosts;
    });
  }

  Map<String, double> _calculatePrices() {
    if (selectedFilament == null) {
      return {'baseCost': 0, 'profit': 0, 'taxes': 0, 'finalPrice': 0};
    }

    return PriceCalculator.calculate(
      hours: double.tryParse(printHours) ?? 0,
      grams: double.tryParse(gramsUsed) ?? 0,
      filamentCostPerKg: selectedFilament!.costPerKg,
      electricityCost: double.tryParse(costs['electricityCost'] ?? '0') ?? 0,
      suppliesCost: double.tryParse(costs['suppliesCost'] ?? '0') ?? 0,
      operatorCost: double.tryParse(costs['operatorCost'] ?? '0') ?? 0,
      depreciationCost: double.tryParse(costs['depreciationCost'] ?? '0') ?? 0,
      igvPercentage: double.tryParse(config['igvPercentage'] ?? '0') ?? 0,
      profitMargin: double.tryParse(config['profitMargin'] ?? '0') ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prices = _calculatePrices();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Horas de Impresión',
            value: printHours,
            onChanged: (value) => setState(() => printHours = value),
          ),
          const SizedBox(height: 16),
          Text(
            'Filamento',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Filament>(
            initialValue: selectedFilament,
            decoration: const InputDecoration(),
            hint: const Text('Seleccionar'),
            items: filaments
                .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f.name),
                    ))
                .toList(),
            onChanged: (value) => setState(() => selectedFilament = value),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Gramos a Usar',
            value: gramsUsed,
            onChanged: (value) => setState(() => gramsUsed = value),
          ),
          const SizedBox(height: 24),
          PriceSummaryCard(prices: prices, isDark: isDark),
        ],
      ),
    );
  }
}