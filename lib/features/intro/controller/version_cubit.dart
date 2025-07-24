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
    
    // جلب معلومات الإصدار من السيرفر
    final result = await ServerGate.i.getFromServer(
      url: 'general/version',
    );
    
    if (result.success) {
      versionModel = VersionModel.fromJson(result.data['data']);
      
      // التحقق مما إذا كان هناك تحديث متاح
      bool updateAvailable = _isUpdateAvailable(
        currentVersion: packageInfo!.version,
        serverVersion: versionModel!.mobileVersion
      );
      
      emit(state.copyWith(
        requestState: RequestState.done,
        updateAvailable: updateAvailable
      ));
    } else {
      emit(state.copyWith(
        requestState: RequestState.error,
        msg: result.msg,
        errorType: result.errType
      ));
    }
  }
  
  // دالة للتحقق مما إذا كان هناك تحديث متاح
  bool _isUpdateAvailable({required String currentVersion, required String serverVersion}) {
    List<int> currentParts = currentVersion.split('.').map((e) => int.parse(e)).toList();
    List<int> serverParts = serverVersion.split('.').map((e) => int.parse(e)).toList();
    
    // التأكد من أن كلا الإصدارين لهما نفس عدد الأجزاء
    while (currentParts.length < serverParts.length) {
      currentParts.add(0);
    }
    while (serverParts.length < currentParts.length) {
      serverParts.add(0);
    }
    
    // المقارنة جزء بجزء
    for (int i = 0; i < currentParts.length; i++) {
      if (serverParts[i] > currentParts[i]) {
        return true; // هناك تحديث متاح
      } else if (serverParts[i] < currentParts[i]) {
        return false; // الإصدار الحالي أحدث
      }
    }
    
    return false; // الإصداران متطابقان
  }
} 