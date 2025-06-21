import 'dart:async';
import 'dart:io';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../models/address.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/widgets/address_sheet.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_radius_icon.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/controller/google_map_search/bloc.dart';
import '../controller/cubit.dart';
import '../controller/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PickLocationView extends StatefulWidget {
  final AddressModel? data;
  const PickLocationView({super.key, this.data});

  @override
  State<PickLocationView> createState() => _PickLocationViewState();
}

class _PickLocationViewState extends State<PickLocationView> {
  final location = LocationService();
  final cubit = sl<GoogleMapSearchBloc>();
  final addressesCubit = sl<AddressesCubit>();
  final markers = <Marker>{};
  LatLng? latLng;
  bool loading = true;

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  getLocation() {
    if (widget.data != null) {
      latLng = LatLng(widget.data!.lat, widget.data!.lng);

      _goToTheLake(latLng!);
    } else {
      location.getCurrentLocation().then(
        (value) {
          final position = value.position;
          if (position != null) {
            _goToTheLake(LatLng(position.latitude, position.longitude));
          } else {
            FlashHelper.showToast(value.msg);
          }
        },
      );
    }
  }

  // Timer? timer;
  // String? old;
  // _onSearch(String value) {
  //   if (timer?.isActive == true) timer?.cancel();
  //   if (value.isNotEmpty && old != value) {
  //     timer = Timer(1.seconds, () {
  //       cubit.search(value);
  //       old = value;
  //     });
  //   }
  // }

  Widget buildLocationButton() {
    return CustomRadiusIcon(
      onTap: getLocationWithErrorHandling,
      size: 60.h,
      backgroundColor: context.primaryColorLight,
      borderRadius: BorderRadius.circular(18.r),
      child: Icon(Icons.my_location, color: context.primaryColor, size: 28),
    );
  }

  void getLocationWithErrorHandling() async {
    try {
      final value = await location.getCurrentLocation();
      final position = value.position;
      if (position != null) {
        _goToTheLake(LatLng(position.latitude, position.longitude));
        addressesCubit.checkZoneLocation(LatLng(position.latitude, position.longitude));
      } else {
        FlashHelper.showToast(value.msg);
        
        // إذا كان الخطأ بسبب تعطيل خدمة الموقع أو رفض الإذن بشكل دائم
        if (value.status == LocationPermission.deniedForever) {
          showLocationPermissionDialog();
        }
      }
    } catch (e) {
      FlashHelper.showToast("Error accessing location: ${e.toString()}");
      log("Location error: ${e.toString()}");
    }
  }

  void showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.location_access_required.tr()),
        content: Text(LocaleKeys.enable_location_in_settings.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // استخدام openLocationSettings بدلاً من openAppSettings
              Geolocator.openLocationSettings();
            },
            child: Text(LocaleKeys.open_settings.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            onTap: (latLng) {
              _goToTheLake(latLng);
              addressesCubit.checkZoneLocation(latLng);
            },
            markers: markers,
            initialCameraPosition: _kGooglePlex,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              getLocation();
              // if (widget.latLng != null) {
              //   _goToTheLake(widget.latLng!);
              // } else {
              //   location.getCurrentLocation().then(
              //     (value) {
              //       final position = value.position;
              //       if (position != null) {
              //         _goToTheLake(
              //             LatLng(position.latitude, position.longitude));
              //       } else {
              //         FlashHelper.showToast(value.msg);
              //       }
              //     },
              //   );
              // }
            },
          ),
          PositionedDirectional(
            top: 50.h,
            child: SizedBox(
              width: context.w,
              height: 70.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CustomRadiusIcon(
                        onTap: () => Navigator.pop(context),
                        backgroundColor: context.canvasColor,
                        child: Icon(Icons.arrow_back),
                      ).withPadding(horizontal: 16.w, bottom: 10.h),
                      Text(
                        LocaleKeys.select_your_location.tr(),
                        style: context.mediumText.copyWith(fontSize: 24),
                      )
                    ],
                  ),
                  // AppField(
                  //   onChanged: _onSearch,
                  //   hintText: LocaleKeys.search_about_the_address.tr(),
                  // ).withPadding(horizontal: 24.w)
                ],
              ),
            ),
          ),
          // PositionedDirectional(
          //   top: 130.h,
          //   child: SafeArea(
          //     child: BlocBuilder<GoogleMapSearchBloc, GoogleMapSearchState>(
          //       bloc: cubit,
          //       builder: (context, state) {
          //         if (state.requestState.isLoading) {
          //           return CustomProgress(size: 20.h)
          //               .toTop
          //               .withPadding(top: 20.h);
          //         } else if (cubit.list.isNotEmpty) {
          //           return Container(
          //             width: context.w,
          //             constraints: BoxConstraints(maxHeight: context.h / 1.2),
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(12.r),
          //               color: context.primaryColorLight,
          //             ),
          //             margin: EdgeInsets.symmetric(
          //                 horizontal: 24.w, vertical: 10.h),
          //             child: SingleChildScrollView(
          //               padding: EdgeInsets.symmetric(
          //                   horizontal: 24.w, vertical: 12.h),
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: List.generate(
          //                   cubit.list.length,
          //                   (index) => GestureDetector(
          //                     onTap: () {
          //                       FocusManager.instance.primaryFocus?.unfocus();
          //                       _goToTheLake(cubit.list[index].latLng);
          //                       setState(() {
          //                         cubit.list.clear();
          //                       });
          //                     },
          //                     child: Container(
          //                       margin: EdgeInsets.symmetric(vertical: 12.h),
          //                       decoration: const BoxDecoration(),
          //                       child: Row(
          //                         children: [
          //                           const Icon(CupertinoIcons.search, size: 18),
          //                           Expanded(
          //                             child: Text(
          //                               cubit.list[index].name,
          //                               style: context.regularText
          //                                   .copyWith(fontSize: 16),
          //                             ).withPadding(horizontal: 12.w),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           );
          //         }
          //         return const SizedBox.shrink();
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 90.h,
          color: context.primaryColorLight,
          padding: EdgeInsets.only(top: 10.h),
          child: BlocBuilder<AddressesCubit, AddressesState>(
            bloc: addressesCubit,
            builder: (context, state) {
              String buttonText = widget.data == null
                ? LocaleKeys.add_address_description.tr()
                : LocaleKeys.edit_address.tr();
              
              Color textColor = context.primaryColor;
              Color backgroundColor = Colors.transparent;
              bool isEnabled = true;
              
              if (state.checkZoneState.isLoading) {
                buttonText = LocaleKeys.checking_location.tr();
              } else if (state.checkZoneState.isDone && latLng != null) {
                if (addressesCubit.isLocationAvailable) {
                  buttonText = LocaleKeys.location_available.tr();
                } else {
                  buttonText = LocaleKeys.location_not_available.tr();
                  textColor = context.errorColor;
                }
              }
              
              return AppBtn(
                textColor: textColor,
                backgroundColor: backgroundColor,
                onPressed: () {
                  if (!state.checkZoneState.isLoading && latLng != null) {
                    if (addressesCubit.isLocationAvailable) {
                      showModalBottomSheet(
                        elevation: 0,
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        builder: (context) => AddAddressSheet(latLng: latLng!, data: widget.data),
                      );
                    } else {
                      FlashHelper.showToast(LocaleKeys.location_not_available_message.tr());
                    }
                  }
                },
                title: buttonText,
              ).withPadding(horizontal: 24.w, vertical: 10.h);
            }
          ),
        ),
      ),
      floatingActionButton: buildLocationButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> _goToTheLake(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    this.latLng = latLng;
    markers.add(
      Marker(
        markerId: const MarkerId('my_location'),
        position: latLng,
      ),
    );
    if (mounted) setState(() {});
    final zoom = await controller.getZoomLevel();
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: zoom < 15 ? 15 : zoom,
        ),
      ),
    );
  }
}
