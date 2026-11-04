/// One Islamic wallpaper, added from the admin panel as a document in the
/// Firestore `wallpapers` collection:
///
///   title       string   shown under the picture
///   image_url   string   full-size image (what gets downloaded)
///   thumb_url   string   optional smaller image for the grid
///   category    string   optional, e.g. "Mosques", "Calligraphy", "Patterns"
///   active      bool     optional, false hides it (default true)
///   created_at  timestamp optional, newest first
class WallpaperModel {
  final String id;
  final String title;
  final String imageUrl;
  final String thumbUrl;
  final String category;
  final bool active;
  final DateTime? createdAt;

  const WallpaperModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.thumbUrl = '',
    this.category = '',
    this.active = true,
    this.createdAt,
  });

  /// The picture to show in the grid: the thumbnail when there is one.
  String get previewUrl => thumbUrl.isNotEmpty ? thumbUrl : imageUrl;

  /// A name for the saved file, safe on every platform.
  String get fileName {
    final base = (title.isNotEmpty ? title : id)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'ruqyah_${base.isEmpty ? 'wallpaper' : base}';
  }

  factory WallpaperModel.fromMap(Map<String, dynamic> map, String docId) {
    final created = map['created_at'];
    DateTime? when;
    // Firestore's Timestamp has toDate(); keep this free of the plugin so the
    // model can be tested, and accept plain DateTime or milliseconds too.
    if (created is DateTime) {
      when = created;
    } else if (created is int) {
      when = DateTime.fromMillisecondsSinceEpoch(created);
    } else if (created != null) {
      try {
        when = (created as dynamic).toDate() as DateTime;
      } catch (_) {
        when = null;
      }
    }
    return WallpaperModel(
      id: docId,
      title: (map['title'] as String?)?.trim() ?? '',
      imageUrl: (map['image_url'] as String?)?.trim() ?? '',
      thumbUrl: (map['thumb_url'] as String?)?.trim() ?? '',
      category: (map['category'] as String?)?.trim() ?? '',
      active: map['active'] as bool? ?? true,
      createdAt: when,
    );
  }

  /// Shown ones only: active and with an image, newest first.
  static List<WallpaperModel> visible(Iterable<WallpaperModel> all) {
    final list = all.where((w) => w.active && w.imageUrl.isNotEmpty).toList();
    list.sort((a, b) {
      final x = a.createdAt, y = b.createdAt;
      if (x == null && y == null) return a.title.compareTo(b.title);
      if (x == null) return 1;
      if (y == null) return -1;
      return y.compareTo(x);
    });
    return list;
  }
}
