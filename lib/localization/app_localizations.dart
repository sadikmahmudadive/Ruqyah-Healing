import 'package:flutter/material.dart';

class AppLocalizations {
  static final ValueNotifier<Locale> currentLocaleNotifier =
      ValueNotifier<Locale>(const Locale('en'));

  static Locale get currentLocale => currentLocaleNotifier.value;

  static void setLocale(String languageCode) {
    currentLocaleNotifier.value = Locale(languageCode);
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
