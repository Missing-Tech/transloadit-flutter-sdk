part of transloadit;

class TransloaditRequest {
  final headers = {"Transloadit-Client": "flutter-sdk:" + "0.0.1"};
  late TransloaditClient transloadit;

  TransloaditRequest(TransloaditClient transloadit) {
    this.transloadit = transloadit;
  }

  Future<Response> httpGet(
      String service, String assemblyPath, Map<String, dynamic> params) {
    final Uri uri;
    if (params.isEmpty)
      uri = Uri.https(service, assemblyPath);
    else
      uri = Uri.https(service, assemblyPath, toPayload(params));

    return get(uri, headers: headers);
  }

  Map<String, dynamic>? toPayload(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return null;
    }
    DateTime expiry =
        DateTime.now().add(Duration(seconds: transloadit.duration));
    data["auth"] = {
      "key": transloadit.authKey,
      "expires": DateFormat('yyyy/mm/dd H:m:s+00:00').format(expiry)
    };
    String jsonData = json.encode(data);
    return {"params": jsonData, "signature": signData(jsonData)};
  }

  String signData(message) {
    var key = utf8.encode(transloadit.authSecret);
    var bytes = utf8.encode(message);
    var hmac = Hmac(sha1, key);
    var digest = hmac.convert(bytes);

    return digest.toString();
  }
}
