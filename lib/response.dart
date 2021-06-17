part of transloadit;

class TransloaditResponse {
  /// Dictionary representation of the returned JSON data.
  late Map<String, dynamic> _data;

  /// HTTP response status code
  late int _statusCode;

  /// Dictionary representation of the headers returned from the server.
  late Map<String, String> _headers;

  /// Constructor function to create a TransloaditResponse from a Response
  TransloaditResponse(Response response) {
    _data = jsonDecode(response.body);
    _statusCode = response.statusCode;
    _headers = response.headers;
  }

  /// Return the http status code of the request.
  int get statusCode {
    return _statusCode;
  }

  /// Return the body of the response
  Map<String, dynamic> get data {
    return _data;
  }

  /// Return the response headers.
  Map<String, dynamic> get headers {
    return _headers;
  }
}
