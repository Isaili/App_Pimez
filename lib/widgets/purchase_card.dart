import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/purchase_model.dart';

class PurchaseCard extends StatelessWidget {
  final Purchase purchase;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PurchaseCard({
    super.key,
    required this.purchase,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(purchase.pepperType),
          child: Text(
            purchase.kilos.toStringAsFixed(0),
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        title: Text(purchase.personName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${purchase.community} • ${dateFormat.format(purchase.purchaseDate)}'),
            Text(
              '${purchase.kilos.toStringAsFixed(2)} kg • ${currencyFormat.format(purchase.pricePerKilo)}/kg',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currencyFormat.format(purchase.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
        isThreeLine: true,
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
}