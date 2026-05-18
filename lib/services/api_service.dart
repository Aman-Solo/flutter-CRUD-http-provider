import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/users';  //JSONPlaceholder API for testing

  // GET: fetching all contacts
  Future<List<Contact>> getContacts() async {
    try{
      final response = await http.get(Uri.parse(baseUrl));
      if(response.statusCode == 200){
        Iterable list = json.decode(response.body);
        return list.map((model) => Contact.fromJson(model)).toList();
      } else {
        throw Exception('Failed to load contacts (Status: ${response.statusCode})');
      }
    }catch (e){
      throw Exception('Network error fetching contacts: $e');
    }
  }
  // POST: creating a new contact
  Future<Contact> createContact(Contact contact) async{
    try{
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(contact.toJson()),
      );
      if (response.statusCode == 201){
        return Contact.fromJson(json.decode(response.body));
      }else{
        throw Exception('Failed to create contact');
      }
    } catch(e){
      throw Exception('Network error creating contact: $e');
    }
  }
  //PUT: updating an existing contact
  Future<Contact> updateContact(Contact contact) async{
    try{
      final response = await http.put(
        Uri.parse('$baseUrl/${contact.id!}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(contact.toJson()),
      );
      if (response.statusCode == 200){
        return Contact.fromJson(json.decode(response.body));
      }else{
        throw Exception('Failed to update contact');
      }
    }catch(e){
      throw Exception('Network error updating contact: $e');
    }
  }
  //DELETE: deleting a contact
  Future<void> deleteContact(int id) async{
    try{
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200){
        throw Exception('Failed to delete contact');
      }
    }catch(e){
      throw Exception('Network error deleting contact: $e');
    }
  }
}