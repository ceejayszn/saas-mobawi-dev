import 'package:flutter/material.dart';

class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({super.key});

  @override
  State<MemberRegistrationScreen> createState() => _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _notesController = TextEditingController();

  String _gender = 'Male';
  String _membershipPackage = 'Monthly Basic - \$30';
  DateTime _startDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _emergencyContactController.dispose();
    _medicalConditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _expiryDate = picked.add(const Duration(days: 30)); // Default 30 days
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Simulate member generation
      final memberNumber = 'MEM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Registration Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Member Name: ${_firstNameController.text} ${_lastNameController.text}'),
              Text('Member Number: $memberNumber'),
              Text('Membership Package: $_membershipPackage'),
              Text('Expiry Date: ${_expiryDate.toLocal().toString().split(' ')[0]}'),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_2, size: 100),
                      const SizedBox(height: 8),
                      Text(memberNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
                _firstNameController.clear();
                _lastNameController.clear();
                _phoneController.clear();
                _nationalIdController.clear();
                _emergencyContactController.clear();
                _medicalConditionsController.clear();
                _notesController.clear();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Details', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name *', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Enter first name' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name *', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Enter last name' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number *', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nationalIdController,
                      decoration: const InputDecoration(labelText: 'National ID / Passport', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                      items: ['Male', 'Female', 'Other']
                          .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                          .toList(),
                      onChanged: (value) => setState(() => _gender = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(labelText: 'Emergency Contact Phone *', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Enter emergency contact' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text('Medical & Notes', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalConditionsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Medical Conditions / Allergies',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'General Notes',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              Text('Membership Package & Scheduling', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _membershipPackage,
                      decoration: const InputDecoration(labelText: 'Membership Plan', border: OutlineInputBorder()),
                      items: [
                        'Monthly Basic - \$30',
                        'Monthly Premium (with Trainer) - \$60',
                        'Quarterly Pass - \$80',
                        'Annual Membership - \$280',
                      ].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
                      onChanged: (value) => setState(() => _membershipPackage = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start Date', border: OutlineInputBorder()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_startDate.toLocal()}'.split(' ')[0]),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Register & Issue Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
