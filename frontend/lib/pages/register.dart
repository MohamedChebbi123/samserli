import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/pages/login.dart';
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? _imageFile;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a profile picture")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var uri = Uri.parse("http://10.0.2.2:8000/register_new_user"); // change to your API URL
      var request = http.MultipartRequest("POST", uri);

      request.fields['first_name'] = firstnameController.text.trim();
      request.fields['last_name'] = lastnameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['password'] = passwordController.text.trim();
      request.fields['phone_number'] = phoneController.text.trim();

      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        _imageFile!.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User registered successfully")),
        );
      } else {
        final respStr = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}\n$respStr")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Page"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // First Name
              TextFormField(
                controller: firstnameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                (value == null || value.trim().length < 6)
                    ? "First name must be at least 6 characters"
                    : null,
              ),
              const SizedBox(height: 16),

              // Last Name
              TextFormField(
                controller: lastnameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                (value == null || value.trim().length < 6)
                    ? "Last name must be at least 6 characters"
                    : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@') || !value.contains('.')) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Enter your password"
                    : null,
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                (value == null || value.trim().length < 8)
                    ? "Phone number must be at least 8 digits"
                    : null,
              ),
              const SizedBox(height: 24),

              // Register Button
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: registerUser,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Register"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, // ✅ no parentheses around context
                    MaterialPageRoute(
                      builder: (context) => const Login(), // 👈 your target page
                    ),
                  );
                },
                child: const Text('Go to Second Page'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
