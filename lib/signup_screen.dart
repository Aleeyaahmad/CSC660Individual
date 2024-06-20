import 'package:flutter/material.dart';
import 'package:aleeyadiary/database_helper.dart';
import 'package:aleeyadiary/home_screen.dart';

class SignupScreen extends StatelessWidget {
  final DatabaseHelper dbHelper;

  SignupScreen({required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFABCDDE),
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Color(0xFFABCDDE),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SignupForm(dbHelper: dbHelper),
        ),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  final DatabaseHelper dbHelper;

  SignupForm({required this.dbHelper});

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signup() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter username and password.');
    } else {
      Map<String, dynamic>? user = await widget.dbHelper.getUser(username);
      if (user != null) {
        _showErrorDialog('Username already exists. Please choose another.');
      } else {
        await widget.dbHelper.insertUser({'username': username, 'password': password});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(user: {'username': username})),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/logo.png'), // Replace with your image path
          ),
          SizedBox(height: 20.0),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              labelStyle: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              labelStyle: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(height: 16.0),
          SizedBox(
            height: 50.0,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signup,
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFEA7D70)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
