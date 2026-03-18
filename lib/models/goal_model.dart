class Goal {
  final int id;
  final String name;
  final double targetKilos;
  final double currentKilos;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Goal({
    required this.id,
    required this.name,
    required this.targetKilos,
    required this.currentKilos,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  double get progress => (currentKilos / targetKilos) * 100;
  
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  
  double get kilosPerDayNeeded {
    if (daysRemaining <= 0) return 0;
    return (targetKilos - currentKilos) / daysRemaining;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetKilos': targetKilos,
      'currentKilos': currentKilos,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      targetKilos: map['targetKilos'],
      currentKilos: map['currentKilos'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isActive: map['isActive'] == 1,
    );
  }
}