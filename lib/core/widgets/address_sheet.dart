import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/extensions.dart';
import '../../features/client/addresses/controller/cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../features/client/addresses/controller/state.dart';
import '../../gen/locale_keys.g.dart';
import '../../models/address.dart';
import '../services/service_locator.dart';
import 'app_btn.dart';
import 'app_field.dart';
import 'app_sheet.dart';
import 'flash_helper.dart';
import 'successfully_sheet.dart';

class AddAddressSheet extends StatefulWidget {
  final LatLng latLng;
  final AddressModel? data;
  const AddAddressSheet({super.key, required this.latLng, this.data});

  @override
  State<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<AddAddressSheet> {
  final cubit = sl<AddressesCubit>();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      cubit.placeTitle.text = widget.data!.placeTitle;
      cubit.placeDesc.text = widget.data!.placeDescription;
    }
  }

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
              if (state.addStateState.isDone || state.editStateState.isDone) {
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
                loading: state.editStateState.isLoading || state.addStateState.isLoading,
                title: LocaleKeys.confirm.tr(),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (widget.data != null) {
                      cubit.editAddress(data: widget.data!);
                    } else {
                      cubit.addAddress(widget.latLng);
                    }
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

class DeleteAddressSheet extends StatefulWidget {
  final String id;

  const DeleteAddressSheet({super.key, required this.id});

  @override
  State<DeleteAddressSheet> createState() => _DeleteAddressSheetState();
}

class _DeleteAddressSheetState extends State<DeleteAddressSheet> {
  final cubit = sl<AddressesCubit>();

  @override
  Widget build(BuildContext context) {
    return CustomAppSheet(
      title: LocaleKeys.are_you_want_to_delete_this_address.tr(),
      children: [
        Row(
          children: [
            BlocBuilder<AddressesCubit, AddressesState>(
              bloc: cubit,
              builder: (context, state) {
                return Expanded(
                    child: AppBtn(
                  loading: state.deleteStateState.isLoading,
                  onPressed: () => cubit.deleteAddress(id: widget.id),
                  title: LocaleKeys.yes.tr(),
                  backgroundColor: context.errorColor,
                ));
              },
            ),
            SizedBox(width: 12.w),
            Expanded(child: AppBtn(onPressed: () => Navigator.pop(context), title: LocaleKeys.no.tr()))
          ],
        )
      ],
    );
  }
}
