import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fiba_3x3/services/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key, required this.onVerified});

  final VoidCallback onVerified;

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool _isLoading = false;
  String? _error;

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  void _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _error = "Please enter the full 6-digit code.");
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authService = AuthService();
    final error = await authService.verifyEmailCode(code);

    setState(() {
      _isLoading = false;
      _error = error;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email verified successfully.")),
      );
      widget.onVerified();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOtpComplete = _controllers.every((c) => c.text.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Verify Your Email"),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Enter the 6-digit code sent to your email",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  height: 64,
                  width: 50,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    onChanged: (pin) {
                      if (pin.length == 1 && index < 5) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_focusNodes[index + 1]);
                      } else if (pin.isEmpty && index > 0) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_focusNodes[index - 1]);
                      }
                    },
                    onFieldSubmitted: (_) {
                      if (index == 5) _verifyOtp();
                    },
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white54,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white12,
                      hintText: "-",
                      hintStyle: const TextStyle(color: Colors.white38),
                    ),
                    enableInteractiveSelection: false,
                    enableSuggestions: false,
                    autocorrect: false,
                    cursorColor: Colors.white,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (!_isLoading && isOtpComplete) ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 3,
                        ),
                      )
                      : const Text(
                        "Verify",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final error = await AuthService().sendVerificationCode();
                if (error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Verification code resent')),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $error')));
                }
              },
              child: Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
