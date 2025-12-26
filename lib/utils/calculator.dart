class PriceCalculator {
  static Map<String, double> calculate({
    required double hours,
    required double grams,
    required double filamentCostPerKg,
    required double electricityCost,
    required double suppliesCost,
    required double operatorCost,
    required double depreciationCost,
    required double igvPercentage,
    required double profitMargin,
  }) {
    final filamentCost = (filamentCostPerKg * grams) / 1000;
    final baseCost = (electricityCost + depreciationCost) * hours + 
                     filamentCost + suppliesCost + operatorCost;
    final profit = baseCost * (profitMargin / 100);
    final taxes = (baseCost + profit) * (igvPercentage / 100);
    final finalPrice = baseCost + profit + taxes;

    return {
      'baseCost': baseCost,
      'profit': profit,
      'taxes': taxes,
      'finalPrice': finalPrice,
    };
  }
}