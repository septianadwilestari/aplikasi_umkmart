import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/models.dart';

class TransaksiService {
  /// POST transaksi ke API — kembalikan TransaksiModel jika berhasil.
  Future<TransaksiModel> buat(Map<String, dynamic> data) async {
    final dio = await ApiService.getClient();
    debugPrint('[TransaksiService] POST /transaksi');
    debugPrint('[TransaksiService] payload: $data');

    try {
      final response = await dio.post('/transaksi', data: data);
      debugPrint('[TransaksiService] status: ${response.statusCode}');
      debugPrint('[TransaksiService] data: ${response.data}');

      // Support berbagai format response Laravel
      final Map<String, dynamic> raw = _extractMap(response.data);
      return TransaksiModel.fromJson(raw);
    } on DioException catch (e) {
      debugPrint('[TransaksiService] DioError POST: ${e.type}');
      debugPrint('[TransaksiService] status: ${e.response?.statusCode}');
      debugPrint('[TransaksiService] body: ${e.response?.data}');
      rethrow;
    }
  }

  /// GET semua transaksi dari API.
  Future<List<TransaksiModel>> getAll() async {
    final dio = await ApiService.getClient();
    debugPrint('[TransaksiService] GET /transaksi');
    try {
      final response = await dio.get('/transaksi');
      debugPrint('[TransaksiService] GET status: ${response.statusCode}');
      debugPrint('[TransaksiService] GET data type: ${response.data.runtimeType}');

      List<dynamic> list = [];
      if (response.data is List) {
        list = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        // Support: { data: [...] } atau { transaksi: [...] }
        list = (map['data'] ?? map['transaksi'] ?? []) as List;
      }

      debugPrint('[TransaksiService] Total transaksi: ${list.length}');
      return list.map((e) {
        try {
          return TransaksiModel.fromJson(e as Map<String, dynamic>);
        } catch (err) {
          debugPrint('[TransaksiService] Parse error item: $err — item: $e');
          return null;
        }
      }).whereType<TransaksiModel>().toList();
    } on DioException catch (e) {
      debugPrint('[TransaksiService] DioError GET: ${e.type} ${e.message}');
      debugPrint('[TransaksiService] status: ${e.response?.statusCode}');
      debugPrint('[TransaksiService] body: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('[TransaksiService] Unexpected error GET: $e');
      return [];
    }
  }

  /// Helper: ekstrak Map dari berbagai format response
  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.containsKey('data') && data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
    }
    throw Exception('Format response tidak dikenal: ${data.runtimeType}');
  }
}