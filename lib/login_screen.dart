import 'package:flutter/material.dart';
import 'package:aleeyadiary/database_helper.dart';
import 'package:aleeyadiary/home_screen.dart';
import 'package:aleeyadiary/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFABCDDE),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: LoginForm(dbHelper: dbHelper),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final DatabaseHelper dbHelper;

  LoginForm({required this.dbHelper});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter username and password.');
    } else {
      Map<String, dynamic>? user = await widget.dbHelper.getUser(username);
      if (user == null) {
        _showErrorDialog('User not found. Please sign up.');
      } else if (user['password'] == password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
        );
      } else {
        _showErrorDialog('Incorrect password. Please try again.');
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
              onPressed: _login,
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF7D8BE0)),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Creating New Account?',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            height: 50.0,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen(dbHelper: widget.dbHelper)),
                );
              },
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
