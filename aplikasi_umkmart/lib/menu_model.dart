class MenuModel {
  final int id;
  final String nama;
  final String? foto;
  final double harga;
  int stok;
  final String kategori;
  bool tersedia;

  MenuModel({
    required this.id,
    required this.nama,
    this.foto,
    required this.harga,
    required this.stok,
    this.kategori = 'Umum',
    this.tersedia = true,
  });

  // getter status stok:
  // stok == 0 → 'habis'
  // stok < 10 → 'low'  
  // else → 'normal'
  String get statusStok {
    if (stok == 0) return 'habis';
    if (stok < 10) return 'low';
    return 'normal';
  }

  factory MenuModel.fromJson(Map<dynamic, dynamic> json) {
    return MenuModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama: json['nama'] ?? '',
      foto: json['foto'],
      harga: (json['harga'] is num) ? (json['harga'] as num).toDouble() : double.parse(json['harga']?.toString() ?? '0'),
      stok: json['stok'] is int ? json['stok'] : int.parse(json['stok']?.toString() ?? '0'),
      kategori: json['kategori'] ?? 'Umum',
      tersedia: json['tersedia'] is bool 
          ? json['tersedia'] 
          : (json['tersedia'] == 1 || json['tersedia'] == '1' || json['tersedia'] == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'foto': foto,
      'harga': harga,
      'stok': stok,
      'kategori': kategori,
      'tersedia': tersedia,
    };
  }

  MenuModel copyWith({
    int? id,
    String? nama,
    String? foto,
    double? harga,
    int? stok,
    String? kategori,
    bool? tersedia,
  }) {
    return MenuModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      foto: foto ?? this.foto,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      kategori: kategori ?? this.kategori,
      tersedia: tersedia ?? this.tersedia,
    );
  }
}
