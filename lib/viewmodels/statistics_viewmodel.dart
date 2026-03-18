import 'package:flutter/material.dart';
import '../models/purchase_model.dart';
import '../models/purchase_stats.dart';
import '../services/calculation_service.dart';
import 'purchase_viewmodel.dart';

class StatisticsViewModel extends ChangeNotifier {
  final PurchaseViewModel _purchaseViewModel;
  PurchaseStats? _stats;

  StatisticsViewModel(this._purchaseViewModel) {
    _purchaseViewModel.addListener(_updateStats);
  }

  PurchaseStats? get stats => _stats;

  void _updateStats() {
    _stats = CalculationService.calculateStats(_purchaseViewModel.purchases);
    notifyListeners();
  }

  Map<String, double> getKilosByTypeChartData() {
    if (_stats == null) return {};
    return {
      'Verde': _stats!.kilosByType['PepperType.verde'] ?? 0,
      'Seca': _stats!.kilosByType['PepperType.seca'] ?? 0,
      'Madura': _stats!.kilosByType['PepperType.madura'] ?? 0,
    };
  }

  Map<String, double> getInvestmentByTypeChartData() {
    if (_stats == null) return {};
    return {
      'Verde': _stats!.investmentByType['PepperType.verde'] ?? 0,
      'Seca': _stats!.investmentByType['PepperType.seca'] ?? 0,
      'Madura': _stats!.investmentByType['PepperType.madura'] ?? 0,
    };
  }

  @override
  void dispose() {
    _purchaseViewModel.removeListener(_updateStats);
    super.dispose();
  }
}