import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favorites = [];
  User? _user; // Make it nullable to handle unauthenticated states

  @override
  void initState() {
    super.initState();
    _loadUserAndFavorites();
  }

  Future<void> _loadUserAndFavorites() async {
    // Wait for the current user to be available
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      // Handle unauthenticated state (e.g., navigate to login)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view favorites')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('${_user!.uid}_favorites') ?? [];
    });

    // Sync with Firestore
    final doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    if (doc.exists) {
      final cloudFavorites = List<String>.from(doc.data()?['favorites'] ?? []);
      if (cloudFavorites.length > favorites.length) {
        favorites = cloudFavorites;
        await prefs.setStringList('${_user!.uid}_favorites', favorites);
        setState(() {});
      }
    }
  }

  Future<void> _addFavorite(String habit) async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add favorites')),
      );
      return;
    }

    favorites.add(habit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${_user!.uid}_favorites', favorites);

    // Sync to Firestore
    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
      'favorites': favorites,
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        itemBuilder: (context, index) => Card(
          elevation: 2,
          child: ListTile(
            title: Text(favorites[index]),
          ),
        ),
      ),
      floatingActionButton: _user == null
          ? null
          : FloatingActionButton(
        backgroundColor: Colors.blue.shade800,
        onPressed: () => _addFavorite('Favorite Habit ${favorites.length + 1}'),
        child: const Icon(Icons.add),
      ),
    );
  }
}