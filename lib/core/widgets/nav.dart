import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/extensions.dart';

/// A beautiful and animated bottom navigation that paints a rounded shape
/// around its [items] to provide a wonderful look.
///
/// Update [selectedIndex] to change the selected item.
/// [selectedIndex] is required and must not be null.
class BottomNavyBar extends StatelessWidget {
  const BottomNavyBar({
    super.key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24,
    this.backgroundColor,
    this.shadowColor = Colors.black12,
    this.itemCornerRadius = 50,
    this.containerHeight = 56,
    this.blurRadius = 2,
    this.spreadRadius = 0,
    this.borderRadius,
    this.shadowOffset = Offset.zero,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.animationDuration = const Duration(milliseconds: 270),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.showInactiveTitle = false,
    required this.items,
    required this.onItemSelected,
    this.curve = Curves.linear,
  }) : assert(items.length >= 2 && items.length <= 5);

  /// The selected item is index. Changing this property will change and animate
  /// the item being selected. Defaults to zero.
  final int selectedIndex;

  /// The icon size of all items. Defaults to 24.
  final double iconSize;

  /// The background color of the navigation bar. It defaults to
  /// [ThemeData.BottomAppBarTheme.color] if not provided.
  final Color? backgroundColor;

  /// Defines the shadow color of the navigation bar. Defaults to [Colors.black12].
  final Color shadowColor;

  /// Whether this navigation bar should show a elevation. Defaults to true.
  final bool showElevation;

  /// Use this to change the item's animation duration. Defaults to 270ms.
  final Duration animationDuration;

  /// Defines the appearance of the buttons that are displayed in the bottom
  /// navigation bar. This should have at least two items and five at most.
  final List<BottomNavyBarItem> items;

  /// A callback that will be called when a item is pressed.
  final ValueChanged<int> onItemSelected;

  /// Defines the alignment of the items.
  /// Defaults to [MainAxisAlignment.spaceBetween].
  final MainAxisAlignment mainAxisAlignment;

  /// The [items] corner radius, if not set, it defaults to 50.
  final double itemCornerRadius;

  /// Defines the bottom navigation bar height. Defaults to 56.
  final double containerHeight;

  /// Used to configure the blurRadius of the [BoxShadow]. Defaults to 2.
  final double blurRadius;

  /// Used to configure the spreadRadius of the [BoxShadow]. Defaults to 0.
  final double spreadRadius;

  /// Used to configure the offset of the [BoxShadow]. Defaults to null.
  final Offset shadowOffset;

  /// Used to configure the borderRadius of the [BottomNavyBar]. Defaults to null.
  final BorderRadiusGeometry? borderRadius;

  /// Used to configure the padding of the [BottomNavyBarItem] [items].
  /// Defaults to EdgeInsets.symmetric(horizontal: 4).
  final EdgeInsets itemPadding;

  /// Used to configure the animation curve. Defaults to [Curves.linear].
  final Curve curve;

  /// Whether this navigation bar should show a Inactive titles. Defaults to false.
  final bool showInactiveTitle;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? (Theme.of(context).bottomAppBarTheme.color ?? Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // Eliminar fondo
        boxShadow: [], // Eliminar sombra
        borderRadius: borderRadius,
      ),
      child: SafeArea(
        child: Container(
          width: context.w,
          height: containerHeight,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items.map((item) {
                  var index = items.indexOf(item);
                  return SizedBox(
                    width: itemWidth,
                    child: GestureDetector(
                      onTap: () => onItemSelected(index),
                      child: _ItemWidget(
                        item: item,
                        iconSize: iconSize,
                        isSelected: index == selectedIndex,
                        backgroundColor: bgColor,
                        itemCornerRadius: itemCornerRadius,
                        animationDuration: animationDuration,
                        itemPadding: itemPadding,
                        curve: curve,
                        numberOfItems: items.length,
                        showInactiveTitle: showInactiveTitle,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final double iconSize;
  final bool isSelected;
  final BottomNavyBarItem item;
  final Color backgroundColor;
  final double itemCornerRadius;
  final Duration animationDuration;
  final EdgeInsets itemPadding;
  final Curve curve;
  final bool showInactiveTitle;
  final int numberOfItems; // Número total de elementos

  const _ItemWidget({
    Key? key,
    required this.iconSize,
    required this.isSelected,
    required this.item,
    required this.backgroundColor,
    required this.itemCornerRadius,
    required this.animationDuration,
    required this.itemPadding,
    required this.showInactiveTitle,
    required this.numberOfItems, // Requerido
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      selected: isSelected,
      child: Container(
        // Ancho fijo para todos los elementos, independientemente de si están seleccionados o no
        width: MediaQuery.of(context).size.width / numberOfItems,
        height: double.maxFinite,
        // Sin animación
        // duration: animationDuration,
        // curve: curve,
        decoration: BoxDecoration(
          color: Colors.transparent, // Fondo transparente
          borderRadius: BorderRadius.circular(itemCornerRadius),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.zero, // Sin padding adicional
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: item.icon // Simplemente mostrar el icono sin filas adicionales
          ),
          ),
        ),
      );
  }
}

/// The [BottomNavyBar.items] definition.
class BottomNavyBarItem {
  BottomNavyBarItem({
    required this.icon,
    required this.title,
    this.activeColor = Colors.blue,
    this.textAlign,
    this.inactiveColor,
  });

  /// Defines this item's icon which is placed in the right side of the [title].
  final Widget icon;

  /// Defines this item's title which placed in the left side of the [icon].
  final Widget title;

  /// The [icon] and [title] color defined when this item is selected. Defaults
  /// to [Colors.blue].
  final Color activeColor;

  /// The [icon] and [title] color defined when this item is not selected.
  final Color? inactiveColor;

  /// The alignment for the [title].
  ///
  /// This will take effect only if [title] it a [Text] widget.
  final TextAlign? textAlign;
}
