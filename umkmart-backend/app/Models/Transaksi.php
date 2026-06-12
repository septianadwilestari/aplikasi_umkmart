<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Transaksi extends Model
{
    protected $fillable = [
        'user_id', 'pelanggan_id', 'promo_id',
        'tanggal', 'total', 'diskon_nominal', 'total_akhir'
    ];

    public function detail() {
        return $this->hasMany(DetailTransaksi::class);
    }
    public function pelanggan() {
        return $this->belongsTo(Pelanggan::class);
    }
    public function user() {
        return $this->belongsTo(User::class);
    }
    public function promo() {
        return $this->belongsTo(Promo::class);
    }
}
