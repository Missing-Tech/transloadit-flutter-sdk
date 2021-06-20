part of transloadit;

class TransloaditAssembly extends Options {
  late TransloaditClient client;
  late Map<String, XFile> files;
  Map<String, dynamic>? _options;

  TransloaditAssembly(
      {required TransloaditClient client,
      Map<String, XFile>? files,
      Map<String, dynamic>? options})
      : super(options: options ?? {}) {
    this._options = options ?? {};
    this.client = client;
    this.files = files ?? {};
  }

  void addFile({required File file, String? fieldName}) {
    fieldName = fieldName ?? getFieldName();
    files[fieldName] = XFile(file.path);
  }

  String getFieldName() {
    String name = "file";
    if (!files.containsKey(name)) {
      return name;
    }
    int counter = 1;
    while (files.containsKey("${name}_$counter")) {
      counter++;
    }
    return "${name}_$counter";
  }

  Future<void> tusUpload(String assemblyURL, String tusURL) async {
    if (files.isNotEmpty) {
      for (var key in files.keys) {
        final metadata = {
          "assembly_url": assemblyURL,
          "fieldname": key,
          "filename": files[key]!.name
        };
        final client = TusClient(Uri.parse(tusURL), files[key]!,
            metadata: metadata, maxChunkSize: 5 * 1024 * 1024);

        await client.upload();
      }
    }
  }

  //TODO: make resumable
  Future<TransloaditResponse> createAssembly({bool wait = false}) async {
    final data = super.options;
    final extraData = {"tus_num_expected_upload_files": files.length};
    TransloaditResponse response = await client.request.httpPost(
        service: client.service,
        assemblyPath: "/assemblies",
        params: data,
        extraParams: extraData);

    tusUpload(response.data["assembly_ssl_url"], response.data["tus_url"]);

    while (!isAssemblyFinished(response)) {
      final url = response.data["assembly_ssl_url"].toString();
      final assemblyID = url.substring(url.lastIndexOf('/') + 1);

      response = await client.getAssembly(assemblyID: assemblyID);
    }

    return response;
  }

  bool isAssemblyFinished(TransloaditResponse response) {
    final status = response.data["ok"];
    bool isAborted = status == "REQUEST_ABORTED";
    bool isCancelled = status == "ASSEMBLY_CANCELED";
    bool isCompleted = status == "ASSEMBLY_COMPLETED";
    bool isFailed = response.data["error"].toString().isNotEmpty;
    return isAborted || isCancelled || isCompleted || isFailed;
  }
}
