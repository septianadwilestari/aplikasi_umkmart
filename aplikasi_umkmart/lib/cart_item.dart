import 'menu_model.dart';

class CartItem {
  final MenuModel menu;
  int qty;
  String? catatan;

  CartItem({
    required this.menu,
    required this.qty,
    this.catatan,
  });

  double get subtotal => menu.harga * qty;

  CartItem copyWith({
    MenuModel? menu,
    int? qty,
    String? catatan,
  }) {
    return CartItem(
      menu: menu ?? this.menu,
      qty: qty ?? this.qty,
      catatan: catatan ?? this.catatan,
    );
  }
}
