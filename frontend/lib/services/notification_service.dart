import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final tokenstorage = const FlutterSecureStorage();
  int _unreadCount = 0;
  
  int get unreadCount => _unreadCount;

  Future<void> fetchUnreadCount() async {
    try {
      String? token = await tokenstorage.read(key: 'token');
      
      if (token == null) {
        _unreadCount = 0;
        notifyListeners();
        return;
      }

      final uri = Uri.parse("http://10.0.2.2:8000/get_unread_message_count");
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _unreadCount = data['unread_count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching unread count: $e");
    }
  }

  Future<void> markConversationAsRead(int otherUserId) async {
    try {
      String? token = await tokenstorage.read(key: 'token');
      
      if (token == null) return;

      final uri = Uri.parse("http://10.0.2.2:8000/mark_conversation_as_read/$otherUserId");
      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        
        await fetchUnreadCount();
      }
    } catch (e) {
      print("Error marking conversation as read: $e");
    }
  }

  void reset() {
    _unreadCount = 0;
    notifyListeners();
  }
}
