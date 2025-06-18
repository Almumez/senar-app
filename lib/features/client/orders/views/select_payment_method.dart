import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_btn.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/payment_methods.dart';
import '../controller/order_details/cubit.dart';

class ClientOrderDetailsSelectPaymentView extends StatefulWidget {
  final ClientOrderDetailsCubit cubit;
  const ClientOrderDetailsSelectPaymentView({super.key, required this.cubit});

  @override
  State<ClientOrderDetailsSelectPaymentView> createState() => _ClientOrderDetailsSelectPaymentViewState();
}

class _ClientOrderDetailsSelectPaymentViewState extends State<ClientOrderDetailsSelectPaymentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.payment.tr()),
      bottomNavigationBar: SafeArea(
        child: AppBtn(
          title: LocaleKeys.confirm.tr(),
          onPressed: () {
            if (widget.cubit.paymentMethod == 'visa') {
              push(
                NamedRoutes.paymentService,
                arg: {
                  "amount": widget.cubit.data?.totalPrice.toString(),
                  "on_success": (v) {
                    widget.cubit.transactionId = v;
                    Navigator.pop(context);
                  }
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
          enable: widget.cubit.paymentMethod != null,
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
