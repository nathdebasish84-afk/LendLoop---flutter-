import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class EntryFormView extends StatefulWidget {
  final TransactionModel? transaction;
  const EntryFormView({super.key, this.transaction});

  @override
  State<EntryFormView> createState() => _EntryFormViewState();
}

class _EntryFormViewState extends State<EntryFormView> {
  final _formKey = GlobalKey<FormState>();
  late String _personName;
  late String _itemOrAmount;
  late String _description;
  late DateTime _dueDate;
  late TransactionType _type;
  late TransactionStatus _status;
  late bool _hasReminder;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _personName = t?.personName ?? '';
    _itemOrAmount = t?.itemOrAmount ?? '';
    _description = t?.description ?? '';
    _dueDate = t?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _type = t?.type ?? TransactionType.lend;
    _status = t?.status ?? TransactionStatus.pending;
    _hasReminder = t?.hasReminder ?? false;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      
      final newTransaction = TransactionModel(
        id: widget.transaction?.id,
        personName: _personName,
        itemOrAmount: _itemOrAmount,
        description: _description,
        dateCreated: widget.transaction?.dateCreated ?? DateTime.now(),
        dueDate: _dueDate,
        hasReminder: _hasReminder,
        type: _type,
        status: _status,
      );

      if (widget.transaction == null) {
        provider.addTransaction(newTransaction);
      } else {
        provider.updateTransaction(newTransaction);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Entry' : 'Edit Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.lend, label: Text('Lend'), icon: Icon(Icons.arrow_upward)),
                  ButtonSegment(value: TransactionType.borrow, label: Text('Borrow'), icon: Icon(Icons.arrow_downward)),
                ],
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _personName,
                decoration: const InputDecoration(labelText: 'Person Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _personName = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _itemOrAmount,
                decoration: const InputDecoration(labelText: 'Item or Amount', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter an item or amount' : null,
                onSaved: (value) => _itemOrAmount = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SwitchListTile(
                title: const Text('Set Reminder'),
                value: _hasReminder,
                onChanged: (value) => setState(() => _hasReminder = value),
              ),
              if (widget.transaction != null)
                DropdownButtonFormField<TransactionStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: TransactionStatus.pending, child: Text('Pending')),
                    DropdownMenuItem(value: TransactionStatus.completed, child: Text('Completed/Repaid')),
                  ],
                  onChanged: (value) => setState(() => _status = value!),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
