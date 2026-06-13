import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AiService {
  static const String _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // ─── System prompt yang ketat: hanya domain bisnis UMKM ───────────────────
  static const String _systemPrompt = '''
Kamu adalah UMKMART AI, konsultan bisnis AI khusus untuk pemilik UMKM (Usaha Mikro Kecil Menengah) di Indonesia.

=== DOMAIN YANG KAMU LAYANI ===
Kamu HANYA boleh membahas topik di bawah ini:
• Strategi penjualan & pemasaran (omzet, konversi, upselling, cross-selling)
• Pengelolaan stok & produk (FIFO, reorder point, dead stock)
• Analisis laporan & keuangan usaha (HPP, laba, cashflow)
• Retensi & loyalitas pelanggan (repeat order, member program, CRM sederhana)
• Strategi promo & diskon yang efektif
• Branding & digital marketing untuk UMKM (WhatsApp marketing, Instagram, Tokopedia, dll)
• Pricing strategy & penetapan harga jual
• Manajemen toko & operasional harian

=== ATURAN KETAT ===
1. Jika pengguna bertanya di luar domain di atas (termasuk: politik, hiburan, matematika umum, coding, sains, berita, olahraga, agama, dll.) — JANGAN jawab substansinya.
2. Alihkan dengan KALIMAT INI (verbatim, jangan diubah):
   "Maaf, saya adalah AI pendamping bisnis UMKM. Saat ini saya hanya dapat membantu seputar penjualan, pengelolaan usaha, strategi pemasaran, pelanggan, stok barang, dan pengembangan bisnis Anda. Silakan ajukan pertanyaan yang masih berkaitan dengan bisnis 😊"
3. Jawab selalu dalam Bahasa Indonesia yang ramah, singkat, dan praktis.
4. Gunakan emoji yang relevan.
5. Berikan tips yang actionable — hindari saran yang membutuhkan modal besar.
6. Ingat konteks percakapan sebelumnya agar jawaban tetap relevan dan tidak mengulang.

=== FORMAT JAWABAN ===
• Gunakan poin-poin bernomor atau bullet untuk jawaban panjang.
• Cetak tebal bagian penting dengan **teks**.
• Sertakan contoh konkret yang sesuai skala UMKM kecil.
''';

  /// Tanya AI dengan riwayat percakapan dan konteks bisnis
  Future<String> tanya({
    required String pertanyaan,
    String? konteksBisnis,
    List<Map<String, String>>? riwayatChat,
  }) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      debugPrint('[AiService] No API key — using fallback');
      return _jawabanFallback(pertanyaan);
    }

    try {
      final contents = <Map<String, dynamic>>[];

      // Suntikkan konteks bisnis sebagai pesan pertama dari model (grounding)
      if (konteksBisnis != null && konteksBisnis.isNotEmpty) {
        contents.add({
          'role': 'user',
          'parts': [{'text': '(Data bisnis saya saat ini)\n$konteksBisnis'}],
        });
        contents.add({
          'role': 'model',
          'parts': [{'text': 'Baik, saya sudah membaca data bisnis Anda. Silakan tanyakan apa saja seputar usaha Anda 😊'}],
        });
      }

      // Tambahkan riwayat chat (maks 10 pesan terakhir untuk efisiensi token)
      if (riwayatChat != null && riwayatChat.isNotEmpty) {
        // Skip welcome message pertama dari riwayat agar tidak membingungkan model
        for (final c in riwayatChat.take(10)) {
          contents.add({
            'role': c['role'] == 'user' ? 'user' : 'model',
            'parts': [{'text': c['text'] ?? ''}],
          });
        }
      }

      // Pertanyaan saat ini
      contents.add({
        'role': 'user',
        'parts': [{'text': pertanyaan}],
      });

      final body = jsonEncode({
        'system_instruction': {
          'parts': [{'text': _systemPrompt}],
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.65,
          'maxOutputTokens': 1024,
          'topP': 0.85,
          'topK': 40,
        },
        'safetySettings': [
          {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
        ],
      });

      debugPrint('[AiService] Sending request — history: ${riwayatChat?.length ?? 0} msgs');

      final response = await http
          .post(
            Uri.parse('$_geminiUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[AiService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        if (text != null && text.isNotEmpty) return text;
        return 'Maaf, AI tidak dapat memproses pertanyaan Anda saat ini. Coba lagi sebentar ya 🙏';
      } else if (response.statusCode == 400) {
        final body400 = response.body;
        if (body400.contains('API_KEY_INVALID')) {
          return '⚠️ API key Gemini tidak valid.\n\nSilakan periksa konfigurasi di `lib/utils/constants.dart`.\n\n---\n\n${_jawabanFallback(pertanyaan)}';
        }
        debugPrint('[AiService] 400 Error: $body400');
        return _jawabanFallback(pertanyaan);
      } else {
        debugPrint('[AiService] Error ${response.statusCode}: ${response.body}');
        return _jawabanFallback(pertanyaan);
      }
    } on Exception catch (e) {
      debugPrint('[AiService] Exception: $e');
      if (e.toString().contains('TimeoutException')) {
        return '⏱️ Koneksi timeout. Periksa koneksi internet Anda dan coba lagi.\n\n---\n\n${_jawabanFallback(pertanyaan)}';
      }
      return _jawabanFallback(pertanyaan);
    }
  }

  // ─── Fallback lokal jika API tidak tersedia ────────────────────────────────
  String _jawabanFallback(String pertanyaan) {
    final q = pertanyaan.toLowerCase();

    // Out-of-context detection sederhana untuk fallback
    final outOfContextKeywords = [
      'presiden', 'politik', 'pemerintah', 'film', 'game', 'musik', 'sinetron',
      'artis', 'bola', 'olahraga', 'coding', 'pemrograman', 'matematika',
      'fisika', 'kimia', 'biologi', 'sejarah', 'agama', 'puisi', 'cerpen',
      'pacar', 'cinta', 'jodoh', 'cuaca', 'berita',
    ];
    if (outOfContextKeywords.any((k) => q.contains(k))) {
      return 'Maaf, saya adalah AI pendamping bisnis UMKM. Saat ini saya hanya dapat membantu seputar penjualan, pengelolaan usaha, strategi pemasaran, pelanggan, stok barang, dan pengembangan bisnis Anda. Silakan ajukan pertanyaan yang masih berkaitan dengan bisnis 😊';
    }

    if (q.contains('omzet') || q.contains('pendapatan') || q.contains('penjualan') || q.contains('jual')) {
      return '''📈 **Strategi Meningkatkan Omzet:**

1. **Bundling produk** — Gabungkan produk lambat dengan produk populer (misal: mie + telur)
2. **Flash sale singkat** — Diskon 1–3 jam untuk mendorong pembelian segera
3. **Loyalty program** — Berikan poin/stempel untuk setiap pembelian
4. **Cross-selling** — Tawarkan produk pelengkap saat checkout
5. **Waktu terbaik promosi** — Jam 07-09 pagi, 12-13 siang, 19-21 malam

💡 **Tips utama:** Pelanggan lama 5× lebih mudah untuk beli ulang daripada mencari pelanggan baru!''';
    }

    if (q.contains('stok') || q.contains('produk') || q.contains('inventory')) {
      return '''📦 **Manajemen Stok yang Efektif:**

1. **FIFO** — First In, First Out: produk lama dijual dulu
2. **Reorder point** — Tentukan batas stok minimum sebelum restock
3. **Analisis ABC** — Pisahkan produk fast-moving vs slow-moving
4. **Dead stock** — Buat promo khusus untuk produk yang jarang terjual
5. **Buffer stock** — Siapkan stok cadangan 20-30% lebih untuk hari ramai

⚡ **Aturan 80/20:** 20% produk Anda menghasilkan 80% pendapatan. Fokus ke sini!''';
    }

    if (q.contains('pelanggan') || q.contains('customer') || q.contains('loyal') || q.contains('repeat')) {
      return '''👥 **Strategi Retensi Pelanggan:**

1. **Follow-up aktif** — Hubungi pelanggan yang sudah lama tidak belanja
2. **Promo ulang tahun** — Berikan diskon spesial di hari ulang tahun
3. **Feedback loop** — Minta ulasan dan tanggapi keluhan dengan cepat
4. **Personalisasi** — Ingat nama dan preferensi pelanggan tetap
5. **WhatsApp aktif** — Kirim promo eksklusif via broadcast WA

💝 **Fakta:** Meningkatkan retensi pelanggan 5% bisa meningkatkan profit hingga 25-95%!''';
    }

    if (q.contains('promo') || q.contains('diskon') || q.contains('marketing') || q.contains('iklan')) {
      return '''🎯 **Strategi Promo Efektif untuk UMKM:**

1. **Beli 2 Gratis 1** — Meningkatkan average order value
2. **Member price** — Harga khusus pelanggan setia (5-10% lebih murah)
3. **Seasonal promo** — Manfaatkan momen Lebaran, HUT RI, Natal, dll
4. **Referral reward** — Pelanggan yang ajak teman dapat bonus/diskon
5. **WA Broadcast** — Kirim promo ke komunitas pelanggan secara massal

📣 **Penting:** Promo terlalu sering justru merusak persepsi nilai produk. Buat promo terasa eksklusif!''';
    }

    if (q.contains('laporan') || q.contains('keuangan') || q.contains('laba') || q.contains('untung') || q.contains('rugi')) {
      return '''💰 **Analisis Keuangan Sederhana:**

1. **Catat harian** — Rekap omzet dan pengeluaran setiap tutup toko
2. **Hitung HPP** — Harga Pokok Penjualan harus dihitung akurat
3. **Target margin** — Minimal 20-30% dari harga jual
4. **Cashflow aman** — Pastikan kas cukup untuk operasional 1 bulan ke depan
5. **Pisahkan rekening** — Keuangan bisnis ≠ keuangan pribadi

📊 **Target sehat:** Laba bersih minimal 10-15% dari total omzet bulanan''';
    }

    if (q.contains('harga') || q.contains('pricing') || q.contains('tarif')) {
      return '''🏷️ **Strategi Penetapan Harga:**

1. **Cost-plus pricing** — HPP × (1 + margin%). Contoh: HPP Rp 8.000, margin 30% → jual Rp 10.400
2. **Competitive pricing** — Bandingkan harga dengan kompetitor terdekat
3. **Value-based pricing** — Harga sesuai nilai yang dirasakan pelanggan
4. **Harga psikologis** — Rp 9.900 terasa lebih murah dari Rp 10.000
5. **Bundling price** — Paket hemat yang meningkatkan nilai transaksi

💡 Jangan selalu bersaing harga murah — tingkatkan value produk/layanan Anda!''';
    }

    if (q.contains('branding') || q.contains('merek') || q.contains('brand')) {
      return '''✨ **Branding untuk UMKM:**

1. **Nama yang mudah diingat** — Singkat, unik, dan relevan dengan produk
2. **Logo konsisten** — Gunakan di kemasan, struk, WA, media sosial
3. **Warna brand** — Pilih 2-3 warna utama dan gunakan konsisten
4. **Cerita brand** — Bagikan cerita di balik usaha Anda di media sosial
5. **Kemasan menarik** — Kemasan yang bagus meningkatkan persepsi kualitas

📱 Di era digital, **konsistensi** adalah kunci branding UMKM!''';
    }

    // Default response
    return '''🤖 **UMKMART AI siap membantu bisnis Anda!**

Saya bisa membantu dengan:
• 📈 Strategi meningkatkan omzet & penjualan
• 📦 Manajemen stok & produk
• 👥 Retensi & loyalitas pelanggan
• 🎯 Strategi promo & diskon
• 💰 Analisis keuangan sederhana
• 🏷️ Pricing strategy
• ✨ Branding & digital marketing UMKM

Silakan tanyakan topik spesifik untuk mendapat jawaban yang lebih detail!

💡 *Untuk jawaban AI yang lebih cerdas:* Tambahkan Gemini API key di `lib/utils/constants.dart`''';
  }
}
