<?php

namespace App\Http\Controllers;

use App\Models\Config;
use App\Models\Menu;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class OrderController extends Controller
{
    /**
     * Display a listing of orders.
     */
    public function index(Request $request)
    {
        $query = Order::query()->with('items');

        if ($request->has('tanggal')) {
            $query->whereDate('created_at', $request->query('tanggal'));
        }

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    /**
     * Store a newly created order.
     */
    public function store(Request $request)
    {
        $request->validate([
            'metode_bayar' => 'required|in:cash,transfer,qris',
            'bayar' => 'required|numeric|min:0',
            'nama_pelanggan' => 'nullable|string|max:100',
            'meja' => 'nullable|integer',
            'items' => 'required|array|min:1',
            'items.*.menu_id' => 'required|exists:menu,id',
            'items.*.qty' => 'required|integer|min:1',
            'items.*.catatan' => 'nullable|string',
        ]);

        try {
            $order = DB::transaction(function () use ($request) {
                // 1. Get Config for taxes and service charges
                $config = Config::first();
                if (!$config) {
                    $config = Config::create([
                        'tax_rate' => 11.0,
                        'service_rate' => 5.0,
                        'passcode_main' => '1234',
                        'passcode_admin' => '0000',
                        'nama_restoran' => 'UMKMART',
                    ]);
                }

                // 2. Generate no_order (ORD-YYYYMMDD-XXX)
                $today = now()->format('Ymd');
                $prefix = 'ORD-' . $today . '-';
                $lastOrder = Order::where('no_order', 'like', $prefix . '%')
                    ->orderBy('no_order', 'desc')
                    ->first();

                $sequence = 1;
                if ($lastOrder) {
                    $parts = explode('-', $lastOrder->no_order);
                    $lastSequence = intval(end($parts));
                    $sequence = $lastSequence + 1;
                }
                $noOrder = $prefix . str_pad($sequence, 3, '0', STR_PAD_LEFT);

                // 3. Process items and subtract stock
                $subtotal = 0.0;
                $itemsToCreate = [];

                foreach ($request->input('items') as $itemData) {
                    $menu = Menu::lockForUpdate()->findOrFail($itemData['menu_id']);

                    if ($menu->stok < $itemData['qty']) {
                        throw new \Exception("Stok menu '{$menu->nama}' tidak mencukupi. Sisa: {$menu->stok}.");
                    }

                    // Subtract stock
                    $menu->stok -= $itemData['qty'];
                    $menu->tersedia = $menu->stok > 0;
                    $menu->save();

                    $itemSubtotal = $menu->harga * $itemData['qty'];
                    $subtotal += $itemSubtotal;

                    $itemsToCreate[] = [
                        'menu_id' => $menu->id,
                        'nama_menu' => $menu->nama,
                        'harga_satuan' => $menu->harga,
                        'qty' => $itemData['qty'],
                        'subtotal' => $itemSubtotal,
                        'catatan' => $itemData['catatan'] ?? null,
                    ];
                }

                // 4. Calculate amounts
                $taxAmount = $subtotal * ($config->tax_rate / 100);
                $serviceAmount = $subtotal * ($config->service_rate / 100);
                $total = $subtotal + $taxAmount + $serviceAmount;

                $bayar = floatval($request->input('bayar'));
                $kembalian = $bayar > $total ? $bayar - $total : 0.0;

                // 5. Create Order
                $order = Order::create([
                    'user_id' => auth()->id(),
                    'no_order' => $noOrder,
                    'subtotal' => $subtotal,
                    'tax_amount' => $taxAmount,
                    'service_amount' => $serviceAmount,
                    'total' => $total,
                    'bayar' => $bayar,
                    'kembalian' => $kembalian,
                    'metode_bayar' => $request->input('metode_bayar'),
                    'status' => 'selesai',
                    'nama_pelanggan' => $request->input('nama_pelanggan'),
                    'meja' => $request->input('meja'),
                ]);

                // 6. Create Order Items
                foreach ($itemsToCreate as $itemToCreate) {
                    $itemToCreate['order_id'] = $order->id;
                    OrderItem::create($itemToCreate);
                }

                return $order;
            });

            return response()->json($order->load('items'), 201);

        } catch (\Exception $e) {
            Log::error('[OrderController] Checkout error: ' . $e->getMessage());
            return response()->json(['message' => $e->getMessage()], 400);
        }
    }

    /**
     * Display detailed order.
     */
    public function show($id)
    {
        $order = Order::with('items')->findOrFail($id);
        return response()->json($order);
    }
}
