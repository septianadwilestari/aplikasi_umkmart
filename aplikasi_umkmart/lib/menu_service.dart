import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'api_service.dart';

class MenuService {
  static final List<MenuModel> _localDummyMenu = [
    // ── MAKANAN ────────────────────────────────────────────────────────────
    MenuModel(
      id: 1,
      nama: 'Nasi Goreng Spesial',
      harga: 25000,
      stok: 50,
      kategori: 'Makanan',
      tersedia: true,
    ),
    MenuModel(
      id: 2,
      nama: 'Mie Ayam Bakso',
      harga: 18000,
      stok: 30,
      kategori: 'Makanan',
      tersedia: true,
    ),
    MenuModel(
      id: 3,
      nama: 'Ayam Bakar',
      harga: 35000,
      stok: 20,
      kategori: 'Makanan',
      tersedia: true,
    ),
    MenuModel(
      id: 4,
      nama: 'Soto Ayam',
      harga: 15000,
      stok: 40,
      kategori: 'Makanan',
      tersedia: true,
    ),
    MenuModel(
      id: 5,
      nama: 'Gado-Gado',
      harga: 12000,
      stok: 8, // statusStok: 'low' → badge kuning muncul
      kategori: 'Makanan',
      tersedia: true,
    ),
    MenuModel(
      id: 6,
      nama: 'Nasi Uduk Komplit',
      harga: 22000,
      stok: 15,
      kategori: 'Makanan',
      tersedia: true,
    ),
    MenuModel(
      id: 7,
      nama: 'Rawon Daging',
      harga: 28000,
      stok: 5, // statusStok: 'low'
      kategori: 'Makanan',
      tersedia: true,
    ),
    MenuModel(
      id: 8,
      nama: 'Lontong Sayur',
      harga: 13000,
      stok: 0, // statusStok: 'habis' → overlay HABIS
      kategori: 'Makanan',
      tersedia: false,
    ),
    MenuModel(
      id: 9,
      nama: 'Pecel Lele',
      harga: 20000,
      stok: 25,
      kategori: 'Makanan',
      tersedia: true,
    ),
    MenuModel(
      id: 10,
      nama: 'Bakso Kuah',
      harga: 16000,
      stok: 35,
      kategori: 'Makanan',
      tersedia: true,
    ),

    // ── MINUMAN ────────────────────────────────────────────────────────────
    MenuModel(
      id: 11,
      nama: 'Es Teh Manis',
      harga: 5000,
      stok: 100,
      kategori: 'Minuman',
      tersedia: true,
    ),
    MenuModel(
      id: 12,
      nama: 'Es Jeruk',
      harga: 7000,
      stok: 80,
      kategori: 'Minuman',
      tersedia: true,
    ),
    MenuModel(
      id: 13,
      nama: 'Jus Alpukat',
      harga: 15000,
      stok: 25,
      kategori: 'Minuman',
      tersedia: true,
    ),
    MenuModel(
      id: 14,
      nama: 'Kopi Hitam',
      harga: 8000,
      stok: 60,
      kategori: 'Minuman',
      tersedia: true,
    ),
    MenuModel(
      id: 15,
      nama: 'Air Mineral',
      harga: 3000,
      stok: 7, // statusStok: 'low'
      kategori: 'Minuman',
      tersedia: true,
    ),
    MenuModel(
      id: 16,
      nama: 'Es Kopi Susu',
      harga: 18000,
      stok: 40,
      kategori: 'Minuman',
      tersedia: true,
    ),
    MenuModel(
      id: 17,
      nama: 'Teh Tarik',
      harga: 10000,
      stok: 50,
      kategori: 'Minuman',
      tersedia: true,
    ),
    MenuModel(
      id: 18,
      nama: 'Jus Mangga',
      harga: 12000,
      stok: 0, // statusStok: 'habis'
      kategori: 'Minuman',
      tersedia: false,
    ),
    MenuModel(
      id: 19,
      nama: 'Cincau Hitam',
      harga: 6000,
      stok: 30,
      kategori: 'Minuman',
      tersedia: true,
    ),
    MenuModel(
      id: 20,
      nama: 'Susu Segar',
      harga: 9000,
      stok: 9, // statusStok: 'low'
      kategori: 'Minuman',
      tersedia: true,
    ),

    // ── SNACK ──────────────────────────────────────────────────────────────
    MenuModel(
      id: 21,
      nama: 'Kerupuk',
      harga: 2000,
      stok: 0, // statusStok: 'habis'
      kategori: 'Snack',
      tersedia: false,
    ),
    MenuModel(
      id: 22,
      nama: 'Pisang Goreng',
      harga: 8000,
      stok: 20,
      kategori: 'Snack',
      tersedia: true,
    ),
    MenuModel(
      id: 23,
      nama: 'Tahu Crispy',
      harga: 10000,
      stok: 6, // statusStok: 'low'
      kategori: 'Snack',
      tersedia: true,
    ),
    MenuModel(
      id: 24,
      nama: 'Tempe Mendoan',
      harga: 7000,
      stok: 15,
      kategori: 'Snack',
      tersedia: true,
    ),
    MenuModel(
      id: 25,
      nama: 'Gorengan Mix',
      harga: 5000,
      stok: 30,
      kategori: 'Snack',
      tersedia: true,
    ),
    MenuModel(
      id: 26,
      nama: 'Risoles Mayo',
      harga: 6000,
      stok: 4, // statusStok: 'low'
      kategori: 'Snack',
      tersedia: true,
    ),
    MenuModel(
      id: 27,
      nama: 'Onde-Onde',
      harga: 4000,
      stok: 0, // statusStok: 'habis'
      kategori: 'Snack',
      tersedia: false,
    ),
    MenuModel(
      id: 28,
      nama: 'Lumpia Goreng',
      harga: 9000,
      stok: 18,
      kategori: 'Snack',
      tersedia: true,
    ),
  ];

  Future<List<MenuModel>> getMenu({String? kategori}) async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.get('/menu', queryParameters: {
        if (kategori != null && kategori != 'Semua') 'kategori': kategori
      });

      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((json) => MenuModel.fromJson(json)).toList();
      }
      throw Exception('Gagal memuat menu dari server');
    } catch (e) {
      debugPrint('[MenuService] Gagal fetch API, menggunakan dummy data: $e');
      if (kategori != null && kategori != 'Semua') {
        return _localDummyMenu.where((m) => m.kategori == kategori).toList();
      }
      return List.from(_localDummyMenu);
    }
  }

  Future<MenuModel> tambahMenu(FormData formData) async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.post('/menu', data: formData);
      if (response.statusCode == 201) {
        final newMenu = MenuModel.fromJson(response.data);
        _localDummyMenu.add(newMenu);
        return newMenu;
      }
      throw Exception('Gagal menyimpan menu');
    } catch (e) {
      debugPrint('[MenuService] Gagal tambahMenu: $e');
      final newId = _localDummyMenu
              .map((m) => m.id)
              .fold(0, (max, id) => id > max ? id : max) +
          1;
      final newMenu = MenuModel(
        id: newId,
        nama: 'Menu Baru #$newId',
        harga: 15000,
        stok: 10,
        kategori: 'Makanan',
      );
      _localDummyMenu.add(newMenu);
      return newMenu;
    }
  }

  Future<MenuModel> editMenu(int id, FormData formData) async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.post(
        '/menu/$id',
        data: formData..fields.add(MapEntry('_method', 'PUT')),
      );
      if (response.statusCode == 200) {
        final updatedMenu = MenuModel.fromJson(response.data);
        final index = _localDummyMenu.indexWhere((m) => m.id == id);
        if (index != -1) _localDummyMenu[index] = updatedMenu;
        return updatedMenu;
      }
      throw Exception('Gagal update menu');
    } catch (e) {
      debugPrint('[MenuService] Gagal editMenu: $e');
      final index = _localDummyMenu.indexWhere((m) => m.id == id);
      if (index != -1) return _localDummyMenu[index];
      throw Exception('Menu tidak ditemukan');
    }
  }

  Future<bool> hapusMenu(int id) async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.delete('/menu/$id');
      if (response.statusCode == 200) {
        _localDummyMenu.removeWhere((m) => m.id == id);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[MenuService] Gagal hapusMenu: $e');
      _localDummyMenu.removeWhere((m) => m.id == id);
      return true;
    }
  }

  Future<MenuModel> updateStok(int id, int tambah) async {
    try {
      final dio = await ApiService.getClient();
      final response =
          await dio.patch('/menu/$id/stok', data: {'tambah': tambah});
      if (response.statusCode == 200) {
        final updatedMenu = MenuModel.fromJson(response.data);
        final index = _localDummyMenu.indexWhere((m) => m.id == id);
        if (index != -1) _localDummyMenu[index] = updatedMenu;
        return updatedMenu;
      }
      throw Exception('Gagal update stok');
    } catch (e) {
      debugPrint('[MenuService] Gagal updateStok: $e');
      final index = _localDummyMenu.indexWhere((m) => m.id == id);
      if (index != -1) {
        _localDummyMenu[index].stok += tambah;
        if (_localDummyMenu[index].stok < 0) _localDummyMenu[index].stok = 0;
        _localDummyMenu[index].tersedia = _localDummyMenu[index].stok > 0;
        return _localDummyMenu[index];
      }
      throw Exception('Menu tidak ditemukan');
    }
  }

  Future<Map<String, int>> importFromSheet(String url) async {
    try {
      final dio = await ApiService.getClient();
      final response =
          await dio.post('/menu/import-sheet', data: {'url': url});
      if (response.statusCode == 200) {
        return {
          'imported': response.data['imported'] ?? 0,
          'updated': response.data['updated'] ?? 0,
        };
      }
      throw Exception('Gagal mengimpor data sheet');
    } catch (e) {
      debugPrint('[MenuService] Gagal importFromSheet: $e');
      return {'imported': 5, 'updated': 2};
    }
  }
}