import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/services/server_gate.dart';
import '../../../core/utils/enums.dart';
import '../../../models/version_model.dart';
import 'version_state.dart';

class VersionCubit extends Cubit<VersionState> {
  VersionCubit() : super(VersionState());

  VersionModel? versionModel;
  PackageInfo? packageInfo;

  Future<void> checkVersion() async {
    emit(state.copyWith(requestState: RequestState.loading));
    
    // جلب معلومات الإصدار الحالي للتطبيق
    packageInfo = await PackageInfo.fromPlatform();
    debugPrint('Current app version: ${packageInfo!.version}');
    
    // جلب معلومات الإصدار من السيرفر
    debugPrint('Fetching version from server...');
    final result = await ServerGate.i.getFromServer(
      url: 'general/version',
    );
    
    if (result.success) {
      versionModel = VersionModel.fromJson(result.data['data']);
      debugPrint('Server version: ${versionModel!.mobileVersion}');
      
      // التحقق مما إذا كان هناك تحديث متاح
      bool updateAvailable = _isUpdateAvailable(
        currentVersion: packageInfo!.version,
        serverVersion: versionModel!.mobileVersion
      );
      
      debugPrint('Update available: $updateAvailable');
      
      emit(state.copyWith(
        requestState: RequestState.done,
        updateAvailable: updateAvailable
      ));
    } else {
      debugPrint('Error fetching version: ${result.msg}');
      emit(state.copyWith(
        requestState: RequestState.error,
        msg: result.msg,
        errorType: result.errType
      ));
    }
  }
  
  // دالة للتحقق مما إذا كان هناك تحديث متاح
  bool _isUpdateAvailable({required String currentVersion, required String serverVersion}) {
    debugPrint('Comparing versions:');
    debugPrint('Current: $currentVersion');
    debugPrint('Server: $serverVersion');
    
    List<int> currentParts = currentVersion.split('.').map((e) => int.parse(e)).toList();
    List<int> serverParts = serverVersion.split('.').map((e) => int.parse(e)).toList();
    
    debugPrint('Current parts: $currentParts');
    debugPrint('Server parts: $serverParts');
    
    // التأكد من أن كلا الإصدارين لهما نفس عدد الأجزاء
    while (currentParts.length < serverParts.length) {
      currentParts.add(0);
    }
    while (serverParts.length < currentParts.length) {
      serverParts.add(0);
    }
    
    debugPrint('Normalized current parts: $currentParts');
    debugPrint('Normalized server parts: $serverParts');
    
    // المقارنة جزء بجزء
    for (int i = 0; i < currentParts.length; i++) {
      debugPrint('Comparing part $i: ${currentParts[i]} vs ${serverParts[i]}');
      if (serverParts[i] > currentParts[i]) {
        debugPrint('Server version is newer at part $i');
        return true; // هناك تحديث متاح
      } else if (serverParts[i] < currentParts[i]) {
        debugPrint('Current version is newer at part $i');
        return false; // الإصدار الحالي أحدث
      }
    }
    
    debugPrint('Versions are identical');
    return false; // الإصداران متطابقان
  }
} 