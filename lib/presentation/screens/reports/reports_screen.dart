import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../providers/report_provider.dart';
import '../../widgets/custom_widgets.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        actions: [
          IconButton(
            onPressed: () => context.read<ReportProvider>().refreshReports(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, report, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Sales',
                        value: 'KES ${report.totalSales.toStringAsFixed(0)}',
                        icon: Icons.payments,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        label: 'Expenses',
                        value: 'KES ${report.totalExpenses.toStringAsFixed(0)}',
                        icon: Icons.money_off,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Net Profit', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          SizedBox(height: 4),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'KES ${report.netProfit.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInsightTile(
                  context,
                  title: 'Order Volume',
                  subtitle: 'Total orders processed today',
                  value: report.orderCount.toString(),
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'EXPORT AS PDF REPORT',
                  onTap: () => _generatePdf(context, report),
                  icon: Icons.picture_as_pdf,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Center(
                    child: Text('PRINT SHIFT SUMMARY', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightTile(BuildContext context, {required String title, required String subtitle, required String value, required IconData icon, required Color color}) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context, ReportProvider report) async {
    final pdf = pw.Document();
    final today = DateFormat('MMM dd, yyyy').format(DateTime.now());
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'EUTON HOTEL - Daily Financial Report'),
            pw.Text('Date: $today'),
            pw.SizedBox(height: 30),
            pw.TableHelper.fromTextArray(
              headers: ['Metric', 'Amount (KES)'],
              data: [
                ['Total Sales', report.totalSales.toStringAsFixed(2)],
                ['Total Expenses', report.totalExpenses.toStringAsFixed(2)],
                ['Net Profit', report.netProfit.toStringAsFixed(2)],
                ['Total Orders', report.orderCount.toString()],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellHeight: 30,
              cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
            ),
            pw.SizedBox(height: 50),
            pw.Divider(),
            pw.Text('Generated on: ${DateTime.now()}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}

