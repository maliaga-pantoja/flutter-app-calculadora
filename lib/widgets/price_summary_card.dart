import 'package:flutter/material.dart';

class PriceSummaryCard extends StatelessWidget {
  final Map<String, double> prices;
  final bool isDark;

  const PriceSummaryCard({
    super.key,
    required this.prices,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryColor = isDark ? Colors.grey : Colors.black54;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Costo Base Total', prices['baseCost']!, secondaryColor, textColor),
          _buildPriceRow('Ganancia', prices['profit']!, secondaryColor, textColor),
          _buildPriceRow('Impuestos', prices['taxes']!, secondaryColor, textColor),
          Divider(color: secondaryColor, height: 24),
          _buildPriceRow('Precio Final de Venta', prices['finalPrice']!, secondaryColor, textColor, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, Color secondaryColor, Color textColor, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? textColor : secondaryColor,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: isTotal ? const Color(0xFF9333EA) : textColor,
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}