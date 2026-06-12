<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    protected $table = 'order_items';

    protected $fillable = [
        'order_id',
        'menu_id',
        'nama_menu',
        'harga_satuan',
        'qty',
        'subtotal',
        'catatan',
    ];

    protected $casts = [
        'harga_satuan' => 'double',
        'qty' => 'integer',
        'subtotal' => 'double',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class, 'order_id');
    }

    public function menu()
    {
        return $this->belongsTo(Menu::class, 'menu_id');
    }
}
