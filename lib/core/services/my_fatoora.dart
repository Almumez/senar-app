import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

import '../../features/shared/components/appbar.dart';
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
  List<MFPaymentMethod> paymentMethods = [];
  List<bool> isSelected = [];
  int selectedPaymentMethodIndex = -1;
  bool hasApplePay = false;
  bool isApplePayLoading = false;

  bool isLoading = true;
  late String currencyIso, country, mAPIKey, mfEnvironment;

  final bloc = sl<PaymentInfoBloc>();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() {
    bloc.add(StartPaymentInfoEvent());
  }

  // استدعاء API لتهيئة بيانات الدفع
  void initiatePayment() {
    try {
      var request = MFInitiatePaymentRequest(
        invoiceAmount: double.parse(widget.amount), 
        currencyIso: currencyIso
      );

      // تهيئة بيانات الدفع
      MFSDK
        .initiatePayment(request, LocaleKeys.lang.tr() == 'ar' ? MFLanguage.ARABIC : MFLanguage.ENGLISH)
        .then(
          (value) => {
            log('استجابة initiatePayment: ${jsonEncode(value.toJson())}'),
            setState(() {
              paymentMethods = [];
              isSelected = [];
              
              // فلترة طرق الدفع وترتيبها لجعل Apple Pay في المقدمة إذا كان متاحاً
              if (Platform.isIOS) {
                // تحقق من وجود Apple Pay
                for (int i = 0; i < value.paymentMethods!.length; i++) {
                  if (value.paymentMethods![i].paymentMethodCode == "ap") {
                    hasApplePay = true;
                    paymentMethods.add(value.paymentMethods![i]);
                    isSelected.add(false);
                    break;
                  }
                }
              }
              
              // أضف باقي طرق الدفع
              for (int i = 0; i < value.paymentMethods!.length; i++) {
                if (value.paymentMethods![i].paymentMethodCode != "ap") {
                  paymentMethods.add(value.paymentMethods![i]);
                  isSelected.add(false);
                }
              }
              
              isLoading = false;
            })
          },
        )
        .catchError((error) {
          print('خطأ في initiatePayment: ${error.toString()}');
          FlashHelper.showToast(error.message ?? '');
        });
    } catch (e) {
      log('خطأ في عملية الدفع: $e');
      FlashHelper.showToast(LocaleKeys.payment_failed.tr());
    }
  }
  
  /*
   * اختيار طريقة دفع
   */
  void setPaymentMethodSelected(int index, bool value) {
    for (int i = 0; i < isSelected.length; i++) {
      if (i == index) {
        isSelected[i] = value;
        if (value) {
          selectedPaymentMethodIndex = index;
        } else {
          selectedPaymentMethodIndex = -1;
        }
      } else {
        isSelected[i] = false;
      }
    }
  }

  /*
   * تنفيذ الدفع باستخدام Apple Pay
   */
  void executeApplePay() {
    setState(() {
      isApplePayLoading = true;
    });
    
    try {
      // تأكيد مبلغ الدفع لـ Apple Pay
      double invoiceValue = double.parse(widget.amount);
      
      // بناء طلب الدفع بواسطة Apple Pay
      var request = MFExecutePaymentRequest(
        invoiceValue: invoiceValue,
        // يجب تحديد معرّف Apple Pay من قائمة طرق الدفع
        paymentMethodId: paymentMethods.firstWhere(
          (method) => method.paymentMethodCode == "ap",
          orElse: () => paymentMethods.first
        ).paymentMethodId!
      );

      // تنفيذ عملية الدفع
      MFSDK.executePayment(
        request,
        LocaleKeys.lang.tr() == 'ar' ? MFLanguage.ARABIC : MFLanguage.ENGLISH,
        (String invoiceId) {
          log('Apple Pay - معرف الفاتورة: $invoiceId');
        }
      ).then((value) {
        setState(() {
          isApplePayLoading = false;
        });
        
        log("استجابة Apple Pay: ${value.toJson()}");
        
        if (value.invoiceTransactions?.isNotEmpty == true) {
          var transaction = value.invoiceTransactions!.first;
          log('حالة معاملة Apple Pay: ${transaction.transactionStatus}');
          
          if (transaction.transactionStatus == 'Success' || 
              transaction.transactionStatus == 'Succss') {
            String transId = transaction.transactionId.toString();
            log('معرف معاملة Apple Pay الناجحة: $transId');
            
            // استدعاء دالة النجاح وإغلاق الشاشة
            widget.onSuccess(transId);
            Navigator.pop(context);
          } else {
            FlashHelper.showToast(LocaleKeys.payment_failed.tr());
          }
        } else {
          FlashHelper.showToast(
            LocaleKeys.lang.tr() == 'en' ? 
            "Apple Pay payment response is empty." : 
            "استجابة Apple Pay فارغة."
          );
        }
      }).catchError((error) {
        setState(() {
          isApplePayLoading = false;
        });
        FlashHelper.showToast(error.message ?? LocaleKeys.payment_failed.tr());
        log('خطأ في Apple Pay: ${error.message}');
      });
    } catch (e) {
      setState(() {
        isApplePayLoading = false;
      });
      log('خطأ في Apple Pay: $e');
      FlashHelper.showToast(LocaleKeys.payment_failed.tr());
    }
  }

  /*
   * تنفيذ عملية الدفع العادية
   */
  void executePayment() {
    if (selectedPaymentMethodIndex == -1) {
      FlashHelper.showToast(LocaleKeys.lang.tr() == "en" 
          ? "Please select payment method first" 
          : "الرجاء تحديد طريقة الدفع أولاً");
      return;
    }

    var request = MFExecutePaymentRequest(
      paymentMethodId: paymentMethods[selectedPaymentMethodIndex].paymentMethodId!, 
      invoiceValue: double.parse(widget.amount)
    );

    MFSDK.executePayment(
      request, 
      LocaleKeys.lang.tr() == 'ar' ? MFLanguage.ARABIC : MFLanguage.ENGLISH,
      (invoiceId) {
        log('معرف الفاتورة: $invoiceId');
      }
    ).then((value) {
      log("استجابة executePayment: ${value.toJson()}");
      
      if (value.invoiceTransactions?.isNotEmpty == true) {
        var transaction = value.invoiceTransactions!.first;
        log('حالة المعاملة: ${transaction.transactionStatus}');
        
        if (transaction.transactionStatus == 'Success' || 
            transaction.transactionStatus == 'Succss') {
          String transId = transaction.transactionId.toString();
          log('معرف المعاملة الناجحة: $transId');
          
          // استدعاء دالة النجاح وإغلاق الشاشة
          widget.onSuccess(transId);
          Navigator.pop(context);
        } else {
          FlashHelper.showToast(LocaleKeys.payment_failed.tr());
        }
      } else {
        FlashHelper.showToast(
          LocaleKeys.lang.tr() == 'en' ? 
          "Payment response is empty." : 
          "استجابة الدفع فارغة."
        );
      }
    }).catchError((error) {
      FlashHelper.showToast(error.message ?? LocaleKeys.payment_failed.tr());
      log('خطأ في executePayment: ${error.message}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: CustomAppbar(title: LocaleKeys.payment.tr(), withBack: true),
      bottomNavigationBar: (!isLoading && paymentMethods.isNotEmpty)
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: ElevatedButton(
                onPressed: selectedPaymentMethodIndex != -1 ? executePayment : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(LocaleKeys.confirm.tr()),
              ),
            )
          : const SizedBox.shrink(),
      body: BlocConsumer<PaymentInfoBloc, PaymentInfoState>(
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
            initiatePayment();
          }
        },
        builder: (context, state) {
          if (state.state.isLoading || (isLoading && paymentMethods.isEmpty)) {
            return const CustomProgress(size: 30).center;
          } else if (state.state.isError) {
            return CustomErrorWidget(
              title: state.msg, 
              subtitle: state.msg, 
              errType: state.errorType
            );
          } else if (paymentMethods.isEmpty) {
            return Center(
              child: Text(
                LocaleKeys.lang.tr() == 'en'
                    ? "No payment methods available"
                    : "لا توجد وسائل دفع متاحة",
                style: const TextStyle(fontSize: 18),
              ),
            );
          } else {
            // عرض طرق الدفع المتاحة
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // قسم المبلغ الإجمالي
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          LocaleKeys.lang.tr() == 'en'
                              ? "Total Amount"
                              : "المبلغ الإجمالي",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "${widget.amount} ${currencyIso}",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // عنوان قسم طرق الدفع
                  Text(
                    LocaleKeys.lang.tr() == 'en'
                        ? "Select Payment Method"
                        : "اختر طريقة الدفع",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // قسم Apple Pay إذا كان متاحاً
                  if (hasApplePay && Platform.isIOS) ...[
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isApplePayLoading ? null : executeApplePay,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            child: isApplePayLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // أيقونة Apple Pay
                                      Icon(
                                        Icons.apple,
                                        color: Colors.white,
                                        size: 24.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "Apple Pay",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    
                    // فاصل
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            LocaleKeys.lang.tr() == 'en'
                                ? "OR PAY WITH"
                                : "أو الدفع باستخدام",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                  ],
                  
                  // قائمة طرق الدفع الأخرى
                  // يتم تجاهل Apple Pay هنا لأننا عرضناه في الأعلى
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paymentMethods.where((method) => method.paymentMethodCode != "ap").length,
                    itemBuilder: (context, index) {
                      // احتساب الفهرس الحقيقي في القائمة الأصلية (مع تجاهل Apple Pay)
                      int actualIndex = paymentMethods.indexWhere(
                        (method) => method.paymentMethodCode != "ap", 
                        hasApplePay && Platform.isIOS ? 1 : 0
                      );
                      
                      if (actualIndex == -1 || actualIndex + index >= paymentMethods.length) {
                        return const SizedBox();
                      }
                      
                      int realIndex = actualIndex + index;
                      
                      if (paymentMethods[realIndex].paymentMethodCode == "ap") {
                        return const SizedBox(); // تجاهل Apple Pay
                      }
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected[realIndex] 
                                ? Theme.of(context).primaryColor 
                                : Colors.grey.shade300,
                            width: isSelected[realIndex] ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              setPaymentMethodSelected(realIndex, !isSelected[realIndex]);
                            });
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: Image.network(
                              paymentMethods[realIndex].imageUrl ?? '',
                              width: 50.w,
                              height: 30.h,
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, obj, st) => Icon(
                                Icons.payment,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          title: Text(
                            LocaleKeys.lang.tr() == "en"
                                ? paymentMethods[realIndex].paymentMethodEn ?? ""
                                : paymentMethods[realIndex].paymentMethodAr ?? "",
                          ),
                          trailing: Radio<bool>(
                            value: true,
                            activeColor: Theme.of(context).primaryColor,
                            groupValue: isSelected[realIndex] ? true : null,
                            onChanged: (value) {
                              setState(() {
                                setPaymentMethodSelected(realIndex, value ?? false);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
