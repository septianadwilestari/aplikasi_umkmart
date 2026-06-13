import 'produk_model.dart';
import 'pelanggan_model.dart';

class KeranjangItem {
  final ProdukModel produk;
  int jumlah;

  KeranjangItem({required this.produk, required this.jumlah});

  double get subtotal => produk.harga * jumlah;
}

class DetailTransaksiModel {
  final int id;
  final String namaProduk;
  final double hargaSatuan;
  final int jumlah;
  final double subtotal;

  DetailTransaksiModel({
    required this.id,
    required this.namaProduk,
    required this.hargaSatuan,
    required this.jumlah,
    required this.subtotal,
  });

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      id:          json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      namaProduk:  json['nama_produk'] ?? '',
      hargaSatuan: json['harga_satuan'] != null ? double.parse(json['harga_satuan'].toString()) : 0.0,
      jumlah:      json['jumlah'] is int ? json['jumlah'] : int.parse(json['jumlah'].toString()),
      subtotal:    json['subtotal'] != null ? double.parse(json['subtotal'].toString()) : 0.0,
    );
  }
}

class TransaksiModel {
  final int id;
  final double subtotal;
  final double diskonNominal;
  final double total;
  final double bayar;
  final double kembalian;
  final String metodeBayar;
  final DateTime tanggal;
  final List<DetailTransaksiModel> details;
  final PelangganModel? pelanggan;
  final String? namaPelanggan;

  TransaksiModel({
    required this.id,
    required this.subtotal,
    required this.diskonNominal,
    required this.total,
    required this.bayar,
    required this.kembalian,
    required this.metodeBayar,
    required this.tanggal,
    required this.details,
    this.pelanggan,
    this.namaPelanggan,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    // Support both 'details' and 'detail' key from Laravel
    final rawDetails = json['details'] ?? json['detail'] ?? json['items'] ?? [];
    
    return TransaksiModel(
      id:            _parseInt(json['id']),
      subtotal:      _parseDouble(json['subtotal']),
      diskonNominal: _parseDouble(json['diskon_nominal']),
      total:         _parseDouble(json['total']),
      bayar:         _parseDouble(json['bayar']),
      kembalian:     _parseDouble(json['kembalian']),
      metodeBayar:   json['metode_bayar']?.toString() ?? 'tunai',
      tanggal:       _parseDate(json['tanggal'] ?? json['created_at']),
      details:       (rawDetails as List<dynamic>)
          .map((d) {
            try { return DetailTransaksiModel.fromJson(d as Map<String, dynamic>); }
            catch (_) { return null; }
          })
          .whereType<DetailTransaksiModel>()
          .toList(),
      pelanggan:     json['pelanggan'] != null
          ? PelangganModel.fromJson(json['pelanggan'] as Map<String, dynamic>)
          : null,
      namaPelanggan: json['pelanggan']?['nama']?.toString(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    try { return DateTime.parse(v.toString()); }
    catch (_) { return DateTime.now(); }
  }
}