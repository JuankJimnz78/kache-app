// lib/features/precios/domain/models/precio.dart

import 'package:kache/domain/model/producto.dart';
import 'package:kache/domain/model/sucursal.dart';

class Precio {
  final int id;
  final int idProducto;
  final int idComercio;
  final double precioActual;
  final double? precioOferta;
  final bool enOferta;
  final double precioEfectivo;
  final String fechaActualizacion;
  final Producto? productoDetalle;
  final ComercioLigero? comercioDetalle;

  const Precio({
    required this.id,
    required this.idProducto,
    required this.idComercio,
    required this.precioActual,
    this.precioOferta,
    required this.enOferta,
    required this.precioEfectivo,
    required this.fechaActualizacion,
    this.productoDetalle,
    this.comercioDetalle,
  });

  factory Precio.fromJson(Map<String, dynamic> j) => Precio(
        id: j['id_precio'] as int,
        idProducto: j['id_producto'] as int,
        idComercio: j['id_comercio'] as int,
        precioActual: double.parse(j['precio_actual'].toString()),
        precioOferta: j['precio_oferta'] != null
            ? double.parse(j['precio_oferta'].toString())
            : null,
        enOferta: j['en_oferta'] as bool,
        precioEfectivo: double.parse(j['precio_efectivo'].toString()),
        fechaActualizacion: j['fecha_actualizacion'] as String,
        productoDetalle: j['producto_detalle'] != null
            ? Producto.fromJson(j['producto_detalle'] as Map<String, dynamic>)
            : null,
        comercioDetalle: j['comercio_detalle'] != null
            ? ComercioLigero.fromJson(
                j['comercio_detalle'] as Map<String, dynamic>)
            : null,
      );
}

class PaginatedPrecios {
  final int count;
  final String? next;
  final List<Precio> results;

  const PaginatedPrecios(
      {required this.count, required this.next, required this.results});

  factory PaginatedPrecios.fromJson(Map<String, dynamic> j) => PaginatedPrecios(
        count: j['count'] as int,
        next: j['next'] as String?,
        results: (j['results'] as List)
            .map((e) => Precio.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
