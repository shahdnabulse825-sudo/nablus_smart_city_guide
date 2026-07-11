import 'package:flutter/material.dart';
import 'info_scaffold.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      titleAr: 'الشروط والأحكام',
      titleEn: 'Terms & Conditions',
      icon: Icons.gavel_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoSection(
            titleAr: 'استخدام التطبيق',
            titleEn: 'Using the App',
            bodyAr:
                'باستخدامك دليل نابلس الذكي، فأنت توافق على استخدامه لأغراض الاستكشاف والاطلاع على المعلومات السياحية والخدمية فقط، وعدم إساءة استخدام أي محتوى أو ميزة فيه.',
            bodyEn:
                'By using Nablus Smart Guide, you agree to use it only for exploring and viewing tourism and service information, and not to misuse any content or feature within it.',
          ),
          InfoSection(
            titleAr: 'دقة المعلومات',
            titleEn: 'Accuracy of Information',
            bodyAr:
                'نبذل جهدًا لإبقاء بيانات الأماكن (المطاعم، الفنادق، أوقات العمل، الأسعار) دقيقة ومحدّثة، إلا أنها قد تتغير من الجهة الفعلية دون إشعار مسبق، لذا يُنصح بالتأكد من التفاصيل الحساسة مباشرة قبل الاعتماد عليها.',
            bodyEn:
                'We make an effort to keep place data (restaurants, hotels, hours, prices) accurate and up to date, but it may change on the actual venue\'s side without prior notice, so please confirm sensitive details directly before relying on them.',
          ),
          InfoSection(
            titleAr: 'الحسابات',
            titleEn: 'Accounts',
            bodyAr:
                'أنت مسؤول عن الحفاظ على سرية بيانات دخولك، ويحق لنا تعليق أي حساب يُستخدم بشكل يخالف هذه الشروط.',
            bodyEn:
                'You are responsible for keeping your login details confidential, and we reserve the right to suspend any account used in violation of these terms.',
          ),
          InfoSection(
            titleAr: 'حدود المسؤولية',
            titleEn: 'Limitation of Liability',
            bodyAr:
                'التطبيق دليل معلوماتي، ولا يتحمل فريق التطبيق مسؤولية أي تعامل تجاري مباشر يتم بينك وبين الأماكن المعروضة (حجوزات، مدفوعات، خدمات).',
            bodyEn:
                'The app is an informational guide, and the app team is not responsible for any direct business dealings between you and the listed venues (bookings, payments, services).',
          ),
          InfoSection(
            titleAr: 'التعديلات',
            titleEn: 'Changes',
            bodyAr:
                'قد نُحدّث هذه الشروط من وقت لآخر لمواكبة تطور التطبيق، وسيظهر أي تحديث جوهري داخل التطبيق.',
            bodyEn:
                'We may update these terms from time to time as the app evolves; any material update will be shown within the app.',
          ),
        ],
      ),
    );
  }
}
