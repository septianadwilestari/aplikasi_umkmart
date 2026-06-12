<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProdukController;
use App\Http\Controllers\PelangganController;
use App\Http\Controllers\TransaksiController;
use App\Http\Controllers\PromoController;
use App\Http\Controllers\LaporanController;
use App\Http\Controllers\PengeluaranController;
use App\Http\Controllers\MenuController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\POSConfigController;

// Auth (tidak perlu token)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);
Route::post('/auth/google', [AuthController::class, 'loginWithGoogle']);
Route::post('/auth/facebook', [AuthController::class, 'loginWithFacebook']);

// Semua route di bawah ini butuh token
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Produk
    Route::apiResource('produk', ProdukController::class);
    Route::get('/produk-stok-menipis', [ProdukController::class, 'stokMenipis']);

    // Pelanggan
    Route::apiResource('pelanggan', PelangganController::class);

    // Promo
    Route::apiResource('promo', PromoController::class);

    // Transaksi
    Route::get('/transaksi',       [TransaksiController::class, 'index']);
    Route::post('/transaksi',      [TransaksiController::class, 'store']);
    Route::get('/transaksi/{id}',  [TransaksiController::class, 'show']);

    // Pengeluaran
    Route::apiResource('pengeluaran', PengeluaranController::class);

    // Laporan
    Route::get('/laporan/dashboard',        [LaporanController::class, 'dashboard']);
    Route::get('/laporan/produk-terlaris',  [LaporanController::class, 'produkTerlaris']);
    Route::get('/laporan/bulanan',          [LaporanController::class, 'bulanan']);
    Route::get('/laporan/hari-ini',         [LaporanController::class, 'hariIni']);
    Route::get('/laporan/7-hari',           [LaporanController::class, 'tujuhHari']);

    // POS Menu
    Route::get('/menu',                [MenuController::class, 'index']);
    Route::post('/menu',               [MenuController::class, 'store']);
    Route::put('/menu/{id}',           [MenuController::class, 'update']);
    Route::delete('/menu/{id}',        [MenuController::class, 'destroy']);
    Route::patch('/menu/{id}/stok',    [MenuController::class, 'updateStok']);
    Route::post('/menu/import-sheet',  [MenuController::class, 'importFromSheet']);

    // POS Orders
    Route::post('/orders',             [OrderController::class, 'store']);
    Route::get('/orders',              [OrderController::class, 'index']);
    Route::get('/orders/{id}',         [OrderController::class, 'show']);

    // POS Config
    Route::get('/config',                  [POSConfigController::class, 'index']);
    Route::put('/config',                  [POSConfigController::class, 'update']);
    Route::post('/config/verify-passcode', [POSConfigController::class, 'verifyPasscode']);
});