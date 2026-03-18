enum PepperType {
  verde,
  seca,
  madura;

  String get displayName {
    switch (this) {
      case PepperType.verde:
        return 'Verde';
      case PepperType.seca:
        return 'Seca';
      case PepperType.madura:
        return 'Madura';
    }
  }

  factory PepperType.fromString(String type) {
    switch (type.toLowerCase()) {
      case 'verde':
        return PepperType.verde;
      case 'seca':
        return PepperType.seca;
      case 'madura':
        return PepperType.madura;
      default:
        return PepperType.verde;
    }
  }
}