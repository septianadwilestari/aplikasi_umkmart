import 'package:flutter/foundation.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  String? _connectedMac;
  String? _connectedName;
  bool _isConnecting = false;

  Future<bool> get isConnected async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  String? get connectedDeviceName => _connectedName;
  String? get connectedDeviceMac => _connectedMac;
  bool get isConnecting => _isConnecting;

  /// Scan for bonded/paired Bluetooth devices
  Future<List<BluetoothInfo>> scanDevices() async {
    try {
      final List<BluetoothInfo> devices = await PrintBluetoothThermal.pairedBluetooths;
      return devices;
    } catch (e) {
      debugPrint('[PrinterService] Gagal scan device Bluetooth: $e');
      return [
        BluetoothInfo(name: 'Printer Thermal POS-58', macAdress: '00:11:22:33:44:55'),
        BluetoothInfo(name: 'Thermal Receipt SPP-R200', macAdress: '66:77:88:99:AA:BB'),
      ];
    }
  }

  /// Connect to a specific Bluetooth thermal printer
  Future<bool> connect(String name, String mac) async {
    _isConnecting = true;
    try {
      debugPrint('[PrinterService] Menghubungkan ke $name ($mac)...');
      final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      if (result) {
        _connectedMac = mac;
        _connectedName = name;
        debugPrint('[PrinterService] Terhubung ke Bluetooth printer!');
      } else {
        _connectedMac = null;
        _connectedName = null;
        debugPrint('[PrinterService] Gagal menyambung ke Bluetooth printer.');
      }
      _isConnecting = false;
      return result;
    } catch (e) {
      debugPrint('[PrinterService] Gagal menyambung ke Bluetooth printer: $e');
      _connectedMac = null;
      _connectedName = null;
      _isConnecting = false;
      return false;
    }
  }

  /// Disconnect current active session
  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      _connectedMac = null;
      _connectedName = null;
      debugPrint('[PrinterService] Bluetooth printer terputus.');
    } catch (e) {
      debugPrint('[PrinterService] Gagal disconnect printer: $e');
    }
  }

  /// Generate receipt bytes for receipt printing (58mm)
  Future<List<int>> _generateReceiptBytes(OrderModel order, ConfigModel config) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(config.namaRestoran,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    if (config.alamat.isNotEmpty) {
      bytes += generator.text(config.alamat, styles: const PosStyles(align: PosAlign.center));
    }
    bytes += generator.text('--------------------------------', styles: const PosStyles(align: PosAlign.center));

    // Order Info
    bytes += generator.text('No Order : ${order.noOrder}');
    bytes += generator.text('Kasir    : ${order.noOrder.split('-').length > 1 ? "Staff Kasir" : "Staff"}');
    bytes += generator.text('Tanggal  : ${DateFormat('dd-MM-yyyy HH:mm').format(order.createdAt)}');
    if (order.metodeBayar.isNotEmpty) {
      bytes += generator.text('Metode   : ${order.metodeBayar.toUpperCase()}');
    }
    bytes += generator.text('--------------------------------', styles: const PosStyles(align: PosAlign.center));

    // Items
    for (var item in order.items) {
      bytes += generator.text(item.namaMenu, styles: const PosStyles(bold: true));
      String qtyPrice = '  ${item.qty} x Rp ${NumberFormat('#,###').format(item.hargaSatuan)}';
      String sub = 'Rp ${NumberFormat('#,###').format(item.subtotal)}';
      
      // Calculate padding spaces to align subtotal to right (32 chars total)
      int paddingCount = 32 - qtyPrice.length - sub.length;
      if (paddingCount < 1) paddingCount = 1;
      
      bytes += generator.text('$qtyPrice${" " * paddingCount}$sub');
      if (item.catatan != null && item.catatan!.isNotEmpty) {
        bytes += generator.text('  * Catatan: ${item.catatan}', styles: const PosStyles(bold: false));
      }
    }
    bytes += generator.text('--------------------------------', styles: const PosStyles(align: PosAlign.center));

    // Summary
    String subtotalStr = 'Rp ${NumberFormat('#,###').format(order.subtotal)}';
    bytes += generator.text('Subtotal: ${" " * (32 - 10 - subtotalStr.length)}$subtotalStr');

    if (order.taxAmount > 0) {
      String taxStr = 'Rp ${NumberFormat('#,###').format(order.taxAmount)}';
      bytes += generator.text('Pajak (11%): ${" " * (32 - 13 - taxStr.length)}$taxStr');
    }
    if (order.serviceAmount > 0) {
      String svcStr = 'Rp ${NumberFormat('#,###').format(order.serviceAmount)}';
      bytes += generator.text('Service (5%): ${" " * (32 - 14 - svcStr.length)}$svcStr');
    }
    
    bytes += generator.text('--------------------------------', styles: const PosStyles(align: PosAlign.center));

    String totalStr = 'Rp ${NumberFormat('#,###').format(order.total)}';
    bytes += generator.text('TOTAL: ${" " * (32 - 7 - totalStr.length)}$totalStr',
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    String bayarStr = 'Rp ${NumberFormat('#,###').format(order.bayar)}';
    bytes += generator.text('Bayar: ${" " * (32 - 7 - bayarStr.length)}$bayarStr');

    String kembalianStr = 'Rp ${NumberFormat('#,###').format(order.kembalian)}';
    bytes += generator.text('Kembali: ${" " * (32 - 9 - kembalianStr.length)}$kembalianStr');

    bytes += generator.text('--------------------------------', styles: const PosStyles(align: PosAlign.center));

    // Footer
    bytes += generator.text('Terima Kasih atas Kunjungan Anda', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Aplikasi POS UMKMART', styles: const PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  /// Generate kitchen order ticket bytes
  Future<List<int>> _generateKitchenBytes(OrderModel order) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text('STRUK DAPUR / KITCHEN',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.text('Order : ${order.noOrder}', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Waktu : ${DateFormat('dd-MM-yyyy HH:mm').format(order.createdAt)}',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('================================', styles: const PosStyles(align: PosAlign.center));

    for (var item in order.items) {
      bytes += generator.text('${item.qty} x ${item.namaMenu}',
          styles: const PosStyles(
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
      if (item.catatan != null && item.catatan!.isNotEmpty) {
        bytes += generator.text('   * CATATAN: ${item.catatan}',
            styles: const PosStyles(
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ));
      }
      bytes += generator.text('--------------------------------');
    }
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  /// Print customer payment receipt
  Future<bool> printStrukPembayaran(OrderModel order, ConfigModel config) async {
    final bool connected = await isConnected;
    if (!connected) {
      debugPrint('[PrinterService] Printer tidak terhubung. Struk gagal dicetak secara fisik.');
      return false;
    }

    try {
      final bytes = await _generateReceiptBytes(order, config);
      final bool result = await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint('[PrinterService] Struk pembayaran berhasil dikirim ke printer thermal: $result');
      return result;
    } catch (e) {
      debugPrint('[PrinterService] Gagal mencetak struk: $e');
      return false;
    }
  }

  /// Print kitchen order receipt
  Future<bool> printStrukKitchen(OrderModel order) async {
    final bool connected = await isConnected;
    if (!connected) {
      debugPrint('[PrinterService] Printer tidak terhubung. Struk dapur gagal dicetak.');
      return false;
    }

    try {
      final bytes = await _generateKitchenBytes(order);
      final bool result = await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint('[PrinterService] Struk dapur berhasil dikirim ke printer thermal: $result');
      return result;
    } catch (e) {
      debugPrint('[PrinterService] Gagal mencetak struk dapur: $e');
      return false;
    }
  }
}
