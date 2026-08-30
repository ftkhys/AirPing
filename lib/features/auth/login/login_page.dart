import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Left side
            Expanded(
              child: Container(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 250),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Continuing with Google
                        SizedBox(
                          width: 300,
                          height: 42,
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle sign up action
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/google.png',
                                  width: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25),

                        // Divider
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Divider(color: Colors.grey, thickness: 1),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Or continue with username/email',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Divider(color: Colors.grey, thickness: 1),
                            ),
                          ],
                        ),

                        SizedBox(height: 15),

                        // Email
                        SizedBox(
                          width: 300,
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: Image.asset(
                                'assets/icons/griddy-icons_email.png',
                                width: 18,
                              ),
                              hintText: 'Email',
                              hintStyle: TextStyle(fontSize: 12),
                              enabledBorder: UnderlineInputBorder(),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Password
                        SizedBox(
                          width: 300,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    prefixIcon: Image.asset(
                                      'assets/icons/carbon_password.png',
                                      width: 18,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    hintText: 'Password',
                                    hintStyle: TextStyle(fontSize: 12),
                                    enabledBorder: UnderlineInputBorder(),
                                  ),
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  // Handle forgot password action
                                },
                                child: Text(
                                  'Forgot?',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),

                        // Sign in
                        SizedBox(
                          width: 300,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle sign in action
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),

                        SizedBox(height: 12),

                        // Remember me
                        Row(
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (value) {
                                // Handle remember me action
                              },
                            ),
                            Text('Remember me', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Right side
            Expanded(
              child: Container(
                color: Colors.white,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/Air Ping.png', width: 300),

                          SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/Remind Your Mind!.png',
                                width: 200,
                              ),

                              SizedBox(width: 10),
                              Image.asset(
                                'assets/images/glyphs-poly_bell.png',
                                width: 45,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Back arrow
                    Positioned(
                      bottom: 50,
                      right: 70,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
