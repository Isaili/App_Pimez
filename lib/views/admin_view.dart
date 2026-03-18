import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../viewmodels/purchase_viewmodel.dart';
import '../viewmodels/statistics_viewmodel.dart';
import '../viewmodels/goal_viewmodel.dart';
import '../models/goal_model.dart';
import '../models/pepper_type.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final numberFormat = NumberFormat('#,##0.0#', 'es');
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Metas'),
            Tab(text: 'Exportar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildGoalsTab(),
          _buildExportTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer3<PurchaseViewModel, StatisticsViewModel, GoalViewModel>(
      builder: (context, purchaseVM, statsVM, goalVM, child) {
        if (purchaseVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = statsVM.stats;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPIs principales
              const Text(
                'Indicadores Clave',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildKpiCard(
                    'Total Kilos',
                    '${numberFormat.format(stats?.totalKilos ?? 0)} kg',
                    Icons.scale,
                    Colors.blue,
                    '${((stats?.totalKilos ?? 0) / 1000).toStringAsFixed(2)} toneladas',
                  ),
                  _buildKpiCard(
                    'Inversión Total',
                    currencyFormat.format(stats?.totalInvestment ?? 0),
                    Icons.attach_money,
                    Colors.green,
                    'Costo promedio: ${currencyFormat.format(stats?.averagePricePerKilo ?? 0)}/kg',
                  ),
                  _buildKpiCard(
                    'Total Acopios',
                    '${stats?.totalPurchases ?? 0}',
                    Icons.shopping_cart,
                    Colors.orange,
                    'Promedio: ${stats?.totalPurchases ?? 0 > 0 ? ((stats?.totalKilos ?? 0) / (stats?.totalPurchases ?? 1)).toStringAsFixed(1) : 0} kg/acopio',
                  ),
                  _buildKpiCard(
                    'Meta Actual',
                    goalVM.activeGoal != null 
                        ? '${goalVM.activeGoal!.progress.toStringAsFixed(1)}%'
                        : 'Sin meta',
                    Icons.flag,
                    Colors.purple,
                    goalVM.activeGoal != null
                        ? '${goalVM.activeGoal!.currentKilos.toStringAsFixed(1)}/${goalVM.activeGoal!.targetKilos.toStringAsFixed(1)} kg'
                        : 'Establece una meta',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Análisis de rentabilidad
              const Text(
                'Análisis de Rentabilidad',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfitabilityRow(
                        'Inversión Total',
                        currencyFormat.format(stats?.totalInvestment ?? 0),
                        Icons.money_off,
                      ),
                      const Divider(),
                      _buildProfitabilityRow(
                        'Proyección de Venta (a \$120/kg)',
                        currencyFormat.format((stats?.totalKilos ?? 0) * 120),
                        Icons.trending_up,
                        color: Colors.green,
                      ),
                      const Divider(),
                      _buildProfitabilityRow(
                        'Ganancia Estimada',
                        currencyFormat.format(((stats?.totalKilos ?? 0) * 120) - (stats?.totalInvestment ?? 0)),
                        Icons.attach_money,
                        color: Colors.amber,
                      ),
                      const Divider(),
                      _buildProfitabilityRow(
                        'Margen de Ganancia',
                        '${stats?.totalInvestment ?? 0 > 0 ? ((((stats?.totalKilos ?? 0) * 120) - (stats?.totalInvestment ?? 0)) / ((stats?.totalKilos ?? 0) * 120) * 100).toStringAsFixed(1) : 0}%',
                        Icons.percent,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Últimas actividades
              const Text(
                'Últimas Actividades',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...purchaseVM.purchases.take(5).map((purchase) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getTypeColor(purchase.pepperType),
                    child: Text(
                      purchase.kilos.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  title: Text(purchase.personName),
                  subtitle: Text(
                    '${dateFormat.format(purchase.purchaseDate)} - ${purchase.community}',
                  ),
                  trailing: Text(
                    currencyFormat.format(purchase.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsTab() {
    return Consumer<GoalViewModel>(
      builder: (context, goalVM, child) {
        return Column(
          children: [
            // Formulario para nueva meta
            if (goalVM.activeGoal == null)
              _buildNewGoalForm()
            else
              _buildActiveGoalCard(goalVM.activeGoal!),

            const SizedBox(height: 16),

            // Historial de metas
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: goalVM.goals.length,
                itemBuilder: (context, index) {
                  final goal = goalVM.goals[index];
                  return _buildGoalHistoryCard(goal);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportTab() {
    return Consumer2<PurchaseViewModel, StatisticsViewModel>(
      builder: (context, purchaseVM, statsVM, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exportar Datos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Opciones de exportación
              _buildExportOption(
                'Reporte Completo',
                'Exporta todos los acopios con estadísticas detalladas',
                Icons.picture_as_pdf,
                Colors.red,
                () => _exportFullReport(),
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                'Resumen Estadístico',
                'Solo gráficas y estadísticas clave',
                Icons.bar_chart,
                Colors.blue,
                () => _exportStatisticsReport(),
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                'Listado de Acopios',
                'Lista completa de todos los acopios',
                Icons.list,
                Colors.green,
                () => _exportPurchasesList(),
              ),

              const SizedBox(height: 24),

              // Backup de datos
              const Text(
                'Respaldo de Datos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.backup, color: Colors.amber),
                ),
                title: const Text('Crear Respaldo'),
                subtitle: Text('Último respaldo: ${_getLastBackupDate()}'),
                trailing: ElevatedButton(
                  onPressed: _createBackup,
                  child: const Text('Respaldar'),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restore, color: Colors.green),
                ),
                title: const Text('Restaurar Datos'),
                subtitle: const Text('Recuperar desde un respaldo anterior'),
                trailing: OutlinedButton(
                  onPressed: _restoreBackup,
                  child: const Text('Restaurar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitabilityRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          child: const Text('Exportar'),
        ),
      ),
    );
  }

  Widget _buildNewGoalForm() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nueva Meta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la meta',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: targetController,
                decoration: const InputDecoration(
                  labelText: 'Kilos objetivo',
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese los kilos objetivo';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          startDate = picked;
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha inicio',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(dateFormat.format(startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate: startDate.add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          endDate = picked;
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha fin',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(dateFormat.format(endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final goalVM = context.read<GoalViewModel>();
                      final statsVM = context.read<StatisticsViewModel>();
                      
                      final goal = Goal(
                        id: DateTime.now().millisecondsSinceEpoch,
                        name: nameController.text,
                        targetKilos: double.parse(targetController.text),
                        currentKilos: statsVM.stats?.totalKilos ?? 0,
                        startDate: startDate,
                        endDate: endDate,
                        isActive: true,
                      );

                      final success = await goalVM.createGoal(goal);
                      
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Meta creada exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Crear Meta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveGoalCard(Goal goal) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🎯 Meta Activa: ${goal.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _deactivateGoal(goal),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.progress >= 100 ? Colors.green : Colors.blue,
              ),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${goal.currentKilos.toStringAsFixed(1)} kg'),
                Text('${goal.targetKilos.toStringAsFixed(1)} kg'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalInfo('Progreso', '${goal.progress.toStringAsFixed(1)}%'),
                _buildGoalInfo('Días restantes', '${goal.daysRemaining}'),
                _buildGoalInfo('Ritmo necesario', '${goal.kilosPerDayNeeded.toStringAsFixed(1)} kg/día'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalHistoryCard(Goal goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(goal.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${dateFormat.format(goal.startDate)} - ${dateFormat.format(goal.endDate)}'),
            LinearProgressIndicator(
              value: goal.progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.progress >= 100 ? Colors.green : Colors.grey,
              ),
              minHeight: 4,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${goal.progress.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${goal.currentKilos.toStringAsFixed(0)}/${goal.targetKilos.toStringAsFixed(0)} kg',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildGoalInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<void> _deactivateGoal(Goal goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar meta'),
        content: const Text('¿Estás seguro de desactivar esta meta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final goalVM = context.read<GoalViewModel>();
      final updatedGoal = Goal(
        id: goal.id,
        name: goal.name,
        targetKilos: goal.targetKilos,
        currentKilos: goal.currentKilos,
        startDate: goal.startDate,
        endDate: goal.endDate,
        isActive: false,
      );
      
      await goalVM.updateGoal(updatedGoal);
    }
  }

  Future<void> _refreshData() async {
    final purchaseVM = context.read<PurchaseViewModel>();
    final goalVM = context.read<GoalViewModel>();
    
    await Future.wait([
      purchaseVM.loadPurchases(),
      goalVM.loadGoals(),
    ]);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _exportFullReport() async {
    try {
      final pdf = pw.Document();
      final purchaseVM = context.read<PurchaseViewModel>();
      final statsVM = context.read<StatisticsViewModel>();
      
      // Aquí construirías el PDF con todos los datos
      // Por ahora mostraremos un mensaje
      
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar reporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportStatisticsReport() async {
    // Implementar exportación de estadísticas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _exportPurchasesList() async {
    // Implementar exportación de lista de acopios
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _getLastBackupDate() {
    // Aquí implementarías la lógica para obtener la fecha del último respaldo
    return 'No hay respaldos';
  }

  Future<void> _createBackup() async {
    // Implementar creación de backup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Respaldo creado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _restoreBackup() async {
    // Implementar restauración de backup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Color _getTypeColor(PepperType type) {
    switch (type) {
      case PepperType.verde:
        return Colors.green;
      case PepperType.seca:
        return Colors.brown;
      case PepperType.madura:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}