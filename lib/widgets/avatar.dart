import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/account.dart';

/// The person's photo in a circle, or their initial if there is no photo or
/// the file is missing (a stored session can outlive a renamed asset).
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.profile, this.size = 40});

  final UserProfile? profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initial = Center(
      child: Text(
        (profile?.name.isNotEmpty ?? false)
            ? profile!.name[0].toUpperCase()
            : '',
        style: TextStyle(
            color: p.accent, fontWeight: FontWeight.w800, fontSize: size * .42),
      ),
    );
    final asset = profile?.avatarAsset;
    return Semantics(
      label: profile == null ? null : '${profile!.name}, photo',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: ColoredBox(
            color: p.accentWash,
            child: asset == null
                ? initial
                : Image.asset(asset,
                    fit: BoxFit.cover, errorBuilder: (_, __, ___) => initial),
          ),
        ),
      ),
    );
  }
}
