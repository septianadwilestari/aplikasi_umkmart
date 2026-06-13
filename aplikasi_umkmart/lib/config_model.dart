class ConfigModel {
  final double taxRate;
  final double serviceRate;
  final String passcodeMain;
  final String passcodeAdmin;
  final String namaRestoran;
  final String alamat;

  ConfigModel({
    required this.taxRate,
    required this.serviceRate,
    required this.passcodeMain,
    required this.passcodeAdmin,
    required this.namaRestoran,
    required this.alamat,
  });

  factory ConfigModel.fromJson(Map<dynamic, dynamic> json) {
    return ConfigModel(
      taxRate: (json['tax_rate'] is num) ? (json['tax_rate'] as num).toDouble() : double.parse(json['tax_rate']?.toString() ?? '0'),
      serviceRate: (json['service_rate'] is num) ? (json['service_rate'] as num).toDouble() : double.parse(json['service_rate']?.toString() ?? '0'),
      passcodeMain: json['passcode_main']?.toString() ?? '1234',
      passcodeAdmin: json['passcode_admin']?.toString() ?? '0000',
      namaRestoran: json['nama_restoran'] ?? 'UMKMART',
      alamat: json['alamat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tax_rate': taxRate,
      'service_rate': serviceRate,
      'passcode_main': passcodeMain,
      'passcode_admin': passcodeAdmin,
      'nama_restoran': namaRestoran,
      'alamat': alamat,
    };
  }
}
