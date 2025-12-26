import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../services/storage_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/filament_card.dart';
import '../utils/message_helper.dart';

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
    // Validar que todos los campos estén llenos
    if (nameController.text.trim().isEmpty) {
      MessageHelper.showError(context, 'Por favor ingresa el nombre del filamento');
      return;
    }

    if (costController.text.trim().isEmpty) {
      MessageHelper.showError(context, 'Por favor ingresa el costo por kilogramo');
      return;
    }

    if (brandController.text.trim().isEmpty) {
      MessageHelper.showError(context, 'Por favor ingresa la marca del filamento');
      return;
    }

    // Validar que el costo sea un número válido
    final cost = double.tryParse(costController.text.trim());
    if (cost == null || cost <= 0) {
      MessageHelper.showError(context, 'Por favor ingresa un costo válido mayor a 0');
      return;
    }

    // Agregar el filamento
    try {
      final newFilament = Filament(
        id: DateTime.now().millisecondsSinceEpoch,
        name: nameController.text.trim(),
        costPerKg: cost,
        brand: brandController.text.trim(),
      );

      setState(() {
        filaments.add(newFilament);
      });

      await StorageService.saveFilaments(filaments);

      // Limpiar los campos
      nameController.clear();
      costController.clear();
      brandController.clear();

      // Mostrar mensaje de éxito
      MessageHelper.showSuccess(context, 'Filamento "${newFilament.name}" agregado correctamente');

      // Quitar el foco de los campos de texto
      FocusScope.of(context).unfocus();
    } catch (e) {
      MessageHelper.showError(context, 'Error al agregar el filamento. Intenta nuevamente.');
    }
  }

  Future<void> _deleteFilament(int id) async {
    // Buscar el nombre del filamento antes de eliminarlo
    final filament = filaments.firstWhere((f) => f.id == id);
    final filamentName = filament.name;

    setState(() => filaments.removeWhere((f) => f.id == id));
    await StorageService.saveFilaments(filaments);

    MessageHelper.showSuccess(context, 'Filamento "$filamentName" eliminado correctamente');
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
              label: const Text('Añadir Filamento', style: TextStyle(color: Colors.white)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filamentos Existentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF9333EA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${filaments.length} ${filaments.length == 1 ? 'filamento' : 'filamentos'}',
                  style: const TextStyle(
                    color: Color(0xFF9333EA),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filaments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: isDark ? Colors.grey : Colors.black26,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay filamentos registrados',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega tu primer filamento usando el formulario',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade600 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
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