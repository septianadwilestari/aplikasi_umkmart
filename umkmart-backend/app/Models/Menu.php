<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Menu extends Model
{
    use HasFactory;

    protected $table = 'menu';

    protected $fillable = [
        'nama',
        'foto',
        'harga',
        'stok',
        'kategori',
        'tersedia',
    ];

    protected $casts = [
        'harga' => 'double',
        'stok' => 'integer',
        'tersedia' => 'boolean',
    ];

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class, 'menu_id');
    }
}
