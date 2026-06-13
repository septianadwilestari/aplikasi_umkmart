import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'transaksi_viewmodel.dart';

class PosViewModel extends ChangeNotifier {
  final MenuService _menuService = MenuService();
  final ConfigService _configService = ConfigService();
  final OrderService _orderService = OrderService();

  // ── Inject TransaksiViewModel agar checkout bisa langsung push riwayat ──
  // Di-set dari luar setelah provide (lihat pos_screen.dart atau main.dart)
  TransaksiViewModel? transaksiViewModel;

  List<MenuModel> _menuList = [];
  List<CartItem> _cart = [];
  ConfigModel? _config;
  bool _isLoading = false;
  String? _errorMessage;

  List<MenuModel> get menuList => _menuList;
  List<CartItem> get cart => List.unmodifiable(_cart);
  ConfigModel? get config => _config;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Loading ──────────────────────────────────────────────────────────────

  Future<void> loadMenu() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _menuList = await _menuService.getMenu();
    } catch (e) {
      _errorMessage = 'Gagal memuat menu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConfig() async {
    try {
      _config = await _configService.getConfig();
      notifyListeners();
    } catch (e) {
      debugPrint('[PosViewModel] Gagal memuat config: $e');
    }
  }

  // ── Cart management ──────────────────────────────────────────────────────

  void addToCart(MenuModel menu) {
    if (menu.stok <= 0) {
      _errorMessage = 'Stok menu "${menu.nama}" habis!';
      notifyListeners();
      return;
    }

    final int index = _cart.indexWhere((item) => item.menu.id == menu.id);
    if (index != -1) {
      if (_cart[index].qty >= menu.stok) {
        _errorMessage =
            'Stok "${menu.nama}" tidak mencukupi (Max: ${menu.stok})';
        notifyListeners();
        return;
      }
      final updated = _cart[index].copyWith(qty: _cart[index].qty + 1);
      _cart = [
        ..._cart.sublist(0, index),
        updated,
        ..._cart.sublist(index + 1),
      ];
    } else {
      _cart = [..._cart, CartItem(menu: menu, qty: 1)];
    }
    _errorMessage = null;
    notifyListeners();
  }

  void removeFromCart(int menuId) {
    _cart = _cart.where((item) => item.menu.id != menuId).toList();
    notifyListeners();
  }

  void updateQty(int menuId, int qty) {
    if (qty <= 0) {
      removeFromCart(menuId);
      return;
    }
    final int index = _cart.indexWhere((item) => item.menu.id == menuId);
    if (index != -1) {
      final menu = _cart[index].menu;
      if (qty > menu.stok) {
        _errorMessage =
            'Stok "${menu.nama}" tidak mencukupi (Max: ${menu.stok})';
        notifyListeners();
        return;
      }
      final updated = _cart[index].copyWith(qty: qty);
      _cart = [
        ..._cart.sublist(0, index),
        updated,
        ..._cart.sublist(index + 1),
      ];
      _errorMessage = null;
      notifyListeners();
    }
  }

  void updateCatatan(int menuId, String catatan) {
    final int index = _cart.indexWhere((item) => item.menu.id == menuId);
    if (index != -1) {
      final updated = _cart[index].copyWith(
        catatan: catatan.isEmpty ? null : catatan,
      );
      _cart = [
        ..._cart.sublist(0, index),
        updated,
        ..._cart.sublist(index + 1),
      ];
      notifyListeners();
    }
  }

  void clearCart() {
    _cart = [];
    _errorMessage = null;
    notifyListeners();
  }

  // ── Computed values ──────────────────────────────────────────────────────

  double get subtotal =>
      _cart.fold(0.0, (sum, item) => sum + item.subtotal);

  double get taxAmount {
    if (_config == null) return subtotal * 0.11;
    return subtotal * (_config!.taxRate / 100);
  }

  double get serviceAmount {
    if (_config == null) return subtotal * 0.05;
    return subtotal * (_config!.serviceRate / 100);
  }

  double get total => subtotal + taxAmount + serviceAmount;

  int get totalItems => _cart.fold(0, (sum, item) => sum + item.qty);

  // ── Checkout ─────────────────────────────────────────────────────────────

  Future<OrderModel?> checkout({
    required String metodeBayar,
    required double bayar,
    String? namaPelanggan,
    int? meja,
  }) async {
    if (_cart.isEmpty) {
      _errorMessage = 'Keranjang masih kosong!';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        items: _cart,
        metodeBayar: metodeBayar,
        bayar: bayar,
        namaPelanggan: namaPelanggan,
        meja: meja,
      );

      // ── KUNCI: push order ke TransaksiViewModel ──────────────────────
      // Ini yang menghubungkan POS → halaman Transaksi
      transaksiViewModel?.tambahTransaksi(order);

      // Update stok lokal
      _menuList = _menuList.map((m) {
        final cartItem = _cart.firstWhere(
          (c) => c.menu.id == m.id,
          orElse: () => CartItem(menu: m, qty: 0),
        );
        if (cartItem.qty == 0) return m;
        final newStok = (m.stok - cartItem.qty).clamp(0, m.stok);
        return m.copyWith(stok: newStok, tersedia: newStok > 0);
      }).toList();

      clearCart();
      return order;
    } catch (e) {
      _errorMessage = 'Checkout gagal: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}