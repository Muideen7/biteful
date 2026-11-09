import 'package:dishly/models/account.dart';
import 'package:dishly/models/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('money formats cents with grouping and two decimals', () {
    expect(money(0), r'$0.00');
    expect(money(499), r'$4.99');
    expect(money(2490), r'$24.90');
    expect(money(123456789), r'$1,234,567.89');
    expect(money(-735), r'-$7.35');
  });

  test('relative times read naturally', () {
    expect(agoLabel(12), '12 min ago');
    expect(agoLabel(300), '5 h ago');
    expect(agoLabel(1500), 'Yesterday');
    expect(agoLabel(60 * 24 * 6), '6 days ago');
    expect(daysAgoLabel(0), 'Today');
  });
}
