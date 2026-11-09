import 'package:flutter/material.dart';

import '../models/catalog.dart';

/// A 3D food render, with the optional side render tucked in front at the
/// lower right, the way a menu photo pairs a burger with its fries.
class FoodArtView extends StatelessWidget {
  const FoodArtView(this.art, {super.key, this.size = 72, this.heroTag});

  final FoodArt art;
  final double size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget img(String name, double s) => Image.asset(
          FoodArt.path(name),
          width: s,
          height: s,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => SizedBox.square(dimension: s),
        );
    final side = art.side;
    Widget child = SizedBox.square(
      dimension: size,
      child: side == null
          ? img(art.main, size)
          : Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(left: 0, top: 0, child: img(art.main, size * .86)),
                Positioned(
                    right: -size * .02,
                    bottom: -size * .02,
                    child: img(side, size * .5)),
              ],
            ),
    );
    if (heroTag != null) child = Hero(tag: heroTag!, child: child);
    return ExcludeSemantics(child: child);
  }
}
