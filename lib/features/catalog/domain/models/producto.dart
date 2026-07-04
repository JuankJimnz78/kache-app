// lib/features/catalog/domain/models/producto.dart

class CategoriaDetalle {
  final int id;
  final String nombre;
  final String descripcion;

  const CategoriaDetalle(
      {required this.id, required this.nombre, required this.descripcion});

  factory CategoriaDetalle.fromJson(Map<String, dynamic> j) => CategoriaDetalle(
        id: j['id_categoria'] as int,
        nombre: j['nombre'] as String,
        descripcion: j['descripcion'] as String,
      );
}

class Producto {
  final int id;
  final String nombre;
  final String marca;
  final String? codigoBarras;
  final String descripcion;
  final String unidadMedida;
  final int? idCategoria;
  final String? imagenUrl;
  final CategoriaDetalle? categoriaDetalle;

  const Producto({
    required this.id,
    required this.nombre,
    required this.marca,
    this.codigoBarras,
    required this.descripcion,
    required this.unidadMedida,
    this.idCategoria,
    this.imagenUrl,
    this.categoriaDetalle,
  });

  factory Producto.fromJson(Map<String, dynamic> j) => Producto(
        id: j['id_producto'] as int,
        nombre: j['nombre'] as String,
        marca: j['marca'] as String,
        codigoBarras: j['codigo_barras'] as String?,
        descripcion: j['descripcion'] as String,
        unidadMedida: j['unidad_medida'] as String,
        idCategoria: j['id_categoria'] as int?,
        imagenUrl: j['imagen_url'] as String?,
        categoriaDetalle: j['categoria_detalle'] != null
            ? CategoriaDetalle.fromJson(
                j['categoria_detalle'] as Map<String, dynamic>)
            : null,
      );
  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'marca': marca,
        'codigo_barras': codigoBarras,
        'descripcion': descripcion,
        'unidad_medida': unidadMedida,
        'id_categoria': idCategoria,
      };
}

class PaginatedProductos {
  final int count;
  final String? next;
  final List<Producto> results;

  const PaginatedProductos(
      {required this.count, required this.next, required this.results});

  factory PaginatedProductos.fromJson(Map<String, dynamic> j) =>
      PaginatedProductos(
        count: j['count'] as int,
        next: j['next'] as String?,
        results: (j['results'] as List)
            .map((e) => Producto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
