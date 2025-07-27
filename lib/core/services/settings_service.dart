import 'package:flutter/material.dart';
import '../../models/settings_model.dart';
import 'server_gate.dart';

class SettingsService {
  final ServerGate _serverGate = ServerGate.i;
  SettingsModel? _settings;

  // Singleton pattern
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  // Getter para los ajustes
  SettingsModel? get settings => _settings;

  // Método para obtener los ajustes desde la API
  Future<SettingsModel?> getSettings() async {
    try {
      final response = await _serverGate.getFromServer(url: 'general/settings');
      
      if (response.success) {
        _settings = SettingsModel.fromJson(response.data['data']);
        return _settings;
      } else {
        debugPrint('Error al obtener los ajustes: ${response.msg}');
        return null;
      }
    } catch (e) {
      debugPrint('Excepción al obtener los ajustes: $e');
      return null;
    }
  }

  // Método para verificar si el servicio está cerrado
  bool isServiceClosed() {
    if (_settings == null) return false;
    
    final now = TimeOfDay.now();
    final closingTime = _parseTimeString(_settings!.closingService.closingTime);
    
    // Convertir a minutos para comparar fácilmente
    final nowMinutes = now.hour * 60 + now.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;
    
    // Si la hora actual es igual o posterior a la hora de cierre, el servicio está cerrado
    return nowMinutes >= closingMinutes;
  }

  // Método para verificar si el servicio está abierto
  bool isServiceOpen() {
    if (_settings == null) return true;
    
    final now = TimeOfDay.now();
    final openingTime = _parseTimeString(_settings!.closingService.openingTime);
    final closingTime = _parseTimeString(_settings!.closingService.closingTime);
    
    // Convertir a minutos para comparar fácilmente
    final nowMinutes = now.hour * 60 + now.minute;
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;
    
    // El servicio está abierto si la hora actual está entre la hora de apertura y cierre
    return nowMinutes >= openingMinutes && nowMinutes < closingMinutes;
  }
  
  // طريقة للتحقق مما إذا كان الوقت الحالي يساوي أو أكبر من وقت بدء الإشعار
  bool isNearClosingTime() {
    if (_settings == null) return false;
    
    final now = TimeOfDay.now();
    final notificationStartTime = _parseTimeString(_settings!.closingService.notificationStartTime);
    
    // تحويل إلى دقائق للمقارنة بسهولة
    final nowMinutes = now.hour * 60 + now.minute;
    final notificationStartMinutes = notificationStartTime.hour * 60 + notificationStartTime.minute;
    
    // إذا كان الوقت الحالي يساوي أو أكبر من وقت بدء الإشعار، ولكن قبل وقت الإغلاق
    return nowMinutes >= notificationStartMinutes && !isServiceClosed();
  }
  
  // الحصول على وقت الإلغاء التلقائي بالدقائق
  int getCancellationTimeInMinutes() {
    if (_settings == null) return 15; // قيمة افتراضية
    return _settings!.closingService.cancellationTime;
  }

  // Método auxiliar para convertir una cadena de tiempo (HH:MM) a TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
} 