part of transloadit;

/// Object representation of a new Template
class TransloaditTemplate extends TransloaditOptions {
  /// Reference to Transloadit client
  late TransloaditClient client;

  /// Name of the Template.
  late String name;

  TransloaditTemplate(
      {required TransloaditClient client,
      required String name,
      Map<String, dynamic>? options})
      : super(options: options) {
    this.client = client;
    this.name = name;
  }

  /// Creates the Template using the options specified.
  Future<TransloaditResponse> createTemplate() async {
    final data = super.options;
    Map<String, dynamic> dataCopy = {};
    dataCopy.update("name", (value) => name, ifAbsent: () => name);
    dataCopy["template"] = data;
    TransloaditResponse response = await client.request.httpPost(
        service: client.service, assemblyPath: "/templates", params: dataCopy);

    return response;
  }
}
