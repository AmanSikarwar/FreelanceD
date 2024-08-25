import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  CreateProjectScreenState createState() => CreateProjectScreenState();
}

class CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Function to show a date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // To prevent overflow errors
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Project Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Project Description'),
                  maxLines: 5, // Allow multiple lines for description
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _budgetController,
                  decoration:
                      const InputDecoration(labelText: 'Budget (in ETH)'),
                  keyboardType: TextInputType.number, // Use numeric keyboard
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a budget';
                    }
                    // You can add more specific validation here (e.g., using regular expressions)
                    // to ensure it's a valid number/ETH amount
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    'Project Deadline: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                  ),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Call your smart contract function to create a project
                      // using the data from the form:
                      // - _titleController.text
                      // - _descriptionController.text
                      // - _budgetController.text
                      // - _selectedDate

                      // After successful project creation:
                      // 1. Optionally, display a success message to the user (e.g., using a SnackBar).
                      // 2. Navigate back to the project list screen:
                      // Navigator.pop(context);
                    }
                  },
                  child: const Text('Create Project'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
