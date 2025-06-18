import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/payment_methods.dart';
import '../controller/cubit.dart';

class ClientCreateOrderSelectPaymentView extends StatefulWidget {
  final CartCubit cubit;
  const ClientCreateOrderSelectPaymentView({super.key, required this.cubit});

  @override
  State<ClientCreateOrderSelectPaymentView> createState() => _ClientCreateOrderSelectPaymentViewState();
}

class _ClientCreateOrderSelectPaymentViewState extends State<ClientCreateOrderSelectPaymentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.payment.tr()),
      bottomNavigationBar: SafeArea(
        child: AppBtn(
          title: LocaleKeys.confirm.tr(),
          onPressed: () {
            Navigator.pop(context);
          },
          enable: widget.cubit.paymentMethod != '',
        ).withPadding(horizontal: 16.w, bottom: 16.h),
      ),
      body: PaymentMethodsView(
        callback: (v) {
          setState(() {
            widget.cubit.paymentMethod = v;
          });
        },
      ).withPadding(horizontal: 16.w, vertical: 16.h),
    );
  }
}
