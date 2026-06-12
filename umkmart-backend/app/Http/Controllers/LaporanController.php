<?php
namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Pengeluaran;
use App\Models\Produk;
use App\Models\Menu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class LaporanController extends Controller
{
    public function dashboard(Request $request)
    {
        $today     = now()->toDateString();
        $yesterday = now()->subDay()->toDateString();

        $omzetRows = Order::selectRaw('DATE(created_at) as tgl, SUM(total) as total')
            ->whereIn(DB::raw('DATE(created_at)'), [$today, $yesterday])
            ->groupBy('tgl')
            ->pluck('total', 'tgl');

        $omzetHariIni  = (double) ($omzetRows[$today]     ?? 0);
        $omzetKemarin  = (double) ($omzetRows[$yesterday] ?? 0);

        $pengeluaranHariIni = (double) Pengeluaran::whereDate('tanggal', $today)->sum('jumlah');
        $labaHariIni        = $omzetHariIni - $pengeluaranHariIni;
        $transaksiHariIni   = (int) Order::whereDate('created_at', $today)->count();

        $persenOmzet = $omzetKemarin > 0
            ? round((($omzetHariIni - $omzetKemarin) / $omzetKemarin) * 100, 1)
            : 0;

        return response()->json([
            'omzet_hari_ini'       => $omzetHariIni,
            'omzet_kemarin'        => $omzetKemarin,
            'persen_omzet'         => $persenOmzet,
            'pengeluaran_hari_ini' => $pengeluaranHariIni,
            'laba_hari_ini'        => $labaHariIni,
            'transaksi_hari_ini'   => $transaksiHariIni,
            'stok_menipis'         => (int) Menu::where('stok', '<=', 5)->count(),
            'total_produk'         => (int) Menu::count(),
        ]);
    }

    public function hariIni(Request $request)
    {
        $startDate = $request->get('start_date', now()->toDateString());
        $endDate   = $request->get('end_date',   now()->toDateString());

        $row = Order::selectRaw('SUM(total) as omzet, COUNT(*) as jumlah_transaksi')
            ->whereBetween(DB::raw('DATE(created_at)'), [$startDate, $endDate])
            ->first();

        $omzetHariIni     = (double) ($row->omzet            ?? 0);
        $transaksiHariIni = (int)    ($row->jumlah_transaksi ?? 0);

        $pengeluaranHariIni = (double) Pengeluaran::selectRaw('SUM(jumlah) as total')
            ->whereBetween(DB::raw('DATE(tanggal)'), [$startDate, $endDate])
            ->value('total') ?? 0;

        $labaHariIni = $omzetHariIni - $pengeluaranHariIni;

        $today     = now()->toDateString();
        $yesterday = now()->subDay()->toDateString();

        $omzetRows = Order::selectRaw('DATE(created_at) as tgl, SUM(total) as total')
            ->whereIn(DB::raw('DATE(created_at)'), [$today, $yesterday])
            ->groupBy('tgl')
            ->pluck('total', 'tgl');

        $omzetToday   = (double) ($omzetRows[$today]     ?? 0);
        $omzetKemarin = (double) ($omzetRows[$yesterday] ?? 0);

        $persenOmzet = $omzetKemarin > 0
            ? round((($omzetToday - $omzetKemarin) / $omzetKemarin) * 100, 1)
            : 0;

        return response()->json([
            'omzet_hari_ini'       => $omzetHariIni,
            'laba_hari_ini'        => $labaHariIni,
            'transaksi_hari_ini'   => $transaksiHariIni,
            'pengeluaran_hari_ini' => $pengeluaranHariIni,
            'omzet_kemarin'        => $omzetKemarin,
            'persen_omzet'         => $persenOmzet,
            'total_produk'         => (int) Menu::count(),
            'stok_menipis'         => (int) Menu::where('stok', '<=', 5)->count(),
        ]);
    }

    public function tujuhHari(Request $request)
    {
        $hariId = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

        $endDate   = $request->get('end_date',   now()->toDateString());
        $startDate = $request->get('start_date', now()->subDays(6)->toDateString());

        $end   = Carbon::parse($endDate);
        $start = Carbon::parse($startDate);

        if ($start->diffInDays($end) > 6) {
            $start = $end->copy()->subDays(6);
        }

        // ✅ 1 query untuk omzet + total_order sekaligus
        $rows = Order::selectRaw('
                DATE(created_at) as tgl,
                SUM(total) as omzet,
                COUNT(*) as total_order
            ')
            ->whereBetween(DB::raw('DATE(created_at)'), [
                $start->toDateString(),
                $end->toDateString(),
            ])
            ->groupBy('tgl')
            ->get()
            ->keyBy('tgl');

        $data    = [];
        $current = $start->copy();

        while ($current->lte($end)) {
            $tgl = $current->toDateString();
            $dow = (int) $current->format('w');
            $row = $rows->get($tgl);

            $data[] = [
                'tanggal'     => $tgl,
                'hari'        => $hariId[$dow],
                'omzet'       => (double) ($row->omzet       ?? 0),
                'total_order' => (int)    ($row->total_order ?? 0),
            ];

            $current->addDay();
        }

        return response()->json($data);
    }

    public function produkTerlaris(Request $request)
    {
        $limit = $request->get('limit', 10);

        $result = DB::table('order_items')
            ->select('menu_id', 'nama_menu', DB::raw('SUM(qty) as total_terjual'))
            ->groupBy('menu_id', 'nama_menu')
            ->orderByDesc('total_terjual')
            ->limit($limit)
            ->get();

        return response()->json($result);
    }

    public function bulanan(Request $request)
    {
        $bulan = $request->get('bulan', now()->month);
        $tahun = $request->get('tahun', now()->year);

        $omzet = (double) Order::whereMonth('created_at', $bulan)
            ->whereYear('created_at', $tahun)
            ->sum('total');

        $pengeluaran = (double) Pengeluaran::whereMonth('tanggal', $bulan)
            ->whereYear('tanggal', $tahun)
            ->sum('jumlah');

        return response()->json([
            'bulan'       => $bulan,
            'tahun'       => $tahun,
            'omzet'       => $omzet,
            'pengeluaran' => $pengeluaran,
            'laba'        => $omzet - $pengeluaran,
        ]);
    }
}