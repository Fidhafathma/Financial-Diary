import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:myfirstapp/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _pinController = TextEditingController();
  String _enteredPin = '';
  final String correctPin = '1234'; // Change this to the actual user PIN

  @override
  void initState() {
    super.initState();
    _authenticateWithBiometrics(); // Try fingerprint on start
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Monexo',
        options: const AuthenticationOptions(
          biometricOnly: true, // Use fingerprint/face only
          stickyAuth: true,
        ),
      );
      if (isAuthenticated) {
        _navigateToHome();
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric auth error: $e');
    }
  }

  void _onDigitPressed(String digit) {
    setState(() {
      if (_enteredPin.length < 4) {
        _enteredPin += digit;
      }
      if (_enteredPin.length == 4) {
        if (_enteredPin == correctPin) {
          _navigateToHome();
        } else {
          _enteredPin = '';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect PIN, try again!')),
          );
        }
      }
    });
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 255, 255, 255), // Top Left color
                  Color.fromARGB(255, 255, 255, 255), // Bottom Right color
                ],
              ),
            ),
          ),

          // Overlay Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Name
              const Text(
                'Enter The Pin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 41, 11, 238),
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // PIN Input Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length
                          ? Color.fromARGB(255, 41, 11, 238)
                          : const Color.fromARGB(77, 162, 159, 162),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Number Pad
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  String buttonText;
                  if (index < 9) {
                    buttonText = '${index + 1}';
                  } else if (index == 9) {
                    buttonText = '←'; // Delete button
                  } else if (index == 10) {
                    buttonText = '0';
                  } else {
                    buttonText = '✔'; // Confirm
                  }

                  return GestureDetector(
                    onTap: () {
                      if (buttonText == '←') {
                        setState(() {
                          if (_enteredPin.isNotEmpty) {
                            _enteredPin = _enteredPin.substring(
                                0, _enteredPin.length - 1);
                          }
                        });
                      } else if (buttonText == '✔') {
                        if (_enteredPin.length == 4) {
                          if (_enteredPin == correctPin) {
                            _navigateToHome();
                          } else {
                            setState(() {
                              _enteredPin = '';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Incorrect PIN, try again!')),
                            );
                          }
                        }
                      } else {
                        _onDigitPressed(buttonText);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            Color.fromARGB(255, 41, 11, 238).withOpacity(0.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 253, 253, 253),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Fingerprint Icon
              GestureDetector(
                onTap: _authenticateWithBiometrics,
                child: const Icon(Icons.fingerprint,
                    size: 50, color: Color.fromARGB(255, 41, 11, 238)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Use Fingerprint',
                style: TextStyle(color: Color.fromARGB(255, 41, 11, 238)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
