import '../../models/user_model.dart';
import 'server_gate.dart';

class ProfileService {
  final ServerGate _serverGate = ServerGate.i;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _serverGate.getFromServer(url: 'general/profile');
    if (response.success) {
      return response.data;
    } else {
      throw Exception('فشل في الحصول على بيانات الملف الشخصي: ${response.msg}');
    }
  }

  Future<bool> switchUserType() async {
    try {
      // الحصول على بيانات الملف الشخصي
      final profileData = await getProfile();
      
      if (profileData['status'] != 'success' || profileData['data'] == null) {
        return false;
      }
      
      final userData = profileData['data'];
      final userType = userData['user_type'];
      final isApproved = userData['admin_approved'] ?? false;
      
      // التحقق مما إذا كان المستخدم مندوب حر ومعتمد من الإدارة
      if (userType == 'free_agent' && isApproved) {
        // تحويل نوع المستخدم من مندوب حر إلى عميل
        UserModel.i.userType = 'client';
        UserModel.i.save();
        return true;
      } else if (userType == 'client') {
        // تحويل نوع المستخدم من عميل إلى مندوب حر
        UserModel.i.userType = 'free_agent';
        UserModel.i.save();
        return true;
      }
      
      return false;
    } catch (e) {
      print('خطأ أثناء تبديل نوع المستخدم: $e');
      return false;
    }
  }
} 