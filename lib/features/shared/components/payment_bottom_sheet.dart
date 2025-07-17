import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/widgets/flash_helper.dart';
import '../../../core/widgets/loading.dart';
import '../../../gen/locale_keys.g.dart';
import '../controller/payment/bloc.dart';
import '../controller/payment/events.dart';
import '../controller/payment/states.dart';
import 'platform_payment_button.dart';
import '../../../core/services/service_locator.dart';

// دالة مساعدة لعرض bottom sheet الدفع
Future<void> showPaymentBottomSheet({
  required BuildContext context,
  required String amount,
  required Function(String) onSuccess,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PaymentBottomSheet(
      amount: amount,
      onSuccess: onSuccess,
    ),
  );
}

class PaymentBottomSheet extends StatefulWidget {
  final String amount;
  final Function(String) onSuccess;

  const PaymentBottomSheet({
    Key? key,
    required this.amount,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  late MFCardPaymentView mfCardView;
  MFInitiateSessionResponse? session;
  bool isLoading = true;
  bool hasApplePay = false;
  bool hasGooglePay = false;
  late String currencyIso, country, mAPIKey, mfEnvironment;

  final bloc = sl<PaymentInfoBloc>();

  @override
  void initState() {
    super.initState();

    // تحسين تصميم واجهة الدفع باستخدام خصائص التخصيص
    MFCardViewStyle cardStyle = MFCardViewStyle();
    
    // تخصيص ارتفاع البطاقة
    cardStyle.cardHeight = 180;
    
    // تخصيص نمط الإدخال
    cardStyle.input = MFCardViewInput();
    // cardStyle.input?.textColor = "#333333";
    cardStyle.input?.fontSize = 14;
    cardStyle.input?.borderRadius = 8;
    // cardStyle.input?.borderColor = "#DDDDDD";
    cardStyle.input?.borderWidth = 1;
    cardStyle.input?.inputMargin = 4;
    cardStyle.input?.fontFamily = MFFontFamily.Monaco;
    
    // تخصيص نمط التسميات
    cardStyle.label =   cardStyle.label;
    // cardStyle.label?.textColor = "#666666";
    cardStyle.label?.fontSize = 12;
    cardStyle.label?.fontWeight = MFFontWeight.Medium;
    cardStyle.label?.display = true;
    
    // إظهار أيقونات البطاقات
    cardStyle.hideCardIcons = false;
    
    mfCardView = MFCardPaymentView(
      cardViewStyle: cardStyle,
    );
    
    getData();
  }

  getData() {
    bloc.add(StartPaymentInfoEvent());
  }

  void initSession() {
    log('Initiating session...');
    MFInitiateSessionRequest initiateSessionRequest = MFInitiateSessionRequest();

    MFSDK.initSession(initiateSessionRequest, MFLanguage.ENGLISH)
        .then((value) {
      log('Session initiated: ${value.toJson()}');
      setState(() {
        session = value;
        isLoading = false;
        // Check for platform-specific payment methods
        if (Platform.isIOS) {
          hasApplePay = true;
        } else if (Platform.isAndroid) {
          hasGooglePay = true;
        }
      });
      loadEmbeddedPayment(value);
    }).catchError((error) {
      log('Error initiating session: ${error.message}');
      FlashHelper.showToast(error.message ?? '');
      setState(() {
        isLoading = false;
      });
    });
  }

  loadEmbeddedPayment(MFInitiateSessionResponse session) {
    try {
      log('Loading embedded payment view...');
      // إضافة تأخير قصير قبل تحميل واجهة الدفع
      Future.delayed(const Duration(milliseconds: 500), () {
        mfCardView.load(
          session,
          (bin) {
            log("BIN: $bin");
          },
        );
      });
    } catch (e) {
      log('Error loading embedded payment: $e');
      FlashHelper.showToast('خطأ في تحميل واجهة الدفع');
    }
  }

  void executeDirectPayment() {
    if (session == null) {
      FlashHelper.showToast('Session not initialized');
      return;
    }

    var request = MFExecutePaymentRequest(invoiceValue: double.parse(widget.amount));
    request.sessionId = session?.sessionId;

    mfCardView.pay(request, MFLanguage.ENGLISH, (invoiceId) {
      log('معرف الفاتورة: $invoiceId');
    }).then((value) {
      log("استجابة executeDirectPayment: ${value.toJson()}");
      if (value.invoiceTransactions?.isNotEmpty == true) {
        var transaction = value.invoiceTransactions!.first;
        log('حالة المعاملة: ${transaction.transactionStatus}');

        if (transaction.transactionStatus == 'Success' || transaction.transactionStatus == 'Succss') {
          String transId = transaction.paymentId.toString();
          log('معرف المعاملة الناجحة: $transId');

          // استدعاء دالة النجاح وإغلاق الشاشة
          widget.onSuccess(transId);
          Navigator.pop(context);
        } else {
          FlashHelper.showToast(LocaleKeys.payment_failed.tr());
        }
      } else {
        FlashHelper.showToast(LocaleKeys.lang.tr() == 'en' ? "Payment response is empty." : "استجابة الدفع فارغة.");
      }
    }).catchError((error) {
      FlashHelper.showToast(error.message ?? LocaleKeys.payment_failed.tr());
      log('خطأ في executeDirectPayment: ${error.message}');
    });
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على حجم الشاشة
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - keyboardHeight;
    
    // تحديد ارتفاع مناسب للمحتوى
    final contentMaxHeight = availableHeight * 0.85; // 85% من الارتفاع المتاح
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      constraints: BoxConstraints(
        maxHeight: contentMaxHeight,
      ),
      padding: EdgeInsets.only(
        top: 16.h,
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الـ bottom sheet
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.payment.tr(),
                  style: context.boldText.copyWith(fontSize: 18.sp),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(height: 16.h),
            
            // محتوى الدفع
            BlocListener<PaymentInfoBloc, PaymentInfoState>(
              bloc: bloc,
              listener: (context, state) {
                if (state.state.isDone && state.data != null) {
                  mAPIKey = state.data!.mAPIKey;
                  currencyIso = state.data!.currencyIso;
                  country = state.data!.country;
                  mfEnvironment = state.data!.mfEnv;

                  log('تهيئة بوابة الدفع: مفتاح=$mAPIKey، بلد=$country، بيئة=$mfEnvironment');

                  // تهيئة SDK
                  MFSDK.init(mAPIKey, country, mfEnvironment);

                  // بدء عملية الدفع
                  initSession();
                }
              },
              child: BlocBuilder<PaymentInfoBloc, PaymentInfoState>(
                bloc: bloc,
                builder: (context, state) {
                  if (state.state.isLoading || (isLoading && session == null)) {
                    return Container(
                      height: 200.h,
                      alignment: Alignment.center,
                      child: const CustomProgress(size: 30),
                    );
                  } else if (state.state.isError) {
                    return Container(
                      height: 200.h,
                      alignment: Alignment.center,
                      child: Text(
                        state.msg,
                        style: context.regularText.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (session == null) {
                    return Container(
                      height: 200.h,
                      alignment: Alignment.center,
                      child: Text(
                        LocaleKeys.lang.tr() == 'en' ? "Could not load payment session" : "تعذر تحميل جلسة الدفع",
                        style: context.regularText,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان المبلغ - تم تصغيره
                      Row(
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            color: context.primaryColor,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            LocaleKeys.lang.tr() == 'en' ? "Payment Amount:" : "مبلغ الدفع:",
                            style: context.regularText.copyWith(
                              fontSize: 13.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "${widget.amount} ${currencyIso}",
                            style: context.boldText.copyWith(
                              fontSize: 15.sp,
                              color: context.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // إضافة زر Apple Pay أو Google Pay
                      if ((Platform.isIOS && hasApplePay) || (Platform.isAndroid && hasGooglePay)) 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 24.h),
                              width: double.infinity,
                              child: PlatformPaymentButton(
                                session: session!,
                                amount: widget.amount,
                                currencyIso: currencyIso,
                                onPaymentSuccess: (String transId) {
                                  widget.onSuccess(transId);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            // إضافة فاصل بين طرق الدفع
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Text(
                                    LocaleKeys.lang.tr() == 'en' ? "OR" : "أو",
                                    style: context.regularText.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                              ],
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      
                      
                      // واجهة إدخال بيانات البطاقة - تم تحسين المظهر
                      Container(
                        // استخدام ارتفاع متجاوب بدلاً من ثابت
                        height: MediaQuery.of(context).size.height < 700 ? 150.h : 180.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: mfCardView,
                        ),
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // زر الدفع
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: executeDirectPayment,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            backgroundColor: context.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            LocaleKeys.lang.tr() == 'en' ? "Pay with Card" : "الدفع بالبطاقة",
                            style: context.mediumText.copyWith(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 