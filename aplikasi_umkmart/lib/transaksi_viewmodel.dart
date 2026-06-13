import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Single source of truth untuk riwayat transaksi POS.
/// Data disimpan permanen di SharedPreferences (JSON)
/// sehingga tetap ada meski app ditutup / Flutter restart.
class TransaksiViewModel extends ChangeNotifier {
  static const _kStorageKey = 'transaksi_riwayat';

  List<OrderModel> _riwayat = [];
  bool _isLoaded = false;

  List<OrderModel> get riwayat => List.unmodifiable(_riwayat);
  bool get isLoaded => _isLoaded;

  TransaksiViewModel() {
    _loadFromStorage();
  }

  // ── Load dari SharedPreferences saat app start ──────────────────────────
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kStorageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        _riwayat = jsonList
            .map((e) {
              try {
                return OrderModel.fromJson(e as Map<String, dynamic>);
              } catch (err) {
                debugPrint('[TransaksiViewModel] Parse error: $err');
                return null;
              }
            })
            .whereType<OrderModel>()
            .toList();
        debugPrint('[TransaksiViewModel] Loaded ${_riwayat.length} transaksi dari storage');
      }
    } catch (e) {
      debugPrint('[TransaksiViewModel] Gagal load storage: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── Simpan ke SharedPreferences ─────────────────────────────────────────
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_riwayat.map((o) => o.toJson()).toList());
      await prefs.setString(_kStorageKey, jsonStr);
      debugPrint('[TransaksiViewModel] Saved ${_riwayat.length} transaksi ke storage');
    } catch (e) {
      debugPrint('[TransaksiViewModel] Gagal save storage: $e');
    }
  }

  // ── Dipanggil dari PosViewModel.checkout() ──────────────────────────────
  Future<void> tambahTransaksi(OrderModel order) async {
    _riwayat.insert(0, order); // terbaru di atas
    notifyListeners();
    await _saveToStorage();   // langsung persist
  }

  // ── Filter berdasarkan tanggal ──────────────────────────────────────────
  List<OrderModel> getByTanggal(DateTime tanggal) {
    return _riwayat.where((o) {
      return o.createdAt.year == tanggal.year &&
          o.createdAt.month == tanggal.month &&
          o.createdAt.day == tanggal.day;
    }).toList();
  }

  // ── Summary ─────────────────────────────────────────────────────────────
  double get omsetHariIni {
    return getByTanggal(DateTime.now())
        .fold(0.0, (sum, o) => sum + o.total);
  }

  int get jumlahTransaksiHariIni {
    return getByTanggal(DateTime.now()).length;
  }

  double get totalOmset =>
      _riwayat.fold(0.0, (sum, o) => sum + o.total);

  // ── Hapus semua riwayat ─────────────────────────────────────────────────
  Future<void> clearRiwayat() async {
    _riwayat.clear();
    notifyListeners();
    await _saveToStorage();
  }
}