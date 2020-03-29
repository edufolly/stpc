import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'Config.dart';

///
///
///
class MetricHttpClient extends BaseClient {
  final Client _inner;

  ///
  ///
  ///
  MetricHttpClient(
    this._inner,
  );

  ///
  ///
  ///
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    StreamedResponse response;
    response = await _inner.send(request);
    return response;
  }

  ///
  ///
  ///
  static Future<Map<String, dynamic>> doCall({
    @required String endpoint,
    String method = 'GET',
    int timeout,
    bool log = true,
  }) async {
    try {
      Config _config = Config();

      timeout = 30000;

      if (!endpoint.startsWith('/')) {
        endpoint = '/$endpoint';
      }

      MetricHttpClient client = MetricHttpClient(Client());

      String url = '${_config.endpoint}$endpoint';

      Map<String, dynamic> body = {
//        'apiKey': _config.apiKey,
        'method': method,
        'url': url,
      };

      if (_config.debug) print(url);
      if (_config.debug) print(body);

      Response response = await client
          .post(
            _config.parser,
            body: json.encode(body),
          )
          .timeout(
            Duration(milliseconds: timeout),
          );

      if (_config.debug) print('Response Status Code: ${response.statusCode}');
      if (_config.debug && log) debugPrint(response.body, wrapWidth: 1024);

      Map<String, dynamic> data = json.decode(response.body);

      client.close();

      return data;
    } catch (exception, stack) {
      print(exception);
      print(stack);
      rethrow;
    }
  }
}

///
///
///
class MetricHttpException implements Exception {
  final String message;

  const MetricHttpException(this.message);

  @override
  String toString() => message;
}
