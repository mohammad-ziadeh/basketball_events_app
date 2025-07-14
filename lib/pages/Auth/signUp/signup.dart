import 'package:fiba_3x3/pages/Auth/signUp/email_verification_page.dart';
import 'package:fiba_3x3/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class StepOnePage extends StatefulWidget {
  final VoidCallback onNext;

  const StepOnePage({super.key, required this.onNext});
  @override
  _StepOnePageState createState() => _StepOnePageState();
}

class _StepOnePageState extends State<StepOnePage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _moreFieldsKey = GlobalKey();

  bool _showMoreFields = false;
  bool _isSubmitting = false;

  String? _gender;
  DateTime? _selectedDate;

  final List<String> _genders = ['male', 'female'];

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  InputDecoration _styledInput(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF757575)),
      errorStyle: const TextStyle(color: Colors.red),
      errorBorder: authOutlineInputBorder.copyWith(
        borderSide: const BorderSide(color: Colors.red),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: authOutlineInputBorder,
      enabledBorder: authOutlineInputBorder,
      focusedBorder: authOutlineInputBorder.copyWith(
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  Future<bool> _submitSignup() async {
    final authService = AuthService();

    final String birthDate =
        _selectedDate?.toIso8601String().split('T').first ?? '';
    final String role = 'player';

    final errorMessage = await authService.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      gender: _gender ?? '',
      birthDate: birthDate,
      role: role,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (errorMessage == null) {
      final sendCodeError = await authService.sendVerificationCode();
      if (sendCodeError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(sendCodeError)));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => EmailVerificationPage(
                  onVerified: () {
                    Navigator.pop(context);
                    widget.onNext();
                  },
                ),
          ),
        );
      }

      return true;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return false;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Enter your personal details to continue",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 48),

                          TextFormField(
                            controller: _firstNameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: _styledInput(
                              "First Name",
                              hintText: "Enter your first name",
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter your first name'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _lastNameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: _styledInput(
                              "Last Name",
                              hintText: "Enter your last name",
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter your last name'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField2<String>(
                            isExpanded: true,
                            decoration: _styledInput(
                              "Gender",
                              hintText: "Select your gender",
                            ),
                            hint: const Text(
                              'Gender',
                              style: TextStyle(color: Color(0xFF757575)),
                            ),
                            items:
                                _genders
                                    .map(
                                      (gender) => DropdownMenuItem<String>(
                                        value: gender,
                                        child: Text(
                                          gender,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            value: _gender,
                            onChanged: (val) => setState(() => _gender = val),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select your gender'
                                        : null,
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          const SizedBox(height: 16),

                          InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: _styledInput("Date of Birth"),
                              child: Text(
                                _selectedDate == null
                                    ? "Select date"
                                    : "${_selectedDate!.toLocal()}".split(
                                      ' ',
                                    )[0],
                                style: TextStyle(
                                  color:
                                      _selectedDate == null
                                          ? const Color(0xFF757575)
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _showMoreFields = true);
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  Scrollable.ensureVisible(
                                    _moreFieldsKey.currentContext!,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Next: Account Info"),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_downward),
                              ],
                            ),
                          ),

                          if (_showMoreFields) ...[
                            const SizedBox(height: 38),
                            Container(
                              key: _moreFieldsKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _phoneController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: _styledInput(
                                      "Phone Number",
                                      hintText: "Enter your phone number",
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator:
                                        (value) =>
                                            value == null || value.isEmpty
                                                ? 'Please enter your phone number'
                                                : null,
                                  ),
                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: _emailController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: _styledInput(
                                      "Email",
                                      hintText: "Enter your email",
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator:
                                        (value) =>
                                            value == null || value.isEmpty
                                                ? 'Please enter your email'
                                                : null,
                                  ),
                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: _passwordController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: _styledInput(
                                      "Password",
                                      hintText: "Enter your password",
                                    ),
                                    obscureText: true,
                                    validator:
                                        (value) =>
                                            value == null || value.length < 6
                                                ? 'Password must be at least 6 characters'
                                                : null,
                                  ),
                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: _styledInput(
                                      "Confirm Password",
                                      hintText: "Re-enter your password",
                                    ),
                                    obscureText: true,
                                    validator:
                                        (value) =>
                                            value != _passwordController.text
                                                ? 'Passwords do not match'
                                                : null,
                                  ),
                                  const SizedBox(height: 32),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed:
                                            _isSubmitting
                                                ? null
                                                : () async {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    FocusScope.of(
                                                      context,
                                                    ).unfocus();
                                                    setState(() {
                                                      _isSubmitting = true;
                                                    });

                                                    await _submitSignup();

                                                    setState(() {
                                                      _isSubmitting = false;
                                                    });
                                                  }
                                                },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(150, 48),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(16),
                                            ),
                                          ),
                                        ),
                                        child:
                                            _isSubmitting
                                                ? const SizedBox(
                                                  width: 24,

                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.black,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                                : const Text("Submit"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

const OutlineInputBorder authOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(color: Color(0xFF757575)),
);
