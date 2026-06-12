<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MenuSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('menu')->truncate();
        
        $now = now();
        DB::table('menu')->insert([

            // ── BERAS & TEPUNG ──
            ['nama'=>'Beras Premium 5kg','harga'=>75000,'stok'=>50,'kategori'=>'Beras & Tepung','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Beras Medium 5kg','harga'=>58000,'stok'=>40,'kategori'=>'Beras & Tepung','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Tepung Terigu 1kg','harga'=>12000,'stok'=>30,'kategori'=>'Beras & Tepung','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Tepung Beras 500gr','harga'=>8000,'stok'=>25,'kategori'=>'Beras & Tepung','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Tepung Tapioka 500gr','harga'=>7000,'stok'=>20,'kategori'=>'Beras & Tepung','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],

            // ── MINYAK & LEMAK ──
            ['nama'=>'Minyak Goreng 1L','harga'=>18000,'stok'=>60,'kategori'=>'Minyak & Lemak','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Minyak Goreng 2L','harga'=>34000,'stok'=>40,'kategori'=>'Minyak & Lemak','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Minyak Sayur 5L','harga'=>78000,'stok'=>20,'kategori'=>'Minyak & Lemak','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Margarin 200gr','harga'=>9000,'stok'=>35,'kategori'=>'Minyak & Lemak','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],

            // ── GULA & GARAM ──
            ['nama'=>'Gula Pasir 1kg','harga'=>14000,'stok'=>50,'kategori'=>'Gula & Garam','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Gula Merah 250gr','harga'=>8000,'stok'=>30,'kategori'=>'Gula & Garam','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Garam Halus 250gr','harga'=>3000,'stok'=>40,'kategori'=>'Gula & Garam','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Gula Aren 250gr','harga'=>10000,'stok'=>7,'kategori'=>'Gula & Garam','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],

            // ── MIE & PASTA ──
            ['nama'=>'Mie Instan Goreng','harga'=>3500,'stok'=>100,'kategori'=>'Mie & Pasta','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Mie Instan Kuah','harga'=>3500,'stok'=>100,'kategori'=>'Mie & Pasta','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Mie Telur 200gr','harga'=>8000,'stok'=>25,'kategori'=>'Mie & Pasta','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Bihun 200gr','harga'=>7000,'stok'=>20,'kategori'=>'Mie & Pasta','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Soun 100gr','harga'=>5000,'stok'=>15,'kategori'=>'Mie & Pasta','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],

            // ── BUMBU & REMPAH ──
            ['nama'=>'Kecap Manis 135ml','harga'=>7000,'stok'=>40,'kategori'=>'Bumbu & Rempah','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Kecap Asin 135ml','harga'=>6000,'stok'=>30,'kategori'=>'Bumbu & Rempah','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Saos Tomat 135ml','harga'=>7500,'stok'=>25,'kategori'=>'Bumbu & Rempah','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Saos Sambal 135ml','harga'=>7500,'stok'=>25,'kategori'=>'Bumbu & Rempah','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Bumbu Racik Ayam','harga'=>2500,'stok'=>50,'kategori'=>'Bumbu & Rempah','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Bumbu Racik Soto','harga'=>2500,'stok'=>45,'kategori'=>'Bumbu & Rempah','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Merica Bubuk 25gr','harga'=>5000,'stok'=>8,'kategori'=>'Bumbu & Rempah','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Penyedap Rasa 50gr','harga'=>4000,'stok'=>60,'kategori'=>'Bumbu & Rempah','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],

            // ── MINUMAN ──
            ['nama'=>'Air Mineral 600ml','harga'=>3000,'stok'=>100,'kategori'=>'Minuman','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Air Mineral 1500ml','harga'=>5000,'stok'=>60,'kategori'=>'Minuman','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Teh Celup 25pcs','harga'=>9000,'stok'=>35,'kategori'=>'Minuman','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Kopi Sachet 10pcs','harga'=>15000,'stok'=>30,'kategori'=>'Minuman','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Susu Kental Manis','harga'=>12000,'stok'=>7,'kategori'=>'Minuman','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Sirup Merah 630ml','harga'=>22000,'stok'=>0,'kategori'=>'Minuman','tersedia'=>false,'created_at'=>$now,'updated_at'=>$now],

            // ── SNACK & MAKANAN RINGAN ──
            ['nama'=>'Kerupuk Udang 250gr','harga'=>12000,'stok'=>20,'kategori'=>'Snack','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Biskuit Kelapa 150gr','harga'=>8000,'stok'=>15,'kategori'=>'Snack','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Wafer Coklat 150gr','harga'=>10000,'stok'=>12,'kategori'=>'Snack','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Keripik Singkong 100gr','harga'=>7000,'stok'=>0,'kategori'=>'Snack','tersedia'=>false,'created_at'=>$now,'updated_at'=>$now],

            // ── SABUN ──
            ['nama'=>'Sabun Cuci Piring 500ml','harga'=>13000,'stok'=>25,'kategori'=>'Kebersihan','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Sabun Mandi 100gr','harga'=>4000,'stok'=>30,'kategori'=>'Kebersihan','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Deterjen Bubuk 1kg','harga'=>18000,'stok'=>9,'kategori'=>'Kebersihan','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Sabun Colek 200gr','harga'=>5000,'stok'=>20,'kategori'=>'Kebersihan','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
            ['nama'=>'Pembersih Lantai 500ml','harga'=>12000,'stok'=>0,'kategori'=>'Kebersihan','tersedia'=>false,'created_at'=>$now,'updated_at'=>$now],

            // ── GAS ──
            ['nama'=>'Gas LPG 3kg (isi ulang)','harga'=>22000,'stok'=>15,'kategori'=>'Gas & Energi','tersedia'=>true,'created_at'=>$now,'updated_at'=>$now],
        ]);
    }
}
