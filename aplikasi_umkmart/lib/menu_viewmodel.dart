import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/services.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuService _menuService = MenuService();

  List<MenuModel> _menuList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MenuModel> get menuList => _menuList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMenu({String? kategori}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _menuList = await _menuService.getMenu(kategori: kategori);
    } catch (e) {
      _errorMessage = 'Gagal memuat menu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tambahMenu({
    required String nama,
    required double harga,
    required int stok,
    required String kategori,
    XFile? foto,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> fields = {
        'nama': nama,
        'harga': harga,
        'stok': stok,
        'kategori': kategori,
      };

      if (foto != null) {
        fields['foto'] = await MultipartFile.fromFile(
          foto.path,
          filename: foto.name,
        );
      }

      final formData = FormData.fromMap(fields);
      await _menuService.tambahMenu(formData);
      await loadMenu();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah menu: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editMenu({
    required int id,
    required String nama,
    required double harga,
    required int stok,
    required String kategori,
    XFile? foto,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> fields = {
        'nama': nama,
        'harga': harga,
        'stok': stok,
        'kategori': kategori,
      };

      if (foto != null) {
        fields['foto'] = await MultipartFile.fromFile(
          foto.path,
          filename: foto.name,
        );
      }

      final formData = FormData.fromMap(fields);
      await _menuService.editMenu(id, formData);
      await loadMenu();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui menu: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> hapusMenu(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _menuService.hapusMenu(id);
      if (success) {
        _menuList.removeWhere((m) => m.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal menghapus menu: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStok(int id, int tambah) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _menuService.updateStok(id, tambah);
      final index = _menuList.indexWhere((m) => m.id == id);
      if (index != -1) {
        _menuList[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate stok: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, int>?> importFromSheet(String url) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _menuService.importFromSheet(url);
      await loadMenu();
      return res;
    } catch (e) {
      _errorMessage = 'Gagal mengimpor spreadsheet: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
