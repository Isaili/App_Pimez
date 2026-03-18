import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/purchase_model.dart';
import '../models/pepper_type.dart';
import '../viewmodels/purchase_viewmodel.dart';

class PurchaseFormView extends StatefulWidget {
  final Purchase? purchase;
  const PurchaseFormView({super.key, this.purchase});

  @override
  State<PurchaseFormView> createState() => _PurchaseFormViewState();
}

class _PurchaseFormViewState extends State<PurchaseFormView> {
  final _formKey = GlobalKey<FormState>();
  final _personController = TextEditingController();
  final _communityController = TextEditingController();
  final _kilosController = TextEditingController();
  final _priceController = TextEditingController();
  
  PepperType _selectedType = PepperType.verde;
  String _selectedQuality = 'limpia';
  DateTime _selectedDate = DateTime.now();
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.purchase != null) {
      _personController.text = widget.purchase!.personName;
      _communityController.text = widget.purchase!.community;
      _kilosController.text = widget.purchase!.kilos.toString();
      _priceController.text = widget.purchase!.pricePerKilo.toString();
      _selectedType = widget.purchase!.pepperType;
      _selectedQuality = widget.purchase!.quality;
      _selectedDate = widget.purchase!.purchaseDate;
      _calculateTotal();
    }
  }

  void _calculateTotal() {
    double kilos = double.tryParse(_kilosController.text) ?? 0;
    double price = double.tryParse(_priceController.text) ?? 0;
    setState(() {
      _totalAmount = kilos * price;
    });
  }

  @override
  Widget build(BuildContext context) {
    final purchaseVM = context.watch<PurchaseViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.purchase == null ? 'Nuevo Acopio' : 'Editar Acopio'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo de pimienta
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de Pimienta',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: PepperType.values.map((type) {
                        return Expanded(
                          child: RadioListTile<PepperType>(
                            title: Text(type.displayName),
                            value: type,
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                            dense: true,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Calidad
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calidad',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Limpia'),
                            value: 'limpia',
                            groupValue: _selectedQuality,
                            onChanged: (value) {
                              setState(() {
                                _selectedQuality = value!;
                              });
                            },
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Con Basura'),
                            value: 'con basura',
                            groupValue: _selectedQuality,
                            onChanged: (value) {
                              setState(() {
                                _selectedQuality = value!;
                              });
                            },
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Datos del vendedor
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _personController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la persona',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _communityController,
                      decoration: const InputDecoration(
                        labelText: 'Comunidad / Municipio',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Datos del acopio
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _kilosController,
                      decoration: const InputDecoration(
                        labelText: 'Kilos',
                        prefixIcon: Icon(Icons.scale),
                        suffixText: 'kg',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateTotal(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio por kilo',
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: '\$/kg',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateTotal(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de acopio',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Total a pagar
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total a pagar:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: purchaseVM.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final purchase = Purchase(
                                id: widget.purchase?.id,
                                personName: _personController.text,
                                community: _communityController.text,
                                kilos: double.parse(_kilosController.text),
                                pricePerKilo: double.parse(_priceController.text),
                                totalAmount: _totalAmount,
                                pepperType: _selectedType,
                                quality: _selectedQuality,
                                purchaseDate: _selectedDate,
                                createdAt: widget.purchase?.createdAt ?? DateTime.now(),
                              );

                              bool success;
                              if (widget.purchase == null) {
                                success = await purchaseVM.addPurchase(purchase);
                              } else {
                                success = await purchaseVM.updatePurchase(purchase);
                              }

                              if (success && mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(widget.purchase == null 
                                        ? 'Acopio registrado exitosamente' 
                                        : 'Acopio actualizado exitosamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: purchaseVM.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.purchase == null ? 'Guardar' : 'Actualizar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _personController.dispose();
    _communityController.dispose();
    _kilosController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}