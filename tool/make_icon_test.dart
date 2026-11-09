// Draws the app icon from the rider's own geometry (lib/widgets/rider/
// rider_painter.dart), so the icon and the in-app art can never drift.
//   flutter test tool/make_icon_test.dart && python3 tool/make_icons.py
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dishly/config/palette.dart';
import 'package:dishly/widgets/rider/rider_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('icon master', () async {
    const s = 1024.0;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    const p = Palette.light;
    // No alpha anywhere: iOS rejects icons with transparency.
    c.drawRect(
      const Rect.fromLTWH(0, 0, s, s),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.headerTop, p.headerBottom],
        ).createShader(const Rect.fromLTWH(0, 0, s, s)),
    );
    // A soft pale disc behind the rider, like the blob in the app.
    c.drawCircle(const Offset(s * .52, s * .5), s * .36,
        Paint()..color = const Color(0xFFE7F3C9));
    const w = s * .86;
    final h = w * RiderPainter.design.height / RiderPainter.design.width;
    c.save();
    c.translate((s - w) / 2 + s * .01, (s - h) / 2 + s * .03);
    RiderPainter(phase: .12, showBlob: false).paint(c, Size(w, h));
    c.restore();
    final img = await rec.endRecording().toImage(s.toInt(), s.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory('assets/brand').createSync(recursive: true);
    File('assets/brand/icon_1024.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
