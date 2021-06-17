import 'package:flutter_test/flutter_test.dart';
import 'package:transloadit/auth/keys.dart';
import 'package:transloadit/transloadit.dart';

void main() {
  test('loading secrets', () async {
    //TODO
    Future<Secret> futureSecret =
        SecretLoader(secretPath: "./lib/auth/test.json").load();
    Secret secret = await futureSecret;
    futureSecret.then((value) => expect(value.apikey, 'test'));
  });

  test('get assembly id', () async {
    TransloaditClient client = TransloaditClient(
        authKey: '72a70fba93ce41cba617cfd7c2a44b1a',
        authSecret: '3b2845e9330051ed3adc06b4217c42e4f504f8f3');
    int code = await client.getAssembly(
        assemblyID: '0fcea03d1cc14b8abfea28db5e377428');

    expect(code, 200);
  });
}
