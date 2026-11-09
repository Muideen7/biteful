import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../models/avatar_crop.dart';
import '../../services/image_encoder.dart';
import '../../widgets/gradient_button.dart';

/// Choose the circle before the photo is saved.
///
/// Silently centre-cropping someone's photo takes the top of their head off
/// about a third of the time, and nothing in the result says a choice was
/// made for them. So cropping is a step: drag to move, pinch or slide to
/// zoom, and what is inside the circle is exactly what is stored.
///
/// Pops the encoded JPEG bytes, or null if cancelled.
class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({super.key, required this.bytes});

  /// The photo as it came from the camera or library.
  final Uint8List bytes;

  static const Key confirmKey = Key('avatar-crop-confirm');
  static const Key zoomKey = Key('avatar-crop-zoom');

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  Size? _imageSize;
  String? _problem;
  bool _working = false;

  double _scale = AvatarCrop.minScale;
  Offset _offset = Offset.zero;
  double _startScale = AvatarCrop.minScale;
  Offset _startOffset = Offset.zero;
  Offset _startFocal = Offset.zero;

  /// Side of the square crop viewport, measured at layout.
  double _viewport = 0;

  @override
  void initState() {
    super.initState();
    _imageSize = _probeSize(widget.bytes);
    if (_imageSize == null) _problem = 'That photo could not be opened.';
  }

  /// The photo's size, read from its header: synchronous and free, and it
  /// does not go through the engine's image codec, which never completes in
  /// a widget test.
  static Size? _probeSize(Uint8List bytes) {
    try {
      final info = img.findDecoderForData(bytes)?.startDecode(bytes);
      if (info == null || info.width <= 0 || info.height <= 0) return null;
      return Size(info.width.toDouble(), info.height.toDouble());
    } catch (_) {
      return null;
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    _startScale = _scale;
    _startOffset = _offset;
    _startFocal = d.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final image = _imageSize;
    if (image == null) return;
    final scale =
        (_startScale * d.scale).clamp(AvatarCrop.minScale, AvatarCrop.maxScale);
    // Carry the pan through the zoom, so what was under the middle of the
    // circle stays there instead of jumping.
    final panned =
        _startOffset * (scale / _startScale) + (d.focalPoint - _startFocal);
    setState(() {
      _scale = scale;
      _offset = AvatarCrop.clampOffset(panned,
          image: image, viewport: _viewport, scale: scale);
    });
  }

  void _setZoom(double scale) {
    final image = _imageSize;
    if (image == null) return;
    setState(() {
      final ratio = scale / _scale;
      _scale = scale;
      _offset = AvatarCrop.clampOffset(_offset * ratio,
          image: image, viewport: _viewport, scale: scale);
    });
  }

  Future<void> _confirm() async {
    final image = _imageSize;
    if (image == null || _working) return;
    setState(() {
      _working = true;
      _problem = null;
    });
    try {
      final r = AvatarCrop.sourceRect(
          image: image, viewport: _viewport, scale: _scale, offset: _offset);
      final cropped = ImageEncoder.croppedAvatar(
        widget.bytes,
        x: r.left.round(),
        y: r.top.round(),
        width: r.width.round(),
        height: r.height.round(),
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop<Uint8List>(cropped);
    } on ImageDecodeException catch (e) {
      if (!mounted) return;
      setState(() {
        _working = false;
        _problem = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final image = _imageSize;
    return Scaffold(
      backgroundColor: p.paper,
      appBar: AppBar(
        backgroundColor: p.paper,
        surfaceTintColor: Colors.transparent,
        title: Text('Position your photo', style: context.heading),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(Space.xl, Space.lg, Space.xl, Space.xl),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: LayoutBuilder(builder: (context, c) {
                    final side = c.biggest.shortestSide;
                    _viewport = side;
                    if (image == null) {
                      // A still placeholder, never a spinner: reading the
                      // size takes a frame, and a looping spinner would only
                      // flash in the app and hang pumpAndSettle in tests.
                      return Container(
                        width: side,
                        height: side,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: p.accentWash),
                        child: Icon(
                          _problem != null
                              ? Icons.broken_image_outlined
                              : Icons.photo_outlined,
                          color: p.muted,
                        ),
                      );
                    }
                    final drawn = AvatarCrop.coverScale(image, side) * _scale;
                    return GestureDetector(
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      child: Container(
                        width: side,
                        height: side,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: p.accent, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: p.accentDeep.withValues(alpha: .18),
                                blurRadius: 24)
                          ],
                        ),
                        child: ClipOval(
                          child: ColoredBox(
                            color: p.accentWash,
                            child: OverflowBox(
                              maxWidth: double.infinity,
                              maxHeight: double.infinity,
                              child: Transform.translate(
                                offset: _offset,
                                child: SizedBox(
                                  width: image.width * drawn,
                                  height: image.height * drawn,
                                  child: Image.memory(widget.bytes,
                                      fit: BoxFit.fill, gaplessPlayback: true),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: Space.xl),
              // A slider as well as the pinch: pinching needs two fingers
              // and a free hand, and neither is a given.
              Row(
                children: [
                  Icon(Icons.zoom_out_rounded, size: 18, color: p.muted),
                  Expanded(
                    child: Slider(
                      key: AvatarCropScreen.zoomKey,
                      value: _scale,
                      min: AvatarCrop.minScale,
                      max: AvatarCrop.maxScale,
                      activeColor: p.accent,
                      inactiveColor: p.line,
                      semanticFormatterCallback: (v) =>
                          'Zoom ${v.toStringAsFixed(1)} times',
                      onChanged: image == null ? null : _setZoom,
                    ),
                  ),
                  Icon(Icons.zoom_in_rounded, size: 18, color: p.muted),
                ],
              ),
              Text('Drag to move, pinch or slide to zoom.',
                  style: context.caption, textAlign: TextAlign.center),
              if (_problem != null) ...[
                const SizedBox(height: Space.lg),
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
              const SizedBox(height: Space.xl),
              GradientButton(
                key: AvatarCropScreen.confirmKey,
                label: 'Use this photo',
                busy: _working,
                onPressed: image == null ? null : _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
