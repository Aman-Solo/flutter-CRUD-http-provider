import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../services/api_service.dart';

class ContactProvider with ChangeNotifier{
  final ApiService _apiService = ApiService();

  List<Contact> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchContacts() async{
    _setLoading(true);
    try{
      _contacts = await _apiService.getContacts();
      _errorMessage = null;
    } catch(e){
      _errorMessage = e.toString();
    } finally{
      _setLoading(false);
    }
  }
  Future<bool> addContact(Contact contact) async{
    _setLoading(true);
    try{
      final newContact = await _apiService.createContact(contact);
      _contacts.insert(0, newContact);
      _errorMessage = null;
      return true;
    }catch(e){
      _errorMessage = e.toString();
      return false;
    }finally{
      _setLoading(false);
    }
  }
  Future<bool> updateContact(Contact contact) async{
    _setLoading(true);
    try{
      final updatedContact = await _apiService.updateContact(contact);
      final index = _contacts.indexWhere((c)=> c.id == contact.id);
      if(index != -1){
        _contacts[index] = updatedContact;
      }
      _errorMessage = null;
      return true;
    }catch(e){
      _errorMessage = e.toString();
      return false;
    }finally{
      _setLoading(false);
    }
  }
  Future<bool> deleteContact(int id) async{
    _setLoading(true);
    try{
      await _apiService.deleteContact(id);
      _contacts.removeWhere((c)=> c.id == id);
      _errorMessage = null;
      return true;
    }catch(e){
      _errorMessage = e.toString();
      return false;
    }finally{
      _setLoading(false);
    }
  }
  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }
}