import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _habitController = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> _getHabits() {
    return FirebaseFirestore.instance
        .collection('habits')
        .where('userId', isEqualTo: _user!.uid)
        .snapshots();
  }

  Future<void> _addHabit() async {
    if (_habitController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('habits').add({
        'name': _habitController.text,
        'userId': _user!.uid,
        'progress': 0,
        'createdAt': Timestamp.now(),
      });
      _habitController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 10),
            const Text('Habit App'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _habitController,
                    decoration: InputDecoration(
                      labelText: 'Add New Habit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addHabit,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getHabits(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading habits'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final habits = snapshot.data?.docs ?? [];
                return ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habitData = habits[index].data() as Map<String, dynamic>;
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(habitData['name']),
                        subtitle: Text('Progress: ${habitData['progress']} days'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                habitId: habits[index].id,
                                habitName: habitData['name'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade800),
              child: Text(
                _user?.displayName ?? 'User',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            ListTile(
              title: const Text('Habit Suggestions (API)'),
              onTap: () {
                Navigator.pushNamed(context, '/api');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }
}