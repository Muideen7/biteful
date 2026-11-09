import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_theme.dart';
import '../models/account.dart';
import '../providers/media_providers.dart';
import '../services/media_ref.dart';

/// The person's photo in a circle.
///
/// In order: a picture just chosen (shown before its file is written), the
/// picture the profile references (bundled or on disk), and otherwise their
/// initial. A reference whose file has gone (cleared storage, a renamed
/// asset) falls back to the initial rather than throwing.
class Avatar extends ConsumerWidget {
  const Avatar({super.key, required this.profile, this.size = 40});

  final UserProfile? profile;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final pending = ref.watch(pendingAvatarProvider);
    final mediaRef = MediaRef.parse(profile?.avatar);

    Widget fill(ImageProvider image) => Image(
          image: image,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => initial,
        );

    final Widget picture;
    if (pending != null) {
      picture = fill(MemoryImage(pending));
    } else if (mediaRef == null) {
      picture = initial;
    } else {
      picture = switch (ref.watch(mediaImageProvider(mediaRef))) {
        AsyncData(:final value?) => fill(value),
        _ => initial,
      };
    }

    return Semantics(
      label: profile == null ? null : '${profile!.name}, photo',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(child: ColoredBox(color: p.accentWash, child: picture)),
      ),
    );
  }
}
