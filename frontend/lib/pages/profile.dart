import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final tokenStorage = const FlutterSecureStorage();

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      String? token = await tokenStorage.read(key: 'token');
      if (token == null) throw Exception("No token found, please login");

      final uri = Uri.parse("http://10.0.2.2:8000/get_profile");
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load profile: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("No profile data")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  userData!['profile_picture'] ?? "https://via.placeholder.com/150"),
            ),
            const SizedBox(height: 24),

            ListTile(
              title: const Text("First Name"),
              subtitle: Text(userData!['first_name']),
            ),
            ListTile(
              title: const Text("Last Name"),
              subtitle: Text(userData!['last_name']),
            ),
            ListTile(
              title: const Text("Email"),
              subtitle: Text(userData!['email']),
            ),
            ListTile(
              title: const Text("Phone Number"),
              subtitle: Text(userData!['phone_number']),
            ),
          ],
        ),
      ),
    );
  }
}
