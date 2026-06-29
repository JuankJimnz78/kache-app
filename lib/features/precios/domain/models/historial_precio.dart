// lib/features/precios/domain/models/historial_precio.dart

class HistorialPrecio {
  final int    id;
  final int    idProducto;
  final int    idComercio;
  final double precioRegistrado;
  final String fechaRegistro;

  const HistorialPrecio({
    required this.id,
    required this.idProducto,
    required this.idComercio,
    required this.precioRegistrado,
    required this.fechaRegistro,
  });

  factory HistorialPrecio.fromJson(Map<String, dynamic> j) => HistorialPrecio(
    id:               j['id_historial']   as int,
    idProducto:       j['id_producto']    as int,
    idComercio:       j['id_comercio']    as int,
    precioRegistrado: double.parse(j['precio_registrado'].toString()),
    fechaRegistro:    j['fecha_registro'] as String,
  );
}
