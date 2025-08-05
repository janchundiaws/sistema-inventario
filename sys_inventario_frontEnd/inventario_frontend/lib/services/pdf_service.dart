import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/product_movement.dart';
import 'api_service.dart';

class PdfService {
  static Future<void> generateProductMovementReport({
    String? startDate,
    String? endDate,
    int? productId,
  }) async {
    try {
      // Obtener datos del reporte
      final response = await ApiService.getProductMovementReport(
        startDate: startDate,
        endDate: endDate,
        productId: productId,
      );

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Error al obtener datos del reporte');
      }

      final reportData = response['data'];
      final report = ProductMovementReport.fromJson(reportData);

      // Crear el documento PDF
      final pdf = pw.Document();

      // Agregar páginas al PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (context) => [
            _buildHeader(report),
            pw.SizedBox(height: 20),
            _buildSummarySection(report),
            pw.SizedBox(height: 20),
            _buildMovementsTable(report),
            pw.SizedBox(height: 20),
            _buildProductSummarySection(report),
          ],
        ),
      );

      // Guardar el PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/reporte_movimiento_productos_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Abrir el PDF
      await OpenFile.open(file.path);
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  static pw.Widget _buildHeader(ProductMovementReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REPORTE DE MOVIMIENTO DE PRODUCTOS',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Sistema de Inventario',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Fecha de generación:',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  DateTime.now().toString().substring(0, 19),
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 10),
        if (report.filters != null) ...[
          pw.Text(
            'Filtros aplicados:',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Fecha inicio: ${report.filters!['start_date'] ?? 'No especificada'}',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Fecha fin: ${report.filters!['end_date'] ?? 'No especificada'}',
            style: pw.TextStyle(fontSize: 12),
          ),
          if (report.filters!['product_id'] != null)
            pw.Text(
              'Producto ID: ${report.filters!['product_id']}',
              style: pw.TextStyle(fontSize: 12),
            ),
        ],
      ],
    );
  }

  static pw.Widget _buildSummarySection(ProductMovementReport report) {
    final totals = report.totals;
    
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESUMEN GENERAL',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            children: [
              _buildSummaryCard('Total Compras', '\$${totals.totalPurchases.toStringAsFixed(2)}', PdfColors.blue),
              pw.SizedBox(width: 20),
              _buildSummaryCard('Total Ventas', '\$${totals.totalSales.toStringAsFixed(2)}', PdfColors.green),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _buildSummaryCard('Cant. Compras', totals.totalPurchaseQuantity.toString(), PdfColors.blue),
              pw.SizedBox(width: 20),
              _buildSummaryCard('Cant. Ventas', totals.totalSaleQuantity.toString(), PdfColors.green),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _buildSummaryCard('Total Movimientos', totals.totalMovements.toString(), PdfColors.grey),
              pw.SizedBox(width: 20),
              _buildSummaryCard('Ganancia Neta', '\$${(totals.totalSales - totals.totalPurchases).toStringAsFixed(2)}', 
                totals.totalSales > totals.totalPurchases ? PdfColors.green : PdfColors.red),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: color,
          border: pw.Border.all(color: color),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildMovementsTable(ProductMovementReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETALLE DE MOVIMIENTOS',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: pw.FlexColumnWidth(1.5), // Fecha
            1: pw.FlexColumnWidth(1.2), // Tipo
            2: pw.FlexColumnWidth(2.5), // Producto
            3: pw.FlexColumnWidth(1.5), // Categoría
            4: pw.FlexColumnWidth(1),   // Cantidad
            5: pw.FlexColumnWidth(1.2), // Precio
            6: pw.FlexColumnWidth(1.2), // Subtotal
          },
          children: [
            // Encabezados
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Fecha', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Tipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Categoría', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Precio', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            // Filas de datos
            ...report.movements.map((movement) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    movement.transactionDate.toIso8601String().substring(0, 10),
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: movement.movementType == 'PURCHASE' ? PdfColors.blue : PdfColors.green,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      movement.movementType == 'PURCHASE' ? 'COMPRA' : 'VENTA',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: movement.movementType == 'PURCHASE' ? PdfColors.blue : PdfColors.green,
                      ),
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    movement.productName ?? 'N/A',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    movement.categoryName ?? 'N/A',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    movement.quantity.toString(),
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '\$${movement.unitPrice.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '\$${movement.subtotal.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildProductSummarySection(ProductMovementReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RESUMEN POR PRODUCTO',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: pw.FlexColumnWidth(2.5), // Producto
            1: pw.FlexColumnWidth(1.5), // Categoría
            2: pw.FlexColumnWidth(1),   // Compra Qty
            3: pw.FlexColumnWidth(1.2), // Compra Total
            4: pw.FlexColumnWidth(1),   // Venta Qty
            5: pw.FlexColumnWidth(1.2), // Venta Total
            6: pw.FlexColumnWidth(1.2), // Ganancia
          },
          children: [
            // Encabezados
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Categoría', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Compra Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Compra Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Venta Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Venta Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Ganancia', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            // Filas de datos
            ...report.products.map((product) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    product.productName ?? 'N/A',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    product.categoryName ?? 'N/A',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    product.totalPurchased.toString(),
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '\$${product.totalPurchaseAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    product.totalSold.toString(),
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '\$${product.totalSaleAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '\$${product.netAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: product.netAmount >= 0 ? PdfColors.green : PdfColors.red,
                    ),
                  ),
                ),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }
} 