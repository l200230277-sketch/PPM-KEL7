import 'dart:typed_data';

class CastMember {
  const CastMember({
    required this.name,
    this.photoAssetPath = '',
    this.photoBytes,
  });

  final String name;
  final String photoAssetPath;
  final Uint8List? photoBytes;

  bool get photoIsNetwork =>
      photoAssetPath.startsWith('http://') ||
      photoAssetPath.startsWith('https://');

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] as String? ?? '',
      photoAssetPath: json['photo_url'] as String? ?? '',
    );
  }

  CastMember copyWith({
    String? name,
    String? photoAssetPath,
    Uint8List? photoBytes,
  }) {
    return CastMember(
      name: name ?? this.name,
      photoAssetPath: photoAssetPath ?? this.photoAssetPath,
      photoBytes: photoBytes ?? this.photoBytes,
    );
  }
}

class Drama {
  const Drama({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.genres,
    required this.tags,
    required this.synopsis,
    required this.posterAsset,
    required this.isFavorite,
    required this.isInMyList,
    this.posterBytes,
    this.mainCast = const [],
  });

  final String id;
  final String title;
  final int year;
  final double rating;
  final List<String> genres;
  final List<String> tags;
  final String synopsis;
  final String posterAsset;
  final Uint8List? posterBytes;
  final bool isFavorite;
  final bool isInMyList;
  final List<CastMember> mainCast;

  String get primaryGenre => genres.isNotEmpty ? genres.first : '';

  bool get posterIsNetwork =>
      posterAsset.startsWith('http://') || posterAsset.startsWith('https://');

  factory Drama.fromJson(Map<String, dynamic> json) {
    final genres = (json['genres'] as List<dynamic>? ?? [])
        .map((g) => g.toString())
        .toList();
    final tags = (json['tags'] as List<dynamic>? ?? [])
        .map((t) => t.toString())
        .toList();
    final cast = (json['main_cast'] as List<dynamic>? ?? [])
        .map(
          (c) => CastMember.fromJson(c as Map<String, dynamic>),
        )
        .toList();

    return Drama(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      genres: genres,
      tags: tags,
      synopsis: json['synopsis'] as String? ?? '',
      posterAsset: json['poster_url'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
      isInMyList: json['is_in_my_list'] as bool? ?? false,
      mainCast: cast,
    );
  }

  Drama copyWith({
    String? id,
    String? title,
    int? year,
    double? rating,
    List<String>? genres,
    List<String>? tags,
    String? synopsis,
    String? posterAsset,
    Uint8List? posterBytes,
    bool? isFavorite,
    bool? isInMyList,
    List<CastMember>? mainCast,
  }) {
    return Drama(
      id: id ?? this.id,
      title: title ?? this.title,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      genres: genres ?? this.genres,
      tags: tags ?? this.tags,
      synopsis: synopsis ?? this.synopsis,
      posterAsset: posterAsset ?? this.posterAsset,
      posterBytes: posterBytes ?? this.posterBytes,
      isFavorite: isFavorite ?? this.isFavorite,
      isInMyList: isInMyList ?? this.isInMyList,
      mainCast: mainCast ?? this.mainCast,
    );
  }
}
