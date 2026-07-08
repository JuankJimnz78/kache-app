// lib/core/widgets/fondo_patron.dart

import 'package:flutter/material.dart';
import 'dart:math';

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
      Icons.sell_outlined,
    ];

    const color = Color(0xFFD4A843);
    const iconSize = 43.0;
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
