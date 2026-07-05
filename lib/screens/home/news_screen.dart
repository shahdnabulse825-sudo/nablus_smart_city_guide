import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("أخبار نابلس")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // عدد الأخبار
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Container(width: 50, height: 50, color: Colors.grey, child: const Icon(Icons.newspaper)),
              title: Text("عنوان الخبر رقم ${index + 1}"),
              subtitle: const Text("هذا ملخص سريع للخبر المنشور في مدينة نابلس..."),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // هنا ننتقل لصفحة تفاصيل الخبر
              },
            ),
          );
        },
      ),
     );
  }
}