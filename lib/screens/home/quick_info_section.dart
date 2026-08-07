import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../map/map_screen.dart';
import '../news/news_screen.dart';

/// قسم "معلومات سريعة" بالشريط الجانبي — بطاقات قابلة للتوسيع (طوارئ، أوقات
/// صلاة، معلومة عن نابلس، فعالية اليوم). يحل محل قسم أسعار العملات القديم.
class QuickInfoSection extends StatelessWidget {
  const QuickInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SideCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SideSectionTitle(
            icon: Icons.bookmark_rounded,
            iconBg: AppColors.primary,
            titleAr: '💫 نبض نابلس',
            titleEn: '💫 Nablus Pulse',
          ),
          SizedBox(height: 10),
          ExpandableInfoCard(
            icon: Icons.emergency_rounded,
            iconBg: AppColors.red,
            titleAr: '🚨 الطوارئ',
            titleEn: '🚨 Emergency',
            child: _EmergencyContent(app: app),
          ),
          Divider(color: AppColors.borderColor, height: 18),
          ExpandableInfoCard(
            icon: Icons.mosque_rounded,
            iconBg: AppColors.teal,
            titleAr: '🕌 أوقات الصلاة',
            titleEn: '🕌 Prayer Times',
            child: _PrayerTimesContent(app: app),
          ),
          Divider(color: AppColors.borderColor, height: 18),
          ExpandableInfoCard(
            icon: Icons.attach_money_rounded,
            iconBg: AppColors.gold,
            titleAr: '💱 أسعار العملات',
            titleEn: '💱 Exchange Rates',
            child: _CurrencyRatesContent(app: app),
          ),
          Divider(color: AppColors.borderColor, height: 18),
          ExpandableInfoCard(
            icon: Icons.lightbulb_rounded,
            iconBg: AppColors.gold,
            titleAr: '💡 هل تعلم؟',
            titleEn: '💡 Did You Know?',
            child: _DidYouKnowContent(app: app),
          ),
          Divider(color: AppColors.borderColor, height: 18),
          ExpandableInfoCard(
            icon: Icons.event_rounded,
            iconBg: AppColors.purpleLight,
            titleAr: '📅 فعالية اليوم',
            titleEn: '📅 Today\'s Event',
            child: _TodayEventContent(app: app),
          ),
        ],
      ),
    );
  }
}

/// يفتح شيت سفلي بأوقات الصلاة — تُستخدم من زر "أوقات الصلاة" بصف
/// الإجراءات السريعة، بإعادة استخدام نفس محتوى بطاقة "نبض نابلس".
Future<void> showPrayerTimesSheet(BuildContext context) {
  final app = AppState.instance;
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _QuickSheet(
      icon: Icons.mosque_rounded,
      iconBg: AppColors.teal,
      titleAr: '🕌 أوقات الصلاة',
      titleEn: '🕌 Prayer Times',
      child: _PrayerTimesContent(app: app),
    ),
  );
}

/// يفتح شيت سفلي بأرقام وأماكن الطوارئ — تُستخدم من زر "الطوارئ" بصف
/// الإجراءات السريعة.
Future<void> showEmergencySheet(BuildContext context) {
  final app = AppState.instance;
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _QuickSheet(
      icon: Icons.emergency_rounded,
      iconBg: AppColors.red,
      titleAr: '🚨 الطوارئ',
      titleEn: '🚨 Emergency',
      child: _EmergencyContent(app: app),
    ),
  );
}

class _QuickSheet extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String titleAr;
  final String titleEn;
  final Widget child;
  const _QuickSheet({
    required this.icon,
    required this.iconBg,
    required this.titleAr,
    required this.titleEn,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 18, color: iconBg),
                ),
                SizedBox(width: 10),
                Text(
                  app.t(titleAr, titleEn),
                  textDirection: app.dir,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// بطاقة قابلة للتوسيع بأنيميشن سلس — عنصر مستقل قابل لإعادة الاستخدام.
class ExpandableInfoCard extends StatefulWidget {
  final IconData icon;
  final Color iconBg;
  final String titleAr;
  final String titleEn;
  final Widget child;
  const ExpandableInfoCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.titleAr,
    required this.titleEn,
    required this.child,
  });

  @override
  State<ExpandableInfoCard> createState() => ExpandableInfoCardState();
}

class ExpandableInfoCardState extends State<ExpandableInfoCard> {
  bool _open = false;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _open = !_open),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _hovering
                  ? AppColors.cardDark2.withValues(alpha: 0.6)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: widget.iconBg.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(widget.icon, size: 16, color: widget.iconBg),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        app.t(widget.titleAr, widget.titleEn),
                        textDirection: app.dir,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 250),
                      turns: _open ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _open
                      ? Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: widget.child,
                        )
                      : const SizedBox(width: double.infinity, height: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyContent extends StatelessWidget {
  final AppState app;
  const _EmergencyContent({required this.app});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EmergencyNumberRow(icon: Icons.local_hospital, labelAr: 'الإسعاف', labelEn: 'Ambulance', number: '101'),
        SizedBox(height: 8),
        _EmergencyNumberRow(icon: Icons.local_police, labelAr: 'الشرطة', labelEn: 'Police', number: '100'),
        SizedBox(height: 8),
        _EmergencyNumberRow(icon: Icons.local_fire_department, labelAr: 'الدفاع المدني', labelEn: 'Civil Defense', number: '102'),
        SizedBox(height: 10),
        _EmergencyPlaceRow(nameAr: 'مستشفى رفيديا', nameEn: 'Rafidia Hospital'),
        SizedBox(height: 6),
        _EmergencyPlaceRow(nameAr: 'المستشفى الوطني', nameEn: 'National Hospital'),
      ],
    );
  }
}

class _EmergencyNumberRow extends StatelessWidget {
  final IconData icon;
  final String labelAr;
  final String labelEn;
  final String number;
  const _EmergencyNumberRow({
    required this.icon,
    required this.labelAr,
    required this.labelEn,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.red),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            app.t(labelAr, labelEn),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey, fontSize: 11),
          ),
        ),
        Text(
          number,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EmergencyPlaceRow extends StatelessWidget {
  final String nameAr;
  final String nameEn;
  const _EmergencyPlaceRow({required this.nameAr, required this.nameEn});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Row(
      children: [
        Icon(Icons.local_hospital_outlined, size: 14, color: AppColors.purpleLight),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            app.t(nameAr, nameEn),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey, fontSize: 11),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => MapScreen())),
          child: Row(
            children: [
              Icon(Icons.map_outlined, size: 12, color: AppColors.primary),
              SizedBox(width: 3),
              Text(
                app.t('على الخريطة', 'On map'),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrencyRatesContent extends StatelessWidget {
  final AppState app;
  const _CurrencyRatesContent({required this.app});

  @override
  Widget build(BuildContext context) {
    if (app.ratesLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (app.ratesError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            app.ratesError!,
            textDirection: app.dir,
            style: TextStyle(color: AppColors.red, fontSize: 10),
          ),
          SizedBox(height: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => app.fetchRates(),
            child: Text(
              app.t('إعادة المحاولة', 'Retry'),
              textDirection: app.dir,
              style: TextStyle(color: AppColors.primary, fontSize: 11),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CurrencyRow(
          flagColor: Colors.blue,
          code: 'USD',
          rate: '${app.usdToIls.toStringAsFixed(2)} ILS',
        ),
        Divider(color: AppColors.borderColor, height: 16),
        _CurrencyRow(
          flagColor: Colors.green,
          code: 'JOD',
          rate: '${app.jodToIls.toStringAsFixed(2)} ILS',
        ),
        Divider(color: AppColors.borderColor, height: 16),
        _CurrencyRow(
          flagColor: Colors.indigo,
          code: 'EUR',
          rate: '${app.eurToIls.toStringAsFixed(2)} ILS',
        ),
      ],
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  final Color flagColor;
  final String code;
  final String rate;
  const _CurrencyRow({
    required this.flagColor,
    required this.code,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 10, backgroundColor: flagColor),
        SizedBox(width: 8),
        Text(
          code,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        Text(
          rate,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PrayerTimesContent extends StatelessWidget {
  final AppState app;
  const _PrayerTimesContent({required this.app});

  // بيانات تجريبية تقريبية لتوقيت نابلس بفصل الصيف، بانتظار ربطها بـ API
  // حقيقي لاحقًا. الوقت هون بنظام 24 ساعة (hour, minute) ونحوّله للعرض
  // بنظام 12 ساعة بدالة [_format12h].
  static const _times = [
    {'ar': 'الفجر', 'en': 'Fajr', 'h': 4, 'm': 20},
    {'ar': 'الشروق', 'en': 'Sunrise', 'h': 5, 'm': 50},
    {'ar': 'الظهر', 'en': 'Dhuhr', 'h': 12, 'm': 45},
    {'ar': 'العصر', 'en': 'Asr', 'h': 16, 'm': 25},
    {'ar': 'المغرب', 'en': 'Maghrib', 'h': 19, 'm': 35},
    {'ar': 'العشاء', 'en': 'Isha', 'h': 21, 'm': 0},
  ];

  String _format12h(int hour24, int minute, bool arabic) {
    final period = hour24 < 12
        ? (arabic ? 'ص' : 'AM')
        : (arabic ? 'م' : 'PM');
    var hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;
    final mm = minute.toString().padLeft(2, '0');
    return '$hour12:$mm $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final t in _times)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    app.t(t['ar'] as String, t['en'] as String),
                    textDirection: app.dir,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                  ),
                ),
                Text(
                  _format12h(t['h'] as int, t['m'] as int, app.isArabic),
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DidYouKnowContent extends StatefulWidget {
  final AppState app;
  const _DidYouKnowContent({required this.app});

  @override
  State<_DidYouKnowContent> createState() => _DidYouKnowContentState();
}

class _DidYouKnowContentState extends State<_DidYouKnowContent> {
  static const List<Map<String, String>> _facts = [
    {'ar': 'نابلس من أقدم المدن المأهولة بالعالم، ويعود تاريخها لآلاف السنين.', 'en': 'Nablus is one of the oldest continuously inhabited cities in the world.'},
    {'ar': 'تشتهر نابلس بالكنافة النابلسية التي اكتسبت شهرة عالمية.', 'en': 'Nablus is world-famous for its Nabulsi Kunafa dessert.'},
    {'ar': 'مدينة نابلس تُعرف تاريخيًا باسم "جبل النار" لكثرة معاصر الصابون فيها.', 'en': 'Nablus was historically known as "Mount of Fire" for its many soap factories.'},
    {'ar': 'الصابون النابلسي يُصنع من زيت الزيتون البلدي منذ مئات السنين.', 'en': 'Nabulsi soap has been made from local olive oil for centuries.'},
    {'ar': 'البلدة القديمة في نابلس تحتوي على أسواق مسقوفة يعود بعضها للعهد العثماني.', 'en': 'The Old City has covered markets dating back to the Ottoman era.'},
    {'ar': 'جبل جرزيم يطل على المدينة ويعتبر مقدسًا عند السامريين.', 'en': 'Mount Gerizim overlooks the city and is sacred to the Samaritan community.'},
    {'ar': 'نابلس تقع بين جبلي عيبال وجرزيم في وسط الضفة الغربية.', 'en': 'Nablus lies between Mount Ebal and Mount Gerizim in the central West Bank.'},
    {'ar': 'مدينة نابلس الحالية أسسها الرومان باسم "فلافيا نيابوليس" عام 72 م.', 'en': 'The Romans founded the city as "Flavia Neapolis" in 72 AD.'},
    {'ar': 'أقدم نسخة من التوراة السامرية محفوظة عند طائفة السامريين بجبل جرزيم.', 'en': 'One of the oldest Samaritan Torah scrolls is kept on Mount Gerizim.'},
    {'ar': 'حي الياسمينة من أقدم أحياء البلدة القديمة بنابلس.', 'en': 'Al-Yasmineh is one of the oldest quarters in the Old City.'},
    {'ar': 'قصر عبد الهادي من أبرز القصور التاريخية بالمدينة القديمة.', 'en': 'Abdel Hadi Palace is one of the most notable historic mansions in the Old City.'},
    {'ar': 'نابلس محطة رئيسية على طريق التجارة القديم بين الساحل وشرق الأردن.', 'en': 'Nablus was a key stop on the ancient trade route between the coast and Transjordan.'},
    {'ar': 'مدينة نابلس تضم أكثر من 30 كنيسة ومسجدًا تاريخيًا.', 'en': 'Nablus has more than 30 historic mosques and churches.'},
    {'ar': 'المسجد الكبير (الجامع الكبير) بني على أنقاض كنيسة بيزنطية.', 'en': 'The Great Mosque was built on the ruins of a Byzantine church.'},
    {'ar': 'بئر يعقوب من أهم المواقع الدينية القريبة من نابلس.', 'en': 'Jacob\'s Well is one of the most important religious sites near Nablus.'},
    {'ar': 'نابلس مركز تجاري وصناعي رئيسي بشمال الضفة الغربية.', 'en': 'Nablus is a major commercial and industrial hub in the northern West Bank.'},
    {'ar': 'جامعة النجاح الوطنية بنابلس من أكبر الجامعات الفلسطينية.', 'en': 'An-Najah National University in Nablus is one of the largest Palestinian universities.'},
    {'ar': 'أزقة البلدة القديمة بنابلس ما زالت تحافظ على طابعها المعماري الأصلي.', 'en': 'The alleys of the Old City still preserve their original architectural character.'},
    {'ar': 'حمام الشفاء من الحمامات التركية التاريخية العاملة بنابلس.', 'en': 'Al-Shifa Turkish Bath is one of the historic operating bathhouses in Nablus.'},
    {'ar': 'نابلس تشتهر أيضًا بالقطايف والمعمول بجانب الكنافة الشهيرة.', 'en': 'Besides kunafa, Nablus is also known for qatayef and maamoul sweets.'},
  ];

  late int _index;

  @override
  void initState() {
    super.initState();
    _index = Random().nextInt(_facts.length);
  }

  void _shuffle() {
    setState(() {
      int next;
      do {
        next = Random().nextInt(_facts.length);
      } while (next == _index && _facts.length > 1);
      _index = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final fact = _facts[_index];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              app.t(fact['ar']!, fact['en']!),
              key: ValueKey(_index),
              textDirection: app.dir,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ),
        SizedBox(width: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _shuffle,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.refresh_rounded, size: 14, color: AppColors.gold),
          ),
        ),
      ],
    );
  }
}

class _TodayEventContent extends StatelessWidget {
  final AppState app;
  const _TodayEventContent({required this.app});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          app.t('أمسية تراثية بالبلدة القديمة', 'Old City Heritage Evening'),
          textDirection: app.dir,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        _EventDetailRow(icon: Icons.calendar_today_rounded, text: app.t('اليوم', 'Today')),
        SizedBox(height: 6),
        _EventDetailRow(icon: Icons.schedule_rounded, text: '6:00 PM'),
        SizedBox(height: 6),
        _EventDetailRow(icon: Icons.place_rounded, text: app.t('ساحة الشهداء، البلدة القديمة', 'Martyrs Square, Old City')),
        SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => NewsScreen())),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.purpleLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 13, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  app.t('عرض التفاصيل', 'View Details'),
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EventDetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.purpleLight),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
