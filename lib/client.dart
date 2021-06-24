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

  /// Gets a Transloadit assembly from an [assemblyID] or [assemblyURL]
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

  /// Gets a list of Transloadit assemblies
  Future<TransloaditResponse> listAssemblies(
      {Map<String, dynamic>? params}) async {
    final response = await request.httpGet(
        service: service, params: {}, assemblyPath: "/assemblies");
    return response;
  }

  /// Creates an Assembly object with optional [params].
  TransloaditAssembly newAssembly({Map<String, dynamic>? params}) {
    params = params ?? {};

    return TransloaditAssembly(client: this, options: params);
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

  /// Attempts to recover the input files and retry the execution of an Assembly
  /// Specify [params] to change details of the Assembly
  /// https://transloadit.com/docs/api/#supported-keys-inside-the-params-field
  Future<TransloaditResponse> replayAssembly(
      {required String assemblyID, Map<String, dynamic>? params}) {
    params = params ?? {};

    String url = 'assemblies/$assemblyID/replay';
    return request.httpPost(service: service, assemblyPath: url);
  }

  /// Creates an Template object with optional [params].
  TransloaditTemplate newTemplate(
      {required String name, Map<String, dynamic>? params}) {
    params = params ?? {};

    return TransloaditTemplate(name: name, options: params, client: this);
  }

  /// Creates an Assembly object from a template.
  TransloaditAssembly assemblyFromTemplate(
      {required String templateID, Map<String, dynamic>? params}) {
    Map<String, dynamic> options = {'template_id': templateID};
    params = params ?? {};
    options.addAll(params);
    return TransloaditAssembly(client: this, options: options);
  }

  /// Gets a Transloadit template from a [templateID]
  Future<TransloaditResponse> getTemplate({
    required String templateID,
  }) async {
    final response = await request.httpGet(
        service: service, assemblyPath: "/templates/$templateID");
    return response;
  }

  /// Updates a Transloadit template from a [templateID]
  /// [merge] is still being implemented (does nothing currently)
  Future<TransloaditResponse> updateTemplate(
      {required String templateID,
      required Map<String, dynamic> template,
      Map<String, dynamic>? params,
      bool merge = false}) async {
    params = params ?? {};

    Map<String, dynamic> templateCopy = {};
    templateCopy["steps"] = template;
    params["template"] = templateCopy;

    // TODO: Implement instruction merging
    // if (merge) {
    //   Map<String, dynamic> currentInstructions = {};
    //   getCurrentInstructions(templateID)
    //       .then((value) => currentInstructions = value);
    //   for (var key in template.keys) {}
    //   print(currentInstructions);
    // }

    final response = await request.httpPut(
        service: service,
        assemblyPath: "/templates/$templateID",
        params: params);
    return response;
  }

  /// Gets the current instructions of a template
  Future<Map<String, dynamic>> getCurrentInstructions(String templateID) async {
    TransloaditResponse response = await getTemplate(templateID: templateID);
    return response.data["content"];
  }

  /// Deletes a Template of a given [templateID ].
  Future<TransloaditResponse> deleteTemplate({
    required String templateID,
  }) async {
    return request.httpDelete(
        service: service, assemblyPath: 'templates/$templateID');
  }
}
