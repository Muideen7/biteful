/// Record and file ids.
///
/// `DateTime.now().millisecondsSinceEpoch` alone is not unique: two records
/// made in the same millisecond collide. A counter is appended, so an id is
/// still readable in stored JSON and sorts roughly by creation time, but
/// cannot repeat within a session.
abstract final class Ids {
  static int _counter = 0;

  /// `<prefix>_<millis>_<n>`, e.g. `o_1762500000000_3`.
  static String next(String prefix) =>
      '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${_counter++}';

  /// A filename-safe stamp, for media whose name already carries its
  /// entity and id.
  static String stamp() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
}
