import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/agent_order.dart';

class InvoicePrinter {
  static Future<void> printInvoice(BuildContext context, AgentOrderModel order) async {
    // قم بإنشاء وثيقة PDF
    final pdf = await _generateInvoicePdf(context, order);
    
    // عرض معاينة الطباعة
    await Printing.layoutPdf(
      onLayout: (format) => pdf,
      name: 'فاتورة_طلب_${order.id}',
    );
  }

  static Future<Uint8List> _generateInvoicePdf(BuildContext context, AgentOrderModel order) async {
    // تحميل الخط العربي
    final arabicFont = await rootBundle.load("assets/fonts/alfont_com_AlFont_com_SST-Arabic-Roman.ttf");
    final ttf = pw.Font.ttf(arabicFont);
    
    // تحميل شعار التطبيق
    final logoImageData = await rootBundle.load('assets/images/splash.png');
    final logoImage = pw.MemoryImage(logoImageData.buffer.asUint8List());
    
    // إنشاء مستند PDF
    final pdf = pw.Document();
    
    // إضافة صفحة للفاتورة
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(textDirection: pw.TextDirection.rtl, child:
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // عنوان الفاتورة والشعار
                _buildHeader(logoImage, order, ttf),

                pw.SizedBox(height: 20),

                // معلومات العميل والعنوان
                _buildSimpleInfo(order, ttf),

                pw.SizedBox(height: 20),

                // ملخص المبالغ والسعر الإجمالي
                _buildPriceSummary(order, ttf),

                pw.SizedBox(height: 20),

                // التذييل
                _buildFooter(ttf),
              ],
            ),
          )

          );
        },
      ),
    );
    
    return pdf.save();
  }
  
  static pw.Widget _buildHeader(pw.ImageProvider logo, AgentOrderModel order, pw.Font ttf) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // رقم الهاتف (على اليسار)
              pw.Container(
                width: 120,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'تلفون:',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '+966501590007',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // الشعار (في المنتصف)
              pw.Container(
                height: 70,
                width: 100,
                child: pw.Image(logo),
              ),
              
              // العنوان (على اليمين)
              pw.Container(
                width: 120,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'العنوان:',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'السعودية - القصيم - بريدة',
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: ttf, fontSize: 12),
                      textAlign: pw.TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'تاريخ: ${order.createdAt}',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(font: ttf, fontSize: 12),
              ),
              pw.Text(
                'فاتورة طلب #${order.id}',
                style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildSimpleInfo(AgentOrderModel order, pw.Font ttf) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // معلومات العميل
          pw.Text(
            'معلومات العميل:',
            style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'الاسم:',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                order.clientName,
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'العنوان:',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                order.address.placeDescription,
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'رقم الطلب:',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                '#${order.id}',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'طريقة الدفع:',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                order.paymentMethod.toLowerCase() == 'cash' ? "كاش" : "الكتروني",
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildPriceSummary(AgentOrderModel order, pw.Font ttf) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'تفاصيل الفاتورة:',
            style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'سعر الخدمة:',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                '${order.price} ${LocaleKeys.sar.tr()}',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          if (!order.type.contains('maintenance') && !order.type.contains('supply'))
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'التوصيل:',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.Text(
                  '${(order.deliveryFee - order.tax)} ${LocaleKeys.sar.tr()}',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'الضريبة:',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                '${order.tax} ${LocaleKeys.sar.tr()}',
                style: pw.TextStyle(font: ttf, fontSize: 12),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'الإجمالي:',
                style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                '${order.totalPrice} ${LocaleKeys.sar.tr()}',
                style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          if (order.isPaid)
            pw.Container(
              margin: pw.EdgeInsets.only(top: 10),
              padding: pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                color: PdfColors.green100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'تم الدفع',
                style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.green900),
                textDirection: pw.TextDirection.rtl,
                textAlign: pw.TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildFooter(pw.Font ttf) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text(
          'شكراً لاستخدامك تطبيق سنار',
          style: pw.TextStyle(font: ttf, fontSize: 12),
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'تم إنشاء هذه الفاتورة إلكترونياً ولا تحتاج إلى توقيع',
          style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700),
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}

// خدمة لتوفير BuildContext العام
class GlobalContextService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
} 