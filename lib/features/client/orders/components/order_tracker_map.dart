import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../core/utils/extensions.dart';

class OrderTrackerMap extends StatefulWidget {
  final String orderId;

  const OrderTrackerMap({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderTrackerMap> createState() => _OrderTrackerMapState();
}

class _OrderTrackerMapState extends State<OrderTrackerMap> {
  final Completer<GoogleMapController> _controllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? _mapController;
  Timer? _timer;
  LatLng? _deliveryLocation;
  bool _isLoading = true;
  String? _errorMessage;
  final Set<Marker> _markers = {};
  String _agentName = '';
  String _agentPhone = '';
  bool _isMapCreated = false;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryLocation();
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    _mapController?.dispose();
    super.dispose();
  }

  void _startLocationUpdates() {
    _timer?.cancel();
    // Call API every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchDeliveryLocation();
    });
  }

  void _stopLocationUpdates() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchDeliveryLocation() async {
    try {
      final response = await ServerGate.i.getFromServer(
        url: 'general/track-order/${widget.orderId}',
      );

      if (response.success) {
        final data = response.data;
        if (data['status'] == true && 
            data['location'] != null && 
            data['location']['lat'] != null && 
            data['location']['lng'] != null) {
          
          final newLat = double.parse(data['location']['lat'].toString());
          final newLng = double.parse(data['location']['lng'].toString());
          final newLocation = LatLng(newLat, newLng);
          
          // استخراج معلومات
          if (data['agent'] != null) {
            _agentName = data['agent']['name']?.toString() ?? LocaleKeys.delivery_person.tr();
            _agentPhone = data['agent']['phone']?.toString() ?? '';
          }

          setState(() {
            _deliveryLocation = newLocation;
            _isLoading = false;
            _errorMessage = null;
          });

          if (!_isMapCreated && _mapController != null) {
            _isMapCreated = true;
            _startLocationUpdates();
          }
          
          // تحديث الموقع على الخريطة
          _updateLocationOnMap(newLocation);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = LocaleKeys.location_not_available.tr();
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.msg;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = LocaleKeys.something_went_wrong_please_try_again.tr();
      });
    }
  }

  Future<void> _updateLocationOnMap(LatLng newLocation) async {
    if (_mapController != null) {
      // تحريك الكاميرا إلى الموقع الجديد
      await _mapController!.animateCamera(CameraUpdate.newLatLng(newLocation));
      
      // تحديث العلامات على الخريطة
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('delivery_person'),
            position: newLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow.noText,
            zIndex: 2,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 50.r, color: Colors.grey),
                        SizedBox(height: 10.h),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: context.mediumText.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: 10.h),
                        TextButton(
                          onPressed: _fetchDeliveryLocation,
                          child: Text(LocaleKeys.retry.tr()),
                        ),
                      ],
                    ),
                  )
                : _deliveryLocation == null
                    ? Center(
                        child: Text(
                          LocaleKeys.location_not_available.tr(),
                          style: context.mediumText,
                        ),
                      )
                    : _buildMap(),
      ),
    );
  }
  
  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _deliveryLocation!,
        zoom: 15,
      ),
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        if (!_controllerCompleter.isCompleted) {
          _controllerCompleter.complete(controller);
        }
        
        // تبدأ التحديثات بعد إنشاء الخريطة
        if (_deliveryLocation != null && !_isMapCreated) {
          _isMapCreated = true;
          _updateLocationOnMap(_deliveryLocation!);
          _startLocationUpdates();
        }
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      zoomControlsEnabled: true,
    );
  }
} 