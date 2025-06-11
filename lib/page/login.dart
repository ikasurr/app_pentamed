import 'package:app_pentamed/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan sudah ada di pubspec.yaml

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

  final Color backgroundColor = Color(0xFFF8F9FB); // background soft
  final Color inputColor = Colors.white;
  final Color textColor = Color(0xFF3A3D45); // abu gelap
  final Color accentColor = Color(0xFF1F3C88); // navy elegan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 40),
                _buildInputBox(
                  child: TextField(
                    controller: usernameController,
                    style: GoogleFonts.inter(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.person, color: accentColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputBox(
                  child: TextField(
                    controller: passwordController,
                    obscureText: statusPassword,
                    style: GoogleFonts.inter(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.lock, color: accentColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          statusPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: menampilkanPassword,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
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
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'LOGIN',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
