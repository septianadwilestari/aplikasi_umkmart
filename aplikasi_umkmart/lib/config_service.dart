import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'api_service.dart';

class ConfigService {
  static ConfigModel _localConfig = ConfigModel(
    taxRate: 11.0,
    serviceRate: 5.0,
    passcodeMain: '1234',
    passcodeAdmin: '0000',
    namaRestoran: 'Warung UMKMART',
    alamat: 'Jl. Contoh No. 123, Surabaya',
  );

  Future<ConfigModel> getConfig() async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.get('/config');
      if (response.statusCode == 200) {
        _localConfig = ConfigModel.fromJson(response.data);
        return _localConfig;
      }
      throw Exception('Gagal memuat setting dari server');
    } catch (e) {
      debugPrint('[ConfigService] Gagal getConfig, menggunakan dummy config: $e');
      return _localConfig;
    }
  }

  Future<ConfigModel> updateConfig(Map<String, dynamic> data) async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.put('/config', data: data);
      if (response.statusCode == 200) {
        _localConfig = ConfigModel.fromJson(response.data);
        return _localConfig;
      }
      throw Exception('Gagal memperbarui konfigurasi');
    } catch (e) {
      debugPrint('[ConfigService] Gagal updateConfig locally: $e');
      // Update local dummy
      _localConfig = ConfigModel(
        taxRate: data['tax_rate'] != null ? double.parse(data['tax_rate'].toString()) : _localConfig.taxRate,
        serviceRate: data['service_rate'] != null ? double.parse(data['service_rate'].toString()) : _localConfig.serviceRate,
        passcodeMain: data['passcode_main']?.toString() ?? _localConfig.passcodeMain,
        passcodeAdmin: data['passcode_admin']?.toString() ?? _localConfig.passcodeAdmin,
        namaRestoran: data['nama_restoran']?.toString() ?? _localConfig.namaRestoran,
        alamat: data['alamat']?.toString() ?? _localConfig.alamat,
      );
      return _localConfig;
    }
  }

  Future<bool> verifyPasscode(String type, String passcode) async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.post('/config/verify-passcode', data: {
        'type': type == 'admin' ? 'admin' : 'main',
        'passcode': passcode,
      });
      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('[ConfigService] Gagal verifyPasscode via API, checking locally: $e');
      final correctPasscode = type == 'admin' ? _localConfig.passcodeAdmin : _localConfig.passcodeMain;
      return passcode == correctPasscode;
    }
  }
}
