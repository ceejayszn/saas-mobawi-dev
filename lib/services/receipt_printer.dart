import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kiosk_models.dart';

class ReceiptPrinterService {
  static Future<void> printOrderReceipt(KioskOrder order, List<Sale> items) async {
    final prefs = await SharedPreferences.getInstance();
    int receiptNo = (prefs.getInt('receipt_count') ?? 0) + 1;
    await prefs.setInt('receipt_count', receiptNo);

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2, style: pw.BorderStyle.dashed),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Text('EUTON HOTEL', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('TILL NUMBER: 3502567', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Receipt No: $receiptNo', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 10),

                // Order Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Order #${order.sequenceId}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(order.createdAt.toString().split('.')[0]),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('Served by: ${order.cashierName.toUpperCase()}'),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 10),

                // Items
                ...items.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text('${item.quantity}x Item #${item.itemId}'), 
                        ),
                        pw.Text('KES ${item.total.toStringAsFixed(0)}'),
                      ],
                    ),
                  );
                }),

                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 10),

                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('KES ${order.total.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(order.paymentMethod.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                if (order.checkoutRequestId.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Trx ID:', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text(order.checkoutRequestId, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],

                pw.SizedBox(height: 20),
                // Cool Logo Placeholder (cutlery icon)
                pw.Text('🍽️', style: const pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 10),
                pw.Text('Thank you for dining with us!', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Receipt_${order.sequenceId}',
    );
  }
}
