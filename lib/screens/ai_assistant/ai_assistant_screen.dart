import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../widgets/themed_image.dart';
import '../common/detail_screen.dart';
import '../places/all_places_screen.dart';
import '../events/events_data.dart';
import '../../services/local_db_service.dart';
import '../../services/data_converters.dart';
import '../../services/weather_service.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_toggle_bar.dart';

class ChatMessage {
  final String textAr;
  final String textEn;
  final bool isUser;
  final DateTime time;
  final UniversalPlace? place;
  final EventItem? event;
  ChatMessage({
    required this.textAr,
    required this.textEn,
    required this.isUser,
    DateTime? time,
    this.place,
    this.event,
  }) : time = time ?? DateTime.now();
}

class AiAssistantScreen extends StatefulWidget {
  final String? initialQuery;
  const AiAssistantScreen({super.key, this.initialQuery});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _hasText = false;
  bool _showScrollToBottom = false;

  void _addGreeting() {
    _messages.add(
      ChatMessage(
        textAr:
            'مرحباً! أنا المساعد الذكي لدليل نابلس 🤖 اسألني عن أي مطعم، فندق، معلم سياحي، فعالية، أو خدمة بالمدينة، وبقترحلك أفضل الخيارات مباشرة.',
        textEn:
            "Hi! I'm the Nablus Guide AI Assistant 🤖 Ask me about any restaurant, hotel, landmark, event, or service in the city, and I'll suggest the best options right away.",
        isUser: false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _addGreeting();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send(widget.initialQuery);
      });
    }
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final distanceFromBottom =
          _scrollController.position.maxScrollExtent - _scrollController.offset;
      final shouldShow = distanceFromBottom > 200;
      if (shouldShow != _showScrollToBottom) {
        setState(() => _showScrollToBottom = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  UniversalPlace? _topRated(String categoryKey, {String? mustContainAr}) {
    final candidates = allPlaces.where((p) {
      if (p.categoryKey != categoryKey) return false;
      if (mustContainAr != null &&
          !p.typeAr.contains(mustContainAr) &&
          !p.nameAr.contains(mustContainAr)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => b.rating.compareTo(a.rating));
    return candidates.isEmpty ? null : candidates.first;
  }

  List<UniversalPlace> _topRatedList(String categoryKey, {int count = 3}) {
    final list = allPlaces.where((p) => p.categoryKey == categoryKey).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(count).toList();
  }

  // محلات "المراكز التجارية" حسب القسم الفرعي (أزياء، أحذية...) — تُستخدم لاقتراح
  // منتجات/محلات مشابهة عند الضغط على "اسأل الذكاء الاصطناعي عن هذا المحل".
  List<UniversalPlace> _topRatedShopping(String subCategory, {int count = 3}) {
    final list =
        allPlaces
            .where(
              (p) => p.categoryKey == 'shopping' && p.subCategory == subCategory,
            )
            .toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(count).toList();
  }

  List<EventItem> get _liveEvents => LocalDbService.instance
      .getAll('events')
      .map((e) => mapToEvent(e.value))
      .toList();

  EventItem? _nextEvent() {
    final live = _liveEvents;
    return live.isEmpty ? null : live.first;
  }

  // ردود ذكية محلية مبنية على بيانات التطبيق الحقيقية (بدون اتصال خارجي)
  ChatMessage _generateReply(String input) {
    final text = input.toLowerCase();

    bool has(List<String> arWords, List<String> enWords) {
      for (final w in arWords) {
        if (input.contains(w)) return true;
      }
      for (final w in enWords) {
        if (text.contains(w)) return true;
      }
      return false;
    }

    String namesList(List<UniversalPlace> items) =>
        items.map((p) => '${p.nameAr} (${p.rating}⭐)').join('، ');
    String namesListEn(List<UniversalPlace> items) =>
        items.map((p) => '${p.nameEn} (${p.rating}⭐)').join(', ');

    if (has(
      ['مرحبا', 'أهلا', 'اهلا', 'السلام عليكم', 'هاي'],
      ['hello', 'hi ', 'hey'],
    )) {
      return ChatMessage(
        textAr:
            'أهلاً فيك! 👋 كيف بقدر أساعدك اليوم؟ اسألني عن مطاعم، فنادق، معالم، تسوق، صحة، أو فعاليات نابلس.',
        textEn:
            'Welcome! 👋 How can I help you today? Ask me about restaurants, hotels, landmarks, shopping, health, or events in Nablus.',
        isUser: false,
      );
    }

    if (has(['كنافة', 'حلويات', 'حلو'], ['kunafa', 'sweets', 'dessert'])) {
      final top =
          _topRated('restaurant', mustContainAr: 'حلويات') ??
          _topRated('restaurant');
      return ChatMessage(
        textAr: 'لازم تجرب الكنافة النابلسية الأصلية! أفضل مكان مقترح حاليًا:',
        textEn:
            'You must try authentic Nabulsi kunafa! The best recommended spot right now:',
        isUser: false,
        place: top,
      );
    }

    if (has(
      ['مطعم', 'مطاعم', 'أكل', 'طعام', 'جوعان'],
      ['restaurant', 'food', 'eat', 'hungry'],
    )) {
      final list = _topRatedList('restaurant');
      return ChatMessage(
        textAr:
            'أفضل المطاعم المقترحة بنابلس حاليًا: ${namesList(list)}. اضغط على الاقتراح بالأسفل لمزيد من التفاصيل.',
        textEn:
            'Top recommended restaurants in Nablus right now: ${namesListEn(list)}. Tap the suggestion below for full details.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(
      ['فندق', 'فنادق', 'حجز', 'إقامة', 'مبيت'],
      ['hotel', 'stay', 'book'],
    )) {
      final list = _topRatedList('hotel');
      return ChatMessage(
        textAr: 'أفضل الفنادق تقييمًا بنابلس: ${namesList(list)}.',
        textEn: 'The best-rated hotels in Nablus: ${namesListEn(list)}.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(['أزياء', 'ملابس', 'موضة'], ['fashion', 'clothing', 'clothes'])) {
      final list = _topRatedShopping('fashion');
      return ChatMessage(
        textAr: list.isEmpty
            ? 'ما لقيت محلات أزياء مسجّلة حاليًا. جربي قسم "المراكز التجارية" بصفحة التسوق.'
            : 'أفضل محلات الأزياء بالمراكز التجارية: ${namesList(list)}. اضغطي على الاقتراح لمزيد من التفاصيل أو محلات قريبة مشابهة.',
        textEn: list.isEmpty
            ? 'No fashion stores are registered right now. Check the "Commercial Centers" section in Shopping.'
            : 'Top fashion stores in the commercial centers: ${namesListEn(list)}. Tap the suggestion for details or similar nearby stores.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(['أحذية', 'حذاء'], ['shoes', 'shoe', 'footwear'])) {
      final list = _topRatedShopping('shoes');
      return ChatMessage(
        textAr: list.isEmpty
            ? 'ما لقيت محلات أحذية مسجّلة حاليًا. جربي قسم "المراكز التجارية" بصفحة التسوق.'
            : 'أفضل محلات الأحذية بالمراكز التجارية: ${namesList(list)}.',
        textEn: list.isEmpty
            ? 'No shoe stores are registered right now. Check the "Commercial Centers" section in Shopping.'
            : 'Top shoe stores in the commercial centers: ${namesListEn(list)}.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(['إلكترونيات', 'الكترونيات', 'موبايل', 'هواتف'], ['electronics', 'electronic', 'mobile', 'phone'])) {
      final list = _topRatedShopping('electronics');
      return ChatMessage(
        textAr: list.isEmpty
            ? 'ما لقيت محلات إلكترونيات مسجّلة حاليًا. جربي قسم "المراكز التجارية" بصفحة التسوق.'
            : 'أفضل محلات الإلكترونيات بالمراكز التجارية: ${namesList(list)}.',
        textEn: list.isEmpty
            ? 'No electronics stores are registered right now. Check the "Commercial Centers" section in Shopping.'
            : 'Top electronics stores in the commercial centers: ${namesListEn(list)}.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(['تجميل', 'مكياج', 'مستحضرات'], ['cosmetics', 'makeup', 'beauty'])) {
      final list = _topRatedShopping('cosmetics');
      return ChatMessage(
        textAr: list.isEmpty
            ? 'ما لقيت محلات مستحضرات تجميل مسجّلة حاليًا. جربي قسم "المراكز التجارية" بصفحة التسوق.'
            : 'أفضل محلات مستحضرات التجميل بالمراكز التجارية: ${namesList(list)}.',
        textEn: list.isEmpty
            ? 'No cosmetics stores are registered right now. Check the "Commercial Centers" section in Shopping.'
            : 'Top cosmetics stores in the commercial centers: ${namesListEn(list)}.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(['مجوهرات', 'ذهب', 'حلي'], ['jewelry', 'jewellery', 'gold'])) {
      final list = _topRatedShopping('jewelry');
      return ChatMessage(
        textAr: list.isEmpty
            ? 'ما لقيت محلات مجوهرات مسجّلة حاليًا. جربي قسم "المراكز التجارية" بصفحة التسوق.'
            : 'أفضل محلات المجوهرات بالمراكز التجارية: ${namesList(list)}.',
        textEn: list.isEmpty
            ? 'No jewelry stores are registered right now. Check the "Commercial Centers" section in Shopping.'
            : 'Top jewelry stores in the commercial centers: ${namesListEn(list)}.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(['مكتبات', 'مكتبة', 'كتب'], ['bookstore', 'books', 'book'])) {
      final list = _topRatedShopping('books');
      return ChatMessage(
        textAr: list.isEmpty
            ? 'ما لقيت مكتبات مسجّلة حاليًا. جربي قسم "المراكز التجارية" بصفحة التسوق.'
            : 'أفضل المكتبات بالمراكز التجارية: ${namesList(list)}.',
        textEn: list.isEmpty
            ? 'No bookstores are registered right now. Check the "Commercial Centers" section in Shopping.'
            : 'Top bookstores in the commercial centers: ${namesListEn(list)}.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(['ترفيه', 'ألعاب', 'العاب'], ['arcade', 'games', 'gaming'])) {
      final list = _topRatedShopping('entertainment');
      return ChatMessage(
        textAr: list.isEmpty
            ? 'ما لقيت محلات ترفيه مسجّلة حاليًا. جربي قسم "المراكز التجارية" بصفحة التسوق.'
            : 'أفضل أماكن الترفيه والألعاب بالمراكز التجارية: ${namesList(list)}.',
        textEn: list.isEmpty
            ? 'No entertainment spots are registered right now. Check the "Commercial Centers" section in Shopping.'
            : 'Top entertainment and arcade spots in the commercial centers: ${namesListEn(list)}.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(
      ['تسوق', 'مول', 'شراء', 'سوق'],
      ['shopping', 'mall', 'buy', 'market'],
    )) {
      final list = _topRatedList('shopping');
      return ChatMessage(
        textAr: 'أفضل أماكن التسوق: ${namesList(list)}.',
        textEn: 'The best shopping spots: ${namesListEn(list)}.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(['صيدلية', 'صيدليات', 'دواء'], ['pharmacy', 'medicine'])) {
      final top = _topRated('pharmacy');
      return ChatMessage(
        textAr: top == null
            ? 'ما لقيت صيدلية مسجّلة حاليًا بالتطبيق.'
            : 'أقرب صيدلية مقترحة حاليًا: ${top.nameAr} (${top.rating}⭐).',
        textEn: top == null
            ? 'No pharmacy is registered in the app right now.'
            : 'The best recommended pharmacy right now: ${top.nameEn} (${top.rating}⭐).',
        isUser: false,
        place: top,
      );
    }

    if (has(
      ['مستشفى', 'عيادة', 'صحة', 'طبيب'],
      ['hospital', 'clinic', 'health', 'doctor'],
    )) {
      final top = _topRated('health');
      return ChatMessage(
        textAr: top == null
            ? 'ما لقيت مركز صحي مسجّل حاليًا بالتطبيق.'
            : 'أفضل مركز صحي مقترح: ${top.nameAr} (${top.rating}⭐).',
        textEn: top == null
            ? 'No health facility is registered in the app right now.'
            : 'The best recommended health facility: ${top.nameEn} (${top.rating}⭐).',
        isUser: false,
        place: top,
      );
    }

    if (has(
      ['مواصلات', 'باص', 'تاكسي', 'سرفيس'],
      ['transport', 'bus', 'taxi'],
    )) {
      final top = _topRated('transport');
      return ChatMessage(
        textAr: top == null
            ? 'ما لقيت خيار مواصلات مسجّل حاليًا بالتطبيق.'
            : 'من أفضل خيارات المواصلات بالمدينة: ${top.nameAr} (${top.rating}⭐).',
        textEn: top == null
            ? 'No transport option is registered in the app right now.'
            : 'One of the best transport options in the city: ${top.nameEn} (${top.rating}⭐).',
        isUser: false,
        place: top,
      );
    }

    if (has(
      ['معلم', 'سياحة', 'زيارة', 'اماكن', 'أماكن', 'تاريخ'],
      ['landmark', 'visit', 'place', 'tourist', 'history'],
    )) {
      final list = _topRatedList('attraction');
      return ChatMessage(
        textAr:
            'أشهر المعالم السياحية بنابلس: ${namesList(list)}. كلها موجودة على الخريطة التفاعلية.',
        textEn:
            'The most famous landmarks in Nablus: ${namesListEn(list)}. All available on the interactive map.',
        isUser: false,
        place: list.isEmpty ? null : list.first,
      );
    }

    if (has(['فعالية', 'فعاليات', 'مهرجان', 'حدث'], ['event', 'festival'])) {
      final ev = _nextEvent();
      return ChatMessage(
        textAr: ev == null
            ? 'ما في فعاليات قادمة مسجّلة حاليًا بالتطبيق.'
            : 'أقرب فعالية قادمة: "${ev.titleAr}" بـ${ev.venueAr} يوم ${ev.day} ${ev.monthAr}.',
        textEn: ev == null
            ? 'There are no upcoming events registered in the app right now.'
            : 'The nearest upcoming event: "${ev.titleEn}" at ${ev.venueEn} on ${ev.day} ${ev.monthEn}.',
        isUser: false,
        event: ev,
      );
    }

    if (has(['طقس', 'حرارة', 'جو'], ['weather', 'temperature'])) {
      final weather = AppState.instance.weather;
      if (weather != null) {
        final cond = weatherConditionFor(weather.weatherCode);
        return ChatMessage(
          textAr:
              'الطقس الحالي في نابلس: ${weather.temperature.round()}° مئوية، ${cond.descriptionAr}. اضغط على خانة "الطقس" بالصفحة الرئيسية لتفاصيل أكثر.',
          textEn:
              'Current weather in Nablus: ${weather.temperature.round()}°C, ${cond.descriptionEn}. Tap the "Weather" card on the home page for more details.',
          isUser: false,
        );
      }
      return ChatMessage(
        textAr:
            'ما قدرت أجيب بيانات الطقس الحية حاليًا. جرّبي تفتحي خانة "الطقس" بالصفحة الرئيسية.',
        textEn:
            "I couldn't fetch live weather data right now. Try opening the \"Weather\" card on the home page.",
        isUser: false,
      );
    }

    if (has(
      ['مساعدة', 'ماذا تفعل', 'شو تقدر', 'قدراتك'],
      ['help', 'what can you do', 'capabilities'],
    )) {
      final restaurantCount = allPlaces.where((p) => p.categoryKey == 'restaurant').length;
      final hotelCount = allPlaces.where((p) => p.categoryKey == 'hotel').length;
      final attractionCount = allPlaces.where((p) => p.categoryKey == 'attraction').length;
      final eventCount = _liveEvents.length;
      return ChatMessage(
        textAr:
            'بقدر أساعدك بـ: اقتراح مطاعم وفنادق ومعالم سياحية، إيجاد أقرب صيدلية أو مركز صحي، إخبارك بالفعاليات القادمة، وإرشادك لأفضل أماكن التسوق والمواصلات — كل هذا مبني على بيانات حقيقية داخل التطبيق '
            '(حاليًا: $restaurantCount مطعم، $hotelCount فندق، $attractionCount معلم سياحي، $eventCount فعالية قادمة).',
        textEn:
            'I can help you with: recommending restaurants, hotels, and landmarks, finding the nearest pharmacy or health center, telling you about upcoming events, and guiding you to the best shopping and transport spots — all based on real data inside the app '
            '(currently: $restaurantCount restaurants, $hotelCount hotels, $attractionCount landmarks, $eventCount upcoming events).',
        isUser: false,
      );
    }

    if (has(
      ['شكرا', 'شكراً', 'يعطيك العافية', 'تسلم'],
      ['thanks', 'thank you'],
    )) {
      return ChatMessage(
        textAr: 'العفو! تحت أمرك في أي وقت 🌿',
        textEn: "You're welcome! Always here to help 🌿",
        isUser: false,
      );
    }

    if (has(['باي', 'وداعا', 'مع السلامة'], ['bye', 'goodbye'])) {
      return ChatMessage(
        textAr: 'مع السلامة! بانتظارك بأي وقت لاستكشاف نابلس أكثر 👋',
        textEn: 'Goodbye! Come back anytime to explore more of Nablus 👋',
        isUser: false,
      );
    }

    return ChatMessage(
      textAr:
          'ما فهمت طلبك بالضبط 🤔 بس تقدر تسألني عن: المطاعم، الفنادق، المعالم السياحية، التسوق، الصيدليات، المستشفيات، المواصلات، الفعاليات، أو الطقس بنابلس.',
      textEn:
          "I didn't quite get that 🤔 but you can ask me about: restaurants, hotels, landmarks, shopping, pharmacies, hospitals, transport, events, or the weather in Nablus.",
      isUser: false,
    );
  }

  void _send([String? preset]) {
    final text = preset ?? _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(textAr: text, textEn: text, isUser: true));
      _controller.clear();
      _hasText = false;
      _isTyping = true;
    });
    _scrollToEnd();
    final delay = 500 + (text.length.clamp(0, 40)) * 15;
    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_generateReply(text));
      });
      _scrollToEnd();
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _addGreeting();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(app),
                  _buildSuggestions(app),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: _messages.length + (_isTyping ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i >= _messages.length) {
                              return _TypingBubble();
                            }
                            return _MessageBubble(
                              message: _messages[i],
                              onOpenPlace: _openPlace,
                              onOpenEvent: _openEvent,
                            );
                          },
                        ),
                        if (_showScrollToBottom)
                          Positioned(
                            bottom: 8,
                            right: 0,
                            left: 0,
                            child: Center(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _scrollToEnd,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardDark,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    size: 16,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildInputBar(app),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openPlace(UniversalPlace p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          titleAr: p.nameAr,
          titleEn: p.nameEn,
          subtitleAr: p.typeAr,
          subtitleEn: p.typeEn,
          descriptionAr: p.aboutAr,
          descriptionEn: p.aboutEn,
          rating: p.rating,
          locationAr: p.locationAr,
          locationEn: p.locationEn,
          customImageBase64: p.customImageBase64,
        ),
      ),
    );
  }

  void _openEvent(EventItem e) {
    final month = AppState.instance.isArabic ? e.monthAr : e.monthEn;
    final time = AppState.instance.isArabic ? e.timeAr : e.timeEn;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          titleAr: e.titleAr,
          titleEn: e.titleEn,
          subtitleAr: e.venueAr,
          subtitleEn: e.venueEn,
          descriptionAr: e.aboutAr,
          descriptionEn: e.aboutEn,
          extraInfo: '${e.day} $month • $time',
        ),
      ),
    );
  }

  Widget _buildHeader(AppState app) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.sidebarDark, AppColors.cardDark2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textWhite,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: 12),
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                  shape: BoxShape.circle,
                  boxShadow: AppColors.glowShadow,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.sidebarDark, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.t('المساعد الذكي', 'AI Assistant'),
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    AppColors.textWhite,
                  ).copyWith(fontSize: 15),
                ),
                Text(
                  app.t(
                    'متصل الآن • يرد فورًا',
                    'Online now • Replies instantly',
                  ),
                  textDirection: app.dir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(AppColors.green),
                ),
              ],
            ),
          ),
          AppToggleBar(),
          SizedBox(width: 10),
          PopupMenuButton<String>(
            color: AppColors.cardDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textWhite,
              size: 20,
            ),
            onSelected: (v) {
              if (v == 'clear') _clearChat();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: AppColors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      app.t('مسح المحادثة', 'Clear chat'),
                      style: AppTypography.body(AppColors.textWhite),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(AppState app) {
    return Container(
      color: AppColors.sidebarDark,
      padding: EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _suggestionChip(
              Icons.restaurant,
              app.t('أفضل المطاعم', 'Best restaurants'),
            ),
            SizedBox(width: 8),
            _suggestionChip(Icons.bed, app.t('أفضل الفنادق', 'Best hotels')),
            SizedBox(width: 8),
            _suggestionChip(
              Icons.mosque,
              app.t('أشهر المعالم', 'Top landmarks'),
            ),
            SizedBox(width: 8),
            _suggestionChip(
              Icons.shopping_bag,
              app.t('أماكن التسوق', 'Shopping spots'),
            ),
            SizedBox(width: 8),
            _suggestionChip(
              Icons.local_pharmacy,
              app.t('أقرب صيدلية', 'Nearest pharmacy'),
            ),
            SizedBox(width: 8),
            _suggestionChip(
              Icons.event,
              app.t('الفعاليات القادمة', 'Upcoming events'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(AppState app) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sidebarDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: TextField(
                controller: _controller,
                textDirection: app.dir,
                onChanged: (v) =>
                    setState(() => _hasText = v.trim().isNotEmpty),
                onSubmitted: (_) => _send(),
                style: AppTypography.body(
                  AppColors.textWhite,
                ).copyWith(fontSize: 13),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: app.t('اكتب سؤالك هنا...', 'Type your question...'),
                  hintStyle: AppTypography.body(
                    AppColors.textGrey,
                  ).copyWith(fontSize: 12),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _hasText ? () => _send() : null,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: _hasText
                    ? LinearGradient(colors: AppColors.primaryGradient)
                    : null,
                color: _hasText ? null : AppColors.cardDark2,
                shape: BoxShape.circle,
                boxShadow: _hasText ? AppColors.glowShadow : null,
              ),
              child: Icon(
                Icons.send_rounded,
                color: _hasText ? Colors.white : AppColors.textGrey,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(IconData icon, String label) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _send(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardDark2,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.primary),
            SizedBox(width: 6),
            Text(label, style: AppTypography.caption(AppColors.textWhite)),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(UniversalPlace) onOpenPlace;
  final void Function(EventItem) onOpenEvent;
  const _MessageBubble({
    required this.message,
    required this.onOpenPlace,
    required this.onOpenEvent,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final text = app.isArabic ? message.textAr : message.textEn;
    final isUser = message.isUser;
    final timeStr = DateFormat('hh:mm a').format(message.time);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 28,
              height: 28,
              margin: EdgeInsets.only(left: 8, top: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 13),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? null
                        : LinearGradient(colors: AppColors.primaryGradient),
                    color: isUser ? AppColors.cardDark2 : null,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 4 : 16),
                      bottomRight: Radius.circular(isUser ? 16 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    textDirection: app.dir,
                    style: AppTypography.body(
                      isUser ? AppColors.textWhite : Colors.white,
                    ).copyWith(fontSize: 13, height: 1.5),
                  ),
                ),
                if (message.place != null) ...[
                  SizedBox(height: 6),
                  _PlaceSuggestionCard(
                    place: message.place!,
                    onTap: () => onOpenPlace(message.place!),
                  ),
                ],
                if (message.event != null) ...[
                  SizedBox(height: 6),
                  _EventSuggestionCard(
                    event: message.event!,
                    onTap: () => onOpenEvent(message.event!),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    timeStr,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceSuggestionCard extends StatelessWidget {
  final UniversalPlace place;
  final VoidCallback onTap;
  const _PlaceSuggestionCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final p = place;
    final name = app.isArabic ? p.nameAr : p.nameEn;
    final type = app.isArabic ? p.typeAr : p.typeEn;
    return SizedBox(
      width: 230,
      child: AppCard(
        padding: EdgeInsets.zero,
        radius: AppRadius.lg,
        onTap: onTap,
        child: Row(
          children: [
            ThemedImage(
              query: p.photoQuery,
              fallbackSeed: p.nameEn,
              height: 64,
              fallbackIcon: p.icon,
              fallbackColor: p.color,
              customImageBase64: p.customImageBase64,
              localAsset: p.image,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      textDirection: app.dir,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        AppColors.textWhite,
                      ).copyWith(fontSize: 12),
                    ),
                    Text(
                      type,
                      textDirection: app.dir,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(AppColors.textGrey),
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 11,
                          color: AppColors.gold,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '${p.rating}',
                          style: AppTypography.caption(AppColors.textWhite),
                        ),
                        Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventSuggestionCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;
  const _EventSuggestionCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final e = event;
    final title = app.isArabic ? e.titleAr : e.titleEn;
    final venue = app.isArabic ? e.venueAr : e.venueEn;
    final month = app.isArabic ? e.monthAr : e.monthEn;
    return SizedBox(
      width: 230,
      child: AppCard(
        padding: EdgeInsets.all(10),
        radius: AppRadius.lg,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [e.color, e.color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                children: [
                  Text(
                    e.day,
                    style: AppTypography.label(
                      Colors.white,
                    ).copyWith(fontSize: 13),
                  ),
                  Text(month, style: AppTypography.caption(Colors.white)),
                ],
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(
                      AppColors.textWhite,
                    ).copyWith(fontSize: 12),
                  ),
                  Text(
                    venue,
                    textDirection: app.dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(AppColors.textGrey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final phase = (_controller.value + i * 0.2) % 1.0;
                    final scale =
                        0.5 +
                        0.5 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Opacity(
                        opacity: 0.4 + 0.6 * scale,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
