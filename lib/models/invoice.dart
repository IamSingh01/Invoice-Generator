import 'package:hive/hive.dart';
import 'client.dart';
import 'invoice_item.dart';

part 'invoice.g.dart';

@HiveType(typeId: 2)
class Invoice extends HiveObject {
  @HiveField(0)
  String invoiceNumber;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  DateTime dueDate;

  @HiveField(3)
  Client client;

  @HiveField(4)
  List<InvoiceItem> items;

  @HiveField(5)
  String currency;

  @HiveField(6)
  double discount; // Percentage or Amount? Let's say Percentage for now.

  @HiveField(7)
  bool isPaid;

  Invoice({
    required this.invoiceNumber,
    required this.date,
    required this.dueDate,
    required this.client,
    required this.items,
    this.currency = 'USD',
    this.discount = 0.0,
    this.isPaid = false,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalTax => items.fold(0, (sum, item) => sum + item.taxAmount);
  double get totalBeforeDiscount => subtotal + totalTax;
  double get discountAmount => totalBeforeDiscount * (discount / 100);
  double get total => totalBeforeDiscount - discountAmount;
}
