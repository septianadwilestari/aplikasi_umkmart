<?php

namespace App\Http\Controllers;

use App\Models\Config;
use Illuminate\Http\Request;

class POSConfigController extends Controller
{
    /**
     * Get active config.
     */
    public function index()
    {
        $config = Config::first();
        if (!$config) {
            $config = Config::create([
                'tax_rate' => 11.0,
                'service_rate' => 5.0,
                'passcode_main' => '1234',
                'passcode_admin' => '0000',
                'nama_restoran' => 'Warung UMKMART',
                'alamat' => 'Jl. Contoh No. 123, Surabaya',
            ]);
        }
        return response()->json($config);
    }

    /**
     * Update config.
     */
    public function update(Request $request)
    {
        $config = Config::first();
        if (!$config) {
            $config = Config::create([
                'tax_rate' => 11.0,
                'service_rate' => 5.0,
                'passcode_main' => '1234',
                'passcode_admin' => '0000',
                'nama_restoran' => 'Warung UMKMART',
                'alamat' => 'Jl. Contoh No. 123, Surabaya',
            ]);
        }

        $request->validate([
            'tax_rate' => 'sometimes|required|numeric|min:0|max:100',
            'service_rate' => 'sometimes|required|numeric|min:0|max:100',
            'passcode_main' => 'sometimes|required|string|size:4',
            'passcode_admin' => 'sometimes|required|string|size:4',
            'nama_restoran' => 'sometimes|required|string|max:100',
            'alamat' => 'sometimes|nullable|string',
        ]);

        $config->update($request->only([
            'tax_rate', 'service_rate', 'passcode_main', 'passcode_admin', 'nama_restoran', 'alamat'
        ]));

        return response()->json($config);
    }

    /**
     * Verify passcode.
     */
    public function verifyPasscode(Request $request)
    {
        $request->validate([
            'type' => 'required|in:main,admin',
            'passcode' => 'required|string',
        ]);

        $config = Config::first();
        if (!$config) {
            $config = Config::create([
                'tax_rate' => 11.0,
                'service_rate' => 5.0,
                'passcode_main' => '1234',
                'passcode_admin' => '0000',
                'nama_restoran' => 'Warung UMKMART',
                'alamat' => 'Jl. Contoh No. 123, Surabaya',
            ]);
        }

        $type = $request->input('type');
        $passcode = $request->input('passcode');
        $storedPasscode = $type === 'admin' ? $config->passcode_admin : $config->passcode_main;

        if ($passcode === $storedPasscode) {
            return response()->json([
                'success' => true,
                'message' => 'Verifikasi passcode berhasil'
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Passcode salah!'
        ], 400);
    }
}
