import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../presentation/providers/report_provider.dart';

class ExportService {
  static Future<void> printReport(ReportProvider summary, String periodLabel) async {
    final pdf = await _generatePdf(summary, periodLabel);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'CopyApp_Operations_Report_$periodLabel.pdf',
    );
  }

  static Future<void> sharePdf(ReportProvider summary, String periodLabel) async {
    final pdf = await _generatePdf(summary, periodLabel);
    final bytes = await pdf.save();
    
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/CopyApp_Operations_Report_$periodLabel.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Operations Report for $periodLabel');
  }

  static Future<void> shareCsv(ReportProvider summary, String periodLabel) async {
    List<List<dynamic>> rows = [
      ['Metric', 'Value'],
      ['Period', periodLabel],
      ['Total Sales', summary.amountSales],
      ['Net Profit', summary.netProfit],
      ['Cash Revenue', summary.cashOnHand],
      ['M-Pesa Revenue', summary.mpesaIncome],
      ['Total Expenses', summary.amountExpenses],
      ['Total Orders', summary.orderCount],
      ['Deliveries Revenue', summary.deliveryRevenue],
      ['Eat In Revenue', summary.eatInRevenue],
    ];

    String csvData = rows.map((row) => row.join(',')).join('\n');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/CopyApp_Operations_Report_$periodLabel.csv');
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(file.path)], text: 'Operations CSV Report for $periodLabel');
  }

  static Future<void> shareDbFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'copy_app.db');
    final file = File(path);
    
    if (await file.exists()) {
      final dir = await getTemporaryDirectory();
      final tempFile = File('${dir.path}/copy_app_export.db');
      await file.copy(tempFile.path);
      await Share.shareXFiles([XFile(tempFile.path)], text: 'Copy App Database Export');
    }
  }

  static Future<pw.Document> _generatePdf(ReportProvider summary, String periodLabel) async {
    final pdf = pw.Document();

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Copy App', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                        pw.Text('Operations Report', style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
                        pw.SizedBox(height: 8),
                        pw.Text('Period: $periodLabel', style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Generated: ${DateTime.now().toString().substring(0, 16)}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                      ],
                    ),
                    pw.Image(logoImage, width: 80, height: 80),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Header(level: 1, child: pw.Text('Financial Summary')),
                _buildTableRow('Total Sales', 'KES ${summary.amountSales.toStringAsFixed(2)}'),
                _buildTableRow('Net Profit', 'KES ${summary.netProfit.toStringAsFixed(2)}', isBold: true),
                _buildTableRow('Cash on Hand', 'KES ${summary.cashOnHand.toStringAsFixed(2)}'),
                _buildTableRow('M-Pesa Income', 'KES ${summary.mpesaIncome.toStringAsFixed(2)}'),
                _buildTableRow('Total Expenses', 'KES ${summary.amountExpenses.toStringAsFixed(2)}'),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, child: pw.Text('Operational Metrics')),
                _buildTableRow('Total Orders', '${summary.orderCount}'),
                _buildTableRow('Eat-in Revenue', 'KES ${summary.eatInRevenue.toStringAsFixed(2)}'),
                _buildTableRow('Delivery Revenue', 'KES ${summary.deliveryRevenue.toStringAsFixed(2)}'),
                pw.SizedBox(height: 40),
                pw.Divider(),
                pw.Center(
                  child: pw.Text('Generated by MOBAWI LLC Operations App', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildTableRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 14, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}
