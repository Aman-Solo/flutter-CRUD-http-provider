import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import '../screens/contact_form_screen.dart';

class ContactListScreen extends StatefulWidget{
  const ContactListScreen({Key? key}): super(key: key);

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}
class _ContactListScreenState extends State<ContactListScreen>{
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      Provider.of<ContactProvider>(context, listen: false).fetchContacts();
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts Manager'),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child){
          if(provider.isLoading && provider.contacts.isEmpty){
            return const Center(child: CircularProgressIndicator());
          }
          
          if(provider.errorMessage != null && provider.contacts.isEmpty){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: ()=> provider.fetchContacts(),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }
          if (provider.contacts.isEmpty){
            return const Center(child: Text('No Contact found'));
          }

          return RefreshIndicator(
            onRefresh: () async{
              await provider.fetchContacts();
            },
            child: ListView.builder(
              itemCount: provider.contacts.length,
              itemBuilder: (context, index){
                final contact = provider.contacts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(contact.name[0].toUpperCase()),
                    ),
                    title: Text(contact.name),
                    subtitle: Text('${contact.email}\n${contact.phone}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ContactFormScreen(contact: contact),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async{
                            final success = await provider.deleteContact(contact.id!);
                            if(success){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${contact.name} deleted')),
                              );
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.errorMessage ?? 'Failed to delete')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ContactFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}