import 'package:flutter/material.dart';
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import 'info_scaffold.dart';

class AboutUsScreen extends StatelessWidget {
  AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      titleAr: 'من نحن',
      titleEn: 'About Us',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.purple, AppColors.blue]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.location_city, color: Colors.white, size: 34),
            ),
          ),
          InfoSection(
            titleAr: 'دليل نابلس الذكي',
            titleEn: 'Nablus Smart Guide',
            bodyAr:
                'دليل نابلس الذكي هو تطبيق شامل يهدف إلى تعريف زوار وسكان مدينة نابلس بكل ما تقدمه المدينة من معالم تاريخية، مطاعم، فنادق، أماكن تسوق، وخدمات يومية، بواجهة عربية وإنجليزية سهلة الاستخدام.',
            bodyEn:
                'Nablus Smart Guide is a comprehensive app that introduces visitors and residents of Nablus to everything the city has to offer: historic landmarks, restaurants, hotels, shopping spots, and everyday services, through an easy-to-use Arabic and English interface.',
          ),
          InfoSection(
            titleAr: 'رسالتنا',
            titleEn: 'Our Mission',
            bodyAr:
                'نسعى لتسهيل اكتشاف نابلس رقميًا، ودعم الأعمال المحلية عبر منحها واجهة عرض حديثة، وربط الزوار بأفضل ما تقدمه المدينة بضغطة واحدة.',
            bodyEn:
                'We aim to make discovering Nablus digitally easier, support local businesses with a modern showcase, and connect visitors with the best the city has to offer in one tap.',
          ),
          InfoSection(
            titleAr: 'لماذا نابلس؟',
            titleEn: 'Why Nablus?',
            bodyAr:
                'نابلس مدينة عريقة تجمع بين تاريخ آلاف السنين وحيوية الحاضر، من أزقة البلدة القديمة وحتى أحدث مراكز التسوق، وهذا التطبيق يحاول أن يعكس هذا التنوع بأمانة.',
            bodyEn:
                'Nablus is a historic city blending thousands of years of history with modern vibrancy, from the alleys of the Old City to the newest shopping centers — this app tries to faithfully reflect that diversity.',
          ),
        ],
      ),
    );
  }
}
