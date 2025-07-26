import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UrlLauncherUtils {
  static Future<void> launchWhatsApp() async {
    // Número de WhatsApp de soporte (reemplaza con el número real)
    const String phoneNumber = '+966501590007'; // Ejemplo: +966500000000
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir WhatsApp');
    }
  }
} 