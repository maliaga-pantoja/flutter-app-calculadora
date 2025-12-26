import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../services/storage_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/filament_card.dart';

class FilamentsScreen extends StatefulWidget {
  const FilamentsScreen({super.key});

  @override
  State<FilamentsScreen> createState() => _FilamentsScreenState();
}

class _FilamentsScreenState extends State<FilamentsScreen> {
  List<Filament> filaments = [];
  final nameController = TextEditingController();
  final costController = TextEditingController();
  final brandController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFilaments();
  }

  Future<void> _loadFilaments() async {
    final loaded = await StorageService.loadFilaments();
    setState(() => filaments = loaded);
  }

  Future<void> _addFilament() async {
    if (nameController.text.isNotEmpty &&
        costController.text.isNotEmpty &&
        brandController.text.isNotEmpty) {
      setState(() {
        filaments.add(Filament(
          id: DateTime.now().millisecondsSinceEpoch,
          name: nameController.text,
          costPerKg: double.tryParse(costController.text) ?? 0,
          brand: brandController.text,
        ));
      });
      await StorageService.saveFilaments(filaments);
      nameController.clear();
      costController.clear();
      brandController.clear();
    }
  }

  Future<void> _deleteFilament(int id) async {
    setState(() => filaments.removeWhere((f) => f.id == id));
    await StorageService.saveFilaments(filaments);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Nombre del Filamento',
            controller: nameController,
            hint: 'Ej: PLA Premium',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Costo por Kilogramo',
            controller: costController,
            hint: 'Ej: 25',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Marca',
            controller: brandController,
            hint: 'Ej: XYZ',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addFilament,
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
          Text(
            'Filamentos Existentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...filaments.map((f) => FilamentCard(
                filament: f,
                isDark: isDark,
                onDelete: () => _deleteFilament(f.id),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    costController.dispose();
    brandController.dispose();
    super.dispose();
  }
}