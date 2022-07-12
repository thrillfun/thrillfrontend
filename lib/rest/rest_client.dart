import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/auth/login.dart';
import 'app_logs.dart';


class RestClient {
  static Future getData(String url, {Map<String, String>? headers}) async {
    var result;
    Log.console('Http.Get Url: $url');

    if (headers != null) {
      Log.console('Http.Get Headers: $headers');
    }

    try {
      http.Response response = await http.get(Uri.parse(url), headers: headers);
      result = handleResponse(response);
      Log.console('Http.Get Response Code: ${response.statusCode}');
      Log.console('Http.Get Response Body: ${response.body}');
    } catch (e) {
      result = handleResponse();
      Log.console('Http.Get Error: $e');
      Log.console('Http.Get Response Body: $result');
    }
    return result;
  }

  static Future postData(String url, {Map<String,
      String>? headers, Object? body, bool skip401 = false}) async {
    var result;
    Log.console('Http.Post Url: $url');
    if (headers != null) {
      Log.console('Http.Post Headers: $headers');
    }
    if (body != null) {
      Log.console('Http.Post Body: $body');
    }

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      result = handleResponse(response, skip401);
      Log.console('Http.Post Response Code: ${response.statusCode}');
      Log.console('Http.Post Response Body: ${response.body}');
    } catch (e) {
      result = handleResponse();
      Log.console('Http.Post Error: $e');
      Log.console('Http.Post Response Body: $result');
    }

    return result;
  }

  static dynamic handleResponse(
      [http.Response? response, bool skip401 = false]) async {
    var result;
    try {
      if (response != null) {
        if (response.statusCode == 200) {
          result = jsonDecode(response.body);
        } else {
          if (response.statusCode == 401) {
            if (!skip401) {
              Future.delayed(const Duration(milliseconds: 400), () async {
                 const String routeName = '/login';
                MaterialPageRoute(
                  settings: const RouteSettings(name: routeName),
                  builder: (context) => const LoginScreen(),
                );
              });
            }
          }
          result = {'status': false, 'message': response.reasonPhrase};
        }
      } else {
        result = {'status': false, 'message': 'Unable to Connect to Server!'};
      }
    } catch (e) {
      Log.console('Handle Response Error: $e');
      result = {'status': false, 'message': 'Something went Wrong!'};
    }
    return result;
  }
}