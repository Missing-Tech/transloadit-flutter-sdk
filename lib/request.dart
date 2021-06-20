part of transloadit;

class TransloaditRequest {
  final headers = {"Transloadit-Client": "flutter-sdk:" + "0.0.1"};
  late TransloaditClient transloadit;

  TransloaditRequest(TransloaditClient transloadit) {
    this.transloadit = transloadit;
  }

  Future<TransloaditResponse> httpGet(
      {required String service,
      required String assemblyPath,
      Map<String, dynamic>? params}) async {
    final Uri uri;
    params = params ?? {};
    params = toPayload(params);

    uri = Uri.https(service, assemblyPath, params);

    Response response = await get(uri, headers: headers);

    return TransloaditResponse(response);
  }

  Future<TransloaditResponse> httpPost(
      {required String service,
      required String assemblyPath,
      Map<String, dynamic>? extraParams,
      Map<String, dynamic>? params}) async {
    final Uri uri;
    params = params ?? {};
    extraParams = extraParams ?? {};

    if (extraParams.isNotEmpty) {
      params.addAll(extraParams);
    }

    params = toPayload(params);

    uri = Uri.https(service, assemblyPath);

    Response response = await post(uri, headers: headers, body: params);

    return TransloaditResponse(response);
  }

  Map<String, dynamic>? toPayload(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return null;
    }
    DateTime expiry =
        DateTime.now().add(Duration(seconds: transloadit.duration));
    data["auth"] = {
      "key": transloadit.authKey,
      "expires": DateFormat('yyyy/MM/dd H:m:s+00:00').format(expiry)
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

  String getFullURL(String url) {
    if (url.startsWith("www")) {
      return url;
    } else {
      return transloadit.service + url;
    }
  }
}
