// lib/features/comercios/domain/models/comercio.dart

import 'package:flutter/material.dart';

enum TipoComercio {
  supermercado('supermercado', 'Supermercados', Color(0xFF4CAF50),
      Icons.shopping_basket_outlined, '🛒', 4),
  farmacia('farmacia', 'Farmacias', Color(0xFF26C6DA),
      Icons.local_pharmacy_outlined, '💊', 5),
  ferreteria('ferreteria', 'Ferreterías', Color(0xFFEA580C),
      Icons.hardware_outlined, '🔧', 6);

  const TipoComercio(this.value, this.label, this.color, this.icon, this.emoji,
      this.idCategoriaPadre);
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  final String emoji;
  final int idCategoriaPadre;

  static TipoComercio fromValue(String v) => TipoComercio.values
      .firstWhere((t) => t.value == v, orElse: () => TipoComercio.supermercado);
}

class Comercio {
  final int id;
  final String nombre;
  final TipoComercio tipo;
  final String? logoUrl;
  final String? sitioWeb;
  final bool activo;
  final bool destacado;
  final String? fechaFinDestacado;
  final bool destacadoActivo;

  const Comercio({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.logoUrl,
    this.sitioWeb,
    required this.activo,
    required this.destacado,
    this.fechaFinDestacado,
    required this.destacadoActivo,
  });

  factory Comercio.fromJson(Map<String, dynamic> j) => Comercio(
        id: j['id_comercio'] as int,
        nombre: j['nombre'] as String,
        tipo: TipoComercio.fromValue(j['tipo'] as String),
        logoUrl: j['logo_url'] as String?,
        sitioWeb: j['sitio_web'] as String?,
        activo: j['activo'] as bool,
        destacado: j['destacado'] as bool,
        fechaFinDestacado: j['fecha_fin_destacado'] as String?,
        destacadoActivo: j['destacado_activo'] as bool,
      );

  /// Devuelve el color de identidad de marca del comercio.
  /// Si no hay color específico para ese comercio, usa el color del tipo.
  Color get colorMarca {
    switch (nombre.toLowerCase()) {
      case 'supermaxi':
        return const Color(0xFFE3000F);
      case 'coral':
        return const Color(0xFF003087);
      case 'fybeca':
        return const Color(0xFF00843D);
      case 'sana sana':
        return const Color(0xFF0066CC);
      case 'kywi':
        return const Color(0xFFE87722);
      default:
        return tipo
            .color; // fallback al color del tipo si no tiene marca conocida
    }
  }
}
