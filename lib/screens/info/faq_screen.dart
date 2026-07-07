import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import 'info_scaffold.dart';

class _Faq {
  final String qAr, qEn, aAr, aEn;
  const _Faq(
      {required this.qAr, required this.qEn, required this.aAr, required this.aEn});
}

final List<_Faq> _faqs = [
  _Faq(
    qAr: 'هل التطبيق يحتاج اتصال بالإنترنت؟',
    qEn: 'Does the app need an internet connection?',
    aAr:
        'الأقسام الأساسية (الأماكن، الفنادق، المطاعم) تعمل من بيانات محفوظة على جهازك، لكن بعض الميزات مثل أسعار العملات، الصور الحقيقية، والخريطة تحتاج اتصالًا بالإنترنت.',
    aEn:
        'The core sections (places, hotels, restaurants) work from data saved on your device, but some features like exchange rates, real photos, and the map need an internet connection.',
  ),
  _Faq(
    qAr: 'كيف أضيف مكانًا إلى المفضلة؟',
    qEn: 'How do I add a place to favorites?',
    aAr: 'اضغط على أيقونة القلب الموجودة على كرت أي مكان في شاشات المطاعم، الفنادق، أو التصنيفات الأخرى.',
    aEn: 'Tap the heart icon on any place card in the restaurants, hotels, or other category screens.',
  ),
  _Faq(
    qAr: 'كيف أغيّر اللغة أو المظهر (فاتح/داكن)؟',
    qEn: 'How do I change the language or theme (light/dark)?',
    aAr: 'استخدم زري تبديل اللغة وتبديل المظهر بأعلى الشاشة الرئيسية، ويُطبَّق التغيير فورًا على كل التطبيق.',
    aEn: 'Use the language and theme toggle buttons at the top of the home screen — the change applies instantly across the whole app.',
  ),
  _Faq(
    qAr: 'كيف أصل إلى موقع مكان معيّن على الخريطة؟',
    qEn: 'How do I find a specific place\'s location on the map?',
    aAr: 'افتح تفاصيل أي مكان واضغط "عرض على الخريطة"، وستفتح خريطة حقيقية (OpenStreetMap) مع تحديد موقعه وزر لفتح الاتجاهات في خرائط جوجل.',
    aEn: 'Open any place\'s details and tap "Show on Map" — a real OpenStreetMap view opens with its location pinned, plus a button to open directions in Google Maps.',
  ),
  _Faq(
    qAr: 'هل يمكنني إنشاء حساب أم يجب الدخول كزائر فقط؟',
    qEn: 'Can I create an account, or must I continue as a guest?',
    aAr: 'يمكنك إنشاء حساب بالبريد الإلكتروني وكلمة المرور من شاشة تسجيل الدخول، أو المتابعة كزائر دون حساب.',
    aEn: 'You can create an account with an email and password from the login screen, or continue as a guest without one.',
  ),
  _Faq(
    qAr: 'من يدير بيانات الأماكن والأخبار؟',
    qEn: 'Who manages the places and news data?',
    aAr: 'يوجد حساب أدمن مخصص لإدارة بيانات التطبيق من تبويب "أدمن" بشاشة تسجيل الدخول.',
    aEn: 'There is a dedicated admin account for managing the app\'s data via the "Admin" tab on the login screen.',
  ),
];

class FaqScreen extends StatefulWidget {
  FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? expanded;

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return InfoScaffold(
      titleAr: 'الأسئلة الشائعة',
      titleEn: 'FAQ',
      icon: Icons.help_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_faqs.length, (i) {
          final f = _faqs[i];
          final isOpen = expanded == i;
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => expanded = isOpen ? null : i),
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(isOpen ? Icons.remove_circle_outline : Icons.add_circle_outline,
                            color: AppColors.blue, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(app.t(f.qAr, f.qEn),
                              textDirection: app.dir,
                              style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isOpen)
                  Padding(
                    padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Text(app.t(f.aAr, f.aEn),
                        textDirection: app.dir,
                        textAlign: app.isArabic ? TextAlign.right : TextAlign.left,
                        style: TextStyle(color: AppColors.textGrey, fontSize: 12, height: 1.6)),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
