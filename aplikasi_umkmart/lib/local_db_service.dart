import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/produk_model.dart';

class LocalDbService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'umkmart.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE produk (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_produk TEXT NOT NULL,
            harga REAL NOT NULL,
            stok INTEGER NOT NULL,
            kategori TEXT,
            gambar TEXT,
            synced INTEGER DEFAULT 0,
            server_id INTEGER
          )
        ''');
      },
    );
  }

  // ── PRODUK ──────────────────────────────────────────────────────────────

  Future<List<ProdukModel>> getAllProduk() async {
    final database = await db;
    final rows = await database.query('produk', orderBy: 'id DESC');
    return rows.map(_rowToProduk).toList();
  }

  Future<ProdukModel> insertProduk(Map<String, dynamic> data) async {
    final database = await db;
    final row = {
      'nama_produk': data['nama_produk'],
      'harga': data['harga'],
      'stok': data['stok'],
      'kategori': data['kategori'] ?? '',
      'gambar': data['gambar'] ?? '',
      'synced': 0,
      'server_id': null,
    };
    final localId = await database.insert('produk', row);
    return ProdukModel(
      id: localId,
      namaProduk: data['nama_produk'],
      harga: (data['harga'] as num).toDouble(),
      stok: data['stok'] as int,
      kategori: data['kategori'],
      gambar: data['gambar'],
    );
  }

  Future<ProdukModel> updateProduk(int localId, Map<String, dynamic> data) async {
    final database = await db;
    await database.update(
      'produk',
      {
        'nama_produk': data['nama_produk'],
        'harga': data['harga'],
        'stok': data['stok'],
        'kategori': data['kategori'] ?? '',
        'synced': 0,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
    final rows = await database.query('produk', where: 'id = ?', whereArgs: [localId]);
    return _rowToProduk(rows.first);
  }

  Future<void> deleteProduk(int localId) async {
    final database = await db;
    await database.delete('produk', where: 'id = ?', whereArgs: [localId]);
  }

  Future<void> markSynced(int localId, int serverId) async {
    final database = await db;
    await database.update(
      'produk',
      {'synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedProduk() async {
    final database = await db;
    return database.query('produk', where: 'synced = 0');
  }

  ProdukModel _rowToProduk(Map<String, dynamic> row) => ProdukModel(
        id: row['id'] as int,
        namaProduk: row['nama_produk'] as String,
        harga: (row['harga'] as num).toDouble(),
        stok: row['stok'] as int,
        kategori: row['kategori'] as String?,
        gambar: row['gambar'] as String?,
      );
}