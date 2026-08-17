import 'package:flutter/material.dart';
import 'home_screen.dart'; // لإعادة استخدام AppState و AppColors
import 'quick_info_section.dart' show ExpandableInfoCard;
import '../../widgets/app_toggle_bar.dart';
import '../../services/auth_service.dart';
import '../../theme/app_typography.dart';
import '../auth/login_screen.dart';
import 'my_businesses_screen.dart';

/// يفتح لوحة الإعدادات كـ Bottom Sheet — نفس أسلوب البطاقات القابلة للتوسيع
/// المستخدم بقسم "نبض نابلس"، بدل ما يكون في أيقونات متفرقة بالشريط العلوي.
Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                app.t('⚙️ الإعدادات', '⚙️ Settings'),
                textDirection: app.dir,
                style: AppTypography.title(AppColors.textWhite),
              ),
              SizedBox(height: 12),
              ExpandableInfoCard(
                icon: Icons.person_rounded,
                iconBg: AppColors.blue,
                titleAr: '👤 الحساب',
                titleEn: '👤 Account',
                child: const _AccountContent(),
              ),
              if (AuthService.instance.userToken != null) ...[
                Divider(color: AppColors.borderColor, height: 18),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MyBusinessesScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          app.t('🏪 أعمالي', '🏪 My Businesses'),
                          textDirection: app.dir,
                          style: AppTypography.title(AppColors.textWhite).copyWith(fontSize: 14),
                        ),
                      ),
                      Icon(
                        app.isArabic
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.textGrey,
                      ),
                    ],
                  ),
                ),
              ],
              Divider(color: AppColors.borderColor, height: 18),
              ExpandableInfoCard(
                icon: Icons.dark_mode_rounded,
                iconBg: AppColors.purple,
                titleAr: '🌙 المظهر',
                titleEn: '🌙 Appearance',
                child: const _AppearanceContent(),
              ),
              Divider(color: AppColors.borderColor, height: 18),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _confirmLogout(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.red, size: 18),
                      SizedBox(width: 8),
                      Text(
                        app.t('تسجيل الخروج', 'Log Out'),
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
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

  void _confirmLogout(BuildContext context) {
    final app = AppState.instance;
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: app.dir,
        child: AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            app.t('تسجيل الخروج', 'Log Out'),
            style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
          ),
          content: Text(
            app.t('هل أنت متأكد من رغبتك بتسجيل الخروج؟', 'Are you sure you want to log out?'),
            style: TextStyle(color: AppColors.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(app.t('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.textGrey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await AuthService.instance.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                app.t('تسجيل الخروج', 'Log Out'),
                style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceContent extends StatelessWidget {
  const _AppearanceContent();

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                app.t('الوضع الليلي واللغة', 'Dark mode & language'),
                textDirection: app.dir,
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ),
            const AppToggleBar(),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                app.t('إخفاء شريط الأخبار المتحرك', 'Hide the news ticker'),
                textDirection: app.dir,
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ),
            Switch(
              value: app.hideNewsTicker,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => app.toggleNewsTicker(),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountContent extends StatefulWidget {
  const _AccountContent();

  @override
  State<_AccountContent> createState() => _AccountContentState();
}

class _AccountContentState extends State<_AccountContent> {
  bool _editing = false;
  bool _saving = false;
  String? _error;
  late final _nameCtrl = TextEditingController(
    text: AuthService.instance.currentUserName ?? '',
  );
  late final _emailCtrl = TextEditingController(
    text: AuthService.instance.currentUserEmail ?? '',
  );
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final app = AppState.instance;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await AuthService.instance.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      currentPassword:
          _newPasswordCtrl.text.isEmpty ? null : _currentPasswordCtrl.text,
      newPassword: _newPasswordCtrl.text.isEmpty ? null : _newPasswordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error == null) {
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.t('تم حفظ التعديلات', 'Changes saved'))),
      );
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final auth = AuthService.instance;

    if (auth.userToken == null) {
      // ضيف أو حساب محلي بدون سيرفر — ما فيه بيانات حساب حقيقية نعدّلها هون
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            app.t(
              'سجّل دخول بحساب حقيقي حتى تقدر تدير بيانات حسابك من هون.',
              'Log in with a real account to manage your account details here.',
            ),
            textDirection: app.dir,
            style: TextStyle(color: AppColors.textGrey, fontSize: 11, height: 1.5),
          ),
        ],
      );
    }

    if (!_editing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoRow(labelAr: 'الاسم', labelEn: 'Name', value: auth.currentUserName ?? '-'),
          SizedBox(height: 6),
          _InfoRow(labelAr: 'البريد الإلكتروني', labelEn: 'Email', value: auth.currentUserEmail ?? '-'),
          SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _editing = true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_rounded, size: 13, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  app.t('تعديل البيانات', 'Edit details'),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsField(
          controller: _nameCtrl,
          hintAr: 'الاسم',
          hintEn: 'Name',
        ),
        SizedBox(height: 8),
        _SettingsField(
          controller: _emailCtrl,
          hintAr: 'البريد الإلكتروني',
          hintEn: 'Email',
        ),
        SizedBox(height: 8),
        _SettingsField(
          controller: _currentPasswordCtrl,
          hintAr: 'كلمة المرور الحالية (لو بدك تغيّرها)',
          hintEn: 'Current password (if changing it)',
          obscure: true,
        ),
        SizedBox(height: 8),
        _SettingsField(
          controller: _newPasswordCtrl,
          hintAr: 'كلمة مرور جديدة (اختياري)',
          hintEn: 'New password (optional)',
          obscure: true,
        ),
        if (_error != null) ...[
          SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: AppColors.red, fontSize: 11)),
        ],
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _saving ? null : () => setState(() => _editing = false),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    app.t('إلغاء', 'Cancel'),
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _saving ? null : _save,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          app.t('حفظ', 'Save'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String labelAr;
  final String labelEn;
  final String value;
  const _InfoRow({required this.labelAr, required this.labelEn, required this.value});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return Row(
      children: [
        Text(
          app.t(labelAr, labelEn),
          textDirection: app.dir,
          style: TextStyle(color: AppColors.textGrey, fontSize: 11),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsField extends StatelessWidget {
  final TextEditingController controller;
  final String hintAr;
  final String hintEn;
  final bool obscure;
  const _SettingsField({
    required this.controller,
    required this.hintAr,
    required this.hintEn,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return TextField(
      controller: controller,
      obscureText: obscure,
      textDirection: app.dir,
      style: TextStyle(color: AppColors.textWhite, fontSize: 13),
      decoration: InputDecoration(
        isDense: true,
        hintText: app.t(hintAr, hintEn),
        hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 12),
        filled: true,
        fillColor: AppColors.cardDark2,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
