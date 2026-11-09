/// The product name and the lines that travel with it live here, and only
/// here. Seed JSON refers to the name as `{app}`, substituted at load.
abstract final class AppBrand {
  /// The wordmark is drawn as [lead] + [accent] + [dot]: "Dish" in ink,
  /// "ly" in the brand green, then a full stop.
  static const lead = 'Dish';
  static const accent = 'ly';
  static const dot = '.';
  static const name = '$lead$accent';

  static const tagline = 'Good food, delivered fast';
  static const headerLine = 'Hot meals,\nright at your door.';
}
