import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/purchase_viewmodel.dart';
import '../viewmodels/statistics_viewmodel.dart';
import '../viewmodels/goal_viewmodel.dart';
import '../widgets/statistics_card.dart';
import '../widgets/goal_progress_card.dart';
import 'purchase_form_view.dart';
import 'purchases_list_view.dart';
import 'statistics_view.dart';
import 'admin_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final purchaseVM = context.watch<PurchaseViewModel>();
    final statsVM = context.watch<StatisticsViewModel>();
    final goalVM = context.watch<GoalViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PIMEZ - Acopio de Pimienta'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminView()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await purchaseVM.loadPurchases();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen rápido
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            'Total Kilos',
                            '${statsVM.stats?.totalKilos.toStringAsFixed(2) ?? '0'} kg',
                            Icons.scale,
                          ),
                          _buildStatColumn(
                            'Inversión Total',
                            '\$${statsVM.stats?.totalInvestment.toStringAsFixed(2) ?? '0'}',
                            Icons.attach_money,
                          ),
                          _buildStatColumn(
                            'Precio Promedio',
                            '\$${statsVM.stats?.averagePricePerKilo.toStringAsFixed(2) ?? '0'}/kg',
                            Icons.trending_up,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            'Acopios',
                            '${statsVM.stats?.totalPurchases ?? 0}',
                            Icons.shopping_cart,
                          ),
                          _buildStatColumn(
                            'Verde',
                            '${statsVM.stats?.kilosByType['PepperType.verde']?.toStringAsFixed(1) ?? '0'} kg',
                            Icons.grass,
                          ),
                          _buildStatColumn(
                            'Seca',
                            '${statsVM.stats?.kilosByType['PepperType.seca']?.toStringAsFixed(1) ?? '0'} kg',
                            Icons.dry,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Meta activa
              if (goalVM.activeGoal != null)
                GoalProgressCard(goal: goalVM.activeGoal!),

              const SizedBox(height: 16),

              // Últimos acopios
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Últimos Acopios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PurchasesListView()),
                      );
                    },
                    child: const Text('Ver todos'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Lista de últimos 3 acopios
              if (purchaseVM.purchases.isNotEmpty)
                ...purchaseVM.purchases.take(3).map((purchase) => PurchaseCard(
                  purchase: purchase,
                  onTap: () {
                    // Navegar a detalle
                  },
                )).toList()
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No hay acopios registrados'),
                  ),
                ),

              const SizedBox(height: 16),

              // Top 3 acopios
              StatisticsCard(stats: statsVM.stats),

              const SizedBox(height: 16),

              // Botones de acción rápida
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PurchaseFormView()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo Acopio'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StatisticsView()),
                        );
                      },
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('Estadísticas'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}