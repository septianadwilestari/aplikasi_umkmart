import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/produk_model.dart';

class ProdukService {
  // ── Dummy data fallback (saat XAMPP mati / tidak konek) ──────────────────
  static final List<ProdukModel> _dummyProduks = [
    // ── Makanan ────────────────────────────────────────────────────────────
    ProdukModel(id: 1, namaProduk: 'Nasi Goreng Spesial', harga: 25000, stok: 50, kategori: 'Makanan'),
    ProdukModel(id: 2, namaProduk: 'Mie Ayam Bakso',      harga: 18000, stok: 30, kategori: 'Makanan'),
    ProdukModel(id: 3, namaProduk: 'Ayam Bakar',          harga: 35000, stok: 20, kategori: 'Makanan'),
    ProdukModel(id: 4, namaProduk: 'Soto Ayam',           harga: 15000, stok: 40, kategori: 'Makanan'),
    ProdukModel(id: 5, namaProduk: 'Gado-Gado',           harga: 12000, stok: 4,  kategori: 'Makanan'), // stokMenipis
    ProdukModel(id: 6, namaProduk: 'Nasi Uduk Komplit',   harga: 22000, stok: 15, kategori: 'Makanan'),
    ProdukModel(id: 7, namaProduk: 'Rawon Daging',        harga: 28000, stok: 3,  kategori: 'Makanan'), // stokMenipis
    ProdukModel(id: 8, namaProduk: 'Lontong Sayur',       harga: 13000, stok: 0,  kategori: 'Makanan'), // habis
    ProdukModel(id: 9, namaProduk: 'Pecel Lele',          harga: 20000, stok: 25, kategori: 'Makanan'),
    ProdukModel(id: 10, namaProduk: 'Bakso Kuah',         harga: 16000, stok: 35, kategori: 'Makanan'),

    // ── Minuman ────────────────────────────────────────────────────────────
    ProdukModel(id: 11, namaProduk: 'Es Teh Manis',  harga: 5000,  stok: 100, kategori: 'Minuman'),
    ProdukModel(id: 12, namaProduk: 'Es Jeruk',      harga: 7000,  stok: 80,  kategori: 'Minuman'),
    ProdukModel(id: 13, namaProduk: 'Jus Alpukat',   harga: 15000, stok: 25,  kategori: 'Minuman'),
    ProdukModel(id: 14, namaProduk: 'Kopi Hitam',    harga: 8000,  stok: 60,  kategori: 'Minuman'),
    ProdukModel(id: 15, namaProduk: 'Air Mineral',   harga: 3000,  stok: 5,   kategori: 'Minuman'), // stokMenipis
    ProdukModel(id: 16, namaProduk: 'Es Kopi Susu',  harga: 18000, stok: 40,  kategori: 'Minuman'),
    ProdukModel(id: 17, namaProduk: 'Teh Tarik',     harga: 10000, stok: 50,  kategori: 'Minuman'),
    ProdukModel(id: 18, namaProduk: 'Jus Mangga',    harga: 12000, stok: 0,   kategori: 'Minuman'), // habis
    ProdukModel(id: 19, namaProduk: 'Cincau Hitam',  harga: 6000,  stok: 30,  kategori: 'Minuman'),
    ProdukModel(id: 20, namaProduk: 'Susu Segar',    harga: 9000,  stok: 2,   kategori: 'Minuman'), // stokMenipis

    // ── Snack ──────────────────────────────────────────────────────────────
    ProdukModel(id: 21, namaProduk: 'Kerupuk',        harga: 2000, stok: 0,  kategori: 'Snack'), // habis
    ProdukModel(id: 22, namaProduk: 'Pisang Goreng',  harga: 8000, stok: 20, kategori: 'Snack'),
    ProdukModel(id: 23, namaProduk: 'Tahu Crispy',    harga: 10000, stok: 4, kategori: 'Snack'), // stokMenipis
    ProdukModel(id: 24, namaProduk: 'Tempe Mendoan',  harga: 7000, stok: 15, kategori: 'Snack'),
    ProdukModel(id: 25, namaProduk: 'Gorengan Mix',   harga: 5000, stok: 30, kategori: 'Snack'),
    ProdukModel(id: 26, namaProduk: 'Risoles Mayo',   harga: 6000, stok: 3,  kategori: 'Snack'), // stokMenipis
    ProdukModel(id: 27, namaProduk: 'Onde-Onde',      harga: 4000, stok: 0,  kategori: 'Snack'), // habis
    ProdukModel(id: 28, namaProduk: 'Lumpia Goreng',  harga: 9000, stok: 18, kategori: 'Snack'),
  ];

  // ── GET ALL ───────────────────────────────────────────────────────────────
  Future<List<ProdukModel>> getAll() async {
    try {
      final dio = await ApiService.getClient();
      debugPrint('[ProdukService] GET /produk');
      final response = await dio.get('/produk');
      debugPrint('[ProdukService] GET /produk → ${response.statusCode}');
      final raw = response.data;
      final list = raw is List ? raw : (raw['data'] ?? raw['produk'] ?? []);
      return (list as List).map((e) => ProdukModel.fromJson(e)).toList();
    } catch (e) {
      // API tidak tersedia → fallback ke dummy data
      debugPrint('[ProdukService] Gagal fetch API, menggunakan dummy data: $e');
      return List.from(_dummyProduks);
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<ProdukModel> create(Map<String, dynamic> data, {File? foto}) async {
    try {
      final dio = await ApiService.getClient();

      late dynamic payload;
      if (foto != null) {
        payload = FormData.fromMap({
          'nama_produk': data['nama_produk'],
          'harga':       data['harga'].toString(),
          'stok':        data['stok'].toString(),
          if ((data['kategori'] ?? '').toString().isNotEmpty)
            'kategori': data['kategori'].toString(),
          if ((data['deskripsi'] ?? '').toString().isNotEmpty)
            'deskripsi': data['deskripsi'].toString(),
          'foto': await MultipartFile.fromFile(
            foto.path,
            filename: foto.path.split('/').last.split('\\').last,
          ),
        });
        debugPrint('[ProdukService] POST /produk (multipart)');
      } else {
        payload = {
          'nama_produk': data['nama_produk'],
          'harga':       data['harga'],
          'stok':        data['stok'],
          if ((data['kategori'] ?? '').toString().isNotEmpty) 'kategori': data['kategori'],
          if ((data['deskripsi'] ?? '').toString().isNotEmpty) 'deskripsi': data['deskripsi'],
        };
        debugPrint('[ProdukService] POST /produk (json)');
      }

      final response = await dio.post(
        '/produk',
        data: payload,
        options: foto != null
            ? Options(contentType: 'multipart/form-data')
            : Options(contentType: 'application/json'),
      );

      final resData = response.data;
      final produkJson = resData is Map && resData.containsKey('data')
          ? resData['data']
          : resData;
      return ProdukModel.fromJson(produkJson);
    } catch (e) {
      // Fallback: simpan lokal ke dummy list
      debugPrint('[ProdukService] Gagal create API, simpan lokal: $e');
      final newId = _dummyProduks.isEmpty
          ? 1
          : _dummyProduks.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
      final newProduk = ProdukModel(
        id:          newId,
        namaProduk:  data['nama_produk'] ?? 'Produk Baru',
        harga:       (data['harga'] as num?)?.toDouble() ?? 0,
        stok:        (data['stok'] as num?)?.toInt() ?? 0,
        kategori:    data['kategori'],
      );
      _dummyProduks.add(newProduk);
      return newProduk;
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<ProdukModel> update(int id, Map<String, dynamic> data, {File? foto}) async {
    try {
      final dio = await ApiService.getClient();

      if (foto != null) {
        final formData = FormData.fromMap({
          '_method':     'PUT',
          'nama_produk': data['nama_produk'],
          'harga':       data['harga'].toString(),
          'stok':        data['stok'].toString(),
          if ((data['kategori'] ?? '').toString().isNotEmpty)
            'kategori': data['kategori'].toString(),
          if ((data['deskripsi'] ?? '').toString().isNotEmpty)
            'deskripsi': data['deskripsi'].toString(),
          'foto': await MultipartFile.fromFile(
            foto.path,
            filename: foto.path.split('/').last.split('\\').last,
          ),
        });
        final response = await dio.post(
          '/produk/$id',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        final resData = response.data;
        final produkJson = resData is Map && resData.containsKey('data')
            ? resData['data']
            : resData;
        return ProdukModel.fromJson(produkJson);
      } else {
        final payload = {
          'nama_produk': data['nama_produk'],
          'harga':       data['harga'],
          'stok':        data['stok'],
          if ((data['kategori'] ?? '').toString().isNotEmpty) 'kategori': data['kategori'],
          if ((data['deskripsi'] ?? '').toString().isNotEmpty) 'deskripsi': data['deskripsi'],
        };
        final response = await dio.put('/produk/$id', data: payload);
        final resData = response.data;
        final produkJson = resData is Map && resData.containsKey('data')
            ? resData['data']
            : resData;
        return ProdukModel.fromJson(produkJson);
      }
    } catch (e) {
      // Fallback: update lokal di dummy list
      debugPrint('[ProdukService] Gagal update API, update lokal: $e');
      final index = _dummyProduks.indexWhere((p) => p.id == id);
      if (index != -1) {
        final updated = ProdukModel(
          id:         id,
          namaProduk: data['nama_produk'] ?? _dummyProduks[index].namaProduk,
          harga:      (data['harga'] as num?)?.toDouble() ?? _dummyProduks[index].harga,
          stok:       (data['stok'] as num?)?.toInt() ?? _dummyProduks[index].stok,
          kategori:   data['kategori'] ?? _dummyProduks[index].kategori,
          gambar:     _dummyProduks[index].gambar,
        );
        _dummyProduks[index] = updated;
        return updated;
      }
      throw Exception('Produk tidak ditemukan');
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> delete(int id) async {
    try {
      final dio = await ApiService.getClient();
      debugPrint('[ProdukService] DELETE /produk/$id');
      await dio.delete('/produk/$id');
      debugPrint('[ProdukService] DELETE /produk/$id — OK');
    } catch (e) {
      // Fallback: hapus dari dummy list lokal
      debugPrint('[ProdukService] Gagal delete API, hapus lokal: $e');
      _dummyProduks.removeWhere((p) => p.id == id);
    }
  }
}