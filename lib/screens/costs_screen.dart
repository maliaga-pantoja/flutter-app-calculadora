import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/custom_text_field.dart';
import '../utils/message_helper.dart';

class CostsScreen extends StatefulWidget {
  const CostsScreen({super.key});

  @override
  State<CostsScreen> createState() => _CostsScreenState();
}

class _CostsScreenState extends State<CostsScreen> {
  Map<String, String> costs = {};

  @override
  void initState() {
    super.initState();
    _loadCosts();
  }

  Future<void> _loadCosts() async {
    final loaded = await StorageService.loadCosts();
    setState(() => costs = loaded);
  }

  Future<void> _saveCosts() async {
    await StorageService.saveCosts(costs);
    MessageHelper.showSuccess(context, 'Costos guardados correctamente');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          CustomTextField(
            label: 'Costo por hora de energía eléctrica',
            value: costs['electricityCost'] ?? '',
            onChanged: (value) => setState(() => costs['electricityCost'] = value),
            hint: 'Ej: 0.5',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Costo de insumos para postprocesado (único)',
            value: costs['suppliesCost'] ?? '',
            onChanged: (value) => setState(() => costs['suppliesCost'] = value),
            hint: 'Ej: 2',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Costo de operario (único)',
            value: costs['operatorCost'] ?? '',
            onChanged: (value) => setState(() => costs['operatorCost'] = value),
            hint: 'Ej: 5',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Costo por hora de depreciación del equipo',
            value: costs['depreciationCost'] ?? '',
            onChanged: (value) => setState(() => costs['depreciationCost'] = value),
            hint: 'Ej: 0.3',
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
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}