# UMKMART

Aplikasi manajemen usaha mikro berbasis Flutter. Dilengkapi dengan fitur kasir/POS, laporan penjualan, manajemen produk & pelanggan, serta broadcast promo WhatsApp.

## Teknologi
- **Frontend**: Flutter (Mobile)
- **Backend**: Laravel (REST API)

## Fitur
- Kasir / POS
- Laporan Penjualan
- Manajemen Produk
- Manajemen Pelanggan
- Broadcast Promo WhatsApp
- AI Bisnis (Gemini)

## Cara Menjalankan

### Backend (Laravel)
```bash
cd umkmart-backend
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

### Frontend (Flutter)
```bash
cd aplikasi_umkmart
flutter pub get
flutter run
```

## Konfigurasi
Ubah `baseUrl` di `aplikasi_umkmart/lib/utils/constants.dart` sesuai IP laptop kamu.
