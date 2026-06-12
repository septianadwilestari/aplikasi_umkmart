<?php

namespace Database\Seeders;

use App\Models\Config;
use Illuminate\Database\Seeder;

class ConfigSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Config::updateOrCreate(
            ['id' => 1],
            [
                'tax_rate' => 11.0,
                'service_rate' => 5.0,
                'passcode_main' => '1234',
                'passcode_admin' => '0000',
                'nama_restoran' => 'Toko Berkah Abadi Jaya',
                'alamat' => 'Jl. Ketintang No. 123, Surabaya',
            ]
        );
    }
}
