import 'package:url_launcher/url_launcher.dart';

Future<void> launchGoogleMaps(double latitude, double longitude) async {
  final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl);
  } else {
    throw 'Could not launch Google Maps';
  }
}
