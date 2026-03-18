import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/purchase_model.dart';
import '../models/pepper_type.dart';
import '../viewmodels/purchase_viewmodel.dart';
import '../widgets/purchase_card.dart';

class PurchasesListView extends StatefulWidget {
  const PurchasesListView({super.key});

  @override
  State<PurchasesListView> createState() => _PurchasesListViewState();
}

class _PurchasesListViewState extends State<PurchasesListView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PepperType? _selectedFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String _sortBy = 'date'; // 'date', 'kilos', 'amount'
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final purchaseVM = context.read<PurchaseViewModel>();
    await purchaseVM.loadPurchases();
  }

  List<Purchase> _getFilteredPurchases(List<Purchase> purchases) {
    return purchases.where((purchase) {
      // Filtro de búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesPerson = purchase.personName.toLowerCase().contains(query);
        final matchesCommunity = purchase.community.toLowerCase().contains(query);
        if (!matchesPerson && !matchesCommunity) return false;
      }

      // Filtro por tipo
      if (_selectedFilter != null && purchase.pepperType != _selectedFilter) {
        return false;
      }

      // Filtro por fecha
      if (_startDateFilter != null && purchase.purchaseDate.isBefore(_startDateFilter!)) {
        return false;
      }
      if (_endDateFilter != null && purchase.purchaseDate.isAfter(_endDateFilter!)) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        int comparison;
        switch (_sortBy) {
          case 'kilos':
            comparison = a.kilos.compareTo(b.kilos);
            break;
          case 'amount':
            comparison = a.totalAmount.compareTo(b.totalAmount);
            break;
          case 'date':
          default:
            comparison = a.purchaseDate.compareTo(b.purchaseDate);
        }
        return _sortAscending ? comparison : -comparison;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Acopios'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Verde'),
            Tab(text: 'Seca'),
            Tab(text: 'Madura'),
          ],
          onTap: (index) {
            setState(() {
              _selectedFilter = index == 0 ? null : PepperType.values[index - 1];
            });
          },
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por persona o comunidad...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),
                
                // Filtros rápidos
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Fecha',
                        icon: Icons.calendar_today,
                        onTap: _showDateFilterDialog,
                        isActive: _startDateFilter != null || _endDateFilter != null,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Ordenar',
                        icon: _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        onTap: _showSortDialog,
                        isActive: true,
                      ),
                      if (_startDateFilter != null || _endDateFilter != null || _selectedFilter != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilter = null;
                                _startDateFilter = null;
                                _endDateFilter = null;
                                _sortBy = 'date';
                                _sortAscending = false;
                              });
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de acopios
          Expanded(
            child: Consumer<PurchaseViewModel>(
              builder: (context, purchaseVM, child) {
                if (purchaseVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (purchaseVM.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${purchaseVM.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredPurchases = _getFilteredPurchases(purchaseVM.purchases);

                if (filteredPurchases.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedFilter != null
                              ? 'No se encontraron resultados'
                              : 'No hay acopios registrados',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        if (_searchQuery.isNotEmpty || _selectedFilter != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _selectedFilter = null;
                              });
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPurchases.length,
                  itemBuilder: (context, index) {
                    final purchase = filteredPurchases[index];
                    return PurchaseCard(
                      purchase: purchase,
                      onTap: () => _showPurchaseDetails(context, purchase),
                      onDelete: () => _confirmDelete(context, purchase),
                    );
                  },
                );
              },
            ),
          ),
        ],
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

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isActive,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.green.shade100,
    );
  }

  Future<void> _showDateFilterDialog() async {
    final DateTime? start = await showDatePicker(
      context: context,
      initialDate: _startDateFilter ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha inicial',
    );

    if (start != null) {
      final DateTime? end = await showDatePicker(
        context: context,
        initialDate: _endDateFilter ?? DateTime.now(),
        firstDate: start,
        lastDate: DateTime.now(),
        helpText: 'Seleccionar fecha final',
      );

      if (end != null) {
        setState(() {
          _startDateFilter = start;
          _endDateFilter = end;
        });
      }
    }
  }

  Future<void> _showSortDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordenar por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Fecha'),
              leading: Radio<String>(
                value: 'date',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Kilos'),
              leading: Radio<String>(
                value: 'kilos',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Monto total'),
              leading: Radio<String>(
                value: 'amount',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Orden ascendente'),
              value: _sortAscending,
              onChanged: (value) {
                setState(() => _sortAscending = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDetails(BuildContext context, Purchase purchase) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getTypeColor(purchase.pepperType),
                      radius: 30,
                      child: Text(
                        purchase.kilos.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            purchase.personName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            purchase.community,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Tipo', purchase.pepperType.displayName),
                _buildDetailRow('Calidad', purchase.quality),
                _buildDetailRow('Kilos', '${purchase.kilos.toStringAsFixed(2)} kg'),
                _buildDetailRow('Precio/kg', '\$${purchase.pricePerKilo.toStringAsFixed(2)}'),
                _buildDetailRow('Total', '\$${purchase.totalAmount.toStringAsFixed(2)}',
                    isHighlighted: true),
                _buildDetailRow('Fecha de acopio',
                    '${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year}'),
                _buildDetailRow('Registrado',
                    '${purchase.createdAt.hour}:${purchase.createdAt.minute} - ${purchase.createdAt.day}/${purchase.createdAt.month}/${purchase.createdAt.year}'),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/purchase-form',
                            arguments: purchase,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Editar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlighted ? 18 : 16,
              color: isHighlighted ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Purchase purchase) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar el acopio de ${purchase.personName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final purchaseVM = context.read<PurchaseViewModel>();
      final success = await purchaseVM.deletePurchase(purchase.id!);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Acopio de ${purchase.personName} eliminado'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    _searchController.dispose();
    super.dispose();
  }
}