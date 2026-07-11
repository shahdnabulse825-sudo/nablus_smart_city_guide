import 'package:flutter/material.dart';
import 'info_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      titleAr: 'سياسة الخصوصية',
      titleEn: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoSection(
            titleAr: 'البيانات التي نجمعها',
            titleEn: 'Data We Collect',
            bodyAr:
                'يخزّن التطبيق بيانات حسابك (الاسم والبريد الإلكتروني) وتفضيلاتك (اللغة، الثيم، الأماكن المفضلة) محليًا على جهازك فقط، ولا تُرسل هذه البيانات إلى أي خادم خارجي.',
            bodyEn:
                'The app stores your account data (name and email) and preferences (language, theme, favorite places) locally on your device only — this data is never sent to an external server.',
          ),
          InfoSection(
            titleAr: 'كيف نستخدم بياناتك',
            titleEn: 'How We Use Your Data',
            bodyAr:
                'تُستخدم بياناتك فقط لتشغيل ميزات التطبيق نفسه، مثل تسجيل الدخول، حفظ تفضيلاتك، وتذكّر الأماكن التي أعجبتك، ولا تُستخدم لأي غرض إعلاني أو تُشارك مع أي طرف ثالث.',
            bodyEn:
                'Your data is used only to power the app\'s own features, such as signing in, saving your preferences, and remembering places you liked. It is never used for advertising or shared with any third party.',
          ),
          InfoSection(
            titleAr: 'كلمات المرور',
            titleEn: 'Passwords',
            bodyAr:
                'يتم تشفير كلمة مرورك محليًا قبل حفظها، ولا يُخزَّن نصها الأصلي في أي مكان.',
            bodyEn:
                'Your password is encrypted locally before being stored — its original text is never saved anywhere.',
          ),
          InfoSection(
            titleAr: 'الصور المعروضة',
            titleEn: 'Displayed Photos',
            bodyAr:
                'بعض صور الأماكن تُجلب من خدمات صور خارجية مجانية (مثل Unsplash وLoremFlickr) بناءً على كلمات وصفية عامة، دون إرسال أي بيانات شخصية لهذه الخدمات.',
            bodyEn:
                'Some place photos are fetched from free external photo services (such as Unsplash and LoremFlickr) using generic descriptive keywords, without sending any personal data to these services.',
          ),
          InfoSection(
            titleAr: 'التحكم ببياناتك',
            titleEn: 'Controlling Your Data',
            bodyAr:
                'يمكنك حذف بياناتك بالكامل بحذف التطبيق من جهازك، أو التواصل معنا لأي استفسار متعلق بالخصوصية.',
            bodyEn:
                'You can delete all your data by uninstalling the app from your device, or contact us with any privacy-related question.',
          ),
        ],
      ),
    );
  }
}
