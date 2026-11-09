import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/motion.dart';
import '../providers/core_providers.dart';

/// Rebuilds [builder] with the current time every [every], so a live order's
/// status and minutes-left move on their own. The timer only runs while
/// ambient motion is on, so tests and reduce-motion get a still screen.
class Ticking extends ConsumerStatefulWidget {
  const Ticking(
      {super.key,
      required this.builder,
      this.every = const Duration(seconds: 15)});

  final Widget Function(BuildContext context, DateTime now) builder;
  final Duration every;

  @override
  ConsumerState<Ticking> createState() => _TickingState();
}

class _TickingState extends ConsumerState<Ticking> {
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (Motion.loops(context)) {
      _timer = Timer.periodic(widget.every, (_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, ref.watch(clockProvider)());
}
