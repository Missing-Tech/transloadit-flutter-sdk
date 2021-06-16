import 'package:flutter_test/flutter_test.dart';
import 'package:transloadit/transloadit.dart';

void main() {
  test('test', () {
    expect(calculate(4, 6), 10);
    expect(calculate(2, 4), 6);
    expect(calculate(1, -4), -3);
  });
}
