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
    String _assemblyID = getAssemblyID(assemblyID, assemblyURL);

    final response = await request.httpGet(
        service: service, assemblyPath: "/assemblies/$_assemblyID");
    return response;
  }

  /// Gets a list of Transloadit assemblies
  Future<TransloaditResponse> listAssemblies(
      {Map<String, dynamic>? params}) async {
    final response = await request.httpGet(
        service: service, params: params, assemblyPath: "/assemblies");
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
    String _assemblyID = getAssemblyID(assemblyID, assemblyURL);

    String url = 'assemblies/$_assemblyID';
    return request.httpDelete(service: service, assemblyPath: url);
  }

  /// Attempts to recover the input files and retry the execution of an Assembly
  /// Specify [params] to change details of the Assembly
  /// https://transloadit.com/docs/api/#supported-keys-inside-the-params-field
  Future<TransloaditResponse> replayAssembly(
      {required String assemblyID, Map<String, dynamic>? params}) {
    params = params ?? {};

    String url = '/assemblies/$assemblyID/replay';
    return request.httpPost(
        service: service, assemblyPath: url, params: params);
  }

  /// Utility function to get the assembly ID either from the one supplied or from a URL
  String getAssemblyID(String assemblyID, String assemblyURL) {
    String _assemblyID = assemblyID;

    if (assemblyID.isEmpty && assemblyURL.isEmpty) {
      throw Exception('Either assemblyID or assemblyURL cannot be empty.');
    }

    if (assemblyURL.isNotEmpty) {
      // Retrieves the Assembly ID from
      _assemblyID = assemblyURL.substring(assemblyURL.lastIndexOf('/') + 1);
    }

    return _assemblyID;
  }

  /// Replays an Assembly Notification of a given [assemblyID]
  Future<TransloaditResponse> replayAssemblyNotification(
      {required String assemblyID, Map<String, dynamic>? params}) {
    params = params ?? {};

    String url = '/assembly_notifications/$assemblyID/replay';
    return request.httpPost(
        service: service, assemblyPath: url, params: params);
  }

  /// Retrieves a list of recent Assembly Notifications
  Future<TransloaditResponse> getAssemblyNotifications(
      {Map<String, dynamic>? params}) {
    params = params ?? {};

    String url = '/assembly_notifications';
    return request.httpGet(service: service, assemblyPath: url, params: params);
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
      Map<String, dynamic>? params}) async {
    params = params ?? {};

    Map<String, dynamic> templateCopy = {};
    templateCopy["steps"] = template;
    params["template"] = templateCopy;

    final response = await request.httpPut(
        service: service,
        assemblyPath: "/templates/$templateID",
        params: params);

    return response;
  }

  /// Deletes a Template of a given [templateID].
  Future<TransloaditResponse> deleteTemplate({
    required String templateID,
  }) async {
    return request.httpDelete(
        service: service, assemblyPath: 'templates/$templateID');
  }

  /// Gets the bill for a given [date]
  /// Example response body: https://transloadit.com/docs/api/#response
  Future<TransloaditResponse> getBill({required DateTime date}) async {
    final String dateString = DateFormat('yyyy-MM').format(date);
    final response = await request.httpGet(
        service: service, assemblyPath: "/bill/$dateString");
    return response;
  }

  /// Retrieves the sum of priority job slots that are currently in use in the [count] field of the response
  Future<TransloaditResponse> getJobSlots() async {
    final response = await request.httpGet(
        service: service, assemblyPath: "/queues/job_slots");
    return response;
  }
}
