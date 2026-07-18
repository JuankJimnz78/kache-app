// lib/domain/model/paginado.dart
//
// Wrapper genérico para respuestas paginadas de Django REST Framework
// (PageNumberPagination): { count, next, previous, results: [...] }

class Paginado<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  const Paginado({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  bool get haySiguiente => next != null;

  factory Paginado.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return Paginado(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
