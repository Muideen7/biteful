import 'catalog.dart';

enum DealKind { percent, flat, freeDelivery }

class Deal {
  const Deal({
    required this.id,
    required this.code,
    required this.eyebrow,
    required this.headline,
    required this.kind,
    required this.value,
    required this.minSpendCents,
    required this.art,
    required this.terms,
  });

  final String id;
  final String code;
  final String eyebrow;
  final String headline;
  final DealKind kind;

  /// Percent for [DealKind.percent], cents for [DealKind.flat], unused for
  /// free delivery.
  final int value;
  final int minSpendCents;
  final FoodArt art;
  final String terms;

  factory Deal.fromJson(Map<String, dynamic> j) => Deal(
        id: j['id'] as String,
        code: j['code'] as String,
        eyebrow: j['eyebrow'] as String,
        headline: j['headline'] as String,
        kind: DealKind.values.byName(j['kind'] as String),
        value: j['value'] as int,
        minSpendCents: j['minSpendCents'] as int,
        art: FoodArt.fromJson(j['art'] as Map<String, dynamic>),
        terms: j['terms'] as String,
      );
}
