class OrderModel {
  final int id;
  final String noOrder;
  final String metodeBayar;
  final String status;
  final double subtotal;
  final double taxAmount;
  final double serviceAmount;
  final double total;
  final double bayar;
  final double kembalian;
  final List<OrderItemModel> items;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.noOrder,
    required this.metodeBayar,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.serviceAmount,
    required this.total,
    required this.bayar,
    required this.kembalian,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<dynamic, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItemModel> orderItems = itemsList.map((item) => OrderItemModel.fromJson(item)).toList();

    return OrderModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      noOrder: json['no_order'] ?? '',
      metodeBayar: json['metode_bayar'] ?? 'cash',
      status: json['status'] ?? 'selesai',
      subtotal: (json['subtotal'] is num) ? (json['subtotal'] as num).toDouble() : double.parse(json['subtotal']?.toString() ?? '0'),
      taxAmount: (json['tax_amount'] is num) ? (json['tax_amount'] as num).toDouble() : double.parse(json['tax_amount']?.toString() ?? '0'),
      serviceAmount: (json['service_amount'] is num) ? (json['service_amount'] as num).toDouble() : double.parse(json['service_amount']?.toString() ?? '0'),
      total: (json['total'] is num) ? (json['total'] as num).toDouble() : double.parse(json['total']?.toString() ?? '0'),
      bayar: (json['bayar'] is num) ? (json['bayar'] as num).toDouble() : double.parse(json['bayar']?.toString() ?? '0'),
      kembalian: (json['kembalian'] is num) ? (json['kembalian'] as num).toDouble() : double.parse(json['kembalian']?.toString() ?? '0'),
      items: orderItems,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_order': noOrder,
      'metode_bayar': metodeBayar,
      'status': status,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'service_amount': serviceAmount,
      'total': total,
      'bayar': bayar,
      'kembalian': kembalian,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class OrderItemModel {
  final int id;
  final int qty;
  final String namaMenu;
  final double hargaSatuan;
  final double subtotal;
  final String? catatan;

  OrderItemModel({
    required this.id,
    required this.qty,
    required this.namaMenu,
    required this.hargaSatuan,
    required this.subtotal,
    this.catatan,
  });

  factory OrderItemModel.fromJson(Map<dynamic, dynamic> json) {
    return OrderItemModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      qty: json['qty'] is int ? json['qty'] : int.parse(json['qty']?.toString() ?? '1'),
      namaMenu: json['nama_menu'] ?? '',
      hargaSatuan: (json['harga_satuan'] is num) ? (json['harga_satuan'] as num).toDouble() : double.parse(json['harga_satuan']?.toString() ?? '0'),
      subtotal: (json['subtotal'] is num) ? (json['subtotal'] as num).toDouble() : double.parse(json['subtotal']?.toString() ?? '0'),
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qty': qty,
      'nama_menu': namaMenu,
      'harga_satuan': hargaSatuan,
      'subtotal': subtotal,
      'catatan': catatan,
    };
  }
}
