part of transloadit;

/// Transloadit tailored HTTP Request object.
class TransloaditRequest {
  /// Request headers to be used globally.
  final headers = {"Transloadit-Client": "flutter-sdk:" + "0.0.1"};

  /// An instance of the Transloadit class.
  late TransloaditClient transloadit;

  TransloaditRequest(TransloaditClient transloadit) {
    this.transloadit = transloadit;
  }

  /// Makes a HTTP GET request.
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

  /// Makes a HTTP POST request.
  Future<TransloaditResponse> httpPost(
      {required String service,
      required String assemblyPath,
      Map<String, dynamic>? extraParams,
      Map<String, dynamic>? params}) async {
    final Uri uri;
    params = params ?? {};
    extraParams = extraParams ?? {};

    params = toPayload(params);

    if (extraParams.isNotEmpty) {
      params!.addAll(extraParams);
    }

    uri = Uri.https(service, assemblyPath);

    Response response = await post(uri, headers: headers, body: params);

    return TransloaditResponse(response);
  }

  /// Converts data into a payload format, with necessary fluff required for Transloadit.
  Map<String, dynamic>? toPayload(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return null;
    }
    DateTime expiry =
        DateTime.now().add(Duration(seconds: transloadit.duration));

    data["auth"] = {
      "key": transloadit.authKey,
      "expires": DateFormat('yyyy/MM/dd HH:mm:ss+00:00').format(expiry)
    };
    String jsonData = json.encode(data);
    return {"params": jsonData, "signature": signData(jsonData)};
  }

  /// Creates a signature for the data.
  String signData(message) {
    var key = utf8.encode(transloadit.authSecret);
    var bytes = utf8.encode(message);
    var hmac = Hmac(sha1, key);
    var digest = hmac.convert(bytes);

    return digest.toString();
  }
}
