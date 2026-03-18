import 'purchase_model.dart';

class PurchaseStats {
  final double totalKilos;
  final double totalInvestment;
  final double averagePricePerKilo;
  final int totalPurchases;
  final Map<String, double> kilosByType;
  final Map<String, double> investmentByType;
  final List<Purchase> top3Purchases;
  final Map<String, List<Purchase>> top3ByType;

  PurchaseStats({
    required this.totalKilos,
    required this.totalInvestment,
    required this.averagePricePerKilo,
    required this.totalPurchases,
    required this.kilosByType,
    required this.investmentByType,
    required this.top3Purchases,
    required this.top3ByType,
  });

  factory PurchaseStats.initial() {
    return PurchaseStats(
      totalKilos: 0,
      totalInvestment: 0,
      averagePricePerKilo: 0,
      totalPurchases: 0,
      kilosByType: {},
      investmentByType: {},
      top3Purchases: [],
      top3ByType: {},
    );
  }
}