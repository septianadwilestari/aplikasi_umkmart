<?php
namespace App\Http\Controllers;

use App\Models\Transaksi;
use App\Models\DetailTransaksi;
use App\Models\Produk;
use App\Models\Pelanggan;
use App\Models\Promo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransaksiController extends Controller
{
    public function index()
    {
        return response()->json(
            Transaksi::with(['detail.produk', 'pelanggan', 'user'])
                ->orderBy('tanggal', 'desc')
                ->get()
        );
    }

    public function store(Request $request)
    {
        $request->validate([
            'pelanggan_id' => 'nullable|exists:pelanggans,id',
            'promo_id'     => 'nullable|exists:promos,id',
            'items'        => 'required|array|min:1',
            'items.*.produk_id' => 'required|exists:produks,id',
            'items.*.jumlah'    => 'required|integer|min:1',
        ]);

        DB::beginTransaction();
        try {
            $total = 0;
            $itemsData = [];

            foreach ($request->items as $item) {
                $produk = Produk::findOrFail($item['produk_id']);
                if ($produk->stok < $item['jumlah']) {
                    return response()->json([
                        'message' => "Stok {$produk->nama_produk} tidak cukup"
                    ], 422);
                }
                $subtotal = $produk->harga * $item['jumlah'];
                $total += $subtotal;
                $itemsData[] = [
                    'produk_id'    => $produk->id,
                    'jumlah'       => $item['jumlah'],
                    'harga_satuan' => $produk->harga,
                    'subtotal'     => $subtotal,
                ];
                $produk->decrement('stok', $item['jumlah']);
            }

            $diskonNominal = 0;
            if ($request->promo_id) {
                $promo = Promo::find($request->promo_id);
                if ($promo && $promo->aktif) {
                    $diskonNominal = $total * ($promo->diskon / 100);
                }
            }

            $transaksi = Transaksi::create([
                'user_id'        => $request->user()->id,
                'pelanggan_id'   => $request->pelanggan_id,
                'promo_id'       => $request->promo_id,
                'tanggal'        => now(),
                'total'          => $total,
                'diskon_nominal' => $diskonNominal,
                'total_akhir'    => $total - $diskonNominal,
            ]);

            foreach ($itemsData as $item) {
                $transaksi->detail()->create($item);
            }

            // Tambah poin loyalitas pelanggan (1 poin per Rp 10.000)
            if ($request->pelanggan_id) {
                $poin = (int) floor(($total - $diskonNominal) / 10000);
                Pelanggan::find($request->pelanggan_id)->increment('poin_loyalitas', $poin);
            }

            DB::commit();
            return response()->json($transaksi->load(['detail.produk', 'pelanggan']), 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => $e->getMessage()], 500);
        }
    }

    public function show($id)
    {
        return response()->json(
            Transaksi::with(['detail.produk', 'pelanggan', 'user'])->findOrFail($id)
        );
    }
}