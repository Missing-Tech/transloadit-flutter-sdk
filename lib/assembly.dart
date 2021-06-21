part of transloadit;

/// Object representation of a new Assembly to be created.
class TransloaditAssembly extends Options {
  /// An instance of the Transloadit class.
  late TransloaditClient client;

  /// Storage of files to be uploaded. Each file is stored with a key corresponding to its field name when it is being uploaded.
  late Map<String, XFile> files;

  /// Params to send along with the assembly. Please see https://transloadit.com/docs/api-docs/#21-create-a-new-assembly for available options.
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

  /// Add a file to be uploaded along with the Assembly.
  void addFile({required File file, String? fieldName}) {
    fieldName = fieldName ?? getFieldName();
    files[fieldName] = XFile(file.path);
  }

  /// Creates a unique field-name for each file.
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

  /// Uploads files to the Assembly via the Tus protocol.
  Future<void> tusUpload(String assemblyURL, String tusURL) async {
    Map<String, String> metadata = {"assembly_url": assemblyURL};
    if (files.isNotEmpty) {
      for (var key in files.keys) {
        metadata["fieldname"] = key;
        metadata["filename"] = basename(files[key]?.name ?? '');

        TusClient client = TusClient(Uri.parse(tusURL), files[key]!,
            metadata: metadata, maxChunkSize: 10 * 1024 * 1024);

        client.upload(onProgress: (progress) {
          //TODO: Expose progress to be used in widgets
        });
      }
    }
  }

  /// Creates the Assembly using the options specified.
  Future<TransloaditResponse> createAssembly() async {
    final data = super.options;
    final extraData = {
      "tus_num_expected_upload_files": files.length.toString()
    };
    TransloaditResponse response = await client.request.httpPost(
        service: client.service,
        assemblyPath: "/assemblies",
        params: data,
        extraParams: extraData);

    await tusUpload(
        response.data["assembly_ssl_url"], response.data["tus_url"]);

    while (!isAssemblyFinished(response)) {
      final url = response.data["assembly_ssl_url"].toString();
      final assemblyID = url.substring(url.lastIndexOf('/') + 1);

      response = await client.getAssembly(assemblyID: assemblyID);
    }

    return response;
  }

  /// Not sure what this one does..
  bool isAssemblyFinished(TransloaditResponse response) {
    final status = response.data["ok"];
    bool isAborted = status == "REQUEST_ABORTED";
    bool isCancelled = status == "ASSEMBLY_CANCELED";
    bool isCompleted = status == "ASSEMBLY_COMPLETED";
    bool isFailed = response.data["error"] ?? false;
    return isAborted || isCancelled || isCompleted || isFailed;
  }
}
