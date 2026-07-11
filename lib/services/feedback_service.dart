import 'local_db_service.dart';

/// رسائل تواصل/بلاغات حقيقية يرسلها الزوار، تظهر كإشعارات فعلية عند الأدمن
/// (بدل قائمة إشعارات وهمية ثابتة).
class FeedbackMessage {
  final dynamic key;
  final String name;
  final String email;
  final String type; // suggestion | issue | question
  final String message;
  final String? relatedPlace;
  final DateTime createdAt;
  final bool read;

  FeedbackMessage({
    required this.key,
    required this.name,
    required this.email,
    required this.type,
    required this.message,
    this.relatedPlace,
    required this.createdAt,
    required this.read,
  });
}

class FeedbackService {
  FeedbackService._internal();
  static final FeedbackService instance = FeedbackService._internal();

  static const _box = 'feedback';

  Future<void> submit({
    required String name,
    required String email,
    required String type,
    required String message,
    String? relatedPlace,
  }) async {
    await LocalDbService.instance.add(_box, {
      'name': name,
      'email': email,
      'type': type,
      'message': message,
      'relatedPlace': relatedPlace,
      'createdAt': DateTime.now().toIso8601String(),
      'read': false,
    });
  }

  List<FeedbackMessage> getAll() {
    final entries = LocalDbService.instance.getAll(_box);
    final list = entries
        .map(
          (e) => FeedbackMessage(
            key: e.key,
            name: e.value['name'] ?? '',
            email: e.value['email'] ?? '',
            type: e.value['type'] ?? 'question',
            message: e.value['message'] ?? '',
            relatedPlace: e.value['relatedPlace'],
            createdAt: DateTime.tryParse(e.value['createdAt'] ?? '') ?? DateTime.now(),
            read: e.value['read'] ?? false,
          ),
        )
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int get unreadCount => getAll().where((f) => !f.read).length;

  Future<void> markRead(dynamic key) async {
    final item = LocalDbService.instance.get(_box, key);
    if (item == null) return;
    await LocalDbService.instance.update(_box, key, {...item, 'read': true});
  }

  Future<void> markAllRead() async {
    for (final f in getAll().where((f) => !f.read)) {
      await markRead(f.key);
    }
  }

  Future<void> delete(dynamic key) async {
    await LocalDbService.instance.delete(_box, key);
  }
}
