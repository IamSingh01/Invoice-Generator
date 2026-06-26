import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/invoice.dart';

class InvoiceProvider with ChangeNotifier {
  static const String boxName = 'invoices';
  List<Invoice> _invoices = [];

  List<Invoice> get invoices => _invoices;

  Future<void> init() async {
    final box = await Hive.openBox<Invoice>(boxName);
    _invoices = box.values.toList();
    notifyListeners();
  }

  Future<void> addInvoice(Invoice invoice) async {
    final box = Hive.box<Invoice>(boxName);
    await box.add(invoice);
    _invoices = box.values.toList();
    notifyListeners();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    await invoice.save();
    notifyListeners();
  }

  Future<void> deleteInvoice(Invoice invoice) async {
    await invoice.delete();
    final box = Hive.box<Invoice>(boxName);
    _invoices = box.values.toList();
    notifyListeners();
  }

  List<Invoice> searchInvoices(String query) {
    return _invoices.where((invoice) =>
        invoice.invoiceNumber.toLowerCase().contains(query.toLowerCase()) ||
        invoice.client.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
