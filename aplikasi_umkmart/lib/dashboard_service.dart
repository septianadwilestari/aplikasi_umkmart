import 'api_service.dart';

class DashboardService {
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.get('/laporan/dashboard');
      final data = response.data;

      // ✅ mapping key Laravel → key Flutter
      return {
        'omzet_hari_ini':      data['omzet_hari_ini'] ?? 0,
        'transaksi_hari_ini':  data['transaksi_hari_ini'] ?? 0,
        'stok_menipis':        data['stok_menipis'] ?? 0,
        'total_produk':        data['total_produk'] ?? 0,
        // bonus data yang tersedia dari Laravel
        'omzet_kemarin':       data['omzet_kemarin'] ?? 0,
        'persen_omzet':        data['persen_omzet'] ?? 0,
        'pengeluaran_hari_ini':data['pengeluaran_hari_ini'] ?? 0,
        'laba_hari_ini':       data['laba_hari_ini'] ?? 0,
      };
    } catch (_) {
      return {
        'omzet_hari_ini': 0,
        'transaksi_hari_ini': 0,
        'stok_menipis': 0,
        'total_produk': 0,
        'omzet_kemarin': 0,
        'persen_omzet': 0,
        'pengeluaran_hari_ini': 0,
        'laba_hari_ini': 0,
      };
    }
  }
}