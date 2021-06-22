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
  Future<TransloaditResponse> getAssembly({
    String assemblyID = '',
    String assemblyURL = '',
  }) async {
    String _assemblyID = assemblyID;

    if (assemblyID.isEmpty && assemblyURL.isEmpty) {
      throw Exception('Either assemblyID or assemblyURL cannot be empty.');
    }

    if (assemblyURL.isNotEmpty) {
      _assemblyID = assemblyURL.substring(assemblyURL.lastIndexOf('/') + 1);
    }

    final response = await request.httpGet(
        service: service, params: {}, assemblyPath: "/assemblies/$_assemblyID");
    return response;
  }

  /// Creates an Assembly object with optional parameters.
  TransloaditAssembly createAssembly({Map<String, dynamic>? params}) {
    params = params ?? {};

    return TransloaditAssembly(client: this, options: params);
  }

  /// Creates an Assembly object from a template.
  TransloaditAssembly runTemplate(
      {required String templateID, Map<String, dynamic>? params}) {
    Map<String, dynamic> options = {'template_id': templateID};
    params = params ?? {};
    options.addAll(params);
    return TransloaditAssembly(client: this, options: options);
  }

  /// Cancels a running Assembly.
  Future<TransloaditResponse> cancelAssembly({
    String assemblyID = '',
    String assemblyURL = '',
  }) async {
    String _assemblyID = assemblyID;

    if (assemblyID.isEmpty && assemblyURL.isEmpty) {
      throw Exception('Either assemblyID or assemblyURL cannot be empty.');
    }

    if (assemblyURL.isNotEmpty) {
      _assemblyID = assemblyURL.substring(assemblyURL.lastIndexOf('/') + 1);
    }

    String url = 'assemblies/$_assemblyID';
    return request.httpDelete(service: service, assemblyPath: url);
  }
}
