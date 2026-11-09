import '../config/app_timing.dart';
import '../models/order.dart';
import 'seed.dart';

/// Placing an order. The basket itself is local state; only checkout talks
/// to the service.
abstract interface class OrderRepository {
  /// Orders placed before this session, newest first.
  Future<List<Order>> history();

  /// Returns the reference shown on the confirmation.
  Future<String> place(List<CartLine> lines, {String? dealCode});
}

class DemoOrderRepository implements OrderRepository {
  /// [firstLaunch] turns the seed's ages ("3 minutes ago") into dates, so
  /// seeded orders age like real ones and never go stale.
  DemoOrderRepository(this._seed,
      {required this.firstLaunch, Duration? latency})
      : _latency = latency;

  final Seed _seed;
  final DateTime firstLaunch;
  final Duration? _latency;
  int _counter = 0;

  @override
  Future<List<Order>> history() async =>
      [for (final s in _seed.orders) s.stampedAt(firstLaunch)];

  @override
  Future<String> place(List<CartLine> lines, {String? dealCode}) async {
    await AppTiming.wait(_latency ?? AppTiming.placeOrder);
    // A counter as well as the clock: two orders in one millisecond must
    // still get different references.
    _counter++;
    final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
    return 'DL-${stamp.toString().padLeft(5, '0')}$_counter';
  }
}

// class RemoteOrderRepository implements OrderRepository {
//   RemoteOrderRepository(this._dio);
//   final Dio _dio;
//
//   @override
//   Future<List<Order>> history() async =>
//       [for (final j in (await _dio.get('/me/orders')).data) Order.fromJson(j)];
//
//   @override
//   Future<String> place(List<CartLine> lines, {String? dealCode}) async {
//     final r = await _dio.post('/orders', data: {
//       'lines': [for (final l in lines) l.toJson()],
//       'dealCode': dealCode,
//     });
//     return r.data['reference'] as String;
//   }
// }
