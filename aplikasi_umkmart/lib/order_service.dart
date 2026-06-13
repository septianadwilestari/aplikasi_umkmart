import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'api_service.dart';

class OrderService {
  final List<OrderModel> _localOrders = [];

Future<OrderModel> createOrder({
  required List<CartItem> items,
  required String metodeBayar,
  required double bayar,
  String? namaPelanggan,
  int? meja,
}) async {
  final dio = await ApiService.getClient();

  final itemsPayload = items.map((c) => {
    'menu_id': c.menu.id,
    'qty': c.qty,
    'catatan': c.catatan,
  }).toList();

  // Normalisasi metode bayar
  String metode = metodeBayar.toLowerCase();
  if (metode == 'tunai') metode = 'cash';

  final payload = {
    'metode_bayar': metode,
    'bayar': bayar,
    'nama_pelanggan': namaPelanggan,
    'meja': meja,
    'items': itemsPayload,
  };

  debugPrint('[OrderService] Payload: $payload');

  try {
    final response = await dio.post('/orders', data: payload);
    debugPrint('[OrderService] Response ${response.statusCode}: ${response.data}');

    if (response.statusCode == 201) {
      final order = OrderModel.fromJson(response.data);
      return order;
    }
    throw Exception('Server error: ${response.statusCode}');
  } on DioException catch (e) {
    debugPrint('[OrderService] DioException: ${e.type}');
    debugPrint('[OrderService] Response: ${e.response?.statusCode} - ${e.response?.data}');
    throw Exception('Checkout gagal: ${e.response?.data?['message'] ?? e.message}');
  }
}

  Future<List<OrderModel>> getOrders({DateTime? tanggal}) async {
    try {
      final dio = await ApiService.getClient();
      final String? tanggalStr = tanggal != null ? DateFormat('yyyy-MM-dd').format(tanggal) : null;

      final response = await dio.get('/orders', queryParameters: {
        if (tanggalStr != null) 'tanggal': tanggalStr
      });

      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((json) => OrderModel.fromJson(json)).toList();
      }
      throw Exception('Gagal memuat list order');
    } catch (e) {
      debugPrint('[OrderService] Gagal getOrders: $e');
      if (tanggal != null) {
        final datePrefix = DateFormat('yyyyMMdd').format(tanggal);
        return _localOrders.where((o) => o.noOrder.contains(datePrefix)).toList();
      }
      return List.from(_localOrders);
    }
  }

  Future<OrderModel> getOrderDetail(int id) async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.get('/orders/$id');
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      }
      throw Exception('Gagal memuat detail order');
    } catch (e) {
      debugPrint('[OrderService] Gagal getOrderDetail: $e');
      return _localOrders.firstWhere((o) => o.id == id);
    }
  }
}
