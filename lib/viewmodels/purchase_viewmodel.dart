import 'package:flutter/material.dart';
import '../models/purchase_model.dart';
import '../models/pepper_type.dart';
import '../services/database_service.dart';

class PurchaseViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Purchase> _purchases = [];
  bool _isLoading = false;
  String? _error;

  List<Purchase> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPurchases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _purchases = await _databaseService.getAllPurchases();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPurchase(Purchase purchase) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.insertPurchase(purchase);
      await loadPurchases();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePurchase(Purchase purchase) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.updatePurchase(purchase);
      await loadPurchases();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePurchase(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.deletePurchase(id);
      await loadPurchases();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<Purchase> getPurchasesByType(PepperType type) {
    return _purchases.where((p) => p.pepperType == type).toList();
  }
}