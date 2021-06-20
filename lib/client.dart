part of transloadit;

/// This class serves as a client interface to the Transloadit API.
class TransloaditClient {
  /// URL of the Transloadit API.
  late String service = "api2.transloadit.com";

  /// Transloadit auth key.
  late String authKey;

  /// Transloadit auth secret.
  late String authSecret;

  /// How long in seconds for which a Transloadit request should be valid.
  late int duration;

  /// An instance of the Transloadit HTTP Request object.
  late TransloaditRequest request;

  /// Client constructor
  TransloaditClient(
      {String service = "api2.transloadit.com",
      required String authKey,
      required String authSecret,
      int duration = 300,
      TransloaditRequest? request}) {
    var pattern = RegExp('^(http|https)://');
    service.replaceAll(pattern, '');

    this.service = service;
    this.authKey = authKey;
    this.authSecret = authSecret;
    this.duration = duration;
    this.request = TransloaditRequest(this);
  }

  /// Gets a Transloadit assembly from an ID
  Future<TransloaditResponse> getAssembly(
      {required String assemblyID,
      String serviceURL = '',
      String assemblyPath = '/assemblies/'}) async {
    if (service.isEmpty) {
      serviceURL = service;
    }
    final response = await request.httpGet(
        service: service, params: {}, assemblyPath: assemblyPath + assemblyID);
    return response;
  }

  TransloaditAssembly createAssembly({Map<String, dynamic>? params}) {
    params = params ?? {};

    return TransloaditAssembly(client: this, options: params);
  }
}
