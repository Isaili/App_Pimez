import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/database_service.dart';
import '../services/calculation_service.dart';
import 'purchase_viewmodel.dart';

class GoalViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final PurchaseViewModel _purchaseViewModel;
  List<Goal> _goals = [];
  Goal? _activeGoal;
  bool _isLoading = false;
  String? _error;

  GoalViewModel(this._purchaseViewModel) {
    _purchaseViewModel.addListener(_updateCurrentKilos);
    loadGoals();
  }

  List<Goal> get goals => _goals;
  Goal? get activeGoal => _activeGoal;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _databaseService.getAllGoals();
      _activeGoal = await _databaseService.getActiveGoal();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateCurrentKilos() {
    if (_activeGoal != null) {
      double totalKilos = 0;
      for (var purchase in _purchaseViewModel.purchases) {
        totalKilos += purchase.kilos;
      }
      
      var updatedGoal = _activeGoal!.copyWith(
        currentKilos: totalKilos,
      );
      
      updateGoal(updatedGoal);
    }
  }

  Future<bool> createGoal(Goal goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
    
      if (_activeGoal != null) {
        var deactivatedGoal = _activeGoal!.copyWith(isActive: false);
        await _databaseService.updateGoal(deactivatedGoal);
      }

      await _databaseService.insertGoal(goal);
      await loadGoals();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGoal(Goal goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.updateGoal(goal);
      await loadGoals();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  double getProjectedCompletion() {
    if (_activeGoal == null) return 0;
    
    return CalculationService.calculateProjectedCompletion(
      _activeGoal!.currentKilos,
      _activeGoal!.targetKilos,
      _activeGoal!.startDate,
      _activeGoal!.endDate,
    );
  }

  int getDaysToGoalAtCurrentRate() {
    if (_activeGoal == null) return 0;
    
    var now = DateTime.now();
    var daysPassed = now.difference(_activeGoal!.startDate).inDays;
    
    if (daysPassed <= 0 || _activeGoal!.currentKilos <= 0) return 0;
    
    var ratePerDay = _activeGoal!.currentKilos / daysPassed;
    if (ratePerDay <= 0) return 0;
    
    var remainingKilos = _activeGoal!.targetKilos - _activeGoal!.currentKilos;
    return (remainingKilos / ratePerDay).ceil();
  }

  @override
  void dispose() {
    _purchaseViewModel.removeListener(_updateCurrentKilos);
    super.dispose();
  }
}

extension on Goal {
  Goal copyWith({
    int? id,
    String? name,
    double? targetKilos,
    double? currentKilos,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetKilos: targetKilos ?? this.targetKilos,
      currentKilos: currentKilos ?? this.currentKilos,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}