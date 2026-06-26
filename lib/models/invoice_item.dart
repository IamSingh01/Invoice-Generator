import 'package:hive/hive.dart';

part 'invoice_item.g.dart';

@HiveType(typeId: 0)
class InvoiceItem extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double unitPrice;

  @HiveField(3)
  double tax; // Percentage

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.tax = 0.0,
  });

  double get subtotal => quantity * unitPrice;
  double get taxAmount => subtotal * (tax / 100);
  double get total => subtotal + taxAmount;
}
