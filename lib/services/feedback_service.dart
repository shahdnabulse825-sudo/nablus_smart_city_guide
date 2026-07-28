import 'local_db_service.dart';
import 'auth_service.dart';
import 'api_service.dart';

/// رسائل تواصل/بلاغات حقيقية يرسلها الزوار، تظهر كإشعارات فعلية عند الأدمن.
/// متزامنة مع السيرفر الحقيقي: أي رسالة بتتخزّن محليًا فورًا (تشتغل حتى بدون
/// إنترنت) وبتترفع للسيرفر بالخلفية، وبتنعرض عند الأدمن مهما كان الجهاز اللي
/// أرسل منه الزائر — بعكس التخزين المحلي البحت اللي كان قبل (كل جهاز يشوف
/// بس رسائله هو).
class FeedbackMessage {
  final dynamic key;
  final String? serverId;
  final String name;
  final String email;
  final String type; // suggestion | issue | question
  final String message;
  final String? relatedPlace;
  final DateTime createdAt;
  final bool read;
  final String? reply;
  final DateTime? repliedAt;

  FeedbackMessage({
    required this.key,
    this.serverId,
    required this.name,
    required this.email,
    required this.type,
    required this.message,
    this.relatedPlace,
    required this.createdAt,
    required this.read,
    this.reply,
    this.repliedAt,
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
    final key = await LocalDbService.instance.add(_box, {
      'name': name,
      'email': email,
      'type': type,
      'message': message,
      'relatedPlace': relatedPlace,
      'createdAt': DateTime.now().toIso8601String(),
      'read': false,
    });

    // نرفعها للسيرفر بالخلفية بدون ما نوقّف تأكيد الإرسال للزائر (صار فورًا
    // محليًا فوق). لو نجح، نخزّن الـ id الحقيقي حتى ما تتكرر لما تنزل مزامنة لاحقة.
    final row = await ApiService.pushFeedback(
      name: name,
      email: email,
      type: type,
      message: message,
      relatedPlace: relatedPlace,
    );
    if (row != null && row['id'] != null) {
      final item = LocalDbService.instance.get(_box, key);
      if (item != null) {
        await LocalDbService.instance.update(_box, key, {...item, 'serverId': row['id']});
      }
    }
  }

  List<FeedbackMessage> getAll() {
    final entries = LocalDbService.instance.getAll(_box);
    final list = entries
        .map(
          (e) => FeedbackMessage(
            key: e.key,
            serverId: e.value['serverId'] as String?,
            name: e.value['name'] ?? '',
            email: e.value['email'] ?? '',
            type: e.value['type'] ?? 'question',
            message: e.value['message'] ?? '',
            relatedPlace: e.value['relatedPlace'],
            createdAt: DateTime.tryParse(e.value['createdAt'] ?? '') ?? DateTime.now(),
            read: e.value['read'] ?? false,
            reply: e.value['reply'],
            repliedAt: DateTime.tryParse(e.value['repliedAt'] ?? ''),
          ),
        )
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// رسائل زائر معيّن (حسب بريده الإلكتروني) — تُستخدم لعرض ردود الأدمن للزائر نفسه
  List<FeedbackMessage> getForEmail(String email) {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) return [];
    return getAll().where((f) => f.email.trim().toLowerCase() == clean).toList();
  }

  int get unreadCount => getAll().where((f) => !f.read).length;

  Future<void> markRead(dynamic key) async {
    final item = LocalDbService.instance.get(_box, key);
    if (item == null) return;
    await LocalDbService.instance.update(_box, key, {...item, 'read': true});
    final serverId = item['serverId'] as String?;
    final adminToken = AuthService.instance.adminToken;
    if (serverId != null && adminToken != null) {
      ApiService.markFeedbackRead(adminToken, serverId);
    }
  }

  /// يحفظ رد الأدمن على رسالة زائر
  Future<void> reply(dynamic key, String text) async {
    final item = LocalDbService.instance.get(_box, key);
    if (item == null) return;
    await LocalDbService.instance.update(_box, key, {
      ...item,
      'reply': text,
      'repliedAt': DateTime.now().toIso8601String(),
      'read': true,
    });
    final serverId = item['serverId'] as String?;
    final adminToken = AuthService.instance.adminToken;
    if (serverId != null && adminToken != null) {
      ApiService.replyFeedback(adminToken, serverId, text);
    }
  }

  Future<void> markAllRead() async {
    for (final f in getAll().where((f) => !f.read)) {
      await markRead(f.key);
    }
  }

  Future<void> delete(dynamic key) async {
    final item = LocalDbService.instance.get(_box, key);
    final serverId = item?['serverId'] as String?;
    await LocalDbService.instance.delete(_box, key);
    final adminToken = AuthService.instance.adminToken;
    if (serverId != null && adminToken != null) {
      ApiService.deleteFeedback(adminToken, serverId);
    }
  }

  /// تسحب رسائل جديدة من السيرفر (من أي جهاز/زائر) وتدمجها محليًا — بدون
  /// حذف أو تكرار أي شي موجود أصلًا. للأدمن: كل الرسائل. لغير الأدمن: رسائلها
  /// هي بس (حسب بريدها). تُستدعى عند فتح شاشة الإشعارات.
  Future<void> syncWithServer() async {
    final auth = AuthService.instance;
    final List<Map<String, dynamic>>? remote;
    if (auth.isAdmin && auth.adminToken != null) {
      remote = await ApiService.fetchAllFeedback(auth.adminToken!);
    } else if (auth.currentUserEmail != null) {
      remote = await ApiService.fetchFeedbackForEmail(auth.currentUserEmail!);
    } else {
      remote = null;
    }
    if (remote == null) return;

    final existing = LocalDbService.instance.getAll(_box);
    final byServerId = {
      for (final e in existing)
        if (e.value['serverId'] != null) e.value['serverId'] as String: e,
    };

    for (final row in remote) {
      final id = row['id'] as String?;
      if (id == null) continue;
      final data = {
        'serverId': id,
        'name': row['name'] ?? '',
        'email': row['email'] ?? '',
        'type': row['type'] ?? 'question',
        'message': row['message'] ?? '',
        'relatedPlace': row['relatedPlace'],
        'createdAt': row['createdAt'] ?? DateTime.now().toIso8601String(),
        'read': row['read'] ?? false,
        'reply': row['reply'],
        'repliedAt': row['repliedAt'],
      };
      final match = byServerId[id];
      if (match == null) {
        await LocalDbService.instance.add(_box, data);
      } else {
        await LocalDbService.instance.update(_box, match.key, data);
      }
    }
  }
}
