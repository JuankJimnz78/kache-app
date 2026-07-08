// lib/features/comercios/domain/models/sucursal.dart

class ComercioLigero {
  final int     id;
  final String  nombre;
  final String  tipo;
  final String? logoUrl;

  const ComercioLigero({required this.id, required this.nombre, required this.tipo, this.logoUrl});

  factory ComercioLigero.fromJson(Map<String, dynamic> j) => ComercioLigero(
    id:      j['id_comercio'] as int,
    nombre:  j['nombre']      as String,
    tipo:    j['tipo']        as String,
    logoUrl: j['logo_url']    as String?,
  );
}

class Sucursal {
  final int             id;
  final int             idComercio;
  final String          nombreSucursal;
  final String          ciudad;
  final String          direccion;
  final bool            activo;
  final ComercioLigero? comercioDetalle;

  const Sucursal({
    required this.id,
    required this.idComercio,
    required this.nombreSucursal,
    required this.ciudad,
    required this.direccion,
    required this.activo,
    this.comercioDetalle,
  });

  factory Sucursal.fromJson(Map<String, dynamic> j) => Sucursal(
    id:              j['id_sucursal']     as int,
    idComercio:      j['id_comercio']     as int,
    nombreSucursal:  j['nombre_sucursal'] as String,
    ciudad:          j['ciudad']          as String,
    direccion:       j['direccion']       as String,
    activo:          j['activo']          as bool,
    comercioDetalle: j['comercio_detalle'] != null
        ? ComercioLigero.fromJson(j['comercio_detalle'] as Map<String, dynamic>)
        : null,
  );
}
