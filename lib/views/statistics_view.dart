import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../viewmodels/statistics_viewmodel.dart';
import '../models/pepper_type.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final numberFormat = NumberFormat('#,##0.0#', 'es');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Gráficas'),
            Tab(text: 'Detalle'),
          ],
        ),
      ),
      body: Consumer<StatisticsViewModel>(
        builder: (context, statsVM, child) {
          if (statsVM.stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralTab(statsVM),
              _buildChartsTab(statsVM),
              _buildDetailTab(statsVM),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGeneralTab(StatisticsViewModel statsVM) {
    final stats = statsVM.stats!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjetas de resumen
          _buildSummaryCard(
            'Total Kilos Acopiados',
            '${numberFormat.format(stats.totalKilos)} kg',
            Icons.scale,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Inversión Total',
            currencyFormat.format(stats.totalInvestment),
            Icons.attach_money,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Precio Promedio',
            '${currencyFormat.format(stats.averagePricePerKilo)}/kg',
            Icons.trending_up,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Total de Acopios',
            '${stats.totalPurchases}',
            Icons.shopping_cart,
            Colors.purple,
          ),

          const SizedBox(height: 24),

          // Distribución por tipo
          const Text(
            'Distribución por Tipo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...PepperType.values.map((type) {
            final kilos = stats.kilosByType[type.toString()] ?? 0;
            final percentage = stats.totalKilos > 0 
                ? (kilos / stats.totalKilos * 100) 
                : 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text('${numberFormat.format(kilos)} kg'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTypeColor(type),
                    ),
                    minHeight: 8,
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Top 3 acopios
          const Text(
            'Top 3 Acopios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...stats.top3Purchases.asMap().entries.map((entry) {
            final index = entry.key;
            final purchase = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getMedalColor(index),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase.personName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${purchase.kilos.toStringAsFixed(2)} kg • ${purchase.pepperType.displayName}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(purchase.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${currencyFormat.format(purchase.pricePerKilo)}/kg',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildChartsTab(StatisticsViewModel statsVM) {
    final stats = statsVM.stats!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gráfico de pastel - Kilos por tipo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distribución de Kilos por Tipo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(statsVM),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildPieLegend(statsVM),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Gráfico de barras - Inversión por tipo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inversión por Tipo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: stats.investmentByType.values.fold(0.0, (max, e) => e > max ? e : max) * 1.1,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  currencyFormat.format(value).replaceAll('\$', ''),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('Verde', style: TextStyle(fontSize: 12));
                                  case 1:
                                    return const Text('Seca', style: TextStyle(fontSize: 12));
                                  case 2:
                                    return const Text('Madura', style: TextStyle(fontSize: 12));
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: stats.investmentByType['PepperType.verde'] ?? 0,
                                color: Colors.green,
                                width: 30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: stats.investmentByType['PepperType.seca'] ?? 0,
                                color: Colors.brown,
                                width: 30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: stats.investmentByType['PepperType.madura'] ?? 0,
                                color: Colors.orange,
                                width: 30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Evolución de acopios (línea de tiempo)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Evolución de Acopios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: stats.totalKilos,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _buildTimeSeriesSpots(context),
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.1),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()} kg',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTab(StatisticsViewModel statsVM) {
    final stats = statsVM.stats!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análisis Detallado',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Tarjetas de análisis
          _buildAnalysisCard(
            'Kilos por Tipo',
            Icons.pie_chart,
            Colors.blue,
            Column(
              children: PepperType.values.map((type) {
                final kilos = stats.kilosByType[type.toString()] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(type.displayName),
                      Text(
                        '${numberFormat.format(kilos)} kg',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          _buildAnalysisCard(
            'Inversión por Tipo',
            Icons.attach_money,
            Colors.green,
            Column(
              children: PepperType.values.map((type) {
                final investment = stats.investmentByType[type.toString()] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(type.displayName),
                      Text(
                        currencyFormat.format(investment),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          _buildAnalysisCard(
            'Precios Promedio por Tipo',
            Icons.trending_up,
            Colors.orange,
            Column(
              children: PepperType.values.map((type) {
                final purchases = context.read<PurchaseViewModel>().purchases
                    .where((p) => p.pepperType == type)
                    .toList();
                
                double avgPrice = 0;
                if (purchases.isNotEmpty) {
                  avgPrice = purchases.map((p) => p.pricePerKilo).reduce((a, b) => a + b) / purchases.length;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(type.displayName),
                      Text(
                        '${currencyFormat.format(avgPrice)}/kg',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Estadísticas adicionales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Adicional',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Total de transacciones', '${stats.totalPurchases}'),
                  _buildInfoRow('Kilo más caro', currencyFormat.format(
                    context.read<PurchaseViewModel>().purchases
                        .map((p) => p.pricePerKilo)
                        .fold(0.0, (max, e) => e > max ? e : max)
                  )),
                  _buildInfoRow('Kilo más barato', currencyFormat.format(
                    context.read<PurchaseViewModel>().purchases
                        .map((p) => p.pricePerKilo)
                        .fold(double.infinity, (min, e) => e < min ? e : min)
                  )),
                  _buildInfoRow('Acopio más grande',
                      '${context.read<PurchaseViewModel>().purchases
                          .map((p) => p.kilos)
                          .fold(0.0, (max, e) => e > max ? e : max)} kg'),
                  _buildInfoRow('Comunidad más frecuente', _getMostFrequentCommunity(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(String title, IconData icon, Color color, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(StatisticsViewModel statsVM) {
    final stats = statsVM.stats!;
    final colors = [Colors.green, Colors.brown, Colors.orange];
    
    return PepperType.values.asMap().entries.map((entry) {
      final index = entry.key;
      final type = entry.value;
      final value = stats.kilosByType[type.toString()] ?? 0;
      
      return PieChartSectionData(
        value: value,
        title: value > 0 ? '${((value / stats.totalKilos) * 100).toStringAsFixed(1)}%' : '',
        color: colors[index],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildPieLegend(StatisticsViewModel statsVM) {
    final stats = statsVM.stats!;
    final colors = [Colors.green, Colors.brown, Colors.orange];
    
    return PepperType.values.asMap().entries.map((entry) {
      final index = entry.key;
      final type = entry.value;
      final value = stats.kilosByType[type.toString()] ?? 0;
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(type.displayName),
            ),
            Text(
              '${numberFormat.format(value)} kg',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<FlSpot> _buildTimeSeriesSpots(BuildContext context) {
    final purchases = context.read<PurchaseViewModel>().purchases;
    if (purchases.isEmpty) return [];

    // Agrupar por mes
    final Map<String, double> monthlyKilos = {};
    for (var purchase in purchases) {
      final key = '${purchase.purchaseDate.year}-${purchase.purchaseDate.month}';
      monthlyKilos[key] = (monthlyKilos[key] ?? 0) + purchase.kilos;
    }

    final sortedMonths = monthlyKilos.keys.toList()..sort();
    
    return sortedMonths.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  String _getMostFrequentCommunity(BuildContext context) {
    final purchases = context.read<PurchaseViewModel>().purchases;
    if (purchases.isEmpty) return 'N/A';

    final communityCount = <String, int>{};
    for (var purchase in purchases) {
      communityCount[purchase.community] = (communityCount[purchase.community] ?? 0) + 1;
    }

    final mostFrequent = communityCount.entries.reduce((a, b) => 
      a.value > b.value ? a : b
    );

    return mostFrequent.key;
  }

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.grey;
    }
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