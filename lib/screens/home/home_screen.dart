import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'news_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false;

  Color get bgColor => _isDarkMode ? const Color(0xFF1E272E) : const Color(0xFFF4F6FC);
  Color get cardColor => _isDarkMode ? const Color(0xFF2D3436) : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF2D3436);
  final Color primaryColor = const Color(0xFF6C5CE7);
  final Color accentColor = const Color(0xFFFF7675);

  String _temp = "--", _usdRate = "--", _jodRate = "--", _eurRate = "--", _currentTime = "";

  void _handleNavigation(String tabName) {
    if (tabName == 'الأخبار') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("جاري الانتقال إلى $tabName...")));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
    fetchExchangeRates();
    _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now()));
    });
  }

  Future<void> fetchExchangeRates() async {
    final String apiKey = "f283fa22e58b0d96ce9e8f59";
    final url = Uri.parse('https://v6.exchangerate-api.com/v6/$apiKey/latest/USD');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          double ilsRate = data['conversion_rates']['ILS'].toDouble();
          _usdRate = ilsRate.toStringAsFixed(2);
          _jodRate = (ilsRate * 1.41).toStringAsFixed(2);
          _eurRate = (ilsRate * 1.08).toStringAsFixed(2);
        });
      }
    } catch (e) { debugPrint("خطأ في العملات: $e"); }
  }

  Future<void> fetchWeather() async {
    final String apiKey = "12cfcdd21283950891b0ebeafc7da981";
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=Nablus&appid=$apiKey&units=metric');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _temp = (data['main']['temp']).round().toString());
      }
    } catch (e) { debugPrint("خطأ في الطقس: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrencySidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  _buildTopBar(), 
                  const SizedBox(height: 40),
                  _buildHeroSection(),
                  const SizedBox(height: 20),
                  _buildDynamicStatusBar(),
                  const SizedBox(height: 40),
                  _buildCategoriesGrid(), 
                  const SizedBox(height: 20),
                  _buildAdditionalCategoriesGrid(), 
                  const SizedBox(height: 40),
                  _buildLowerSections(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
          child: Text("الساعة: $_currentTime", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ),
        _buildHeader(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: ['الرئيسية', 'استكشف', 'الخريطة', 'المساعد الذكي', 'الأخبار']
          .map((tab) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () => _handleNavigation(tab), // ربط الضغط بالدالة
                  child: Text(tab, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCategoriesGrid() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _buildCategoryCard('صيدليات', Icons.local_pharmacy, Colors.redAccent),
    _buildCategoryCard('مطاعم', Icons.restaurant, accentColor),
    _buildCategoryCard('فنادق', Icons.hotel, primaryColor),
    _buildCategoryCard('سياحة', Icons.castle, Colors.green),
  ]);

  Widget _buildAdditionalCategoriesGrid() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _buildCategoryCard('صحة', Icons.health_and_safety, Colors.blue),
    _buildCategoryCard('مواصلات', Icons.directions_bus, Colors.teal),
    _buildCategoryCard('تسوق', Icons.shopping_bag, Colors.pink),
  ]);

  Widget _buildCurrencySidebar() {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20),
       boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("أسعار الصرف", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            IconButton(icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: textColor),
             onPressed: () => setState(() => _isDarkMode = !_isDarkMode))
          ]),
          const Divider(),
          _buildCurrencyRow("USD", _usdRate),
          _buildCurrencyRow("JOD", _jodRate),
          _buildCurrencyRow("EUR", _eurRate),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(String name, String rate) => 
  Padding
  (padding: const EdgeInsets.symmetric(vertical: 8),
   child: 
   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
  children:
   [Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
   Text("$rate ILS", style: TextStyle(color: textColor))]
   )

   );

  Widget _buildHeroSection() => Column(children: 
  [Text('دليلك الكامل لمدينة نابلس',
   style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)), 
   const SizedBox(height: 20),
     Container(width: 600, decoration: BoxDecoration(color: cardColor, 
    borderRadius: BorderRadius.circular(20)), 
    child: const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), 
    border: InputBorder.none, hintText: "ابحث عن مكان...")))]);

  Widget _buildDynamicStatusBar() => Row(mainAxisAlignment: MainAxisAlignment.center,
   children: [_buildDynamicChip(Icons.wb_sunny_rounded, 'نابلس $_temp°C'),
    const SizedBox(width: 15), _buildDynamicChip(Icons.people_alt_rounded, '500+ زائر')]);

  Widget _buildDynamicChip(IconData icon, String label) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)), 
  child: Row(children: [Icon(icon, color: primaryColor), 
  const SizedBox(width: 8), 
  Text(label, style: TextStyle(color: textColor))]));

  Widget _buildCategoryCard(String title, IconData icon, Color iconColor) => Container(margin: const EdgeInsets.symmetric(horizontal: 10), 
  padding: const EdgeInsets.all(20), 
  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)), 
  child: Column(children: [Icon(icon, color: iconColor), 
  const SizedBox(height: 10), 
  Text(title, style: TextStyle(color: textColor))]));

  Widget _buildLowerSections() => Row(children: [Expanded(child: _buildSectionBox('فعاليات', Icons.event, accentColor)), 
  const SizedBox(width: 20),
   Expanded(child: _buildSectionBox('خريطة', Icons.map, primaryColor))]);

  Widget _buildSectionBox(String title, IconData icon, Color color) => Container(height: 150, decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)), 
  child: Column(mainAxisAlignment: MainAxisAlignment.center,
   children: [Icon(icon, color: color, size: 40),
   Text(title, style: TextStyle(color: textColor))]));
}