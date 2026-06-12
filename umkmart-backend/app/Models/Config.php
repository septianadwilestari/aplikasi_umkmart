<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Config extends Model
{
    use HasFactory;

    protected $table = 'config';

    protected $fillable = [
        'tax_rate',
        'service_rate',
        'passcode_main',
        'passcode_admin',
        'nama_restoran',
        'alamat',
    ];

    protected $casts = [
        'tax_rate' => 'double',
        'service_rate' => 'double',
    ];
}
