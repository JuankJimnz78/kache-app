// lib/features/catalog/domain/models/categoria.dart

class Categoria {
  final int    id;
  final String nombre;
  final String descripcion;
  final int?   categoriaPadre;

  const Categoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.categoriaPadre,
  });

  factory Categoria.fromJson(Map<String, dynamic> j) => Categoria(
    id:             j['id_categoria']    as int,
    nombre:         j['nombre']          as String,
    descripcion:    j['descripcion']     as String,
    categoriaPadre: j['categoria_padre'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'nombre':          nombre,
    'descripcion':     descripcion,
    'categoria_padre': categoriaPadre,
  };

  Categoria copyWith({String? nombre, String? descripcion, int? categoriaPadre}) => Categoria(
    id:             id,
    nombre:         nombre         ?? this.nombre,
    descripcion:    descripcion    ?? this.descripcion,
    categoriaPadre: categoriaPadre ?? this.categoriaPadre,
  );
}
