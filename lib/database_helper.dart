import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final _databaseName = "fmdb.db";
  static final _databaseVersion = 1;
  static final table = 'clients';

  static final columnId = '_id';
  static final columnTr = 'tr';
  static final columnCustomer = 'customer';
  static final columnPrompt = 'prompt';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnTr TEXT PRIMARY KEY NOT NULL,
        $columnCustomer TEXT NOT NULL,
        $columnPrompt TEXT
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> update(String trRef, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: '$columnTr = ?',
      whereArgs: [trRef],
    );
  }

  Future<int> insertOrUpdate(Map<String, dynamic> row) async {
    final db = await database;
    String trRef = row[columnTr];
    
    if (await checkTRExists(trRef)) {
      // Update existing record
      return await db.update(
        table,
        row,
        where: '$columnTr = ?',
        whereArgs: [trRef],
      );
    } else {
      // Insert new record
      return await db.insert(table, row);
    }
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'))!;
  }

  Future<int> delete(String trRef) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnTr = ?', whereArgs: [trRef]);
  }

  Future<Map<String, dynamic>?> search(String tr) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      where: '$columnTr = ?',
      whereArgs: [tr],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<bool> checkTRExists(String trRef) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      columns: ['COUNT(*) as count'],
      where: '$columnTr = ?',
      whereArgs: [trRef],
    );
    int count = Sqflite.firstIntValue(results) ?? 0;
    return count > 0;
  }
}
