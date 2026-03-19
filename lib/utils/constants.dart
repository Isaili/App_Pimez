import 'package:flutter/material.dart';
import '../models/pepper_type.dart';

/// Constantes de la aplicación PIMEZ
class AppConstants {
  // Nombre de la aplicación
  static const String appName = 'PIMEZ';
  static const String appVersion = '1.0.0';
  
  // Configuración de base de datos
  static const String dbName = 'pimez.db';
  static const int dbVersion = 1;
  
  // Formatos de fecha
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatStorage = 'yyyy-MM-dd';
  static const String timeFormatDisplay = 'HH:mm';
  static const String dateTimeFormatDisplay = 'dd/MM/yyyy HH:mm';
  
  // Moneda
  static const String currencySymbol = '\$';
  static const String currencyCode = 'MXN';
  
  // Unidades
  static const String weightUnit = 'kg';
  static const String weightUnitLong = 'kilogramos';
  static const String weightUnitShort = 'kg';
  
  // Límites y validaciones
  static const double minKilos = 0.1;
  static const double maxKilos = 10000;
  static const double minPrice = 0.01;
  static const double maxPrice = 1000;
  static const int maxNameLength = 100;
  static const int maxCommunityLength = 100;
  
  // Precios por defecto para proyecciones
  static const double defaultSalePricePerKilo = 100.0;
  
  // Configuración de metas
  static const int minGoalDays = 1;
  static const int maxGoalDays = 365;
  static const double minGoalKilos = 1.0;
  
  // Configuración de backups
  static const int maxBackupFiles = 10;
  static const String backupFolder = 'backups';
  static const String backupExtension = '.json';
  static const String backupPrefix = 'backup_';
  
  // Rutas de assets
  static const String logoPath = 'assets/images/logo.png';
  static const String iconPath = 'assets/icons/icon.png';
  
  // Animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);
  static const Duration snackBarDuration = Duration(seconds: 3);
  
  // Paginación
  static const int itemsPerPage = 20;
  
  // Tamaños
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;
}

/// Colores de la aplicación
class AppColors {
  // Colores primarios
  static const Color primary = Colors.green;
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF2E7D32);
  
  // Colores secundarios
  static const Color secondary = Colors.orange;
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);
  
  // Colores de fondo
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFFE0E0E0);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Colores por tipo de pimienta
  static const Color pepperGreen = Color(0xFF4CAF50);
  static const Color pepperDry = Color(0xFF8B4513);
  static const Color pepperRipe = Color(0xFFFF5722);
  
  // Colores para gráficas
  static const List<Color> chartColors = [
    Color(0xFF4CAF50), // Verde
    Color(0xFF8B4513), // Café
    Color(0xFFFF5722), // Naranja
    Color(0xFF2196F3), // Azul
    Color(0xFF9C27B0), // Púrpura
    Color(0xFFFFC107), // Amarillo
  ];
  
  // Colores para medallas (top 3)
  static const Color medalGold = Color(0xFFFFD700);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalBronze = Color(0xFFCD7F32);
  
  // Colores de acentos
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentTeal = Color(0xFF009688);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Obtener color según tipo de pimienta
  static Color getPepperColor(PepperType type) {
    switch (type) {
      case PepperType.verde:
        return pepperGreen;
      case PepperType.seca:
        return pepperDry;
      case PepperType.madura:
        return pepperRipe;
    }
  }
  
  /// Obtener color para medalla según posición
  static Color getMedalColor(int position) {
    switch (position) {
      case 0:
        return medalGold;
      case 1:
        return medalSilver;
      case 2:
        return medalBronze;
      default:
        return textSecondary;
    }
  }
}

/// Estilos de texto
class AppTextStyles {
  static const String fontFamily = 'Roboto';
  
  // Headers
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle headline5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle headline6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
  );
  
  // Números y estadísticas
  static const TextStyle numberLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle numberMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle numberSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    fontFamily: fontFamily,
  );
}

/// Mensajes de la aplicación
class AppMessages {
  // Mensajes de éxito
  static const String successPurchaseAdded = 'Acopio registrado exitosamente';
  static const String successPurchaseUpdated = 'Acopio actualizado exitosamente';
  static const String successPurchaseDeleted = 'Acopio eliminado exitosamente';
  static const String successGoalCreated = 'Meta creada exitosamente';
  static const String successGoalUpdated = 'Meta actualizada exitosamente';
  static const String successGoalDeleted = 'Meta eliminada exitosamente';
  static const String successBackupCreated = 'Respaldo creado exitosamente';
  static const String successBackupRestored = 'Datos restaurados exitosamente';
  static const String successExportCompleted = 'Exportación completada';
  
  // Mensajes de error
  static const String errorGeneral = 'Ha ocurrido un error';
  static const String errorNetwork = 'Error de conexión';
  static const String errorDatabase = 'Error en la base de datos';
  static const String errorValidation = 'Por favor verifica los datos ingresados';
  static const String errorLoadData = 'Error al cargar los datos';
  static const String errorSaveData = 'Error al guardar los datos';
  static const String errorDeleteData = 'Error al eliminar los datos';
  static const String errorBackup = 'Error al crear respaldo';
  static const String errorRestore = 'Error al restaurar datos';
  static const String errorExport = 'Error al exportar datos';
  
  // Mensajes de confirmación
  static const String confirmDelete = '¿Estás seguro de eliminar?';
  static const String confirmDeletePurchase = '¿Eliminar este acopio?';
  static const String confirmDeleteGoal = '¿Eliminar esta meta?';
  static const String confirmDeactivateGoal = '¿Desactivar esta meta?';
  static const String confirmRestoreBackup = '¿Restaurar este respaldo? Los datos actuales serán reemplazados';
  static const String confirmDeleteBackup = '¿Eliminar este respaldo?';
  
  // Mensajes de información
  static const String infoNoData = 'No hay datos para mostrar';
  static const String infoNoPurchases = 'No hay acopios registrados';
  static const String infoNoGoals = 'No hay metas establecidas';
  static const String infoNoBackups = 'No hay respaldos disponibles';
  static const String infoLoading = 'Cargando...';
  static const String infoSaving = 'Guardando...';
  static const String infoDeleting = 'Eliminando...';
  
  // Etiquetas de formulario
  static const String labelPersonName = 'Nombre de la persona';
  static const String labelCommunity = 'Comunidad / Municipio';
  static const String labelKilos = 'Kilos';
  static const String labelPrice = 'Precio por kilo';
  static const String labelTotal = 'Total a pagar';
  static const String labelDate = 'Fecha de acopio';
  static const String labelPepperType = 'Tipo de pimienta';
  static const String labelQuality = 'Calidad';
  
  // Botones
  static const String buttonSave = 'Guardar';
  static const String buttonUpdate = 'Actualizar';
  static const String buttonCancel = 'Cancelar';
  static const String buttonDelete = 'Eliminar';
  static const String buttonEdit = 'Editar';
  static const String buttonAdd = 'Agregar';
  static const String buttonCreate = 'Crear';
  static const String buttonExport = 'Exportar';
  static const String buttonBackup = 'Respaldar';
  static const String buttonRestore = 'Restaurar';
  static const String buttonShare = 'Compartir';
  static const String buttonRefresh = 'Actualizar';
  static const String buttonRetry = 'Reintentar';
  static const String buttonClose = 'Cerrar';
  static const String buttonConfirm = 'Confirmar';
}

/// Keys para SharedPreferences
class PrefKeys {
  static const String themeMode = 'theme_mode';
  static const String lastBackupDate = 'last_backup_date';
  static const String defaultSalePrice = 'default_sale_price';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String languageCode = 'language_code';
  static const String firstLaunch = 'first_launch';
  static const String userId = 'user_id';
  static const String sessionToken = 'session_token';
}

/// Keys para análisis (Firebase Analytics)
class AnalyticsEvents {
  static const String purchaseAdded = 'purchase_added';
  static const String purchaseUpdated = 'purchase_updated';
  static const String purchaseDeleted = 'purchase_deleted';
  static const String goalCreated = 'goal_created';
  static const String goalCompleted = 'goal_completed';
  static const String backupCreated = 'backup_created';
  static const String backupRestored = 'backup_restored';
  static const String exportPerformed = 'export_performed';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String error = 'error';
}

/// Configuración de gráficas
class ChartConfig {
  static const double defaultHeight = 250;
  static const double pieChartRadius = 80;
  static const double pieChartCenterSpace = 40;
  static const double barChartWidth = 30;
  static const double lineChartBarWidth = 3;
  
  static const Duration animationDuration = Duration(milliseconds: 500);
  
  static const List<double> pieChartStops = [0.2, 0.5, 0.8];
}

/// Configuración de notificaciones
class NotificationConfig {
  static const String channelId = 'pimez_channel';
  static const String channelName = 'Notificaciones PIMEZ';
  static const String channelDescription = 'Notificaciones de la app PIMEZ';
  
  static const int idGoalProgress = 1;
  static const int idBackupReminder = 2;
  static const int idNewPurchase = 3;
  
  static const Duration reminderInterval = Duration(days: 7);
}

/// Enlaces y URLs
class AppUrls {
  static const String privacyPolicy = 'https://pimez.com/privacy';
  static const String termsOfService = 'https://pimez.com/terms';
  static const String help = 'https://pimez.com/help';
  static const String website = 'https://pimez.com';
  
  static const String apiBaseUrl = 'https://api.pimez.com/v1';
  static const String apiPurchases = '$apiBaseUrl/purchases';
  static const String apiGoals = '$apiBaseUrl/goals';
  static const String apiStats = '$apiBaseUrl/stats';
  static const String apiSync = '$apiBaseUrl/sync';
}

/// Extensiones útiles
extension DoubleExtensions on double {
  String toCurrency() {
    return '${AppConstants.currencySymbol}${toStringAsFixed(2)}';
  }
  
  String toWeight() {
    return '${toStringAsFixed(2)} ${AppConstants.weightUnit}';
  }
  
  String toPercentage() {
    return '${toStringAsFixed(1)}%';
  }
}

extension DateTimeExtensions on DateTime {
  String toDisplayDate() {
    final format = DateFormat(AppConstants.dateFormatDisplay);
    return format.format(this);
  }
  
  String toDisplayTime() {
    final format = DateFormat(AppConstants.timeFormatDisplay);
    return format.format(this);
  }
  
  String toDisplayDateTime() {
    final format = DateFormat(AppConstants.dateTimeFormatDisplay);
    return format.format(this);
  }
  
  String toStorageDate() {
    final format = DateFormat(AppConstants.dateFormatStorage);
    return format.format(this);
  }
  
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

/// Mapa de tipos de pimienta con sus propiedades
class PepperTypeInfo {
  final String name;
  final String displayName;
  final Color color;
  final IconData icon;
  
  const PepperTypeInfo({
    required this.name,
    required this.displayName,
    required this.color,
    required this.icon,
  });
  
  static final Map<PepperType, PepperTypeInfo> map = {
    PepperType.verde: PepperTypeInfo(
      name: 'verde',
      displayName: 'Verde',
      color: AppColors.pepperGreen,
      icon: Icons.grass,
    ),
    PepperType.seca: PepperTypeInfo(
      name: 'seca',
      displayName: 'Seca',
      color: AppColors.pepperDry,
      icon: Icons.dry,
    ),
    PepperType.madura: PepperTypeInfo(
      name: 'madura',
      displayName: 'Madura',
      color: AppColors.pepperRipe,
      icon: Icons.agriculture,
    ),
  };
  
  static PepperTypeInfo fromType(PepperType type) => map[type]!;
}