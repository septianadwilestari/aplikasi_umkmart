import 'package:flutter/material.dart';
import 'dart:io';
import '../models/models.dart';
import '../services/services.dart';

class ProdukViewModel extends ChangeNotifier {
  final ProdukService _service = ProdukService();
  List<ProdukModel> produks = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProduks() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      produks = await _service.getAll();
    } catch (e) {
      errorMessage = _parseError(e);
      debugPrint('[ProdukViewModel] loadProduks error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah produk. Melempar String error jika gagal.
  Future<void> tambah(Map<String, dynamic> data, {File? foto}) async {
    try {
      final p = await _service.create(data, foto: foto);
      produks.add(p);
      notifyListeners();
    } catch (e) {
      debugPrint('[ProdukViewModel] tambah error: $e');
      throw _parseError(e);
    }
  }

  /// Edit produk. Melempar String error jika gagal.
  Future<void> edit(int id, Map<String, dynamic> data, {File? foto}) async {
    try {
      final p = await _service.update(id, data, foto: foto);
      final i = produks.indexWhere((x) => x.id == id);
      if (i != -1) produks[i] = p;
      notifyListeners();
    } catch (e) {
      debugPrint('[ProdukViewModel] edit error: $e');
      throw _parseError(e);
    }
  }

  Future<bool> hapus(int id) async {
    try {
      await _service.delete(id);
      produks.removeWhere((x) => x.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ProdukViewModel] hapus error: $e');
      return false;
    }
  }

  List<ProdukModel> get stokMenipis => produks.where((p) => p.stokMenipis).toList();

  /// Parse exception menjadi pesan yang ramah untuk user
  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('TimeoutException') || msg.contains('timeout')) {
      return 'Koneksi timeout. Periksa jaringan internet Anda.';
    }
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Tidak dapat terhubung ke server. Pastikan server aktif.';
    }
    if (msg.contains('401') || msg.contains('Unauthenticated')) {
      return 'Sesi Anda telah berakhir. Silakan login ulang.';
    }
    if (msg.contains('422') || msg.contains('Unprocessable')) {
      return 'Data tidak valid. Periksa kembali isian form.';
    }
    if (msg.contains('500')) {
      return 'Server error. Coba beberapa saat lagi.';
    }
    return 'Gagal menyimpan produk. Coba lagi.';
  }
}