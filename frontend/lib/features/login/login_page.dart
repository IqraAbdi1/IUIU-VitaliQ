import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/login/login_controller.dart'; // adjust path if needed

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: Scaffold(
        backgroundColor: Colors.lightGreen[100], // Full screen green
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Consumer<LoginController>(
                builder: (context, controller, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo on top
                    Image.asset(
                      'assets/images/System Logo.png',
                      height: 120,
                    ),
                    const SizedBox(height: 30),

                    // Registration Number
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Registration Number',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: controller.updateRegistration,
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                      onChanged: controller.updatePassword,
                    ),
                    const SizedBox(height: 20),

                    // Error message
                    if (controller.errorMessage.isNotEmpty)
                      Text(
                        controller.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 20),

                    // Login button
                    ElevatedButton(
                      onPressed: controller.login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.brown[700],
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}