import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

import '../../features/shared/components/appbar.dart';
import '../../features/shared/components/platform_payment_button.dart';
import '../../features/shared/controller/payment/bloc.dart';
import '../../features/shared/controller/payment/events.dart';
import '../../features/shared/controller/payment/states.dart';
import '../../gen/locale_keys.g.dart';
import '../utils/extensions.dart';
import '../widgets/error_widget.dart';
import '../widgets/flash_helper.dart';
import '../widgets/loading.dart';
import 'service_locator.dart';

class PaymentService extends StatefulWidget {
  final String amount;
  final Function(String) onSuccess;
  const PaymentService({super.key, required this.amount, required this.onSuccess});

  @override
  State<PaymentService> createState() => _PaymentServiceState();
}

class _PaymentServiceState extends State<PaymentService> {
  late MFCardPaymentView mfCardView;
  MFApplePayButton? mfApplePayButton;
  MFGooglePayButton? mfGooglePayButton;
  MFInitiateSessionResponse? session;

  bool hasApplePay = false;
  bool hasGooglePay = false;
  bool isApplePayLoading = false;
  bool isGooglePayLoading = false;

  bool isLoading = true;
  late String currencyIso, country, mAPIKey, mfEnvironment;

  final bloc = sl<PaymentInfoBloc>();

  @override
  void initState() {
    super.initState();

    // تهيئة واجهة الدفع بالبطاقة
    mfCardView = MFCardPaymentView(
      cardViewStyle: MFCardViewStyle(),
    );
    
    if (Platform.isIOS) {
      mfApplePayButton = MFApplePayButton(applePayStyle: MFApplePayStyle());
    } else if (Platform.isAndroid) {
      mfGooglePayButton = MFGooglePayButton();
    }
    
    getData();
  }

  getData() {
    bloc.add(StartPaymentInfoEvent());
  }

  void initSession() {
    log('Initiating session...');
    // You can send the customer identifier to be able to use the saved card option.
    MFInitiateSessionRequest initiateSessionRequest = MFInitiateSessionRequest();

    MFSDK.initSession(initiateSessionRequest, MFLanguage.ENGLISH)
        .then((value) {
      log('Session initiated: ${value.toJson()}');
      setState(() {
        session = value;
        isLoading = false;
        // Check for Apple Pay availability from session
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

  /*
   * تنفيذ عملية الدفع المباشر (البطاقة المدمجة)
   */
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
    return Scaffold(
      extendBody: true,
      appBar: CustomAppbar(title: LocaleKeys.payment.tr(), withBack: true),
      body: BlocListener<PaymentInfoBloc, PaymentInfoState>(
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
              return const CustomProgress(size: 30).center;
            } else if (state.state.isError) {
              return CustomErrorWidget(title: state.msg, subtitle: state.msg, errType: state.errorType);
            } else if (session == null) {
              return Center(
                child: Text(
                  LocaleKeys.lang.tr() == 'en' ? "Could not load payment session" : "تعذر تحميل جلسة الدفع",
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان المبلغ
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 24.h),
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          LocaleKeys.lang.tr() == 'en' ? "Payment Amount" : "مبلغ الدفع",
                          style: context.regularText.copyWith(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "${widget.amount} ${currencyIso}",
                          style: context.boldText.copyWith(
                            fontSize: 22.sp,
                            color: context.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // عنوان طريقة الدفع
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      LocaleKeys.lang.tr() == 'en' ? "Payment Methods" : "طرق الدفع",
                      style: context.mediumText.copyWith(
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  
                  // إضافة زر Apple Pay أو Google Pay
                  if ((Platform.isIOS && hasApplePay) || (Platform.isAndroid && hasGooglePay)) 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            Platform.isIOS ? "Apple Pay" : "Google Pay",
                            style: context.mediumText.copyWith(
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20.h),
                          width: double.infinity,
                          height: 50.h,
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
                        Divider(height: 32.h),
                      ],
                    ),
                  
                  // عنوان الدفع بالبطاقة
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      LocaleKeys.lang.tr() == 'en' ? "Pay with Card" : "الدفع بالبطاقة",
                      style: context.mediumText.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  
                  // واجهة إدخال بيانات البطاقة
                  Container(
                    height: 300.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: mfCardView,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: (!isLoading && session != null)
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: executeDirectPayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
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
            )
          : const SizedBox.shrink(),
    );
  }
}
