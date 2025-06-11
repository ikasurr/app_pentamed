import 'package:app_pentamed/auth_service.dart';

import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool statusPassword = true;
  bool isLoading = false;

  menampilkanPassword() {
    setState(() {
      statusPassword = !statusPassword;
    });
  }

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: 'username',
              hintText: 'enter your username',
            ),
          ),
          TextField(
            obscureText: statusPassword,
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'enter your password',
              suffixIcon: IconButton(
                onPressed: () {
                  menampilkanPassword();
                },
                icon: statusPassword
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await AuthService().login(
                usernameController.text,
                passwordController.text,
                context,
              );
              setState(() {
                isLoading = false;
              });
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
