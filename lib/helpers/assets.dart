import 'dart:io';

class AppConstants {
  static bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  // Responsive spacing
  static double get defaultPadding => isDesktop ? 24.0 : 16.0;
  static double get fieldSpacing => isDesktop ? 16.0 : 12.0;
  static double get sectionSpacing => isDesktop ? 32.0 : 20.0;
  static double get imageSize => isDesktop ? 180.0 : 150.0;

  // Font sizes
  static double get fontSizeTitle => isDesktop ? 20.0 : 18.0;
  static double get fontSizeBody => isDesktop ? 15.0 : 14.0;

  // Layout
  static double get formMaxWidth => isDesktop ? 800.0 : double.infinity;
  static const List<String> educationLevels = [
    "ဝိဇ္ဇာ",
    "သိပ္ပံ",
    "အထက်တန်း",
    "အလယ်တန်း",
    "မူလတန်း",
    "စာရေးတတ်ဖတ်တတ်",
  ];

  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  static const List<String> assignedBranches = [
    "ဟင်္သာတ",
    "ရေကြည်",
    "မဲဇလီကုန်း",
    "ဥသျှစ်ပင်",
    "မင်းဘူး",
    "သရက်",
  ];

  static const List<String> salaryRanges = [
    "308000-4000-328000",
    "275000-4000-295000",
    "234000-2000-224000",
    "216000-2000-226000",
    "198000-2000-208000",
    "180000-2000-190000",
    "162000-2000-172000",
    "144000-2000-154000",
  ];

  static const List<String> positionSuggestions = [
  "အမ(မပ)",
  "လအန",
  "အအန(၁)သံလမ်း",
  "အအန(၂)သံလမ်း",
  "အအန(၂)လုပ်ငန်း",
  "ဌာနခွဲစာရေး",
  "ပုံဆွဲ(၂)",
  "အကြီးတန်းစာရေး",
  "အအန(၃)သံလမ်း",
  "အအန(၃/၂)သံလမ်း",
  "အအန(၃)သံလမ်း",
  "အအန(၄)သံလမ်း",
  "အငယ်တန်းစာရေး",
  "အငစ(အချိန်မှတ်)",
  "ပုံဆွဲ(၄)",
  "အငစ(လက်နှိပ်စက်)",
  "ဒု-လ/ထကကမ(လင)",
  "ဒု-လ/ထကကမ(တတ)",
  "လသမ(၅)",
  "လမက(၅)တံတား",
  "လမက(၅)လသခ",
  "လမက(၅)ဇဝလ",
  "ရုံးအကူ",
  "သန့်ရှင်းရေးအကူ",
  "လုပ်သား(စက်ထိန်း)",
  "လုပ်သား(တံတား)",
  "လုပ်သား(လုပ်ငန်း)",
  "အစောင့်",
  "ရိပ်သာစောင့်",
  "ဂိတ်စောင့်",
  ];

  // static const double defaultPadding = 16.0;
  // static const double fieldSpacing = 8.0;
}
