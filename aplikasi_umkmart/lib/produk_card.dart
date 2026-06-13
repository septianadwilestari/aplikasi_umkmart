import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../utils/app_colors.dart';
import '../utils/app_helpers.dart';

class ProdukCard extends StatelessWidget {
  final ProdukModel produk;
  final VoidCallback? onTambah;
  final VoidCallback? onKurangi;
  final VoidCallback? onEdit;
  final VoidCallback? onHapus;
  final int jumlahDiKeranjang;

  const ProdukCard({
    super.key,
    required this.produk,
    this.onTambah,
    this.onKurangi,
    this.onEdit,
    this.onHapus,
    this.jumlahDiKeranjang = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isStokHabis = produk.stok == 0;
    final adaDiKeranjang = jumlahDiKeranjang > 0;

    Color stokColor = AppColors.success;
    if (isStokHabis) {
      stokColor = AppColors.error;
    } else if (produk.stokMenipis) {
      stokColor = AppColors.warningStock;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: adaDiKeranjang
              ? AppColors.tealPrimary
              : AppColors.divider,
          width: adaDiKeranjang ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── Gambar / Icon produk ──────────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isStokHabis
                    ? Colors.grey[100]
                    : AppColors.tealPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: produk.gambar != null && produk.gambar!.isNotEmpty
                    ? Image.network(
                        produk.gambar!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.tealPrimary,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.inventory_2_rounded,
                          color: isStokHabis
                              ? Colors.grey[400]
                              : AppColors.tealPrimary,
                          size: 24,
                        ),
                      )
                    : Icon(
                        Icons.inventory_2_rounded,
                        color: isStokHabis
                            ? Colors.grey[400]
                            : AppColors.tealPrimary,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Detail produk ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          produk.namaProduk,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (produk.kategori != null &&
                          produk.kategori!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tealPrimary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            produk.kategori!,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: AppColors.tealPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppHelpers.formatRupiah(produk.harga),
                    style: GoogleFonts.poppins(
                      color: AppColors.tealPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: stokColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isStokHabis
                            ? 'Stok habis'
                            : produk.stokMenipis
                                ? 'Stok menipis: ${produk.stok}'
                                : 'Stok: ${produk.stok}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: stokColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Action buttons ────────────────────────────────────────
            if (onTambah != null) ...[
              if (adaDiKeranjang && onKurangi != null) ...[
                GestureDetector(
                  onTap: onKurangi,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(
                      Icons.remove_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$jumlahDiKeranjang',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: isStokHabis ? null : onTambah,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isStokHabis
                        ? Colors.grey[100]
                        : AppColors.tealPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isStokHabis
                          ? Colors.grey[200]!
                          : AppColors.tealPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: isStokHabis ? Colors.grey : AppColors.tealPrimary,
                  ),
                ),
              ),
            ] else ...[
              if (onEdit != null)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    color: AppColors.tealPrimary,
                    onPressed: onEdit,
                    tooltip: 'Edit produk',
                    padding: EdgeInsets.zero,
                  ),
                ),
              if (onHapus != null)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_rounded, size: 16),
                    color: AppColors.error,
                    onPressed: onHapus,
                    tooltip: 'Hapus produk',
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}