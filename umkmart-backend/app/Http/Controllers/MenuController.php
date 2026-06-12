<?php

namespace App\Http\Controllers;

use App\Models\Menu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MenuController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $kategori = $request->query('kategori');
        $query = Menu::query();

        if ($kategori && $kategori !== 'Semua') {
            $query->where('kategori', $kategori);
        }

        return response()->json($query->orderBy('nama')->get());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:100',
            'harga' => 'required|numeric|min:0',
            'stok' => 'nullable|integer|min:0',
            'kategori' => 'nullable|string|max:50',
            'foto' => 'nullable|image|max:2048', // max 2MB
        ]);

        $data = $request->only(['nama', 'harga', 'stok', 'kategori']);
        $data['stok'] = $data['stok'] ?? 0;
        $data['kategori'] = $data['kategori'] ?? 'Umum';
        $data['tersedia'] = $data['stok'] > 0;

        if ($request->hasFile('foto')) {
            $file = $request->file('foto');
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('menu'), $filename);
            $data['foto'] = 'menu/' . $filename;
        }

        $menu = Menu::create($data);

        return response()->json($menu, 201);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $menu = Menu::findOrFail($id);

        $request->validate([
            'nama' => 'sometimes|required|string|max:100',
            'harga' => 'sometimes|required|numeric|min:0',
            'stok' => 'sometimes|required|integer|min:0',
            'kategori' => 'sometimes|required|string|max:50',
            'foto' => 'nullable|image|max:2048',
            'tersedia' => 'nullable|boolean',
        ]);

        $data = $request->only(['nama', 'harga', 'stok', 'kategori', 'tersedia']);
        
        if (isset($data['stok'])) {
            $data['tersedia'] = $data['stok'] > 0;
        }

        if ($request->hasFile('foto')) {
            // Delete old photo if exists
            if ($menu->foto && file_exists(public_path($menu->foto))) {
                @unlink(public_path($menu->foto));
            }

            $file = $request->file('foto');
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('menu'), $filename);
            $data['foto'] = 'menu/' . $filename;
        }

        $menu->update($data);

        return response()->json($menu);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $menu = Menu::findOrFail($id);

        if ($menu->foto && file_exists(public_path($menu->foto))) {
            @unlink(public_path($menu->foto));
        }

        $menu->delete();

        return response()->json(['message' => 'Menu berhasil dihapus']);
    }

    /**
     * Update stock only.
     */
    public function updateStok(Request $request, $id)
    {
        $request->validate([
            'tambah' => 'required|integer',
        ]);

        $menu = Menu::findOrFail($id);
        $menu->stok += $request->tambah;
        if ($menu->stok < 0) {
            $menu->stok = 0;
        }
        $menu->tersedia = $menu->stok > 0;
        $menu->save();

        return response()->json($menu);
    }

    /**
     * Import from Google Sheet CSV URL.
     */
    public function importFromSheet(Request $request)
    {
        $request->validate([
            'url' => 'required|url',
        ]);

        $url = $request->input('url');

        // Convert standard sheet URL to direct export CSV link if needed
        if (str_contains($url, '/edit')) {
            $url = preg_replace('/\/edit.*/', '/export?format=csv', $url);
        }

        try {
            $response = Http::get($url);
            if (!$response->successful()) {
                return response()->json(['message' => 'Gagal mengunduh spreadsheet. Pastikan link dipublikasikan untuk umum.'], 400);
            }

            $csvContent = $response->body();
            $lines = preg_split('/\r\n|\r|\n/', $csvContent);
            $header = null;
            $imported = 0;
            $updated = 0;

            foreach ($lines as $line) {
                if (empty(trim($line))) {
                    continue;
                }

                $row = str_getcsv($line);
                if (!$header) {
                    // Lowercase and trim headers
                    $header = array_map('strtolower', array_map('trim', $row));
                    continue;
                }

                if (count($row) < count($header)) {
                    // Fill up row elements if short
                    $row = array_pad($row, count($header), '');
                }

                $data = array_combine($header, array_slice($row, 0, count($header)));

                $nama = $data['nama'] ?? null;
                $harga = floatval($data['harga'] ?? 0);
                $stok = intval($data['stok'] ?? 0);
                $kategori = $data['kategori'] ?? 'Umum';

                if (!$nama || empty(trim($nama))) {
                    continue;
                }

                $menu = Menu::where('nama', $nama)->first();
                if ($menu) {
                    $menu->update([
                        'harga' => $harga,
                        'stok' => $stok,
                        'kategori' => empty($kategori) ? 'Umum' : $kategori,
                        'tersedia' => $stok > 0
                    ]);
                    $updated++;
                } else {
                    Menu::create([
                        'nama' => $nama,
                        'harga' => $harga,
                        'stok' => $stok,
                        'kategori' => empty($kategori) ? 'Umum' : $kategori,
                        'tersedia' => $stok > 0
                    ]);
                    $imported++;
                }
            }

            return response()->json([
                'imported' => $imported,
                'updated' => $updated
            ]);

        } catch (\Exception $e) {
            Log::error('[MenuController] Import CSV error: ' . $e->getMessage());
            return response()->json(['message' => 'Terjadi kesalahan saat memproses file CSV: ' . $e->getMessage()], 500);
        }
    }
}
