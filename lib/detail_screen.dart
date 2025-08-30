import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final String habitId;
  final String habitName;

  const DetailScreen({Key? key, required this.habitId, required this.habitName}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _progress = 0;

  Future<void> _fetchProgress() async {
    final doc = await FirebaseFirestore.instance.collection('habits').doc(widget.habitId).get();
    if (doc.exists) {
      setState(() {
        _progress = doc.data()?['progress'] ?? 0;
      });
    }
  }

  Future<void> _updateProgress() async {
    await FirebaseFirestore.instance.collection('habits').doc(widget.habitId).update({
      'progress': _progress + 1,
    });
    setState(() {
      _progress++;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.habitName} Details'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habit: ${widget.habitName}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('Progress: $_progress days'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _updateProgress,
                      child: const Text('Mark as Completed Today'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}