import 'pepper_type.dart';

class Purchase {
  int? id;
  final String personName;
  final String community;
  final double kilos;
  final double pricePerKilo;
  final double totalAmount;
  final PepperType pepperType;
  final String quality; 
  final DateTime purchaseDate;
  final DateTime createdAt;

  Purchase({
    this.id,
    required this.personName,
    required this.community,
    required this.kilos,
    required this.pricePerKilo,
    required this.totalAmount,
    required this.pepperType,
    required this.quality,
    required this.purchaseDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'community': community,
      'kilos': kilos,
      'pricePerKilo': pricePerKilo,
      'totalAmount': totalAmount,
      'pepperType': pepperType.toString(),
      'quality': quality,
      'purchaseDate': purchaseDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      personName: map['personName'],
      community: map['community'],
      kilos: map['kilos'],
      pricePerKilo: map['pricePerKilo'],
      totalAmount: map['totalAmount'],
      pepperType: PepperType.fromString(map['pepperType'].split('.').last),
      quality: map['quality'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Purchase copyWith({
    int? id,
    String? personName,
    String? community,
    double? kilos,
    double? pricePerKilo,
    double? totalAmount,
    PepperType? pepperType,
    String? quality,
    DateTime? purchaseDate,
    DateTime? createdAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      community: community ?? this.community,
      kilos: kilos ?? this.kilos,
      pricePerKilo: pricePerKilo ?? this.pricePerKilo,
      totalAmount: totalAmount ?? this.totalAmount,
      pepperType: pepperType ?? this.pepperType,
      quality: quality ?? this.quality,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}