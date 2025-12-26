import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/filament.dart';

class StorageService {
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? true;
  }

  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  static Future<Map<String, String>> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'igvPercentage': prefs.getString('igvPercentage') ?? '',
      'profitMargin': prefs.getString('profitMargin') ?? '',
    };
  }

  static Future<void> saveConfig(String igv, String margin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('igvPercentage', igv);
    await prefs.setString('profitMargin', margin);
  }

  static Future<Map<String, String>> loadCosts() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'electricityCost': prefs.getString('electricityCost') ?? '',
      'suppliesCost': prefs.getString('suppliesCost') ?? '',
      'operatorCost': prefs.getString('operatorCost') ?? '',
      'depreciationCost': prefs.getString('depreciationCost') ?? '',
    };
  }

  static Future<void> saveCosts(Map<String, String> costs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('electricityCost', costs['electricityCost'] ?? '');
    await prefs.setString('suppliesCost', costs['suppliesCost'] ?? '');
    await prefs.setString('operatorCost', costs['operatorCost'] ?? '');
    await prefs.setString('depreciationCost', costs['depreciationCost'] ?? '');
  }

  static Future<List<Filament>> loadFilaments() async {
    final prefs = await SharedPreferences.getInstance();
    final filamentsJson = prefs.getString('filaments');
    if (filamentsJson != null) {
      final List<dynamic> decoded = json.decode(filamentsJson);
      return decoded.map((e) => Filament.fromJson(e)).toList();
    }
    return [
      Filament(id: 1, name: 'Filamento PLA', costPerKg: 25, brand: 'XYZ'),
      Filament(id: 2, name: 'Filamento ABS', costPerKg: 30, brand: 'ABC'),
      Filament(id: 3, name: 'Filamento PETG', costPerKg: 40, brand: 'DEF'),
    ];
  }

  static Future<void> saveFilaments(List<Filament> filaments) async {
    final prefs = await SharedPreferences.getInstance();
    final filamentsJson = json.encode(filaments.map((e) => e.toJson()).toList());
    await prefs.setString('filaments', filamentsJson);
  }
}