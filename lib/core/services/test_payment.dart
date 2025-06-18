// import 'dart:convert';
// import 'dart:developer';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gasapp/core/utils/extensions.dart';
// import 'package:gasapp/core/widgets/app_btn.dart';
// import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

// import '../../features/shared/components/appbar.dart';
// import '../../gen/locale_keys.g.dart';
// import '../routes/app_routes_fun.dart';
// import '../widgets/flash_helper.dart';

// class PaymentService extends StatefulWidget {
//   final String amount;
//   final Function(String) onSuccess;

//   const PaymentService(
//       {super.key, required this.amount, required this.onSuccess});

//   @override
//   State<PaymentService> createState() => _PaymentServiceState();
// }

// class _PaymentServiceState extends State<PaymentService> {
//   List<MFPaymentMethod> paymentMethods = [];
//   List<bool> isSelected = [];
//   int selectedPaymentMethodIndex = -1;

//   bool visibilityObs = false;

//   @override
//   void initState() {
//     initiatePayment();
//     super.initState();
//   }

//   void initiatePayment() {
//     var request = MFInitiatePaymentRequest(
//         invoiceAmount: double.parse(widget.amount), currencyIso: 'SAR');
//     MFSDK
//         .initiatePayment(
//             request,
//             LocaleKeys.lang.tr() == 'ar'
//                 ? MFLanguage.ARABIC
//                 : MFLanguage.ENGLISH)
//         .then(
//           (value) => {
//             log('-=-=-=-==--= ${jsonEncode(value.toJson())}'),
//             paymentMethods.addAll(value.paymentMethods!),
//             for (int i = 0; i < paymentMethods.length; i++)
//               setState(() => isSelected.add(false))
//           },
//         )
//         .catchError((error) {
//       FlashHelper.showToast(error.message ?? '');
//       pushBack();
//     });
//     setState(() {});
//   }

//   executeRegularPayment(int paymentMethodId) async {
//     var request = MFExecutePaymentRequest(
//         paymentMethodId: paymentMethodId,
//         invoiceValue: double.parse(widget.amount));
//     await MFSDK.executePayment(request,
//         LocaleKeys.lang.tr() == 'ar' ? MFLanguage.ARABIC : MFLanguage.ENGLISH,
//         (invoiceId) {
//       log('-=-=---=- invoiceId $invoiceId');
//     }).then((value) {
//       print("=-=-=-=-=- $value");
//       if (value.invoiceTransactions?.isNotEmpty == true) {
//         var transaction = value.invoiceTransactions!.first;
//         log('Transaction Status: ${transaction.transactionStatus}');
//         if (transaction.transactionStatus == 'Success') {
//           String transId = transaction.transactionId.toString();
//           Navigator.pop(context, transId);
//           widget.onSuccess(transId);
//         } else {
//           FlashHelper.showToast(LocaleKeys.payment_failed.tr());
//         }
//       } else {
//         FlashHelper.showToast(LocaleKeys.lang.tr() == 'en'
//             ? "Payment response is empty."
//             : "استجابة الدفع فارغة.");
//       }
//     }).catchError((error) {
//       FlashHelper.showToast(error.message);
//       log('-=-=-=-=-= ${error.message}');
//     });
//   }

//   void setPaymentMethodSelected(int index, bool value) {
//     for (int i = 0; i < isSelected.length; i++) {
//       if (i == index) {
//         isSelected[i] = value;
//         if (value) {
//           selectedPaymentMethodIndex = index;
//           visibilityObs = paymentMethods[index].isDirectPayment!;
//         } else {
//           selectedPaymentMethodIndex = -1;
//           visibilityObs = false;
//         }
//       } else {
//         isSelected[i] = false;
//       }
//     }
//   }

//   void pay() {
//     executeRegularPayment(
//         paymentMethods[selectedPaymentMethodIndex].paymentMethodId!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       appBar: CustomAppbar(title: LocaleKeys.payment.tr()),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: paymentMethods.length,
//               itemBuilder: (BuildContext ctx, int index) {
//                 return Row(spacing: 10.w, children: <Widget>[
//                   Checkbox(
//                       value: isSelected[index],
//                       onChanged: (bool? value) {
//                         setState(() {
//                           setPaymentMethodSelected(index, value!);
//                         });
//                       }),
//                   Image.network(paymentMethods[index].imageUrl!,
//                       width: 40.0, height: 40.0),
//                   Expanded(
//                       child: Text(
//                     LocaleKeys.lang.tr() == "en"
//                         ? paymentMethods[index].paymentMethodEn ?? ""
//                         : paymentMethods[index].paymentMethodAr ?? "",
//                   ))
//                 ]).withPadding(horizontal: 16, top: 16);
//               },
//             ),
//           ),
//           AppBtn(
//             title: LocaleKeys.confirm.tr(),
//             onPressed: () => pay(),
//             enable: selectedPaymentMethodIndex != -1,
//           ).withPadding(all: 16)
//         ],
//       ),
//     );
//   }
// }
