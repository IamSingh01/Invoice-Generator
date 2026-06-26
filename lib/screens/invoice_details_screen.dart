import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import '../services/pdf_service.dart';
import '../utils/currency_helper.dart';
import 'create_invoice_screen.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${invoice.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateInvoiceScreen(invoice: invoice)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Invoice'),
                  content: const Text('Are you sure you want to delete this invoice?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                Provider.of<InvoiceProvider>(context, listen: false).deleteInvoice(invoice);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Invoice Number', invoice.invoiceNumber),
                    _buildInfoRow('Date', DateFormat('MMM dd, yyyy').format(invoice.date)),
                    _buildInfoRow('Due Date', DateFormat('MMM dd, yyyy').format(invoice.dueDate)),
                    _buildInfoRow('Status', invoice.isPaid ? 'PAID' : 'UNPAID', color: invoice.isPaid ? Colors.green : Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Client Info'),
            Card(
              child: ListTile(
                title: Text(invoice.client.name),
                subtitle: Text('${invoice.client.email}\n${invoice.client.phone}\n${invoice.client.address}'),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Items'),
            Card(
              child: Column(
                children: [
                  ...invoice.items.map((item) => ListTile(
                    title: Text(item.description),
                    subtitle: Text('${item.quantity} x ${CurrencyHelper.getSymbol(invoice.currency)}${item.unitPrice}'),
                    trailing: Text('${CurrencyHelper.getSymbol(invoice.currency)}${item.total.toStringAsFixed(2)}'),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Summary'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', invoice.subtotal, invoice.currency),
                    _buildSummaryRow('Tax', invoice.totalTax, invoice.currency),
                    _buildSummaryRow('Discount (${invoice.discount}%)', -invoice.discountAmount, invoice.currency),
                    const Divider(),
                    _buildSummaryRow('Total', invoice.total, invoice.currency, isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => PdfService.generateAndPrintInvoice(invoice),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('GENERATE PDF & PRINT'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, String currency, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
          Text(
            '${CurrencyHelper.getSymbol(currency)}${amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14),
          ),
        ],
      ),
    );
  }
}
