import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../config/motion.dart';
import '../../models/account.dart';
import '../../providers/account_providers.dart';
import '../../widgets/app_sheet.dart';

Future<void> showNotificationsSheet(BuildContext context) =>
    showAppSheet(context, builder: (_) => const _NotificationList());

/// Tap opens a notification (and so marks it read). Marking it unread again
/// is the rarer action, offered once it is open.
class _NotificationList extends ConsumerStatefulWidget {
  const _NotificationList();

  @override
  ConsumerState<_NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends ConsumerState<_NotificationList> {
  String? _open;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);
    final marks = ref.read(readMarksProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Space.gutter, Space.sm, Space.sm, Space.sm),
          child: Row(
            children: [
              Expanded(child: Text('Notifications', style: context.heading)),
              if (unread > 0)
                TextButton(
                  onPressed: () => marks.markAll(items.map((n) => n.id)),
                  child: Text('Mark all read',
                      style: TextStyle(
                          color: p.accent, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.lg),
            itemCount: items.length,
            itemBuilder: (_, i) => _Tile(
              n: items[i],
              open: _open == items[i].id,
              onTap: () {
                setState(
                    () => _open = _open == items[i].id ? null : items[i].id);
                if (!items[i].read) marks.mark(items[i].id, read: true);
              },
              onMarkUnread: () {
                marks.mark(items[i].id, read: false);
                setState(() => _open = null);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(
      {required this.n,
      required this.open,
      required this.onTap,
      required this.onMarkUnread});

  final AppNotification n;
  final bool open;
  final VoidCallback onTap;
  final VoidCallback onMarkUnread;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.md),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration:
                  BoxDecoration(color: p.accentWash, shape: BoxShape.circle),
              child: Icon(Icons.delivery_dining_rounded,
                  color: p.accent, size: 20),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: AnimatedSize(
                duration: Motion.short,
                curve: Motion.enter,
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: context.title.copyWith(
                          fontWeight:
                              n.read ? FontWeight.w600 : FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.body,
                      style: context.body.copyWith(fontSize: 13),
                      maxLines: open ? null : 2,
                      overflow: open ? null : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(agoLabel(n.minutesAgo), style: context.caption),
                        const Spacer(),
                        if (open && n.read)
                          GestureDetector(
                            onTap: onMarkUnread,
                            child: Text('Mark unread',
                                style: context.caption.copyWith(
                                    color: p.accent,
                                    fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!n.read)
              Padding(
                padding: const EdgeInsets.only(left: Space.sm, top: 6),
                child: Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: p.accent, shape: BoxShape.circle)),
              ),
          ],
        ),
      ),
    );
  }
}
