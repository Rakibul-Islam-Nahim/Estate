import 'package:flutter/material.dart';

class DarkSignInPage extends StatelessWidget {
  const DarkSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/realState.jpg"),fit: BoxFit.fill),
        ),
        child: Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 20),
                const Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.email, color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text("Dont have an account?", style: TextStyle(color:Colors.white),),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
