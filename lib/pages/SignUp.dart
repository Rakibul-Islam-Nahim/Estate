import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class signup extends StatelessWidget {
  const signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/realState.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_open_outlined,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _userName(),
                const SizedBox(height: 15),
                _address(),
                const SizedBox(height: 15),
                _emailField(),
                const SizedBox(height: 15),
                _passwordField(),
                const SizedBox(height: 15),
                _confirmPass(),
                const SizedBox(height: 15),
                _naviagtorText(context),
                const SizedBox(height: 10),
                _loginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  RichText _naviagtorText(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "Already Have an Account? ",
        style: TextStyle(color: Colors.white),
        children: [
          TextSpan(
            text: " Sign In",
            style: TextStyle(color: Colors.tealAccent),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, '/');
              },
          ),
        ],
      ),
    );
  }

  TextField _confirmPass() {
    return TextField(
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Confirm Password",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  TextField _address() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Address",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.location_city, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  TextField _userName() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "User Name",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.person, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  SizedBox _loginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  TextField _passwordField() {
    return TextField(
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  TextField _emailField() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Email",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.email, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
