class PelangganModel {
  final int id;
  String nama;
  String? noWa;
  int poinLoyalitas;

  PelangganModel({
    required this.id,
    required this.nama,
    this.noWa,
    this.poinLoyalitas = 0,
  });

  factory PelangganModel.fromJson(Map<String, dynamic> json) {
    return PelangganModel(
      id:            json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama:          json['nama'] ?? '',
      noWa:          json['no_wa'],
      poinLoyalitas: json['poin_loyalitas'] is int
          ? json['poin_loyalitas']
          : int.parse((json['poin_loyalitas'] ?? 0).toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama':           nama,
      'no_wa':          noWa,
      'poin_loyalitas': poinLoyalitas,
    };
  }
}