// import 'dart:convert';

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory PaginationLinks.fromMap(Map<String, dynamic> map) {
    return PaginationLinks(
      first: map['first'] as String?,
      last: map['last'] as String?,
      prev: map['prev'] as String?,
      next: map['next'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'first': first,
      'last': last,
      'prev': prev,
      'next': next,
    };
  }
}

class PaginationMetaLink {
  final String? url;
  final String label;
  final bool active;

  PaginationMetaLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PaginationMetaLink.fromMap(Map<String, dynamic> map) {
    return PaginationMetaLink(
      url: map['url'] as String?,
      label: map['label'] as String,
      active: map['active'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}

class PaginationMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final List<PaginationMetaLink> links;
  final String path;
  final int perPage;
  final int to;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory PaginationMeta.fromMap(Map<String, dynamic> map) {
    return PaginationMeta(
      currentPage: map['current_page'] as int,
      from: map['from'] as int,
      lastPage: map['last_page'] as int,
      links: (map['links'] as List<dynamic>)
          .map((e) => PaginationMetaLink.fromMap(e as Map<String, dynamic>))
          .toList(),
      path: map['path'] as String,
      perPage: map['per_page'] as int,
      to: map['to'] as int,
      total: map['total'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'links': links.map((e) => e.toMap()).toList(),
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationLinks links;
  final PaginationMeta meta;

  PaginatedResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory PaginatedResponse.fromMap(
      Map<String, dynamic> map, T Function(Map<String, dynamic>) fromJsonT) {
    return PaginatedResponse(
      data: (map['data'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      links: PaginationLinks.fromMap(map['links'] as Map<String, dynamic>),
      meta: PaginationMeta.fromMap(map['meta'] as Map<String, dynamic>),
    );
  }
}
