import 'package:flutter/material.dart';
import '../Models/Book.dart';
import '../Models/Concept.dart';
import '../databases/Local/ConceptsTable.dart';


class ConceptBookScreen extends StatefulWidget {
  final Book book;

  const ConceptBookScreen({super.key, required this.book});

  @override
  _ConceptBookScreenState createState() => _ConceptBookScreenState();
}

class _ConceptBookScreenState extends State<ConceptBookScreen> {
  List<Concept> _concepts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConcepts();
  }

  Future<void> _loadConcepts() async {
    try {
      var concepts = await Concepts.getConcepts(widget.book.postgId);
      setState(() {
        _concepts = concepts;
        _isLoading = false;
      });
    } catch (e) {
      // Handle the error or show an error message
      print('Error loading concepts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book.title} Concepts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _concepts.length,
        itemBuilder: (context, index) {
          return Container(
            color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
            child: ListTile(
              title: Text(_concepts[index].concept),
              subtitle: Text(_concepts[index].definition),
            ),
          );
        },
      ),
    );
  }
}
