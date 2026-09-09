import 'package:flutter/material.dart';

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier(super.value);

  void setLocale(String languageCode) {
    value = Locale(languageCode);
    notifyListeners();
  }
}

class AppLocalizations {
  static final LocaleNotifier currentLocaleNotifier =
      LocaleNotifier(const Locale('en'));

  static Locale get currentLocale => currentLocaleNotifier.value;

  static void setLocale(String languageCode) {
    currentLocaleNotifier.setLocale(languageCode);
  }

  static String getLanguageName(String code) {
    switch (code) {
      case 'bn':
        return 'বাংলা';
      case 'ar':
        return 'العربية';
      case 'ur':
        return 'اردو';
      case 'en':
      default:
        return 'English';
    }
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome_to': 'WELCOME TO',
      'ruqyah_healing': 'RUQYAH HEALING',
      'tagline': 'Compassionate care for body, mind and soul',
      'choose_language': 'Choose your language',
      'continue': 'Continue',
      'sign_in_account': 'SIGN IN TO YOUR ACCOUNT',
      'create_account_title': 'CREATE YOUR ACCOUNT',
      'email': 'Email',
      'phone': 'Phone',
      'email_address': 'Email Address',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'send_otp': 'Send OTP',
      'otp_code': 'OTP Code',
      'select_role': 'Select Role',
      'user': 'User',
      'raki': 'Raki',
      'therapist': 'Therapist',
      'full_name': 'Full Name',
      'or_continue_with': 'or continue with',
      'continue_google': 'Continue with Google',
      'home': 'Home',
      'services': 'Services',
      'bookings': 'Bookings',
      'learn': 'Learn',
      'profile': 'Profile',
      'settings': 'Settings',
      'greeting': 'Assalamu Alaikum,',
      'health_index': 'Health Index',
      'holistic_services': 'Holistic Services',
      'prayer_times': "Today's Prayer Times",
      'my_appointments': 'My Appointments',
      'browse_category': 'Browse by Category',
      'featured_courses': 'Featured Courses',
      'personal_info': 'Personal Information',
      'logout': 'Logout',
      'theme_mode': 'Theme Mode',
      'language': 'Language',
      'good': 'Good',
      'overall_wellness': 'Overall physical & spiritual wellness',
      'next_appointment': 'NEXT APPOINTMENT',
      'ruqyah': 'Ruqyah',
      'hijama': 'Hijama',
      'acupuncture': 'Acupuncture',
      'emergency': 'Emergency',
    },
    'bn': {
      'welcome_to': 'স্বাগতম',
      'ruqyah_healing': 'রুকিয়াহ হিলিং',
      'tagline': 'দেহ, মন ও আত্মার সহানুভূতিশীল সেবা',
      'choose_language': 'আপনার ভাষা নির্বাচন করুন',
      'continue': 'এগিয়ে যান',
      'sign_in_account': 'আপনার অ্যাকাউন্টে সাইন ইন করুন',
      'create_account_title': 'অ্যাকাউন্ট তৈরি করুন',
      'email': 'ইমেইল',
      'phone': 'ফোন',
      'email_address': 'ইমেইল ঠিকানা',
      'password': 'পাসওয়ার্ড',
      'confirm_password': 'পাসওয়ার্ড নিশ্চিত করুন',
      'forgot_password': 'পাসওয়ার্ড ভুলে গেছেন?',
      'sign_in': 'সাইন ইন',
      'sign_up': 'সাইন আপ',
      'send_otp': 'ওটিপি পাঠান',
      'otp_code': 'ওটিপি কোড',
      'select_role': 'ভূমিকা নির্বাচন করুন',
      'user': 'ব্যবহারকারী',
      'raki': 'রাকী',
      'therapist': 'থেরাপিস্ট',
      'full_name': 'সম্পূর্ণ নাম',
      'or_continue_with': 'অথবা এটি দিয়ে চালিয়ে যান',
      'continue_google': 'গুগল দিয়ে চালিয়ে যান',
      'home': 'হোম',
      'services': 'সেবা',
      'bookings': 'বুকিং',
      'learn': 'শিখুন',
      'profile': 'প্রোফাইল',
      'settings': 'সেটিংস',
      'greeting': 'আসসালামু আলাইকুম,',
      'health_index': 'স্বাস্থ্য ইনডেক্স',
      'holistic_services': 'হোলিস্টিক সেবা',
      'prayer_times': 'আজকের নামাযের সময়',
      'my_appointments': 'আমার অ্যাপয়েন্টমেন্ট',
      'browse_category': 'ক্যাটাগরি অনুযায়ী দেখুন',
      'featured_courses': 'বিশেষ কোর্সসমূহ',
      'personal_info': 'ব্যক্তিগত তথ্য',
      'logout': 'লগআউট',
      'theme_mode': 'থিম মোড',
      'language': 'ভাষা',
      'good': 'ভালো',
      'overall_wellness': 'সামগ্রিক শারীরিক ও আত্মিক সুস্থতা',
      'next_appointment': 'পরবর্তী অ্যাপয়েন্টমেন্ট',
      'ruqyah': 'রুকিয়াহ',
      'hijama': 'হিজামা',
      'acupuncture': 'আকুপাংচার',
      'emergency': 'জরুরী সেবা',
    },
    'ar': {
      'welcome_to': 'مرحباً بكم في',
      'ruqyah_healing': 'الرقية الشرعية',
      'tagline': 'رعاية شفيقة للجسد والعقل والروح',
      'choose_language': 'اختر لغتك',
      'continue': 'متابعة',
      'sign_in_account': 'تسجيل الدخول إلى حسابك',
      'create_account_title': 'إنشاء حساب جديد',
      'email': 'البريد',
      'phone': 'الهاتف',
      'email_address': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'sign_in': 'تسجيل الدخول',
      'sign_up': 'إنشاء حساب',
      'send_otp': 'إرسال الرمز',
      'otp_code': 'رمز التحقق',
      'select_role': 'اختر الصفة',
      'user': 'مستخدم',
      'raki': 'راقي',
      'therapist': 'معالج',
      'full_name': 'الاسم الكامل',
      'or_continue_with': 'أو المتابعة باستخدام',
      'continue_google': 'المتابعة بـ Google',
      'home': 'الرئيسية',
      'services': 'الخدمات',
      'bookings': 'الحجوزات',
      'learn': 'تعلم',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'greeting': 'السلام عليكم،',
      'health_index': 'مؤشر الصحة',
      'holistic_services': 'الخدمات الشاملة',
      'prayer_times': 'مواقيت الصلاة اليوم',
      'my_appointments': 'مواعيدي',
      'browse_category': 'التصفح حسب الفئة',
      'featured_courses': 'الدورات المميزة',
      'personal_info': 'المعلومات الشخصية',
      'logout': 'تسجيل الخروج',
      'theme_mode': 'وضع المظهر',
      'language': 'اللغة',
      'good': 'جيد',
      'overall_wellness': 'العافية الجسدية والروحية الشاملة',
      'next_appointment': 'الموعد القادم',
      'ruqyah': 'الرقية',
      'hijama': 'الحجامة',
      'acupuncture': 'الوخز بالإبر',
      'emergency': 'الطوارئ',
    },
    'ur': {
      'welcome_to': 'خوش آمدید',
      'ruqyah_healing': 'رقیہ ہیلنگ',
      'tagline': 'جسم، ذہن اور روح کی دیکھ بھال',
      'choose_language': 'اپنی زبان منتخب کریں',
      'continue': 'جاری رکھیں',
      'sign_in_account': 'اپنے اکاؤنٹ میں سائن ان کریں',
      'create_account_title': 'نیا اکاؤنٹ بنائیں',
      'email': 'ای میل',
      'phone': 'فون',
      'email_address': 'ای میل ایڈریس',
      'password': 'پاس ورڈ',
      'confirm_password': 'پاس ورڈ کی تصدیق کریں',
      'forgot_password': 'پاس ورڈ بھول گئے؟',
      'sign_in': 'سائن ان',
      'sign_up': 'سائن اپ',
      'send_otp': 'او ٹی پی بھیجیں',
      'otp_code': 'او ٹی پی کوڈ',
      'select_role': 'کردار منتخب کریں',
      'user': 'صارف',
      'raki': 'راقی',
      'therapist': 'معالج',
      'full_name': 'مکمل نام',
      'or_continue_with': 'یا اس کے ساتھ جاری رکھیں',
      'continue_google': 'گوگل کے ساتھ جاری رکھیں',
      'home': 'ہوم',
      'services': 'خدمات',
      'bookings': 'بکنگز',
      'learn': 'سیکھیں',
      'profile': 'پروفائل',
      'settings': 'سیٹنگز',
      'greeting': 'السلام علیکم،',
      'health_index': 'ہیلتھ انڈیکس',
      'holistic_services': 'ہولسٹک سروسز',
      'prayer_times': 'آج کے اوقاتِ نماز',
      'my_appointments': 'میری اپائنٹمنٹس',
      'browse_category': 'زمرہ جات کے لحاظ سے دیکھئے',
      'featured_courses': 'نمایاں کورسز',
      'personal_info': 'ذاتی معلومات',
      'logout': 'لاگ آؤٹ',
      'theme_mode': 'تھیم موڈ',
      'language': 'زبان',
      'good': 'بہتر',
      'overall_wellness': 'مجموعی جسمانی اور روحانی صحت',
      'next_appointment': 'اگلی اپائنٹمنٹ',
      'ruqyah': 'رقیہ',
      'hijama': 'حجامہ',
      'acupuncture': 'ایکیوپنکچر',
      'emergency': 'ہنگامی',
    },
  };

  static String tr(BuildContext context, String key) {
    final lang = currentLocaleNotifier.value.languageCode;
    return _localizedValues[lang]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

extension LocalizationContext on BuildContext {
  String tr(String key) => AppLocalizations.tr(this, key);
}
