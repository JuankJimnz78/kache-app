// lib/features/precios/domain/models/lista_comparacion.dart

import '../../../catalog/domain/models/producto.dart';
import '../../../comercios/domain/models/sucursal.dart';

class ItemComparacion {
  final int id;
  final Producto productoDetalle;
  final ComercioLigero comercioDetalle;
  final double precioMomento;

  const ItemComparacion({
    required this.id,
    required this.productoDetalle,
    required this.comercioDetalle,
    required this.precioMomento,
  });

  factory ItemComparacion.fromJson(Map<String, dynamic> j) => ItemComparacion(
        id: j['id_item'] as int,
        productoDetalle:
            Producto.fromJson(j['producto_detalle'] as Map<String, dynamic>),
        comercioDetalle: ComercioLigero.fromJson(
            j['comercio_detalle'] as Map<String, dynamic>),
        precioMomento: double.parse(j['precio_momento'].toString()),
      );
}

class TotalPorComercio {
  final int idComercio;
  final String nombreComercio;
  final int cantidadProductos;
  final double total;

  const TotalPorComercio({
    required this.idComercio,
    required this.nombreComercio,
    required this.cantidadProductos,
    required this.total,
  });

  factory TotalPorComercio.fromJson(Map<String, dynamic> j) => TotalPorComercio(
        idComercio: j['id_comercio'] as int,
        nombreComercio: j['nombre_comercio'] as String,
        cantidadProductos: j['cantidad_productos'] as int,
        total: double.parse(j['total'].toString()),
      );
}

class ListaComparacionResumen {
  final int id;
  final String nombre;

  const ListaComparacionResumen({required this.id, required this.nombre});

  factory ListaComparacionResumen.fromJson(Map<String, dynamic> j) =>
      ListaComparacionResumen(
          id: j['id_lista'] as int, nombre: j['nombre'] as String);
}

class ListaComparacionDetalle {
  final int id;
  final String nombre;
  final List<ItemComparacion> items;
  final List<TotalPorComercio> totalesPorComercio;

  const ListaComparacionDetalle({
    required this.id,
    required this.nombre,
    required this.items,
    required this.totalesPorComercio,
  });

  factory ListaComparacionDetalle.fromJson(Map<String, dynamic> j) =>
      ListaComparacionDetalle(
        id: j['id_lista'] as int,
        nombre: j['nombre'] as String,
        items: (j['items'] as List)
            .map((e) => ItemComparacion.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalesPorComercio: (j['totales_por_comercio'] as List)
            .map((e) => TotalPorComercio.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
