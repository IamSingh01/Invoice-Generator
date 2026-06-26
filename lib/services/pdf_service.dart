import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../utils/currency_helper.dart';

class PdfService {
  static Future<void> generateAndPrintInvoice(Invoice invoice) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (context) => [
          _buildHeader(invoice),
          pw.SizedBox(height: 20),
          _buildClientInfo(invoice),
          pw.SizedBox(height: 20),
          _buildInvoiceItems(invoice),
          pw.Divider(),
          _buildTotal(invoice),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildHeader(Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('Invoice #: ${invoice.invoiceNumber}'),
            pw.Text('Date: ${invoice.date.toString().substring(0, 10)}'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('YOUR COMPANY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Your Address Line 1'),
            pw.Text('Your City, Country'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildClientInfo(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(invoice.client.name),
        pw.Text(invoice.client.address),
        pw.Text(invoice.client.email),
        pw.Text(invoice.client.phone),
      ],
    );
  }

  static pw.Widget _buildInvoiceItems(Invoice invoice) {
    final headers = ['Description', 'Quantity', 'Unit Price', 'Tax', 'Total'];
    final data = invoice.items.map((item) {
      return [
        item.description,
        item.quantity.toString(),
        '${CurrencyHelper.getSymbol(invoice.currency)}${item.unitPrice.toStringAsFixed(2)}',
        '${item.tax}%',
        '${CurrencyHelper.getSymbol(invoice.currency)}${item.total.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTotal(Invoice invoice) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 200,
        child: pw.Column(
          children: [
            _buildTotalRow('Subtotal', invoice.subtotal, invoice.currency),
            _buildTotalRow('Tax', invoice.totalTax, invoice.currency),
            _buildTotalRow('Discount (${invoice.discount}%)', -invoice.discountAmount, invoice.currency),
            pw.Divider(),
            _buildTotalRow('Total', invoice.total, invoice.currency, isBold: true),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, double amount, String currency, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
          pw.Text(
            '${CurrencyHelper.getSymbol(currency)}${amount.toStringAsFixed(2)}',
            style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}
