import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'diary.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  void _onCreate(Database db, int version) async {
    // Create user table
    await db.execute(
        "CREATE TABLE User(username TEXT PRIMARY KEY, password TEXT)");

    // Create entries table
    await db.execute(
        "CREATE TABLE Entry(id INTEGER PRIMARY KEY, feeling TEXT, description TEXT, image TEXT)");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the image column to the Entry table
      await db.execute("ALTER TABLE Entry ADD COLUMN image TEXT");
    }
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database dbClient = await db;
    return await dbClient.insert('User', user);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    Database dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query(
      'User',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertEntry(Map<String, dynamic> entry) async {
    Database dbClient = await db;
    return await dbClient.insert('Entry', entry);
  }

  Future<List<Map<String, dynamic>>> getAllEntries(String s) async {
    Database dbClient = await db;
    return await dbClient.query('Entry');
  }

  Future<int> updateEntry(Map<String, dynamic> entry) async {
    Database dbClient = await db;
    return await dbClient.update(
      'Entry',
      entry,
      where: 'id = ?',
      whereArgs: [entry['id']],
    );
  }

  Future<int> deleteEntry(int id) async {
    Database dbClient = await db;
    return await dbClient.delete(
      'Entry',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future close() async {
    Database dbClient = await db;
    dbClient.close();
  }
}
