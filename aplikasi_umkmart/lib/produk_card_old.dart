// Backup of original produk_card.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

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

    Color stokColor = AppTheme.success;
    if (isStokHabis) {
      stokColor = AppTheme.danger;
    } else if (produk.stokMenipis) {
      stokColor = AppTheme.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: adaDiKeranjang
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.6), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: AppTheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          produk.namaProduk,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (produk.kategori != null && produk.kategori!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            produk.kategori!,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.secondary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.formatRupiah(produk.harga),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                        style: TextStyle(
                          fontSize: 11,
                          color: stokColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (onTambah != null) ...[
              if (adaDiKeranjang && onKurangi != null) ...[
                GestureDetector(
                  onTap: onKurangi,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove_rounded,
                        size: 16, color: AppTheme.danger),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$jumlahDiKeranjang',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primary,
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
                        ? Colors.grey.withValues(alpha: 0.1)
                        : AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_rounded,
                      size: 16,
                      color: isStokHabis ? Colors.grey : AppTheme.primary),
                ),
              ),
            ]
            else ...[
              if (onEdit != null)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    color: AppTheme.secondary,
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
                    color: AppTheme.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_rounded, size: 16),
                    color: AppTheme.danger,
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
