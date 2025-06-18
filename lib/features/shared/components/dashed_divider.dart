import 'package:flutter/widgets.dart';
import '../../../core/utils/extensions.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(30, (index) => Container(width: 8, height: 1, color: context.borderColor)),
    );
  }
}
