<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $table = 'orders';

    protected $fillable = [
        'user_id',
        'no_order',
        'subtotal',
        'tax_amount',
        'service_amount',
        'total',
        'bayar',
        'kembalian',
        'metode_bayar',
        'status',
        'nama_pelanggan',
        'meja',
    ];

    protected $casts = [
        'subtotal' => 'double',
        'tax_amount' => 'double',
        'service_amount' => 'double',
        'total' => 'double',
        'bayar' => 'double',
        'kembalian' => 'double',
        'meja' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class, 'order_id');
    }
}
