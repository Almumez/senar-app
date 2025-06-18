import '../gen/locale_keys.g.dart';

class ProfileItemModel {
  final String title, image;
  final Function()? onTap;

  ProfileItemModel({required this.title, required this.image, this.onTap});

  bool get isLogout => title == LocaleKeys.logout;
}
