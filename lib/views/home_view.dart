import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/purchase_viewmodel.dart';
import '../viewmodels/statistics_viewmodel.dart';
import '../viewmodels/goal_viewmodel.dart';
import '../widgets/statistics_card.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/purchase_card.dart';
import '../widgets/animated_counter.dart';
import '../widgets/fade_in_slide.dart';
import 'purchase_form_view.dart';
import 'purchases_list_view.dart';
import 'statistics_view.dart';
import 'admin_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createView() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.pushNamed(context, '/admin');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await purchaseVM.loadPurchases();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos actualizados'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => purchaseVM.loadPurchases(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen rápido con animaciones
              FadeInSlide(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAnimatedStatColumn(
                              'Total Kilos',
                              statsVM.stats?.totalKilos ?? 0,
                              Icons.scale,
                              Colors.blue,
                              (value) => '${value.toStringAsFixed(1)} kg',
                            ),
                            _buildAnimatedStatColumn(
                              'Inversión Total',
                              statsVM.stats?.totalInvestment ?? 0,
                              Icons.attach_money,
                              Colors.green,
                              (value) => '\$${value.toStringAsFixed(2)}',
                            ),
                            _buildAnimatedStatColumn(
                              'Precio Promedio',
                              statsVM.stats?.averagePricePerKilo ?? 0,
                              Icons.trending_up,
                              Colors.orange,
                              (value) => '\$${value.toStringAsFixed(2)}/kg',
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAnimatedStatColumn(
                              'Acopios',
                              statsVM.stats?.totalPurchases ?? 0,
                              Icons.shopping_cart,
                              Colors.purple,
                              (value) => '${value.toInt()}',
                            ),
                            _buildAnimatedStatColumn(
                              'Verde',
                              statsVM.stats?.kilosByType['PepperType.verde'] ?? 0,
                              Icons.grass,
                              Colors.green,
                              (value) => '${value.toStringAsFixed(1)} kg',
                            ),
                            _buildAnimatedStatColumn(
                              'Seca',
                              statsVM.stats?.kilosByType['PepperType.seca'] ?? 0,
                              Icons.dry,
                              Colors.brown,
                              (value) => '${value.toStringAsFixed(1)} kg',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Meta activa con animación
              if (goalVM.activeGoal != null)
                FadeInSlide(
                  duration: const Duration(milliseconds: 400),
                  child: GoalProgressCard(goal: goalVM.activeGoal!),
                ),

              const SizedBox(height: 16),

              // Últimos acopios
              FadeInSlide(
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Últimos Acopios',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/purchases-list');
                      },
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Lista de últimos 3 acopios con animación
              if (purchaseVM.purchases.isNotEmpty)
                ...purchaseVM.purchases.take(3).asMap().entries.map((entry) {
                  return FadeInSlide(
                    duration: Duration(milliseconds: 600 + (entry.key * 100)),
                    child: PurchaseCard(
                      purchase: entry.value,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/purchase-form',
                          arguments: entry.value,
                        );
                      },
                    ),
                  );
                }).toList()
              else
                FadeInSlide(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay acopios registrados',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/purchase-form');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar primer acopio'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Top 3 acopios con animación
              if (statsVM.stats != null && statsVM.stats!.top3Purchases.isNotEmpty)
                FadeInSlide(
                  duration: const Duration(milliseconds: 700),
                  child: StatisticsCard(stats: statsVM.stats),
                ),

              const SizedBox(height: 16),

              // Botones de acción rápida con animación
              FadeInSlide(
                duration: const Duration(milliseconds: 800),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/purchase-form');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo Acopio'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/statistics');
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Estadísticas'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/purchase-form');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimatedStatColumn(
    String label,
    double value,
    IconData icon,
    Color color,
    String Function(double) formatter,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        AnimatedCounter(
          value: value,
          formatter: formatter,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}