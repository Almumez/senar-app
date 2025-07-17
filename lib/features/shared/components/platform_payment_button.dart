import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

class PlatformPaymentButton extends StatefulWidget {
  final MFInitiateSessionResponse session;
  final String amount;
  final String currencyIso;
  final Function(String) onPaymentSuccess;

  const PlatformPaymentButton({
    Key? key,
    required this.session,
    required this.amount,
    required this.currencyIso,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<PlatformPaymentButton> createState() => _PlatformPaymentButtonState();
}

class _PlatformPaymentButtonState extends State<PlatformPaymentButton> {
  late MFApplePayButton? mfApplePayButton;
  bool isLoading = false;
  int? googlePayMethodId=1661616161616;

  @override
  void initState() {
    super.initState();
    
    // تهيئة الأزرار حسب المنصة
    if (Platform.isIOS) {
      // تخصيص مظهر زر Apple Pay
      MFApplePayStyle applePayStyle = MFApplePayStyle();
     
      
      mfApplePayButton = MFApplePayButton(applePayStyle: applePayStyle);
      _setupApplePay();
    } else if (Platform.isAndroid) {
      // للأندرويد، نحتاج إلى الحصول على معرف طريقة الدفع لـ Google Pay
      _getPaymentMethods();
    }
  }

  // الحصول على طرق الدفع المتاحة لمعرفة معرف Google Pay
  void _getPaymentMethods() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      MFInitiatePaymentRequest request = MFInitiatePaymentRequest(
        invoiceAmount: double.parse(widget.amount),
        currencyIso: widget.currencyIso
      );
      
      await MFSDK.initiatePayment(request, MFLanguage.ENGLISH)
          .then((MFInitiatePaymentResponse response) {
            // البحث عن طريقة الدفع Google Pay
            for (var paymentMethod in response.paymentMethods ?? []) {
              if (paymentMethod.paymentMethodEn?.toLowerCase() == 'google pay') {
                googlePayMethodId = paymentMethod.paymentMethodId;
                log('تم العثور على معرف Google Pay: $googlePayMethodId');
                break;
              }
            }
            
            setState(() {
              isLoading = false;
            });
          })
          .catchError((error) {
            log('خطأ في الحصول على طرق الدفع: ${error.message}');
            setState(() {
              isLoading = false;
            });
          });
    } catch (e) {
      log('خطأ في الحصول على طرق الدفع: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setupApplePay() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      double invoiceValue = double.parse(widget.amount);
      MFExecutePaymentRequest executePaymentRequest = MFExecutePaymentRequest(invoiceValue: invoiceValue);
      executePaymentRequest.displayCurrencyIso = widget.currencyIso;

      await mfApplePayButton!
          .displayApplePayButton(widget.session, executePaymentRequest, MFLanguage.ENGLISH)
          .then((value) {
            log("Apple Pay button displayed successfully");
          })
          .catchError((error) {
            log('Error displaying Apple Pay button: ${error.message}');
          });
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log('Error setting up Apple Pay: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _executeApplePay() async {
    if (mfApplePayButton == null) return;
    
    try {
      setState(() {
        isLoading = true;
      });
      
      double invoiceValue = double.parse(widget.amount);
      MFExecutePaymentRequest executePaymentRequest = MFExecutePaymentRequest(invoiceValue: invoiceValue);
      executePaymentRequest.displayCurrencyIso = widget.currencyIso;
      executePaymentRequest.sessionId = widget.session.sessionId;

      await mfApplePayButton!
          .executeApplePayButton(
            executePaymentRequest,
            (invoiceId) {
              log('Apple Pay - معرف الفاتورة: $invoiceId');
            },
          )
          .then((value) {
            setState(() {
              isLoading = false;
            });
            
            log("استجابة Apple Pay: ${value.toJson()}");
            if (value.invoiceTransactions?.isNotEmpty == true) {
              var transaction = value.invoiceTransactions!.first;
              log('حالة معاملة Apple Pay: ${transaction.transactionStatus}');
              
              if (transaction.transactionStatus == 'Success' || transaction.transactionStatus == 'Succss') {
                String transId = transaction.paymentId.toString();
                log('معرف معاملة Apple Pay الناجحة: $transId');
                widget.onPaymentSuccess(transId);
              }
            }
          })
          .catchError((error) {
            setState(() {
              isLoading = false;
            });
            log('خطأ في Apple Pay: ${error.message}');
          });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log('خطأ في Apple Pay: $e');
    }
  }

  void _executeGooglePay() async {
    if (googlePayMethodId == null) {
      log('معرف طريقة دفع Google Pay غير متاح');
      return;
    }
    
    try {
      setState(() {
        isLoading = true;
      });
      
      // تنفيذ الدفع باستخدام Google Pay
      double invoiceValue = double.parse(widget.amount);
      
      // إنشاء طلب تنفيذ الدفع
      MFExecutePaymentRequest executePaymentRequest = MFExecutePaymentRequest(
        invoiceValue: invoiceValue,
        paymentMethodId: googlePayMethodId!,
      );
      
      // تنفيذ الدفع
      MFSDK.executePayment(
        executePaymentRequest, 
        MFLanguage.ENGLISH, 
        (String invoiceId) {
          log('Google Pay - معرف الفاتورة: $invoiceId');
        }
      ).then((value) {
        setState(() {
          isLoading = false;
        });
        
        log("استجابة Google Pay: ${value.toJson()}");
        if (value.invoiceTransactions?.isNotEmpty == true) {
          var transaction = value.invoiceTransactions!.first;
          log('حالة معاملة Google Pay: ${transaction.transactionStatus}');
          
          if (transaction.transactionStatus == 'Success' || transaction.transactionStatus == 'Succss') {
            String transId = transaction.paymentId.toString();
            log('معرف معاملة Google Pay الناجحة: $transId');
            widget.onPaymentSuccess(transId);
          }
        }
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        log('خطأ في Google Pay: ${error.message}');
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log('خطأ في Google Pay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (Platform.isIOS && mfApplePayButton != null) {
      // استخدام زر Apple Pay المخصص
      return Container(
        width: double.infinity,
        height: 45.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r), // زيادة نصف قطر الحواف
        ),
        child: GestureDetector(
          onTap: _executeApplePay,
          child: mfApplePayButton,
        ),
      );
    } else if (Platform.isAndroid) {
      // زر Google Pay مخصص مشابه لزر Apple Pay
      return GestureDetector(
        onTap: _executeGooglePay,
        child: Container(
          height: 45.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12.r), // زيادة نصف قطر الحواف
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // شعار Google Pay - تم عكس الترتيب
                Text(
                  'Pay',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // في حالة عدم دعم الجهاز لأي من طرق الدفع
      return const SizedBox.shrink();
    }
  }
} 