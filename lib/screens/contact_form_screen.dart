import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';

class ContactFormScreen extends StatefulWidget{
  final Contact? contact;
  const ContactFormScreen({Key? key, this.contact}) : super(key: key);

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}
class _ContactFormScreenState extends State<ContactFormScreen>{
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState(){
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
  }
  @override
  void dispose(){
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  void _saveForm() async{
    if(!_formKey.currentState!.validate()) return;
    setState((){
      _isSaving = true;
    });
    final provider = Provider.of<ContactProvider>(context, listen: false);

    final newContact = Contact(
      id: widget.contact?.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    bool success;
    if (widget.contact == null){
      success = await provider.addContact(newContact);
    }else {
      success = await provider.updateContact(newContact);
    }
    setState((){
      _isSaving = false;
    });

    if (success && mounted){
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.contact == null ? 'Contact added!' : 'Contact updated!')),
      );
    }else if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'An error occurred')),
      );
    }
  }
  @override
  Widget build(BuildContext context){
    final isEditing = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Contact' : 'Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType:TextInputType.emailAddress,
                validator: (value){
                  if (value == null || value.isEmpty) return 'Please enter an email';
                  if (!value.contains('@')) return 'Please enter a valid email';
                  return null;
                }
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value)=> value == null || value.isEmpty ? 'Please enter a phone number' : null,
              ),
              const SizedBox(height: 30),
              _isSaving ? const CircularProgressIndicator() : ElevatedButton(
                onPressed: _saveForm,
                child: Text(isEditing ? 'Update Contact' : 'Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}