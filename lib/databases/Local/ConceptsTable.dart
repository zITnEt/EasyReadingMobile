import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../Models/Concept.dart';

class Concepts{
  static Future<Database> getDatabase(int id) async {
    final databasesPath = await getDatabasesPath();
    final path = '${databasesPath}your_database.db';

    // open the database or create it if it doesn't exist
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // create tables if needed
          await db.execute('''
        CREATE TABLE concepts$id (
          id INTEGER PRIMARY KEY,
          concept TEXT,
          definition TEXT
        )
      ''');
        });
  }

  static Future<List<Concept>> getConcepts(int id) async{
    final Database db = await getDatabase(id);
    await ensureTable("concepts$id", db);

    final List<Map<String, dynamic>> maps = await db.query('concepts$id');

    return List.generate(maps.length, (index) {
      return Concept(
          concept: maps[index]['concept'],
          definition: maps[index]['definition'],
      );
    });
  }

  static Future<void> ensureTable (String tablename, Database db) async{
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $tablename (
      id INTEGER PRIMARY KEY,
      concept TEXT,
      definition TEXT
    )
  ''');
  }


  static Future<void> addConcept(int id, Concept concept) async {
    final Database db = await getDatabase(id);
    await ensureTable("concepts$id", db);

    await db.insert(
        'concepts$id',
        concept.toMap()
    );
  }

  static Future<void> deleteTable(int id) async {
    final Database db = await getDatabase(id);
    await db.execute(
      "DROP TABLE IF EXISTS concepts$id",
    );
  }
}