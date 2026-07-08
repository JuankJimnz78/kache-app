// lib/core/utils/comercio_links.dart

class ComercioLinks {
  static String? urlDelivery(String nombreComercio, String nombreProducto) {
    final q = Uri.encodeComponent(nombreProducto);
    const utm = 'utm_source=kache&utm_medium=app&utm_campaign=comparador';
    switch (nombreComercio.toLowerCase()) {
      case 'kywi':
        return 'https://www.kywi.com.ec/$q?_q=$q&map=ft&$utm';
      case 'ferrisariato':
        return 'https://www.ferrisariato.com/?s=$q&$utm';
      case 'fybeca':
        return 'https://www.fybeca.com/?q=$q&$utm';
      case 'medicity':
        return 'https://www.farmaciasmedicity.com/?q=$q&$utm';
      case 'supermaxi':
        return 'https://www.supermaxi.com/?s=$q&$utm';
      case 'coral':
        return 'https://coralhipermercados.com/catalogsearch/result/?q=$q&$utm';
      default:
        return null;
    }
  }

  static String? urlMaps(String nombreComercio) {
    switch (nombreComercio.toLowerCase()) {
      case 'kywi':
        return 'https://maps.google.com/?q=Kywi+Quito+Ecuador';
      case 'ferrisariato':
        return 'https://maps.google.com/?q=Ferrisariato+Quito+Ecuador';
      case 'fybeca':
        return 'https://maps.google.com/?q=Fybeca+Quito+Ecuador';
      case 'medicity':
        return 'https://maps.google.com/?q=Farmacias+Medicity+Quito+Ecuador';
      case 'supermaxi':
        return 'https://maps.google.com/?q=Supermaxi+Quito+Ecuador';
      case 'coral':
        return 'https://maps.google.com/?q=Coral+Hipermercados+Quito+Ecuador';
      default:
        return null;
    }
  }

  static bool tieneDelivery(String nombreComercio) {
    return ['kywi', 'fybeca', 'supermaxi', 'coral']
        .contains(nombreComercio.toLowerCase());
  }
}
