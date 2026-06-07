import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (pickedDate != null) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
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
        actions: [
          if (widget.transaction != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Entry'),
                    content: const Text('Are you sure you want to delete this transaction?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(widget.transaction!.id!);
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
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
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Due Date & Time'),
                      subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(_dueDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDateTime(context),
                    ),
                    SwitchListTile(
                      title: const Text('Set Reminder Notification'),
                      value: _hasReminder,
                      onChanged: (value) => setState(() => _hasReminder = value),
                    ),
                  ],
                ),
              ),
              if (widget.transaction != null) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<TransactionStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: TransactionStatus.pending, child: Text('Pending')),
                    DropdownMenuItem(value: TransactionStatus.completed, child: Text('Completed/Repaid')),
                  ],
                  onChanged: (value) => setState(() => _status = value!),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(widget.transaction == null ? 'Save Entry' : 'Update Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
