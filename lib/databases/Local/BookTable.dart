import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:storyteller/requests/DeleteDocumentRequest.dart';
import 'package:http/http.dart' as http;
import '../../Models/Book.dart';
import '../../Models/Concept.dart';
import 'ConceptsTable.dart';

class Books{
  static Future<Database> getDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = '${databasesPath}your_database.db';

    // open the database or create it if it doesn't exist
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // create tables if needed
          await db.execute('''
        CREATE TABLE books (
          id INTEGER PRIMARY KEY,
          imagePath TEXT,
          path TEXT,
          title TEXT,
          currentPage INTEGER,
          postgId INTEGER
        )
      ''');
        });
  }

  static Future<List<Book>> getBooks() async{
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('books');

    return List.generate(maps.length, (index) {
      return Book(
        imagePath: maps[index]['imagePath'],
        path: maps[index]['path'],
        title: maps[index]['title'],
        currentPage: maps[index]['currentPage'],
        postgId: maps[index]['postgId']
      );
    });
  }

  static Future<void> addBook(Book newBook) async {
    final Database db = await getDatabase();

    await db.insert(
      'books',
      newBook.toMap()
    );
  }

  static Future<void> deleteBooks(List<Book> books) async {
    final Database db = await getDatabase();
    const url = 'http://localhost:8080/book';
    for (Book book in books) {
      db.delete(
        'books',
        where: 'path = ?',
        whereArgs: [book.path],
      );

      await Concepts.deleteTable(book.postgId);

      final request = DeleteDocumentRequest(id: book.postgId);
      await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
    }
  }

  static Future<void> updatePage(String path, int page) async {
    final database = await getDatabase();
    await database.update(
      'books',
      {'currentPage': page},
      where: 'path = ?',
      whereArgs: [path],
    );
  }
}