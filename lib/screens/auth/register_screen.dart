import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kidNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  @override
  void dispose() {
    _kidNameController.dispose();
    _fatherNameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String kidName = _kidNameController.text.trim();

    try {
      // 1️⃣ Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      // 2️⃣ Update display name
      if (user != null) await user.updateDisplayName(kidName);

      // 3️⃣ Save user data in Firestore
      await _firestore.collection("users").doc(user!.uid).set({
        "kidName": kidName,
        "fatherName": _fatherNameController.text.trim(),
        "gender": _genderController.text.trim(),
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
        "role": "student", // optional role field
      }).timeout(
        const Duration(seconds: 5),
        onTimeout: () => debugPrint("⚠️ Firestore write timed out"),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! You can now log in.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "Email already in use";
          break;
        case 'weak-password':
          message = "Password is too weak";
          break;
        case 'invalid-email':
          message = "Invalid email address";
          break;
        case 'operation-not-allowed':
          message = "Email/Password authentication not enabled";
          break;
        default:
          message = e.message ?? "Unknown error";
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Student Register',
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register',
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 30),
                _buildInputField(controller: _kidNameController, label: "Kid's Name", hintText: "Enter kid's name"),
                const SizedBox(height: 20),
                _buildInputField(controller: _fatherNameController, label: "Father Name", hintText: "Enter father's name"),
                const SizedBox(height: 20),
                _buildGenderDropdown(),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _emailController,
                  label: "Email",
                  hintText: "Enter email",
                  keyboardType: TextInputType.emailAddress,
                  isEmail: true,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _passwordController,
                  label: "Password",
                  hintText: "Enter password",
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  hintText: "Confirm your password",
                  obscureText: true,
                  isConfirmPassword: true,
                ),
                const SizedBox(height: 50),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA1E3A1),
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Register',
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool isEmail = false,
    bool isConfirmPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "$label is required";
            if (isEmail && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return "Enter a valid email";
            if (isConfirmPassword && value != _passwordController.text) return "Passwords do not match";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _genderController.text.isEmpty ? null : _genderController.text,
          items: ['Male', 'Female'].map((gender) {
            return DropdownMenuItem(value: gender, child: Text(gender));
          }).toList(),
          onChanged: (value) => _genderController.text = value ?? '',
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          validator: (value) => value == null || value.isEmpty ? "Gender is required" : null,
        ),
      ],
    );
  }
}
