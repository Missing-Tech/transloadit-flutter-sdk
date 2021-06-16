part of transloadit;

class TransloaditClient {
  late String service = "https://api2.transloadit.com";
  late String authKey;
  late String authSecret;
  late int duration;
  late TransloaditRequest request;

  TransloaditClient(
      {String service = "https://api2.transloadit.com",
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

  Future<int> getAssembly(
      {required String assemblyID,
      String service = '',
      String assemblyPath = '/assemblies/'}) async {
    final response =
        await request.httpGet(service, assemblyPath + assemblyID, {});
    return response.statusCode;
  }
}
