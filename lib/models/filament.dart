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