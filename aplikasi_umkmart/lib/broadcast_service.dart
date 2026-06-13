import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pelanggan_model.dart';
import 'api_service.dart';

// ─── Model komunitas WA ─────────────────────────────────────────────────────────
class KomunitasWa {
  final String id;
  String nama;
  String linkUrl; // e.g. https://chat.whatsapp.com/XXXXX

  KomunitasWa({required this.id, required this.nama, required this.linkUrl});

  factory KomunitasWa.fromJson(Map<String, dynamic> j) =>
      KomunitasWa(id: j['id'], nama: j['nama'], linkUrl: j['linkUrl']);

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama, 'linkUrl': linkUrl};
}

// ─── Service ────────────────────────────────────────────────────────────────────
class BroadcastService {
  static const _komunitasKey = 'wa_komunitas_list';

  // ── Pelanggan ────────────────────────────────────────────────────────────────

  Future<List<PelangganModel>> getPelanggan() async {
    try {
      final dio = await ApiService.getClient();
      final resp = await dio.get('/pelanggan');
      final List<dynamic> raw =
          resp.data is List ? resp.data : (resp.data['data'] ?? []);
      return raw.map((e) => PelangganModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('[BroadcastService] Error getPelanggan: $e');
      return [];
    }
  }

  // ── Buka WhatsApp ke nomor personal (URL-encoded message) ───────────────────

  Future<bool> kirimWaPribadi(String nomorWa, String pesan) async {
    String nomor = nomorWa.replaceAll(RegExp(r'[^0-9]'), '');
    if (nomor.startsWith('0')) {
      nomor = '62${nomor.substring(1)}';
    } else if (!nomor.startsWith('62')) {
      nomor = '62$nomor';
    }

    final encoded = Uri.encodeComponent(pesan);
    final waUrl = Uri.parse('https://wa.me/$nomor?text=$encoded');
    debugPrint('[BroadcastService] Buka WA pribadi: $waUrl');

    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[BroadcastService] Error buka WA pribadi: $e');
      return false;
    }
  }

  // ── Buka WA Grup/Komunitas (URL-encoded message via deep link) ──────────────

  /// Buka link grup/komunitas WA dan langsung isi pesan via parameter `text`.
  /// WhatsApp tidak selalu mendukung `?text=` di grup link — gunakan clipboard sebagai fallback.
  Future<bool> kirimKeKomunitas({
    required String linkKomunitas,
    required String pesan,
  }) async {
    try {
      // Salin pesan ke clipboard sebagai fallback
      await Clipboard.setData(ClipboardData(text: pesan));
      debugPrint('[BroadcastService] Pesan disalin ke clipboard');

      // Normalisasi URL komunitas: pastikan HTTPS
      String url = linkKomunitas.trim();
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }

      // Coba tambah ?text= ke URL (hanya works untuk beberapa versi WA)
      final encoded = Uri.encodeComponent(pesan);
      final uriDenganPesan = Uri.tryParse('$url?text=$encoded');
      final uriBiasa = Uri.tryParse(url);

      if (uriDenganPesan != null && await canLaunchUrl(uriDenganPesan)) {
        await launchUrl(uriDenganPesan, mode: LaunchMode.externalApplication);
        return true;
      } else if (uriBiasa != null && await canLaunchUrl(uriBiasa)) {
        await launchUrl(uriBiasa, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[BroadcastService] Error buka komunitas: $e');
      return false;
    }
  }

  // ── Clipboard saja ───────────────────────────────────────────────────────────

  Future<void> salinKeClipboard(String teks) async {
    await Clipboard.setData(ClipboardData(text: teks));
  }

  // ── CRUD Komunitas WA (disimpan di SharedPreferences) ───────────────────────

  Future<List<KomunitasWa>> getKomunitas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_komunitasKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => KomunitasWa.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveKomunitas(List<KomunitasWa> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _komunitasKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<KomunitasWa> tambahKomunitas(String nama, String link) async {
    final list = await getKomunitas();
    final baru = KomunitasWa(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: nama,
      linkUrl: link,
    );
    list.add(baru);
    await _saveKomunitas(list);
    return baru;
  }

  Future<void> editKomunitas(String id, String nama, String link) async {
    final list = await getKomunitas();
    final idx = list.indexWhere((k) => k.id == id);
    if (idx != -1) {
      list[idx].nama = nama;
      list[idx].linkUrl = link;
      await _saveKomunitas(list);
    }
  }

  Future<void> hapusKomunitas(String id) async {
    final list = await getKomunitas();
    list.removeWhere((k) => k.id == id);
    await _saveKomunitas(list);
  }

  // ── Generate template pesan promo ────────────────────────────────────────────

  String generatePesan({
    required String namaPelanggan,
    required String judulPromo,
    required String isiPromo,
    required String diskon,
    required String tanggal,
  }) {
    return '''Halo $namaPelanggan 👋

Ada promo spesial dari kami! 🎉

*$judulPromo*

$isiPromo

💰 Diskon: *$diskon%*
📅 Berlaku hingga: $tanggal

Yuk belanja sekarang dan dapatkan penghematannya! 🛍️

_Pesan ini dikirim dari UMKMART_''';
  }

  /// Generate pesan untuk broadcast komunitas (tanpa nama personal)
  String generatePesanKomunitas({
    required String judulPromo,
    required String isiPromo,
    required String diskon,
    required String tanggal,
  }) {
    return '''Halo pelanggan setia 👋

Ada promo spesial hari ini! 🎉

✨ *$judulPromo*

$isiPromo

🔥 Diskon: *$diskon%*
📅 Berlaku hingga: $tanggal

Yuk order sekarang 😊

_Pesan dari UMKMART_''';
  }
}
