import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/client/addresses/controller/cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../features/client/addresses/controller/state.dart';
import '../../gen/locale_keys.g.dart';
import '../services/service_locator.dart';
import 'app_btn.dart';
import 'app_field.dart';
import 'app_sheet.dart';
import 'flash_helper.dart';
import 'successfully_sheet.dart';

class AddAddressSheet extends StatefulWidget {
  final LatLng latLng;
  const AddAddressSheet({super.key, required this.latLng});

  @override
  State<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<AddAddressSheet> {
  final cubit = sl<AddressesCubit>();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: CustomAppSheet(
        title: LocaleKeys.address_description.tr(),
        children: [
          AppField(
            labelText: LocaleKeys.full_address.tr(),
            controller: cubit.placeTitle,
          ),
          AppField(
            labelText: LocaleKeys.description.tr(),
            controller: cubit.placeDesc,
          ),
          BlocConsumer<AddressesCubit, AddressesState>(
            bloc: cubit,
            listener: (context, state) {
              if (state.addStateState.isDone) {
                Navigator.pop(context);
                Navigator.pop(context);

                
                showModalBottomSheet(
                  elevation: 0,
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) => SuccessfullySheet(
                    title: LocaleKeys.address_added_successfully.tr(),
                  ),
                );
              } else if (state.addStateState.isError) {
                FlashHelper.showToast(state.msg);
              }
            },
            builder: (context, state) {
              return AppBtn(
                loading: state.addStateState.isLoading,
                title: LocaleKeys.confirm.tr(),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    cubit.addAddress(widget.latLng);
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }
}
