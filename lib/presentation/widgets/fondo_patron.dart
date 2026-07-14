// lib/presentation/widgets/fondo_patron.dart

import 'dart:math';
import 'package:flutter/material.dart';

// ── Fondo con patrón de íconos ──────────────────────────────────
class FondoPatron extends StatelessWidget {
  const FondoPatron({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _PatronPainter(),
      ),
    );
  }
}

class _PatronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final iconos = [
      Icons.shopping_basket_outlined,
      Icons.local_pharmacy_outlined,
      Icons.hardware_outlined,
      Icons.compare_arrows,
      Icons.attach_money,
      Icons.storefront_outlined,
      Icons.discount_outlined,
      Icons.receipt_outlined,
      Icons.price_check,
      Icons.savings_outlined,
      Icons.sell_outlined,
      Icons.shopping_cart_outlined,
      Icons.percent,
      Icons.star_outline,
      Icons.inventory_2_outlined,
    ];

    const color = Color(0xFFD4A843);
    const iconSize = 18.0;
    const espaciadoX = 55.0;
    const espaciadoY = 55.0;

    int fila = 0;
    for (double y = -10; y < size.height + espaciadoY; y += espaciadoY) {
      int col = 0;
      final offsetX = (fila % 2 == 0) ? 0.0 : espaciadoX / 2;
      for (double x = offsetX - 10;
          x < size.width + espaciadoX;
          x += espaciadoX) {
        final seed = fila * 100 + col;
        final dx = ((seed * 7 + 3) % 14).toDouble() - 7;
        final dy = ((seed * 11 + 5) % 14).toDouble() - 7;
        final angulo = ((seed * 37) % 100) / 100.0 * 3.14159;
        final icono = iconos[(fila * 5 + col * 3) % iconos.length];

        canvas.save();
        canvas.translate(x + dx, y + dy);
        canvas.rotate(angulo);
        _dibujarIcono(canvas, icono, Offset.zero, iconSize,
            color.withValues(alpha: 0.10));
        canvas.restore();
        col++;
      }
      fila++;
    }
  }

  void _dibujarIcono(
      Canvas canvas, IconData icon, Offset center, double size, Color color) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Tira de rombos (izquierda) ──────────────────────────────────
class TiraRombosPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const escala = 0.55;
    void r(double left, double top, double w, Color color) {
      w = w * escala;
      left = left * escala;
      top = top * escala;
      final paint = Paint()..color = color;
      canvas.save();
      canvas.translate(left + w / 2, top + w / 2);
      canvas.rotate(pi / 4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: w, height: w),
        paint,
      );
      canvas.restore();
    }

    r(-6, 3, 30, const Color(0xFFFF8F00));
    r(12, -1, 16, const Color(0xFFFDD835));
    r(20, 20, 10, const Color(0xFFFFCA28));
    r(28, 8, 22, const Color(0xFFFFB300));
    r(40, 2, 8, const Color(0xFFFFF176));
    r(44, 18, 14, const Color(0xFFFFD600));
    r(58, 2, 32, const Color(0xFF0D47A1));
    r(72, -2, 18, const Color(0xFF1565C0));
    r(82, 22, 11, const Color(0xFF1976D2));
    r(90, 6, 24, const Color(0xFF1E88E5));
    r(105, 1, 9, const Color(0xFF42A5F5));
    r(108, 18, 14, const Color(0xFF90CAF9));
    r(124, 3, 30, const Color(0xFFB71C1C));
    r(138, -2, 18, const Color(0xFFC62828));
    r(148, 22, 10, const Color(0xFFD32F2F));
    r(156, 5, 26, const Color(0xFFE53935));
    r(172, 1, 8, const Color(0xFFEF5350));
    r(175, 20, 15, const Color(0xFFFF8A80));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Tira de rombos centrada (para login) ────────────────────────
class TiraRombosCentradoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const escala = 0.70;
    final offsetX = (size.width - 105) / 2;

    void r(double left, double top, double w, Color color) {
      w = w * escala;
      left = left * escala + offsetX;
      top = top * escala;
      final paint = Paint()..color = color;
      canvas.save();
      canvas.translate(left + w / 14, top + w / 2);
      canvas.rotate(pi / 4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: w, height: w),
        paint,
      );
      canvas.restore();
    }

    r(-6, 3, 30, const Color(0xFFFF8F00));
    r(12, -1, 16, const Color(0xFFFDD835));
    r(20, 20, 10, const Color(0xFFFFCA28));
    r(28, 8, 22, const Color(0xFFFFB300));
    r(40, 2, 8, const Color(0xFFFFF176));
    r(44, 18, 14, const Color(0xFFFFD600));
    r(58, 2, 32, const Color(0xFF0D47A1));
    r(72, -2, 18, const Color(0xFF1565C0));
    r(82, 22, 11, const Color(0xFF1976D2));
    r(90, 6, 24, const Color(0xFF1E88E5));
    r(105, 1, 9, const Color(0xFF42A5F5));
    r(108, 18, 14, const Color(0xFF90CAF9));
    r(124, 3, 30, const Color(0xFFB71C1C));
    r(138, -2, 18, const Color(0xFFC62828));
    r(148, 22, 10, const Color(0xFFD32F2F));
    r(156, 5, 26, const Color(0xFFE53935));
    r(172, 1, 8, const Color(0xFFEF5350));
    r(175, 20, 15, const Color(0xFFFF8A80));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Encabezado reutilizable con tira de rombos ──────────────────
class EncabezadoPreciosEC extends StatelessWidget {
  final String titulo;
  final Widget? extra;
  const EncabezadoPreciosEC({super.key, this.titulo = '', this.extra});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 10,
            child: SizedBox(
              height: 24,
              width: 180,
              child: CustomPaint(painter: TiraRombosPainter()),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'PreciosEC',
                  style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              if (titulo.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
              if (extra != null) ...[
                const SizedBox(height: 12),
                extra!,
              ],
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
