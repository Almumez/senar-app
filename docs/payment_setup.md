# إعداد Apple Pay و Google Pay في تطبيق Senar

هذا الدليل يشرح كيفية إعداد وتكوين Apple Pay و Google Pay في تطبيق Senar باستخدام بوابة الدفع MyFatoorah.

## متطلبات عامة

1. حساب نشط في MyFatoorah مع مفاتيح API
2. تطبيق Flutter مهيأ للعمل مع MyFatoorah (مكتبة myfatoorah_flutter)

## إعداد Apple Pay (iOS)

### 1. إعداد حساب المطور Apple

1. قم بتسجيل الدخول إلى [حساب مطور Apple](https://developer.apple.com/)
2. انتقل إلى قسم "Certificates, Identifiers & Profiles"
3. قم بإنشاء معرف تاجر (Merchant ID) جديد:
   - انقر على "Identifiers" ثم "+"
   - اختر "Merchant IDs"
   - أدخل وصفًا واسمًا للمعرف (مثال: `merchant.com.senar.app`)
   - قم بتسجيل المعرف

### 2. إعداد المشروع في Xcode

1. افتح مشروع iOS في Xcode
2. انتقل إلى إعدادات المشروع وحدد "Signing & Capabilities"
3. أضف قدرة "Apple Pay":
   - انقر على "+" لإضافة قدرة جديدة
   - ابحث عن "Apple Pay" وأضفها
   - أضف معرف التاجر الذي أنشأته سابقًا

### 3. تكوين ملفات المشروع

1. تأكد من وجود الإعدادات التالية في ملف `Info.plist`:
   ```xml
   <key>com.apple.developer.in-app-payments</key>
   <array>
       <string>merchant.com.senar.app</string>
   </array>
   ```

2. تأكد من وجود ملف `Entitlements.plist` بالمحتوى التالي:
   ```xml
   <dict>
       <key>com.apple.developer.in-app-payments</key>
       <array>
           <string>merchant.com.senar.app</string>
       </array>
   </dict>
   ```

### 4. تكوين Apple Pay في MyFatoorah

1. قم بتسجيل الدخول إلى لوحة تحكم MyFatoorah
2. انتقل إلى إعدادات Apple Pay
3. أدخل معرف التاجر الخاص بك
4. قم بتحميل شهادة Apple Pay المطلوبة

## إعداد Google Pay (Android)

### 1. تكوين ملف AndroidManifest.xml

1. أضف البيانات الوصفية التالية داخل علامة `<application>`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.wallet.api.enabled"
       android:value="true" />
   ```

2. أضف الاستعلام التالي داخل علامة `<queries>`:
   ```xml
   <intent>
       <action android:name="android.intent.action.VIEW" />
       <data android:scheme="https" android:host="pay.google.com" />
   </intent>
   ```

### 2. تكوين Google Pay في MyFatoorah

1. قم بتسجيل الدخول إلى لوحة تحكم MyFatoorah
2. انتقل إلى إعدادات Google Pay
3. قم بتفعيل خدمة Google Pay

## استخدام Apple Pay و Google Pay في التطبيق

تم إنشاء مكون `PlatformPaymentButton` الذي يعرض تلقائيًا زر الدفع المناسب بناءً على منصة المستخدم:

```dart
PlatformPaymentButton(
  session: session,
  amount: amount,
  currencyIso: currencyIso,
  onPaymentSuccess: (String transId) {
    // معالجة نجاح الدفع
  },
)
```

## ملاحظات هامة

1. **اختبار Apple Pay**: يمكنك اختبار Apple Pay في جهاز حقيقي فقط، ولا يمكن اختباره في المحاكي.

2. **اختبار Google Pay**: يمكنك اختبار Google Pay في جهاز حقيقي أو في محاكي مع خدمات Google Play.

3. **بيئة الاختبار**: تأكد من استخدام بيئة الاختبار (Sandbox) في MyFatoorah أثناء التطوير.

4. **معرف التاجر**: يجب أن يكون معرف التاجر متطابقًا في كل من حساب مطور Apple ولوحة تحكم MyFatoorah.

5. **التوافق**: تأكد من أن الأجهزة المستهدفة تدعم Apple Pay أو Google Pay قبل عرض الأزرار.

## استكشاف الأخطاء وإصلاحها

إذا واجهت مشاكل في تكامل Apple Pay أو Google Pay، تحقق من:

1. صحة مفاتيح API لـ MyFatoorah
2. تكوين معرف التاجر بشكل صحيح
3. تكوين ملفات المشروع (Info.plist و AndroidManifest.xml)
4. سجلات التطبيق للتحقق من رسائل الخطأ التفصيلية 