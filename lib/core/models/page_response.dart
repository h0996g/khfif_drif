/// The shared pagination envelope used by every list endpoint:
/// `{ data, page, size, totalElements, totalPages }`.
///
/// Items that fail to parse are dropped rather than failing the whole page —
/// one malformed row from the server should never blank a list.
final class PageResponse<T> {
  const PageResponse({
    required this.data,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  const PageResponse.empty()
      : data = const [],
        page = -1,
        size = 0,
        totalElements = 0,
        totalPages = 0;

  final List<T> data;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  /// Whether [page] is the last one. Guards `totalPages == 0` (an empty list)
  /// so we never paginate into nothing.
  bool get hasReachedMax => totalPages <= 0 || page + 1 >= totalPages;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final items = (json['data'] as List<dynamic>? ?? const [])
        .map((e) {
          try {
            return itemParser(e as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<T>()
        .toList();

    return PageResponse<T>(
      data: items,
      page: _asInt(json['page']),
      size: _asInt(json['size']),
      totalElements: _asInt(json['totalElements']),
      totalPages: _asInt(json['totalPages']),
    );
  }

  static int _asInt(Object? value, [int fallback = 0]) =>
      value is int ? value : (value is num ? value.toInt() : fallback);
}
