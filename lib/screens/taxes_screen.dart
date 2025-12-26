import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/custom_text_field.dart';

class TaxesScreen extends StatefulWidget {
  const TaxesScreen({super.key});

  @override
  State<TaxesScreen> createState() => _TaxesScreenState();
}

class _TaxesScreenState extends State<TaxesScreen> {
  Map<String, String> config = {};

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final loaded = await StorageService.loadConfig();
    setState(() => config = loaded);
  }

  Future<void> _saveConfig() async {
    await StorageService.saveConfig(
      config['igvPercentage'] ?? '',
      config['profitMargin'] ?? '',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Porcentaje de IGV',
            value: config['igvPercentage'] ?? '',
            onChanged: (value) => setState(() => config['igvPercentage'] = value),
            hint: 'Ej: 18',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Margen de Ganancia',
            value: config['profitMargin'] ?? '',
            onChanged: (value) => setState(() => config['profitMargin'] = value),
            hint: 'Ej: 40',
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