import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/repositories/i_report_repository.dart';

class ExportService {
  // ─────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────

  /// Print full invoice to any connected printer (laser / inkjet)
  static Future<void> printInvoice(
    ReportSummary summary,
    String periodLabel,
    List<DailySaleItem> items, {
    String adminName = 'Admin',
    String businessName = 'Copy App',
  }) async {
    final pdf = await _buildInvoicePdf(
      summary, periodLabel, items,
      adminName: adminName,
      businessName: businessName,
    );
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  /// Share full invoice PDF (opens share sheet / saves to files)
  static Future<void> shareInvoicePdf(
    ReportSummary summary,
    String periodLabel,
    List<DailySaleItem> items, {
    String adminName = 'Admin',
    String businessName = 'Copy App',
  }) async {
    final pdf = await _buildInvoicePdf(
      summary, periodLabel, items,
      adminName: adminName,
      businessName: businessName,
    );
    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${businessName.replaceAll(' ', '_')}_Invoice_$periodLabel.pdf',
    );
  }

  /// Print compact receipt to thermal printer (58mm / 80mm ESC-POS compatible)
  static Future<void> printThermalReceipt(
    ReportSummary summary,
    String periodLabel, {
    String adminName = 'Admin',
    String businessName = 'Copy App',
  }) async {
    final pdf = await _buildThermalReceipt(
      summary, periodLabel,
      adminName: adminName,
      businessName: businessName,
    );
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      // 58mm thermal paper: 164 points wide, continuous height
      format: const PdfPageFormat(164, double.infinity, marginAll: 6),
    );
  }

  /// Export summary as CSV
  static Future<void> shareCsv(
    ReportSummary summary,
    String periodLabel,
  ) async {
    final List<List<dynamic>> rows = [
      ['Copy App — Report Export'],
      ['Period', periodLabel],
      ['Generated', DateTime.now().toString()],
      [],
      ['METRIC', 'VALUE'],
      ['Net Profit', 'KES ${summary.netProfit.toStringAsFixed(2)}'],
      ['Cash Revenue', 'KES ${summary.cashRevenue.toStringAsFixed(2)}'],
      ['M-Pesa Revenue', 'KES ${summary.mpesaRevenue.toStringAsFixed(2)}'],
      ['Total Expenses', 'KES ${summary.totalExpenses.toStringAsFixed(2)}'],
      ['Today\'s Sales', 'KES ${summary.todaySales.toStringAsFixed(2)}'],
      ['Weekly Sales', 'KES ${summary.weeklySales.toStringAsFixed(2)}'],
      ['Monthly Sales', 'KES ${summary.monthlySales.toStringAsFixed(2)}'],
      ['Annual Sales', 'KES ${summary.annualSales.toStringAsFixed(2)}'],
      [],
      ['ORDERS', ''],
      ['Total Orders', summary.totalOrders],
      ['Paid Orders', summary.paidOrders],
      ['Pending Orders', summary.pendingOrders],
      ['Deliveries', summary.deliveries],
      ['Staff on Duty', summary.staffOnDuty],
      ['Low Stock Items', summary.lowStockItems],
    ];

    final csvData = rows.map((r) => r.join(',')).join('\n');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/CopyAppHotel_Report_$periodLabel.csv');
    await file.writeAsString(csvData);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      text: 'Copy App $periodLabel Report',
    ));
  }

  // ─────────────────────────────────────────────
  // INVOICE PDF BUILDER
  // ─────────────────────────────────────────────

  static Future<pw.Document> _buildInvoicePdf(
    ReportSummary summary,
    String periodLabel,
    List<DailySaleItem> items, {
    required String adminName,
    required String businessName,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    // Try to load hotel logo
    pw.ImageProvider? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/hotel_logo.jpg');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      // Logo not available — proceed without it
    }

    final headerStyle = pw.TextStyle(
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.green800,
    );
    final subHeaderStyle = pw.TextStyle(
      fontSize: 11,
      color: PdfColors.grey600,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (pw.Context context) => [
          // ── HEADER ──────────────────────────────────────
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoImage != null)
                pw.Container(
                  width: 72,
                  height: 72,
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(12),
                    color: PdfColors.black,
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 12,
                    verticalRadius: 12,
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                ),
              if (logoImage != null) pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(businessName.toUpperCase(), style: headerStyle),
                    pw.Text('Admin POS Service', style: subHeaderStyle),
                    pw.SizedBox(height: 4),
                    pw.Text('Developed by MOBAWI LLC',
                        style: pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey500)),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _pdfTag('REPORT INVOICE', PdfColors.green800),
                  pw.SizedBox(height: 6),
                  pw.Text('Date: $dateStr',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  pw.Text('Time: $timeStr',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  pw.Text('Period: $periodLabel',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.green800, thickness: 2),
          pw.SizedBox(height: 6),

          // ── META INFO ────────────────────────────────────
          pw.Row(
            children: [
              _metaBox('Prepared by', adminName),
              pw.SizedBox(width: 12),
              _metaBox('Property', businessName),
              pw.SizedBox(width: 12),
              _metaBox('Report Period', periodLabel),
            ],
          ),

          pw.SizedBox(height: 18),

          // ── FINANCIAL SUMMARY ────────────────────────────
          _pdfSectionHeader('FINANCIAL SUMMARY'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              _pdfTableHeader(['DESCRIPTION', 'AMOUNT (KES)']),
              _pdfTableRow(['Net Profit / Loss',
                  summary.netProfit >= 0
                      ? '+ ${summary.netProfit.toStringAsFixed(2)}'
                      : summary.netProfit.toStringAsFixed(2)],
                  highlight: true,
                  isProfit: summary.netProfit >= 0),
              _pdfTableRow(['Cash Revenue', summary.cashRevenue.toStringAsFixed(2)]),
              _pdfTableRow(['M-Pesa Revenue', summary.mpesaRevenue.toStringAsFixed(2)]),
              _pdfTableRow(
                ['Total Revenue',
                  (summary.cashRevenue + summary.mpesaRevenue).toStringAsFixed(2)],
                bold: true,
              ),
              _pdfTableRow(['Total Expenses', summary.totalExpenses.toStringAsFixed(2)],
                  isExpense: true),
            ],
          ),

          pw.SizedBox(height: 18),

          // ── SALES BREAKDOWN ───────────────────────────────
          _pdfSectionHeader('SALES BREAKDOWN'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              _pdfTableHeader(['PERIOD', 'SALES (KES)']),
              _pdfTableRow(["Today's Sales", summary.todaySales.toStringAsFixed(2)]),
              _pdfTableRow(['Weekly Sales', summary.weeklySales.toStringAsFixed(2)]),
              _pdfTableRow(['Monthly Sales', summary.monthlySales.toStringAsFixed(2)]),
              _pdfTableRow(['Annual Sales', summary.annualSales.toStringAsFixed(2)], bold: true),
            ],
          ),

          pw.SizedBox(height: 18),

          // ── ORDER METRICS ─────────────────────────────────
          _pdfSectionHeader('ORDER METRICS'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              _pdfTableHeader(['METRIC', 'COUNT']),
              _pdfTableRow(['Total Orders', '${summary.totalOrders}']),
              _pdfTableRow(['Paid Orders', '${summary.paidOrders}']),
              _pdfTableRow(['Pending Orders', '${summary.pendingOrders}']),
              _pdfTableRow(['Deliveries', '${summary.deliveries}']),
              _pdfTableRow(['Staff on Duty', '${summary.staffOnDuty}']),
              _pdfTableRow(['Low Stock Items', '${summary.lowStockItems}']),
            ],
          ),

          // ── ITEM SALES LIST ───────────────────────────────
          if (items.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _pdfSectionHeader('ITEMISED SALES — ${periodLabel.toUpperCase()}'),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                _pdfTableHeader(['ITEM', 'QTY', 'UNIT (KES)', 'TOTAL (KES)']),
                ...items.map((item) => _pdfTableRow([
                      item.itemName,
                      '${item.quantity}',
                      item.unitPrice.toStringAsFixed(2),
                      item.totalPrice.toStringAsFixed(2),
                    ])),
                // Totals row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _pdfCell('TOTAL', bold: true),
                    _pdfCell(
                        '${items.fold(0, (s, i) => s + i.quantity)}',
                        bold: true),
                    _pdfCell(''),
                    _pdfCell(
                        items
                            .fold(0.0, (s, i) => s + i.totalPrice)
                            .toStringAsFixed(2),
                        bold: true),
                  ],
                ),
              ],
            ),
          ],

          pw.SizedBox(height: 24),

          // ── FOOTER ───────────────────────────────────────
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated by MOBAWI LLC · Copy App Admin POS',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
              pw.Text(
                '$dateStr $timeStr',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }

  // ─────────────────────────────────────────────
  // THERMAL RECEIPT BUILDER
  // ─────────────────────────────────────────────

  static Future<pw.Document> _buildThermalReceipt(
    ReportSummary summary,
    String periodLabel, {
    required String adminName,
    required String businessName,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final centre = pw.TextAlign.center;
    final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
    final normal = const pw.TextStyle(fontSize: 9);
    final small = const pw.TextStyle(fontSize: 8);
    final dash = '─' * 28;

    pw.Widget row(String label, String value) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: normal),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ],
        );

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(164, double.infinity, marginAll: 6),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(businessName.toUpperCase(),
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold),
                textAlign: centre),
            pw.Text('Admin POS Service', style: small, textAlign: centre),
            pw.SizedBox(height: 4),
            pw.Text(dash, style: small),
            pw.Text('REPORT RECEIPT', style: bold, textAlign: centre),
            pw.Text(dash, style: small),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Date: $dateStr', style: small),
                pw.Text('Time: $timeStr', style: small),
              ],
            ),
            pw.Text('Period: $periodLabel', style: small, textAlign: centre),
            pw.Text('By: $adminName', style: small, textAlign: centre),
            pw.SizedBox(height: 4),
            pw.Text(dash, style: small),

            // Financial
            row('Net Profit', 'KES ${summary.netProfit.toStringAsFixed(0)}'),
            row('Cash', 'KES ${summary.cashRevenue.toStringAsFixed(0)}'),
            row('M-Pesa', 'KES ${summary.mpesaRevenue.toStringAsFixed(0)}'),
            row('Expenses', 'KES ${summary.totalExpenses.toStringAsFixed(0)}'),

            pw.SizedBox(height: 3),
            pw.Text(dash, style: small),

            // Orders
            row('Total Orders', '${summary.totalOrders}'),
            row('Paid', '${summary.paidOrders}'),
            row('Pending', '${summary.pendingOrders}'),
            row('Deliveries', '${summary.deliveries}'),
            row('Staff on Duty', '${summary.staffOnDuty}'),

            pw.SizedBox(height: 3),
            pw.Text('══' * 14, style: small, textAlign: centre),

            // Total Revenue line
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL REVENUE',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    'KES ${(summary.cashRevenue + summary.mpesaRevenue).toStringAsFixed(0)}',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ],
            ),

            pw.SizedBox(height: 6),
            pw.Text(dash, style: small),
            pw.SizedBox(height: 4),
            pw.Text('Thank you', style: small, textAlign: centre),
            pw.Text('MOBAWI LLC · Copy App', style: small, textAlign: centre),
            pw.SizedBox(height: 8),
          ],
        ),
      ),
    );
    return pdf;
  }

  // ─────────────────────────────────────────────
  // PDF HELPERS
  // ─────────────────────────────────────────────

  static pw.Widget _pdfSectionHeader(String title) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: const pw.BoxDecoration(color: PdfColors.green800),
        child: pw.Text(
          title,
          style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.8),
        ),
      );

  static pw.Widget _pdfTag(String text, PdfColor color) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(text,
            style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold)),
      );

  static pw.Widget _metaBox(String label, String value) => pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(
                color: PdfColors.grey200,
                width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey500)),
              pw.SizedBox(height: 2),
              pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );

  static pw.TableRow _pdfTableHeader(List<String> cols) => pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: cols
            .map((c) => _pdfCell(c,
                bold: true, color: PdfColors.grey800))
            .toList(),
      );

  static pw.TableRow _pdfTableRow(
    List<String> cols, {
    bool highlight = false,
    bool bold = false,
    bool isProfit = false,
    bool isExpense = false,
  }) {
    PdfColor? bg;
    PdfColor? textColor;
    if (highlight && isProfit) {
      bg = const PdfColor(0.93, 0.99, 0.94);
      textColor = PdfColors.green800;
    } else if (highlight && !isProfit) {
      bg = const PdfColor(1.0, 0.95, 0.95);
      textColor = PdfColors.red800;
    } else if (isExpense) {
      textColor = PdfColors.red700;
    }

    return pw.TableRow(
      decoration: bg != null ? pw.BoxDecoration(color: bg) : null,
      children: cols.asMap().entries.map((e) {
        final isFirst = e.key == 0;
        final isLast = e.key == cols.length - 1;
        return _pdfCell(
          e.value,
          bold: bold || highlight,
          color: (isLast || !isFirst) ? textColor : null,
          alignRight: !isFirst,
        );
      }).toList(),
    );
  }

  static pw.Widget _pdfCell(
    String text, {
    bool bold = false,
    PdfColor? color,
    bool alignRight = false,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: pw.Text(
          text,
          textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: bold ? pw.FontWeight.bold : null,
            color: color,
          ),
        ),
      );
}
