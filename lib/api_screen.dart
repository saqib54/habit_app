import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiScreen extends StatefulWidget {
  const ApiScreen({Key? key}) : super(key: key);

  @override
  _ApiScreenState createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  List<dynamic> suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        setState(() {
          suggestions = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Suggestions'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : suggestions.isEmpty
          ? const Center(child: Text('No suggestions available'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) => Card(
          elevation: 2,
          child: ListTile(
            title: Text(suggestions[index]['title']),
            subtitle: Text(suggestions[index]['body'].substring(0, 100) + '...'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Add to habits in Firestore
                FirebaseFirestore.instance.collection('habits').add({
                  'name': suggestions[index]['title'],
                  'userId': FirebaseAuth.instance.currentUser!.uid,
                  'progress': 0,
                  'createdAt': Timestamp.now(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Habit added!')),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}