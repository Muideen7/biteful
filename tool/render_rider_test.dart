// Renders the rider to PNG for visual review: flutter test tool/render_rider_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dishly/widgets/rider/rider_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('render rider poses', () async {
    final out = Platform.environment['OUT'] ?? 'build/rider.png';
    const w = 960.0, h = 400.0;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.drawRect(const Rect.fromLTWH(0, 0, w * 2, h),
        Paint()..color = const Color(0xFFF2F4EC));
    RiderPainter(phase: .1, speed: 1).paint(c, const Size(w / 2, h));
    c.translate(w / 2, 0);
    c.drawRect(const Rect.fromLTWH(0, 0, w / 2, h),
        Paint()..color = const Color(0xFF5E8F2B));
    RiderPainter(phase: .3, pose: RiderPose.waving)
        .paint(c, const Size(w / 2, h));
    final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File(out).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
