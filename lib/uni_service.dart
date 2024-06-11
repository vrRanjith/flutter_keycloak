import 'package:flutter/material.dart';
import 'package:flutter_keycloak/context_utility.dart';
import 'package:flutter_keycloak/main.dart';
import 'package:uni_links/uni_links.dart';

class UniServices {
  static String _code = "";
  static String get code => _code;
  static bool get hasCode => _code.isNotEmpty;

  static void reset() => _code = '';

  static Future<void> init() async {
    try {
      final Uri? uri = await getInitialUri();
      if (uri != null) {
        _handleUri(uri); // Modified: Calls _handleUri to handle the initial URI
      }
    } on FormatException catch (e) {
      print("Wrong format code received");
    }

    // Modified: Listens for incoming URI links
    uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        _handleUri(uri); // Modified: Calls _handleUri to handle the incoming URI
      }
    }, onError: (error) {
      print("OnUriLink Error: $error");
    });
  }

  // Modified: Function to handle the received URI
  static void _handleUri(Uri uri) {
    if (uri.queryParameters.isEmpty) return;

    String receivedCode = uri.queryParameters['code'] ?? '';

    if (receivedCode.isNotEmpty) {
      _code = receivedCode;
      Navigator.push(
        ContextUtility.context!,
        MaterialPageRoute(
          builder: (context) => HomePage(token: _code),
        ),
      );
    } else {
      Navigator.push(
        ContextUtility.context!,
        MaterialPageRoute(
          builder: (context) => RegistrationPage(),
        ),
      );
    }
  }
}
