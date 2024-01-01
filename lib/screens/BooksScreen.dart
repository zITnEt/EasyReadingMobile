import 'dart:convert';
import 'package:http/http.dart';
import 'package:storyteller/ErrorAnouncer.dart';
import 'package:storyteller/abbreviations/Pictures.dart';
import 'package:storyteller/requests/CreateDocumentRequest.dart';
import 'package:storyteller/screens/EasyReadingScreen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../Models/Book.dart';
import '../databases/Local/BookTable.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> _selectedBooks = [];
  final Set<Book> _deletingBooks = <Book>{};
  final Map<String, Book> _books = {};
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
    for (int i = 0; i < _selectedBooks.length; i++){
      _books[_selectedBooks[i].path] = _selectedBooks[i];
    }
    setState(() {

    });
  }

  Future<void> _pickBooks() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        List<File> pickedFiles = result.paths.map((path) => File(path!)).toList();
        await _loadBooks(pickedFiles);
      }
    } catch (e) {
      print('Error picking books: $e');
    }
  }

  bool isItDeleting(Book book){
    if (_deletingBooks.contains(book)){
      return true;
    }
    return false;
  }

  Future<void> _loadBooks(List<File> pdfFiles) async {
    List<Book> books = [];

    for (File pdfFile in pdfFiles) {
      final brokenPath = pdfFile.path.split(Platform.pathSeparator).last.split('.');
      String title = '';
      for (int i = 0; i < brokenPath.length; i++){
        if (i != 0 && brokenPath[i] != 'pdf'){
          title += '.';
        }
        if (brokenPath[i] != 'pdf'){
          title += brokenPath[i];
        }
      }

      if (_books.containsKey(title)){
        continue;
      }

      final String imagePath = await generateImage(pdfFile.path, title);
      if (!_books.containsKey(title)){
        const url = 'http://localhost:8080/document';
        pdfx.PdfDocument document = await pdfx.PdfDocument.openFile(pdfFile.path);
        CreateDocumentRequest request = CreateDocumentRequest(title: title, pagesCount: (document.pagesCount));
        await document.close();
        Response response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode(request));

        if (response.statusCode != 200){
          ErrorAnouncer.showErrorDialog("Something went wrong\nTry again", context);
        }

        _books[title] = Book(postgId: int.parse(response.body), path: pdfFile.path, title: title, imagePath: imagePath, currentPage: 0);
        books.add(_books[title]!);
        Books.addBook(_books[title]!);
      }
    }

    setState(() {
      _selectedBooks.addAll(books); // Update the list of selected books
    });
  }


  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Books'),
          actions: [
            (_isVisible) ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                List<Book> deletedBooks = [];
                for (Book book in _deletingBooks){
                  final file = File(book.imagePath);
                  _books.remove(book.path);
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
                    PdfDocument pdfDocument = PdfDocument(inputBytes: File(_selectedBooks[index].path).readAsBytesSync());
                    PdfTextExtractor extractor = PdfTextExtractor(pdfDocument);

                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => EasyReadingScreen(extractor: extractor, book: _selectedBooks[index], document: pdfDocument, pages: pdfDocument.pages.count)));
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
                  margin: EdgeInsets.all(8*(_screenWidth/360)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
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
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await _pickBooks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<String> generateImage(String pdfPath, String title) async{
  pdfx.PdfDocument pdfDocument = await pdfx.PdfDocument.openFile(pdfPath);
  final pdfPage = await pdfDocument.getPage(1);
  final pdfPageImage = await pdfPage.render(width: pdfPage.width, height: pdfPage.height);
  final Uint8List? bytes = pdfPageImage?.bytes;
  String filePath = '';
  final appDocumentDir = await getApplicationDocumentsDirectory();

  if (bytes != null){
    filePath = path.join(appDocumentDir.path, '$title.png');
    final img.Image image = img.decodeImage(bytes)!;
    List<int> pngBytes = img.encodePng(image);
    final directory = Directory(appDocumentDir.path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    File file = File(filePath);
    await file.create();
    await file.writeAsBytes(pngBytes);
    filePath = file.path;
  }
  else{
    filePath = PicAbbrvs.noimage;
  }
  pdfPage.close();
  pdfDocument.close();
  return filePath;
}