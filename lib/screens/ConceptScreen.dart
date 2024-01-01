import 'package:storyteller/screens/ConceptBookScreen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../Models/Book.dart';
import '../databases/Local/BookTable.dart';

class ConceptScreen extends StatefulWidget {
  const ConceptScreen({super.key});

  @override
  _ConceptScreenState createState() => _ConceptScreenState();
}

class _ConceptScreenState extends State<ConceptScreen> {
  List<Book> _selectedBooks = [];
  final Set<Book> _deletingBooks = <Book>{};
  late double _screenWidth;
  late double _screenHeight;
  bool _isVisible = false;

  @override
  void initState(){
    _loadbooks();
    super.initState();
  }

  Future<void> _loadbooks() async {
    _selectedBooks = await Books.getBooks();
    setState(() {

    });
  }

  bool isItDeleting(Book book){
    if (_deletingBooks.contains(book)){
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Concepts'),
        actions: [
          (_isVisible) ? IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              List<Book> deletedBooks = [];
              for (Book book in _deletingBooks){
                final file = File(book.imagePath);
                deletedBooks.add(book);
                _selectedBooks.remove(book);
                file.delete();
              }
              setState(() {
                Books.deleteBooks(deletedBooks);
                _deletingBooks.clear();
                _isVisible = false;
              });
            },
          ) : const SizedBox(),
          (_isVisible) ? IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              _deletingBooks.clear();
              setState(() {
                _isVisible = false;
              });
            },
          ) : const SizedBox(),
          // Add more IconButton widgets as needed
        ],
      ),
      body: Scrollbar(
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: _selectedBooks.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                if (_deletingBooks.isEmpty){

                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ConceptBookScreen(book: _selectedBooks[index])));
                }
                else{
                  if (_deletingBooks.contains(_selectedBooks[index])){
                    setState(() {
                      _deletingBooks.remove(_selectedBooks[index]);
                      if (_deletingBooks.isEmpty){
                        _isVisible = false;
                      }
                    });
                  }
                  else{
                    setState(() {
                      _deletingBooks.add(_selectedBooks[index]);
                    });
                  }
                }
              },
              onLongPress: (){
                setState(() {
                  _deletingBooks.add(_selectedBooks[index]);
                  _isVisible = true;
                });
              },
              child: Container(
                color: Colors.white24,
                padding: EdgeInsets.all(8*(_screenWidth/360)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        children: [
                          Image.file(File(_selectedBooks[index].imagePath),
                              width: 120 * (_screenWidth/360),
                              height: 130 * (_screenHeight/640)),
                          (isItDeleting(_selectedBooks[index])) ?
                          Container(
                            width: 120 * (_screenWidth/360),
                            height: 130 * (_screenHeight/640),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ) : Container(
                            width: 120 * (_screenWidth/360),
                            height: 130 * (_screenHeight/640),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}