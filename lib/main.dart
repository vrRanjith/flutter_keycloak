import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initDeepLinkHandler();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void initDeepLinkHandler() {
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        handleDeepLink(Uri.parse(link));
      }
    }, onError: (err) {
      // Handle exception
      print('Error occurred while handling deep link: $err');
    });
  }

  void handleDeepLink(Uri uri) {
    if (uri.scheme == 'myapp' && uri.host == 'callback') {
      final token = uri.queryParameters['code'];

      if (token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(token: token),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Keycloak Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Login'),
              onPressed: () {
                _launchURL(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  _launchURL(BuildContext context) async {
  final url =
      'https://sso.sandbox.kezel.io/realms/kezel/protocol/openid-connect/auth?client_id=kezel&redirect_uri=http://192.168.29.242:3000/&response_type=code&scope=openid%20profile%20email';
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Register'),
              onPressed: () async {
                try {
                  final response = await Dio().post(
                    'http://localhost:8080/auth/admin/realms/myrealm/users',
                    options: Options(
                      headers: {
                        'Authorization': 'Bearer YOUR_ADMIN_ACCESS_TOKEN',
                        'Content-Type': 'application/json'
                      },
                    ),
                    data: {
                      'username': _usernameController.text,
                      'email': _emailController.text,
                      'enabled': true,
                      'credentials': [
                        {
                          'type': 'password',
                          'value': _passwordController.text,
                          'temporary': false,
                        },
                      ],
                    },
                  );
                  if (response.statusCode == 201) {
                    Navigator.pop(context);
                    // Optionally, show a success message or navigate to another screen
                  }
                } catch (error) {
                  print('Error occurred during registration: $error');
                  // Optionally, show an error message to the user
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String token;

  HomePage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Logged in with token: $token'),
      ),
    );
  }
}
