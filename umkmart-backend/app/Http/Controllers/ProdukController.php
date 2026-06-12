<?php
namespace App\Http\Controllers;

use App\Models\Menu;
use Illuminate\Http\Request;

class ProdukController extends Controller
{
    private function mapToProduks($items)
    {
        return $items->map(fn($m) => [
            'id'          => $m->id,
            'nama_produk' => $m->nama,
            'harga'       => (double) $m->harga,
            'stok'        => (int) $m->stok,
            'kategori'    => $m->kategori ?? null,
            'gambar'      => $m->foto ? asset($m->foto) : null, // ✅ map foto → gambar
        ]);
    }

    public function index()
    {
        return response()->json($this->mapToProduks(Menu::orderBy('nama')->get()));
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama_produk' => 'required|string|max:100',
            'harga'       => 'required|numeric|min:0',
            'stok'        => 'required|integer|min:0',
            'kategori'    => 'nullable|string|max:50',
            'foto'        => 'nullable|image|max:2048', // ✅ terima foto
        ]);

        $data = [
            'nama'     => $request->nama_produk,
            'harga'    => $request->harga,
            'stok'     => $request->stok ?? 0,
            'kategori' => $request->kategori ?? 'Umum',
            'tersedia' => ($request->stok ?? 0) > 0,
        ];

        // ✅ Handle upload foto
        if ($request->hasFile('foto')) {
            $file     = $request->file('foto');
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('menu'), $filename);
            $data['foto'] = 'menu/' . $filename;
        }

        $menu = Menu::create($data);

        return response()->json([
            'id'          => $menu->id,
            'nama_produk' => $menu->nama,
            'harga'       => (double) $menu->harga,
            'stok'        => (int) $menu->stok,
            'kategori'    => $menu->kategori,
            'gambar'      => $menu->foto ? asset($menu->foto) : null,
        ], 201);
    }

    public function show($id)
    {
        $menu = Menu::findOrFail($id);
        return response()->json([
            'id'          => $menu->id,
            'nama_produk' => $menu->nama,
            'harga'       => (double) $menu->harga,
            'stok'        => (int) $menu->stok,
            'kategori'    => $menu->kategori,
            'gambar'      => $menu->foto ? asset($menu->foto) : null,
        ]);
    }

    public function update(Request $request, $id)
    {
        $menu = Menu::findOrFail($id);

        $request->validate([
            'nama_produk' => 'sometimes|required|string|max:100',
            'harga'       => 'sometimes|required|numeric|min:0',
            'stok'        => 'sometimes|required|integer|min:0',
            'kategori'    => 'nullable|string|max:50',
            'foto'        => 'nullable|image|max:2048', // ✅ terima foto
        ]);

        $data = [
            'nama'     => $request->nama_produk ?? $menu->nama,
            'harga'    => $request->harga       ?? $menu->harga,
            'stok'     => $request->stok        ?? $menu->stok,
            'kategori' => $request->kategori    ?? $menu->kategori,
            'tersedia' => ($request->stok ?? $menu->stok) > 0,
        ];

        // ✅ Handle upload foto baru, hapus foto lama
        if ($request->hasFile('foto')) {
            if ($menu->foto && file_exists(public_path($menu->foto))) {
                @unlink(public_path($menu->foto));
            }
            $file     = $request->file('foto');
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('menu'), $filename);
            $data['foto'] = 'menu/' . $filename;
        }

        $menu->update($data);

        return response()->json([
            'id'          => $menu->id,
            'nama_produk' => $menu->nama,
            'harga'       => (double) $menu->harga,
            'stok'        => (int) $menu->stok,
            'kategori'    => $menu->kategori,
            'gambar'      => $menu->foto ? asset($menu->foto) : null,
        ]);
    }

    public function destroy($id)
    {
        $menu = Menu::findOrFail($id);

        // ✅ Hapus foto saat produk dihapus
        if ($menu->foto && file_exists(public_path($menu->foto))) {
            @unlink(public_path($menu->foto));
        }

        $menu->delete();
        return response()->json(['message' => 'Produk dihapus']);
    }

    public function stokMenipis()
    {
        return response()->json($this->mapToProduks(Menu::where('stok', '<=', 5)->get()));
    }
}