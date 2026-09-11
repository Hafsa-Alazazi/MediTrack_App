# MediTrack — تطبيق تتبع الأدوية

تطبيق Flutter لتتبع الأدوية اليومية، التذكير بمواعيد الجرعات، وتتبع إحصائيات الالتزام بها. المشروع يعتمد بالكامل على قاعدة بيانات محلية (SQLite)، بدون تسجيل دخول.

## 📱 الواجهات الأربع
1. **الرئيسية (قائمة الأدوية)** — `lib/screens/home_screen.dart`
2. **إضافة / تعديل دواء** — `lib/screens/add_medication_screen.dart`
3. **تفاصيل الدواء (سجل الجرعات + تسجيل جرعة جديدة)** — `lib/screens/medication_details_screen.dart`
4. **إحصائيات الالتزام** — `lib/screens/statistics_screen.dart`

## 🗄️ قاعدة البيانات المحلية (SQLite)
جدولان أساسيان بعمليات CRUD كاملة على كل منهما:

| الجدول | Create | Read | Update | Delete |
|---|---|---|---|---|
| `medications` | إضافة دواء | عرض القائمة | تعديل دواء | حذف دواء |
| `dose_logs` | تسجيل جرعة (أخذتها/فاتتني) | عرض سجل الجرعات | تبديل حالة السجل | حذف سجل |

## 🧩 إدارة الحالة
تم استخدام **Provider**، بمزودين رئيسيين:
- `MedicationProvider` — قائمة الأدوية (متصل بـ SQLite)
- `DoseLogProvider` — سجلات الجرعات وحساب الإحصائيات (متصل بـ SQLite)

## ⚙️ خطوات التشغيل
```bash
flutter clean
flutter pub get
flutter run
```

### إعداد الإشعارات (مهم)
**Android** — في `android/app/src/main/AndroidManifest.xml` قبل وسم `<application>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

في `android/app/build.gradle.kts`:
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

## 📂 هيكل المشروع
```
lib/
├── main.dart
├── models/
│   ├── medication.dart
│   └── dose_log.dart
├── providers/
│   ├── medication_provider.dart
│   └── dose_log_provider.dart
├── services/
│   ├── database_helper.dart
│   └── notification_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── add_medication_screen.dart
│   ├── medication_details_screen.dart
│   └── statistics_screen.dart
└── widgets/
    └── medication_card.dart
```
