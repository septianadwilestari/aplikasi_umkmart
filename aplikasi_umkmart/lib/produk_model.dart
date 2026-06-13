class ProdukModel {
  final int id;
  String namaProduk;
  double harga;
  int stok;
  String? kategori;
  String? gambar;

  ProdukModel({
    required this.id,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    this.kategori,
    this.gambar,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id:         json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      namaProduk: json['nama_produk'] ?? '',
      harga:      json['harga'] != null ? double.parse(json['harga'].toString()) : 0.0,
      stok:       json['stok'] is int ? json['stok'] : int.parse(json['stok'].toString()),
      kategori:   json['kategori'],
      gambar:     json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_produk': namaProduk,
      'harga':       harga,
      'stok':        stok,
      'kategori':    kategori,
      'gambar':      gambar,
    };
  }

  bool get stokMenipis => stok <= 5;

  ProdukModel copyWith({
    int? id,
    String? namaProduk,
    double? harga,
    int? stok,
    String? kategori,
    String? gambar,
  }) {
    return ProdukModel(
      id:         id ?? this.id,
      namaProduk: namaProduk ?? this.namaProduk,
      harga:      harga ?? this.harga,
      stok:       stok ?? this.stok,
      kategori:   kategori ?? this.kategori,
      gambar:     gambar ?? this.gambar,
    );
  }
}