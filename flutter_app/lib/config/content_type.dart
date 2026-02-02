/// Content type constants
/// Migrated from Angular content-type.const.ts
enum ContentType {
  movie,
  tv;

  String get value {
    switch (this) {
      case ContentType.movie:
        return 'movie';
      case ContentType.tv:
        return 'tv';
    }
  }

  @override
  String toString() => value;
}
