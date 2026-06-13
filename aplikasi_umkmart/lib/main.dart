import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/app_theme.dart';
import 'viewmodels/viewmodels.dart';
import 'viewmodels/transaksi_viewmodel.dart';
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/main_screen.dart';
import 'views/produk/produk_form_screen.dart';
import 'views/pos/pos_screen.dart';
import 'views/pos/passcode_screen.dart';
import 'views/promo/broadcast_screen.dart';
import 'views/ai/ai_business_screen.dart';
import 'views/profil/edit_profil_screen.dart';
import 'views/pengaturan/pengaturan_screen.dart';
import 'views/notifikasi/notifikasi_screen.dart';
import 'views/laporan/detail_transaksi_laporan_screen.dart';
import 'views/produk/produk_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const UmkmartApp());
}

class UmkmartApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const UmkmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..loadUser()),
        ChangeNotifierProvider(create: (_) => ProdukViewModel()),
        ChangeNotifierProvider(create: (_) => MenuViewModel()),

        // TransaksiViewModel harus dibuat SEBELUM PosViewModel
        // karena PosViewModel butuh reference ke sini
        ChangeNotifierProvider(create: (_) => TransaksiViewModel()),

        // PosViewModel dibuat dengan inject TransaksiViewModel
        ChangeNotifierProxyProvider<TransaksiViewModel, PosViewModel>(
          create: (_) => PosViewModel(),
          update: (_, transaksiVm, posVm) {
            // Setiap kali TransaksiViewModel berubah, update reference di PosViewModel
            // Ini memastikan checkout() bisa langsung push ke riwayat transaksi
            posVm!.transaksiViewModel = transaksiVm;
            return posVm;
          },
        ),
      ],
      child: MaterialApp(
        title: 'UMKMART',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/':                (_) => const SplashScreen(),
          '/login':           (_) => const LoginScreen(),
          '/register':        (_) => const RegisterScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/dashboard':       (_) => const MainScreen(),
          '/produk/form':     (_) => const ProdukFormScreen(),
          '/pos':             (_) => const PosScreen(),
          '/pos/passcode':    (_) => const PasscodeScreen(),
          '/broadcast':       (_) => BroadcastScreen(),
          '/ai-bisnis':       (_) => const AiBusinessScreen(),
          '/profil/edit':     (_) => const EditProfilScreen(),
          '/pengaturan':      (_) => const PengaturanScreen(),
          '/notifikasi':      (_) => const NotifikasiScreen(),
          '/transaksi':       (_) => const DetailTransaksiLaporanScreen(),
          '/produk':          (_) => const ProdukListScreen(),
        },
      ),
    );
  }
}