import 'package:flutter/foundation.dart';
import 'api_service.dart';

class LaporanService {
  Future<Map<String, dynamic>> getSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final dio = await ApiService.getClient();
      final Map<String, dynamic> params = {};
      if (startDate != null) params['start_date'] = startDate;
      if (endDate != null) params['end_date'] = endDate;

      final response = await dio.get(
        '/laporan/hari-ini',
        queryParameters: params.isNotEmpty ? params : null,
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Gagal memuat laporan');
    } catch (e) {
      debugPrint('[LaporanService] getSummary error: $e');
      return {
        'omzet_hari_ini': 0.0,
        'laba_hari_ini': 0.0,
        'transaksi_hari_ini': 0,
        'pengeluaran_hari_ini': 0.0,
        'omzet_kemarin': 0.0,
        'persen_omzet': 0.0,
        'total_produk': 0,
        'stok_menipis': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> get7Hari({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final dio = await ApiService.getClient();

      final Map<String, dynamic> params = {};
      if (startDate != null) params['start_date'] = startDate;
      if (endDate != null) params['end_date'] = endDate;

      final response = await dio.get(
        '/laporan/7-hari',
        queryParameters: params.isNotEmpty ? params : null,
      );
      if (response.statusCode == 200) {
        final list = response.data as List;
        return list
            .map((json) => Map<String, dynamic>.from(json))
            .toList();
      }
      throw Exception('Gagal memuat laporan 7 hari');
    } catch (e) {
      debugPrint('[LaporanService] get7Hari error: $e');
      return [];
    }
  }
}