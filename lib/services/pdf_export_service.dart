import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/purchase_model.dart';
import '../models/purchase_stats.dart';
import '../models/pepper_type.dart';

class PdfExportService {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final numberFormat = NumberFormat('#,##0.0#', 'es');
  final dateFormat = DateFormat('dd/MM/yyyy');
  final timeFormat = DateFormat('HH:mm:ss');

  // Exportar reporte completo
  Future<void> exportFullReport(
    BuildContext context,
    List<Purchase> purchases,
    PurchaseStats stats,
  ) async {
    try {
      final pdf = pw.Document();

      // Página de título
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildTitlePage();
          },
        ),
      );

      // Página de resumen
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildSummaryPage(stats);
          },
        ),
      );

      // Páginas de detalles por tipo
      for (var type in PepperType.values) {
        final typePurchases = purchases
            .where((p) => p.pepperType == type)
            .toList();
        
        if (typePurchases.isNotEmpty) {
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return _buildTypeDetailPage(type, typePurchases, stats);
              },
            ),
          );
        }
      }

      // Página de listado completo
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPurchasesListPage(purchases);
          },
        ),
      );

      // Guardar o imprimir
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );

    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  // Exportar solo estadísticas
  Future<void> exportStatisticsReport(
    BuildContext context,
    PurchaseStats stats,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildStatisticsOnlyPage(stats);
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );

    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  // Exportar lista de acopios
  Future<void> exportPurchasesList(
    BuildContext context,
    List<Purchase> purchases,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildSimplePurchasesList(purchases);
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );

    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  // Guardar PDF en archivo
  Future<String> savePdfToFile(pw.Document pdf, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  // Página de título
  pw.Widget _buildTitlePage() {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Icon(
          pw.IconData(0xe567),
          size: 80,
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'PIMEZ',
          style: pw.TextStyle(
            fontSize: 40,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Sistema de Acopio de Pimienta',
          style: pw.TextStyle(fontSize: 16),
        ),
        pw.SizedBox(height: 40),
        pw.Text(
          'Reporte Completo',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Fecha de generación: ${dateFormat.format(DateTime.now())}'),
        pw.Text('Hora: ${timeFormat.format(DateTime.now())}'),
      ],
    );
  }

  // Página de resumen
  pw.Widget _buildSummaryPage(PurchaseStats stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumen General',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              _buildSummaryRow('Total Kilos', '${numberFormat.format(stats.totalKilos)} kg'),
              _buildSummaryRow('Inversión Total', currencyFormat.format(stats.totalInvestment)),
              _buildSummaryRow('Precio Promedio', '${currencyFormat.format(stats.averagePricePerKilo)}/kg'),
              _buildSummaryRow('Total Acopios', '${stats.totalPurchases}'),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Distribución por Tipo',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        ...PepperType.values.map((type) {
          final kilos = stats.kilosByType[type.toString()] ?? 0;
          final percentage = stats.totalKilos > 0 ? (kilos / stats.totalKilos * 100) : 0;
          
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 100,
                  child: pw.Text(type.displayName),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        height: 20,
                        width: pw.Metrics.percent(percentage, pw.Context()),
                        color: _getPdfColor(type),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text('${percentage.toStringAsFixed(1)}%'),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // Página de detalle por tipo
  pw.Widget _buildTypeDetailPage(PepperType type, List<Purchase> purchases, PurchaseStats stats) {
    final totalKilos = purchases.fold(0.0, (sum, p) => sum + p.kilos);
    final totalInvestment = purchases.fold(0.0, (sum, p) => sum + p.totalAmount);
    final avgPrice = totalKilos > 0 ? totalInvestment / totalKilos : 0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${type.displayName} - Detalle',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _getPdfColor(type)),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              _buildSummaryRow('Total Kilos', '${numberFormat.format(totalKilos)} kg'),
              _buildSummaryRow('Inversión', currencyFormat.format(totalInvestment)),
              _buildSummaryRow('Precio Promedio', '${currencyFormat.format(avgPrice)}/kg'),
              _buildSummaryRow('Cantidad Acopios', '${purchases.length}'),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Top 3 Acopios',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        ...purchases
            .where((p) => p.pepperType == type)
            .toList()
            ..sort((a, b) => b.kilos.compareTo(a.kilos))
            .take(3)
            .map((p) => _buildPurchaseRow(p)),
      ],
    );
  }

  // Página de listado completo
  pw.Widget _buildPurchasesListPage(List<Purchase> purchases) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Listado Completo de Acopios',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Total de registros: ${purchases.length}'),
        pw.SizedBox(height: 10),
        pw.Expanded(
          child: pw.ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              return _buildPurchaseRow(purchases[index]);
            },
          ),
        ),
      ],
    );
  }

  // Página solo estadísticas
  pw.Widget _buildStatisticsOnlyPage(PurchaseStats stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Estadísticas de Acopio',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        _buildStatsTable(stats),
        pw.SizedBox(height: 30),
        pw.Text(
          'Top 3 Acopios Generales',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        ...stats.top3Purchases.map((p) => _buildPurchaseRow(p)),
      ],
    );
  }

  // Lista simple de acopios
  pw.Widget _buildSimplePurchasesList(List<Purchase> purchases) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Listado de Acopios',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Fecha: ${dateFormat.format(DateTime.now())}'),
        pw.SizedBox(height: 20),
        pw.Expanded(
          child: pw.ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final p = purchases[index];
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(p.personName),
                    ),
                    pw.Expanded(
                      child: pw.Text('${p.kilos} kg'),
                    ),
                    pw.Expanded(
                      child: pw.Text(currencyFormat.format(p.totalAmount)),
                    ),
                    pw.Expanded(
                      child: pw.Text(dateFormat.format(p.purchaseDate)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Tabla de estadísticas
  pw.Widget _buildStatsTable(PurchaseStats stats) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        pw.TableRow(
          children: [
            _buildTableCell('Métrica', isHeader: true),
            _buildTableCell('Valor', isHeader: true),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Total Kilos'),
            _buildTableCell('${numberFormat.format(stats.totalKilos)} kg'),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Inversión Total'),
            _buildTableCell(currencyFormat.format(stats.totalInvestment)),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Precio Promedio'),
            _buildTableCell('${currencyFormat.format(stats.averagePricePerKilo)}/kg'),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Total Acopios'),
            _buildTableCell('${stats.totalPurchases}'),
          ],
        ),
        for (var type in PepperType.values)
          pw.TableRow(
            children: [
              _buildTableCell('Kilos ${type.displayName}'),
              _buildTableCell('${numberFormat.format(stats.kilosByType[type.toString()] ?? 0)} kg'),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildPurchaseRow(Purchase purchase) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  purchase.personName,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  purchase.community,
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              children: [
                pw.Text('${purchase.kilos} kg'),
                pw.Text(
                  purchase.pepperType.displayName,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(currencyFormat.format(purchase.totalAmount)),
                pw.Text(
                  dateFormat.format(purchase.purchaseDate),
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PdfColor _getPdfColor(PepperType type) {
    switch (type) {
      case PepperType.verde:
        return PdfColors.green;
      case PepperType.seca:
        return PdfColors.brown;
      case PepperType.madura:
        return PdfColors.orange;
    }
  }
}