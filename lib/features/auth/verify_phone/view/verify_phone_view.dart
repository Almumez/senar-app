import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/auth_back_button.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/custom_timer.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/pin_code.dart';
import '../../../../core/widgets/resend_timer_widget.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../controller/verify_phone_bloc.dart';
import '../controller/verify_phone_states.dart';
import '../widgets/edit_email_sheet.dart';

class VerifyPhoneView extends StatefulWidget {
  final VerifyType type;
  final String phone, phoneCode;
  const VerifyPhoneView({super.key, required this.type, required this.phone, required this.phoneCode});

  @override
  State<VerifyPhoneView> createState() => _VerifyPhoneViewState();
}

class _VerifyPhoneViewState extends State<VerifyPhoneView> {
  final timerController = CustomTimerController(30.seconds);
  final bloc = sl<VerifyPhoneCubit>();
  final form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    bloc.phoneCode = widget.phoneCode;
    bloc.phone = widget.phone;
    bloc.type = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 80.h),
                  Center(child: CustomImage("assets/images/splash.png", height: 100.2.h)),
                  SizedBox(height: 45.h),
                  Center(child: Text(LocaleKeys.confirm_identity.tr(), style: context.mediumText.copyWith(fontSize: 20, color: Colors.black))),
                  SizedBox(height: 24.h),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: LocaleKeys.we_have_sent_a_verification_code_consisting_of_4_digits_to.tr(args: [bloc.phone.toString()]),
                          ),
                          TextSpan(
                            text: context.locale.languageCode == "en" ? ' +${bloc.phoneCode}${bloc.phone} ' : ' ${bloc.phoneCode}${bloc.phone}+ ',
                            style: context.mediumText.copyWith(fontSize: 14, color: Colors.black),
                            locale: Locale('en'),
                          ),

                        ],
                        style: context.mediumText.copyWith(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  InkWell(
                    onTap: () {
                      if (widget.type == VerifyType.register) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => BlocProvider.value(
                            value: bloc,
                            child: EditPhoneSheet(phone: bloc.phone!),
                          ),
                        ).then((value) {
                          if (value != null) {
                            timerController.setDuration(30.seconds);
                            setState(() {});
                          }
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      LocaleKeys.edit_phone.tr(),
                      style: context.mediumText.copyWith(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  CustomPinCode(controller: bloc.code).withPadding(vertical: 16.h),
                  BlocConsumer<VerifyPhoneCubit, VerifyPhoneState>(
                    bloc: bloc,
                    buildWhen: (previous, current) => previous.resendState != current.resendState,
                    listenWhen: (previous, current) => previous.resendState != current.resendState,
                    listener: (context, state) {
                      if (state.resendState.isDone) {
                        timerController.setDuration(1.minutes);
                        FlashHelper.showToast(state.msg, type: MessageType.success);
                      } else if (state.resendState.isError) {
                        FlashHelper.showToast(state.msg);
                      }
                    },
                    builder: (context, state) {
                      return ResendTimerWidget(
                        timer: timerController,
                        onTap: () {
                          if (!state.resendState.isLoading) {
                            bloc.resend();
                          }
                        },
                        loading: state.resendState.isLoading,
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  BlocConsumer<VerifyPhoneCubit, VerifyPhoneState>(
                    bloc: bloc,
                    buildWhen: (previous, current) => previous.verifyState != current.verifyState,
                    listenWhen: (previous, current) => previous.verifyState != current.verifyState,
                    listener: (context, state) {
                      if (state.verifyState.isDone) {
                        if (widget.type == VerifyType.register) {
                          if (UserModel.i.accountType == UserType.freeAgent) {
                            replacement(NamedRoutes.completeData, arg: {'phone': widget.phone, 'phone_code': widget.phoneCode});
                          } else {
                            pushAndRemoveUntil(NamedRoutes.navbar);
                          }
                        } else {
                          replacement(NamedRoutes.resetPassword, arg: {'phone': widget.phone, 'code': bloc.code.text, 'phone_code': widget.phoneCode});
                        }
                      } else if (state.verifyState.isError) {
                        FlashHelper.showToast(state.msg);
                      }
                    },
                    builder: (context, state) {
                      return AppBtn(
                        title: "تأكيد",
                        loading: state.verifyState.isLoading,
                        onPressed: () => form.isValid ? bloc.verify() : null,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          AuthBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
