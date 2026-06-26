import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import '../models/invoice_item.dart';
import '../providers/invoice_provider.dart';
import '../utils/currency_helper.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final Invoice? invoice; // If provided, we are editing

  const CreateInvoiceScreen({super.key, this.invoice});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _invoiceNumber;
  late DateTime _date;
  late DateTime _dueDate;
  late String _currency;
  late double _discount;
  
  // Client Info
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _clientPhoneController = TextEditingController();

  List<InvoiceItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _invoiceNumber = widget.invoice!.invoiceNumber;
      _date = widget.invoice!.date;
      _dueDate = widget.invoice!.dueDate;
      _currency = widget.invoice!.currency;
      _discount = widget.invoice!.discount;
      _clientNameController.text = widget.invoice!.client.name;
      _clientEmailController.text = widget.invoice!.client.email;
      _clientAddressController.text = widget.invoice!.client.address;
      _clientPhoneController.text = widget.invoice!.client.phone;
      _items = List.from(widget.invoice!.items);
    } else {
      _invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      _date = DateTime.now();
      _dueDate = DateTime.now().add(const Duration(days: 7));
      _currency = 'USD';
      _discount = 0.0;
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientAddressController.dispose();
    _clientPhoneController.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get _totalTax => _items.fold(0, (sum, item) => sum + item.taxAmount);
  double get _totalBeforeDiscount => _subtotal + _totalTax;
  double get _discountAmount => _totalBeforeDiscount * (_discount / 100);
  double get _total => _totalBeforeDiscount - _discountAmount;

  void _addItem() async {
    final newItem = await showDialog<InvoiceItem>(
      context: context,
      builder: (context) => const AddItemDialog(),
    );
    if (newItem != null) {
      setState(() {
        _items.add(newItem);
      });
    }
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item')),
        );
        return;
      }

      final client = Client(
        name: _clientNameController.text,
        email: _clientEmailController.text,
        address: _clientAddressController.text,
        phone: _clientPhoneController.text,
      );

      final invoice = Invoice(
        invoiceNumber: _invoiceNumber,
        date: _date,
        dueDate: _dueDate,
        client: client,
        items: _items,
        currency: _currency,
        discount: _discount,
      );

      final provider = Provider.of<InvoiceProvider>(context, listen: false);
      if (widget.invoice != null) {
        // Update
        widget.invoice!.invoiceNumber = _invoiceNumber;
        widget.invoice!.date = _date;
        widget.invoice!.dueDate = _dueDate;
        widget.invoice!.client = client;
        widget.invoice!.items = _items;
        widget.invoice!.currency = _currency;
        widget.invoice!.discount = _discount;
        provider.updateInvoice(widget.invoice!);
      } else {
        provider.addInvoice(invoice);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice == null ? 'Create Invoice' : 'Edit Invoice'),
        actions: [
          TextButton(
            onPressed: _saveInvoice,
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('General Information'),
            TextFormField(
              initialValue: _invoiceNumber,
              decoration: const InputDecoration(labelText: 'Invoice Number'),
              onChanged: (v) => _invoiceNumber = v,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(_date)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(labelText: 'Currency'),
              items: CurrencyHelper.currencySymbols.keys.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (v) => setState(() => _currency = v!),
            ),
            const Divider(height: 40),
            _buildSectionTitle('Client Information'),
            TextFormField(
              controller: _clientNameController,
              decoration: const InputDecoration(labelText: 'Client Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _clientEmailController,
              decoration: const InputDecoration(labelText: 'Client Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _clientAddressController,
              decoration: const InputDecoration(labelText: 'Client Address'),
              maxLines: 2,
            ),
            TextFormField(
              controller: _clientPhoneController,
              decoration: const InputDecoration(labelText: 'Client Phone'),
              keyboardType: TextInputType.phone,
              maxLength: 15,
            ),
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Items'),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            ..._items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return ListTile(
                title: Text(item.description),
                subtitle: Text('${item.quantity} x ${CurrencyHelper.getSymbol(_currency)}${item.unitPrice}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${CurrencyHelper.getSymbol(_currency)}${item.total.toStringAsFixed(2)}'),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _items.removeAt(idx)),
                    ),
                  ],
                ),
              );
            }),
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No items added yet', style: TextStyle(fontStyle: FontStyle.italic))),
              ),
            const Divider(height: 40),
            _buildSummaryRow('Subtotal', _subtotal),
            _buildSummaryRow('Tax', _totalTax),
            TextFormField(
              initialValue: _discount.toString(),
              decoration: const InputDecoration(labelText: 'Discount (%)', suffixText: '%'),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0.0),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Total', _total, isBold: true),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
          Text(
            '${CurrencyHelper.getSymbol(_currency)}${amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14),
          ),
        ],
      ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _taxController = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Unit Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _taxController,
              decoration: const InputDecoration(labelText: 'Tax (%)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: () {
            if (_descriptionController.text.isNotEmpty && _priceController.text.isNotEmpty) {
              Navigator.pop(
                context,
                InvoiceItem(
                  description: _descriptionController.text,
                  quantity: int.tryParse(_quantityController.text) ?? 1,
                  unitPrice: double.tryParse(_priceController.text) ?? 0.0,
                  tax: double.tryParse(_taxController.text) ?? 0.0,
                ),
              );
            }
          },
          child: const Text('ADD'),
        ),
      ],
    );
  }
}
