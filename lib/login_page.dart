  import 'package:flutter/material.dart';
  import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
  import 'database_helper.dart';
  import 'main_page.dart';
  import 'supervisor_page.dart';

  class LoginPage extends StatefulWidget {
    const LoginPage({Key? key}) : super(key: key);

    @override
    _LoginPageState createState() => _LoginPageState();
  }

  class _LoginPageState extends State<LoginPage> {
    late String nfcId = '';
    final dbHelper = DatabaseHelper();
    final TextEditingController _idController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    void _startScanning() async {
      try {
        NFCTag tag = await FlutterNfcKit.poll();
        if (!mounted) return;
        setState(() {
          nfcId = tag.id;
          _checkNfcId();
        });
      } catch (e) {
        debugPrint("Error reading NFC: $e");
      }
    }

    void _checkNfcId() async {
      final user = await dbHelper.getUserByNfcId(nfcId);
      if (!mounted) return;
      if (user.isNotEmpty) {
        String name = user[0]['name'];
        if (user[0]['role'] == 'employee') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage(nfcId: nfcId, name: name)),
          );
        } else if (user[0]['role'] == 'supervisor') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SupervisorPage(name: name)),
          );
        }
      } else {
        debugPrint('NFC ID tidak dikenal');
      }
    }

    void _loginManually() async {
      String manualId = _idController.text;
      String password = _passwordController.text;
      if (dbHelper.checkManualLogin(manualId, password)) {
        final user = await dbHelper.getUserByManualId(manualId); 
        if (user != null) {
          String name = user['name'];
          String nfcId = user['nfcId']; 
          if (user['role'] == 'employee') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainPage(nfcId: nfcId, name: name)),
            );
          } else if (user['role'] == 'supervisor') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupervisorPage(name: name)),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid ID or Password')),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('NFC Login'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(nfcId.isNotEmpty ? "NFC ID: $nfcId" : "Scan NFC untuk login"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startScanning,
                child: const Text('Mulai Scan NFC'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: _loginManually,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }
  }
