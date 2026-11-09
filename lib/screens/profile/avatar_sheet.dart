import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../providers/media_providers.dart';
import '../../providers/session_providers.dart';
import '../../services/image_encoder.dart';
import '../../services/photo_picker.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/gradient_button.dart';
import 'avatar_crop_screen.dart';

/// Keys for the photo flow, in one place so tests and screens cannot drift.
abstract final class AvatarKeys {
  static const Key avatar = Key('profile-avatar');
  static const Key camera = Key('avatar-camera');
  static const Key choose = Key('avatar-choose');
  static const Key remove = Key('avatar-remove');
}

Future<void> showAvatarSheet(BuildContext context, {required bool hasPhoto}) =>
    showAppSheet(context,
        title: 'Profile photo',
        builder: (_) => _AvatarSheet(hasPhoto: hasPhoto));

/// Take a photo, choose one, or remove the one there is. Remove appears only
/// when there is something to remove.
class _AvatarSheet extends ConsumerStatefulWidget {
  const _AvatarSheet({required this.hasPhoto});

  final bool hasPhoto;

  @override
  ConsumerState<_AvatarSheet> createState() => _AvatarSheetState();
}

class _AvatarSheetState extends ConsumerState<_AvatarSheet> {
  String? _problem;
  bool _busy = false;

  void _fail(String message) {
    if (mounted) {
      setState(() {
        _busy = false;
        _problem = message;
      });
    }
  }

  Future<void> _pick(PhotoOrigin origin) async {
    setState(() {
      _busy = true;
      _problem = null;
    });
    Uint8List? picked;
    try {
      picked = await ref.read(photoPickerProvider).pick(origin);
    } on PhotoAccessDenied catch (e) {
      // A refusal is a normal path with a way forward: say what is missing
      // and leave the other route on screen.
      return _fail(origin == PhotoOrigin.camera
          ? '${e.message} You can still choose an existing photo.'
          : '${e.message} Change this in Settings, or take a new photo instead.');
    } on PhotoPickFailed catch (e) {
      return _fail(e.message);
    }
    // Dismissed without choosing: nothing to say about it.
    if (picked == null || !mounted) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    // Full screen, above the tab bar, so nothing competes with the circle.
    final cropped =
        await Navigator.of(context, rootNavigator: true).push<Uint8List>(
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AvatarCropScreen(bytes: picked!)),
    );
    if (!mounted) return;
    if (cropped == null) {
      setState(() => _busy = false);
      return;
    }
    try {
      await ref.read(profileProvider.notifier).setAvatarBytes(cropped);
      if (mounted) Navigator.of(context).pop();
    } on ImageDecodeException catch (e) {
      _fail(e.message);
    } catch (_) {
      // The picture shown while saving has already been dropped.
      _fail('Could not save that photo. Your old one is still here.');
    }
  }

  Future<void> _remove() async {
    setState(() {
      _busy = true;
      _problem = null;
    });
    try {
      await ref.read(profileProvider.notifier).removeAvatar();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      _fail('Could not remove that photo. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget secondary(
            {required Key key,
            required IconData icon,
            required String label,
            required VoidCallback? onTap,
            Color? color}) =>
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            key: key,
            onPressed: onTap,
            icon: Icon(icon, size: 19),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: color ?? p.accentDeep,
              side:
                  BorderSide(color: (color ?? p.accent).withValues(alpha: .5)),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                  fontFamily: AppTheme.font,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
          ),
        );
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.hasPhoto
                ? 'Replace it, or remove it and show your initial.'
                : 'Add a photo, or keep your initial.',
            style: context.body,
          ),
          if (_problem != null) ...[
            const SizedBox(height: Space.md),
            Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 18, color: p.error),
                const SizedBox(width: Space.sm),
                Expanded(
                    child: Text(_problem!,
                        style: context.caption.copyWith(color: p.error))),
              ],
            ),
          ],
          const SizedBox(height: Space.lg),
          KeyedSubtree(
            key: AvatarKeys.camera,
            child: GradientButton(
              label: 'Take a photo',
              height: 50,
              onPressed: _busy ? null : () => _pick(PhotoOrigin.camera),
            ),
          ),
          const SizedBox(height: Space.sm),
          secondary(
            key: AvatarKeys.choose,
            icon: Icons.photo_library_outlined,
            label: 'Choose a photo',
            onTap: _busy ? null : () => _pick(PhotoOrigin.gallery),
          ),
          if (widget.hasPhoto) ...[
            const SizedBox(height: Space.sm),
            secondary(
              key: AvatarKeys.remove,
              icon: Icons.delete_outline_rounded,
              label: 'Remove photo',
              color: p.error,
              onTap: _busy ? null : _remove,
            ),
          ],
        ],
      ),
    );
  }
}
