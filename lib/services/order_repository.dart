import '../config/app_timing.dart';
import '../models/order.dart';

/// Placing an order. The basket itself is local state; only checkout talks
/// to the service.
abstract interface class OrderRepository {
  /// Returns the reference shown on the confirmation.
  Future<String> place(List<CartLine> lines, {String? dealCode});
}

class DemoOrderRepository implements OrderRepository {
  DemoOrderRepository({Duration? latency}) : _latency = latency;

  final Duration? _latency;
  int _counter = 0;

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
//   Future<String> place(List<CartLine> lines, {String? dealCode}) async {
//     final r = await _dio.post('/orders', data: {
//       'lines': [for (final l in lines) l.toJson()],
//       'dealCode': dealCode,
//     });
//     return r.data['reference'] as String;
//   }
// }
