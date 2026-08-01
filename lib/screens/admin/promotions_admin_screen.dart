import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../home/home_screen.dart'; // لإعادة استخدام AppState و AppColors
import '../../theme/app_typography.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

const List<(String, String, String)> _categoryOptions = [
  ('', 'بدون ربط', 'No link'),
  ('restaurants', 'مطاعم', 'Restaurants'),
  ('hotels', 'فنادق', 'Hotels'),
  ('pharmacies', 'صيدليات', 'Pharmacies'),
  ('attractions', 'سياحة ومعالم', 'Attractions'),
  ('shopping', 'تسوق', 'Shopping'),
  ('transport', 'مواصلات', 'Transport'),
  ('health', 'صحة', 'Health'),
  ('education', 'تعليم', 'Education'),
  ('banks', 'بنوك وصرافة', 'Banks & Exchange'),
  ('entertainment', 'ترفيه', 'Entertainment'),
  ('government', 'خدمات حكومية', 'Government Services'),
];

/// شاشة إدارة "عروض وإعلانات" — عرض/إضافة/تعديل/حذف، منفصلة عن نظام
/// AdminCollectionScreen العام لأن شكل بيانات العرض مختلف كليًا (عنوان/كود
/// خصم/فترة صلاحية) عن باقي الأقسام.
class PromotionsAdminScreen extends StatefulWidget {
  const PromotionsAdminScreen({super.key});

  @override
  State<PromotionsAdminScreen> createState() => _PromotionsAdminScreenState();
}

class _PromotionsAdminScreenState extends State<PromotionsAdminScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = AuthService.instance.adminToken;
    final items = token == null
        ? null
        : await ApiService.fetchAllPromotionsForAdmin(token);
    if (!mounted) return;
    setState(() {
      _items = items ?? [];
      _loading = false;
    });
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.teal,
      ),
    );
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => _PromotionFormScreen(existing: existing),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final app = AppState.instance;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: app.dir,
        child: AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text(
            app.t('حذف العرض', 'Delete offer'),
            style: TextStyle(color: AppColors.textWhite),
          ),
          content: Text(
            app.t('متأكدة إنك بدك تحذفي هالعرض؟', 'Are you sure you want to delete this offer?'),
            style: TextStyle(color: AppColors.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(app.t('إلغاء', 'Cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                app.t('حذف', 'Delete'),
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final token = AuthService.instance.adminToken;
    if (token == null) return;
    final status = await ApiService.deleteItem(token, 'promotions', item['id']);
    if (status >= 200 && status < 300) {
      _showMessage(app.t('تم الحذف', 'Deleted'), isError: false);
      _load();
    } else {
      _showMessage(app.t('فشل الحذف', 'Delete failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _openForm(),
          child: Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: AppColors.sidebarDark,
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                    ),
                    SizedBox(width: 12),
                    Text(
                      app.t('عروض وإعلانات', 'Deals & Offers'),
                      textDirection: app.dir,
                      style: AppTypography.title(AppColors.textWhite),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _items.isEmpty
                        ? Center(
                            child: Text(
                              app.t('ما في عروض حالياً — اضغطي + لإضافة عرض', 'No offers yet — tap + to add one'),
                              textDirection: app.dir,
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _items.length,
                            itemBuilder: (context, i) {
                              final item = _items[i];
                              final endDate = DateTime.tryParse(item['endDate'] ?? '');
                              final expired = endDate != null && endDate.isBefore(DateTime.now());
                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  app.isArabic ? item['titleAr'] : item['titleEn'],
                                                  textDirection: app.dir,
                                                  style: AppTypography.label(AppColors.textWhite)
                                                      .copyWith(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              if (expired)
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.red.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    app.t('منتهي', 'Expired'),
                                                    style: TextStyle(color: AppColors.red, fontSize: 10),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if ((item['placeNameAr'] ?? '').toString().isNotEmpty) ...[
                                            SizedBox(height: 4),
                                            Text(
                                              app.isArabic ? item['placeNameAr'] : item['placeNameEn'],
                                              textDirection: app.dir,
                                              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                                            ),
                                          ],
                                          if ((item['discountCode'] ?? '').toString().isNotEmpty) ...[
                                            SizedBox(height: 4),
                                            Text(
                                              '${app.t("كود", "Code")}: ${item['discountCode']}',
                                              style: TextStyle(color: AppColors.primary, fontSize: 12),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: AppColors.textGrey, size: 20),
                                      onPressed: () => _openForm(existing: item),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: AppColors.red, size: 20),
                                      onPressed: () => _delete(item),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromotionFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const _PromotionFormScreen({this.existing});

  @override
  State<_PromotionFormScreen> createState() => _PromotionFormScreenState();
}

class _PromotionFormScreenState extends State<_PromotionFormScreen> {
  late final TextEditingController _titleAr;
  late final TextEditingController _titleEn;
  late final TextEditingController _descAr;
  late final TextEditingController _descEn;
  late final TextEditingController _code;
  late final TextEditingController _placeAr;
  late final TextEditingController _placeEn;
  String _categoryKey = '';
  DateTime? _startDate;
  DateTime? _endDate;
  List<int>? _newImageBytes;
  String? _newImageFilename;
  bool _saving = false;
  bool _pickingImage = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleAr = TextEditingController(text: e?['titleAr'] ?? '');
    _titleEn = TextEditingController(text: e?['titleEn'] ?? '');
    _descAr = TextEditingController(text: e?['descriptionAr'] ?? '');
    _descEn = TextEditingController(text: e?['descriptionEn'] ?? '');
    _code = TextEditingController(text: e?['discountCode'] ?? '');
    _placeAr = TextEditingController(text: e?['placeNameAr'] ?? '');
    _placeEn = TextEditingController(text: e?['placeNameEn'] ?? '');
    _categoryKey = e?['categoryKey'] ?? '';
    _startDate = DateTime.tryParse(e?['startDate'] ?? '');
    _endDate = DateTime.tryParse(e?['endDate'] ?? '');
  }

  @override
  void dispose() {
    for (final c in [_titleAr, _titleEn, _descAr, _descEn, _code, _placeAr, _placeEn]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _pickingImage = true);
    try {
      final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
      final file = result?.files.single;
      if (file?.bytes != null) {
        setState(() {
          _newImageBytes = file!.bytes;
          _newImageFilename = file.name;
        });
      }
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.red));
  }

  Future<void> _save() async {
    final app = AppState.instance;
    if (_titleAr.text.trim().isEmpty || _titleEn.text.trim().isEmpty) {
      _showMessage(app.t('لازم تكتبي عنوان العرض بالعربي والإنجليزي', 'Please enter the offer title in both languages'));
      return;
    }
    final token = AuthService.instance.adminToken;
    if (token == null) {
      _showMessage(app.t('انتهت جلسة الدخول', 'Session expired'));
      return;
    }
    setState(() => _saving = true);
    final fields = {
      'titleAr': _titleAr.text.trim(),
      'titleEn': _titleEn.text.trim(),
      'descriptionAr': _descAr.text.trim(),
      'descriptionEn': _descEn.text.trim(),
      'discountCode': _code.text.trim(),
      'placeNameAr': _placeAr.text.trim(),
      'placeNameEn': _placeEn.text.trim(),
      'categoryKey': _categoryKey,
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
    };
    final existingId = widget.existing?['id'] as String?;
    final status = existingId == null
        ? await ApiService.createItem(
            token,
            'promotions',
            fields,
            imageBytes: _newImageBytes,
            imageFilename: _newImageFilename,
          )
        : await ApiService.updateItem(
            token,
            'promotions',
            existingId,
            fields,
            imageBytes: _newImageBytes,
            imageFilename: _newImageFilename,
          );
    if (!mounted) return;
    setState(() => _saving = false);
    if (status >= 200 && status < 300) {
      Navigator.of(context).pop(true);
    } else {
      _showMessage(app.t('فشل الحفظ — تأكدي إنه السيرفر شغال', 'Save failed — make sure the server is running'));
    }
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
    final app = AppState.instance;
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        textDirection: app.dir,
        style: TextStyle(color: AppColors.textWhite),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textGrey),
          filled: true,
          fillColor: AppColors.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final dateFmt = DateFormat('yyyy-MM-dd');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: AppColors.sidebarDark,
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Icon(Icons.arrow_back, color: AppColors.textWhite),
                    ),
                    SizedBox(width: 12),
                    Text(
                      widget.existing == null
                          ? app.t('إضافة عرض', 'Add offer')
                          : app.t('تعديل عرض', 'Edit offer'),
                      textDirection: app.dir,
                      style: AppTypography.title(AppColors.textWhite),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickingImage ? null : _pickImage,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          alignment: Alignment.center,
                          child: _pickingImage
                              ? CircularProgressIndicator(color: AppColors.primary)
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.image, color: AppColors.textGrey),
                                    SizedBox(height: 6),
                                    Text(
                                      _newImageFilename ??
                                          app.t('اختيار صورة (اختياري)', 'Choose an image (optional)'),
                                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 16),
                      _field(app.t('عنوان العرض (عربي)', 'Offer title (Arabic)'), _titleAr),
                      _field(app.t('عنوان العرض (إنجليزي)', 'Offer title (English)'), _titleEn),
                      _field(app.t('تفاصيل العرض (عربي)', 'Details (Arabic)'), _descAr, maxLines: 3),
                      _field(app.t('تفاصيل العرض (إنجليزي)', 'Details (English)'), _descEn, maxLines: 3),
                      _field(app.t('كود الخصم (اختياري)', 'Discount code (optional)'), _code),
                      _field(app.t('اسم المحل (عربي)', 'Place name (Arabic)'), _placeAr),
                      _field(app.t('اسم المحل (إنجليزي)', 'Place name (English)'), _placeEn),
                      Container(
                        margin: EdgeInsets.only(bottom: 14),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _categoryKey,
                            dropdownColor: AppColors.cardDark,
                            style: TextStyle(color: AppColors.textWhite),
                            items: _categoryOptions
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.$1,
                                    child: Text(app.isArabic ? c.$2 : c.$3),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _categoryKey = v ?? ''),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pickDate(isStart: true),
                              child: Text(
                                _startDate == null
                                    ? app.t('تاريخ البداية (اختياري)', 'Start date (optional)')
                                    : dateFmt.format(_startDate!),
                                style: TextStyle(fontSize: 12, color: AppColors.textWhite),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pickDate(isStart: false),
                              child: Text(
                                _endDate == null
                                    ? app.t('تاريخ الانتهاء (اختياري)', 'End date (optional)')
                                    : dateFmt.format(_endDate!),
                                style: TextStyle(fontSize: 12, color: AppColors.textWhite),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: _saving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  app.t('حفظ', 'Save'),
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
