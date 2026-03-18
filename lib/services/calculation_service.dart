import '../models/purchase_model.dart';
import '../models/purchase_stats.dart';

class CalculationService {
  static PurchaseStats calculateStats(List<Purchase> purchases) {
    if (purchases.isEmpty) return PurchaseStats.initial();

    double totalKilos = 0;
    double totalInvestment = 0;
    Map<String, double> kilosByType = {};
    Map<String, double> investmentByType = {};

    for (var purchase in purchases) {
      totalKilos += purchase.kilos;
      totalInvestment += purchase.totalAmount;
      
      String typeKey = purchase.pepperType.toString();
      kilosByType[typeKey] = (kilosByType[typeKey] ?? 0) + purchase.kilos;
      investmentByType[typeKey] = (investmentByType[typeKey] ?? 0) + purchase.totalAmount;
    }

    double averagePricePerKilo = totalInvestment / totalKilos;

    // Top 3 general purchases
    var sortedPurchases = List<Purchase>.from(purchases)
      ..sort((a, b) => b.kilos.compareTo(a.kilos));
    var top3Purchases = sortedPurchases.take(3).toList();

    // Top 3 by type
    Map<String, List<Purchase>> top3ByType = {};
    for (var type in PepperType.values) {
      var typePurchases = purchases
          .where((p) => p.pepperType == type)
          .toList()
        ..sort((a, b) => b.kilos.compareTo(a.kilos));
      top3ByType[type.toString()] = typePurchases.take(3).toList();
    }

    return PurchaseStats(
      totalKilos: totalKilos,
      totalInvestment: totalInvestment,
      averagePricePerKilo: averagePricePerKilo,
      totalPurchases: purchases.length,
      kilosByType: kilosByType,
      investmentByType: investmentByType,
      top3Purchases: top3Purchases,
      top3ByType: top3ByType,
    );
  }

  static double calculateProjectedCompletion(
    double currentKilos, 
    double targetKilos, 
    DateTime startDate, 
    DateTime endDate
  ) {
    var now = DateTime.now();
    var totalDays = endDate.difference(startDate).inDays;
    var daysPassed = now.difference(startDate).inDays;
    
    if (daysPassed <= 0) return 0;
    
    var projectedKilos = (currentKilos / daysPassed) * totalDays;
    return (projectedKilos / targetKilos) * 100;
  }
}