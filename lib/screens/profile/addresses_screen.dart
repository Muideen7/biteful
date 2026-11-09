import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../config/design_tokens.dart';
import '../../models/account.dart';
import '../../models/catalog.dart';
import '../../models/order.dart';
import '../../providers/account_providers.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/brand_field.dart';
import '../../widgets/common.dart';
import '../../widgets/gradient_button.dart';
import '../shell/tab_page.dart';

/// Saved addresses: choose where to deliver, add, edit and remove.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final list = ref.watch(addressesProvider).valueOrNull ?? const <Address>[];
    final current = ref.watch(currentAddressProvider);
    return TabPage(
      title: 'Addresses',
      subtitle: 'Tap one to deliver there',
      trailing: IconButton.filled(
        tooltip: 'Add address',
        onPressed: () => showAddressEditor(context),
        style: IconButton.styleFrom(
            backgroundColor: p.card, foregroundColor: p.accentDeep),
        icon: const Icon(Icons.add_rounded),
      ),
      slivers: [
        if (list.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              art: const FoodArt('takeout'),
              title: 'No saved addresses',
              message: 'Add one so riders know where to bring your food.',
              action: 'Add address',
              onAction: () => showAddressEditor(context),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                Space.gutter, Space.lg, Space.gutter, 0),
            sliver: SliverList.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: Space.md),
              itemBuilder: (_, i) => _AddressTile(
                  address: list[i], selected: list[i].id == current?.id),
            ),
          ),
      ],
    );
  }
}

class _AddressTile extends ConsumerWidget {
  const _AddressTile({required this.address, required this.selected});

  final Address address;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final a = address;
    return Dismissible(
      key: ValueKey(a.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        final notifier = ref.read(addressesProvider.notifier);
        notifier.remove(a.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('${a.label} removed'),
            action: SnackBarAction(
                label: 'Undo',
                textColor: p.accent,
                onPressed: () => notifier.save(a)),
          ));
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Space.xl),
        decoration: BoxDecoration(
            color: p.error, borderRadius: BorderRadius.circular(Radii.lg)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: p.card),
            const SizedBox(width: 6),
            Text('Remove',
                style: TextStyle(color: p.card, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      child: Material(
        color: selected ? p.accentWash : p.card,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.lg),
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(selectedAddressIdProvider.notifier).select(a.id);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                Space.lg, Space.md, Space.xs, Space.md),
            child: Row(
              children: [
                Icon(addressIcon(a.label), color: p.accent),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                              child: Text(a.label,
                                  style: context.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
                          if (selected) ...[
                            const SizedBox(width: Space.sm),
                            Text('Delivering here',
                                style: context.caption.copyWith(
                                    color: p.accent,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(a.line,
                          style: context.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit ${a.label}',
                  onPressed: () => showAddressEditor(context, existing: a),
                  icon: Icon(Icons.edit_outlined, color: p.muted, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData addressIcon(String label) => switch (label.toLowerCase()) {
      'home' => Icons.home_rounded,
      'work' => Icons.work_rounded,
      _ => Icons.place_rounded,
    };

/// Add a new address, or edit [existing].
Future<void> showAddressEditor(BuildContext context, {Address? existing}) =>
    showAppSheet(
      context,
      title: existing == null ? 'Add address' : 'Edit address',
      builder: (_) => _AddressEditor(existing: existing),
    );

class _AddressEditor extends ConsumerStatefulWidget {
  const _AddressEditor({this.existing});

  final Address? existing;

  @override
  ConsumerState<_AddressEditor> createState() => _AddressEditorState();
}

class _AddressEditorState extends ConsumerState<_AddressEditor> {
  late final _label = TextEditingController(text: widget.existing?.label ?? '');
  late final _line = TextEditingController(text: widget.existing?.line ?? '');
  bool _tried = false;

  static const _suggestions = ['Home', 'Work', 'Gym', 'Partner'];

  String? get _labelError =>
      _tried && _label.text.trim().isEmpty ? 'Give it a name, like Home' : null;
  String? get _lineError => _tried && _line.text.trim().length < 6
      ? 'Enter the street and area'
      : null;

  @override
  void dispose() {
    _label.dispose();
    _line.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _tried = true);
    if (_labelError != null || _lineError != null) return;
    final nav = Navigator.of(context);
    final a =
        (widget.existing ?? Address(id: Ids.next('a'), label: '', line: ''))
            .copyWith(label: _label.text.trim(), line: _line.text.trim());
    await ref.read(addressesProvider.notifier).save(a);
    if (widget.existing == null) {
      await ref.read(selectedAddressIdProvider.notifier).select(a.id);
    }
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          Space.gutter, Space.sm, Space.gutter, Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Space.sm,
            children: [
              for (final s in _suggestions)
                ChoiceChip(
                  label: Text(s),
                  selected: _label.text.trim() == s,
                  onSelected: (_) => setState(() => _label.text = s),
                  selectedColor: p.accentWash,
                  side: BorderSide(color: p.line),
                  shape: const StadiumBorder(),
                  showCheckmark: false,
                  labelStyle: context.label,
                ),
            ],
          ),
          const SizedBox(height: Space.md),
          BrandField(
            fieldKey: const Key('address-label'),
            controller: _label,
            hint: 'Name, like Home',
            icon: Icons.bookmark_outline_rounded,
            error: _labelError,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Space.md),
          BrandField(
            fieldKey: const Key('address-line'),
            controller: _line,
            hint: 'Street, area and city',
            icon: Icons.location_on_outlined,
            error: _lineError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Space.xl),
          GradientButton(
              label: widget.existing == null ? 'Save address' : 'Save changes',
              onPressed: _save),
        ],
      ),
    );
  }
}
