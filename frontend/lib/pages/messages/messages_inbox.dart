import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/houses/message_user.dart';
import 'package:frontend/services/notification_service.dart';

class MessagesInbox extends StatefulWidget {
  const MessagesInbox({Key? key}) : super(key: key);

  @override
  State<MessagesInbox> createState() => _MessagesInboxState();
}

class _MessagesInboxState extends State<MessagesInbox> {
  final tokenstorage = const FlutterSecureStorage();
  final NotificationService _notificationService = NotificationService();
  
  List<dynamic> conversations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String? token = await tokenstorage.read(key: 'token');

      if (token == null) {
        setState(() {
          errorMessage = "No authentication token found";
          isLoading = false;
        });
        return;
      }

      final uri = Uri.parse("http://10.0.2.2:8000/get_all_conversations");
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          conversations = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load conversations: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  void openConversation(int userId, String userName, String userImage) async {
    await _notificationService.markConversationAsRead(userId);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageUser(
          receiverId: userId,
          receiverName: userName,
          receiverImage: userImage,
        ),
      ),
    ).then((_) {
      fetchConversations();
    });
  }

  Future<void> blockUser(int userId, String userName) async {
    try {
      String? token = await tokenstorage.read(key: 'token');
      if (token == null) return;

      final uri = Uri.parse("http://10.0.2.2:8000/block_user/$userId");
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$userName has been blocked"),
            backgroundColor: Colors.green,
          ),
        );
        fetchConversations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to block user"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> unblockUser(int userId, String userName) async {
    try {
      String? token = await tokenstorage.read(key: 'token');
      if (token == null) return;

      final uri = Uri.parse("http://10.0.2.2:8000/unblock_user/$userId");
      final response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$userName has been unblocked"),
            backgroundColor: Colors.green,
          ),
        );
        fetchConversations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to unblock user"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, bool>> checkBlockStatus(int userId) async {
    try {
      String? token = await tokenstorage.read(key: 'token');
      if (token == null) return {"i_blocked_them": false, "they_blocked_me": false};

      final uri = Uri.parse("http://10.0.2.2:8000/check_block_status/$userId");
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "i_blocked_them": data['i_blocked_them'] ?? false,
          "they_blocked_me": data['they_blocked_me'] ?? false,
        };
      }
    } catch (e) {
      print("Error checking block status: $e");
    }
    return {"i_blocked_them": false, "they_blocked_me": false};
  }

  void showConversationOptions(int userId, String userName, String userImage) async {
    final blockStatus = await checkBlockStatus(userId);
    final iBlocked = blockStatus['i_blocked_them'] ?? false;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Color(0xFF222222)),
                title: const Text("Open Conversation"),
                onTap: () {
                  Navigator.pop(context);
                  openConversation(userId, userName, userImage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF222222)),
                title: const Text("Edit Last Message"),
                subtitle: const Text("Go to chat to edit your messages"),
                onTap: () {
                  Navigator.pop(context);
                  openConversation(userId, userName, userImage);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  iBlocked ? Icons.block : Icons.block_outlined,
                  color: Colors.red,
                ),
                title: Text(iBlocked ? "Unblock User" : "Block User"),
                subtitle: Text(
                  iBlocked 
                    ? "Allow $userName to message you"
                    : "Stop receiving messages from $userName"
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (iBlocked) {
                    unblockUser(userId, userName);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Block User"),
                        content: Text("Are you sure you want to block $userName? You won't receive messages from them."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              blockUser(userId, userName);
                            },
                            child: const Text("Block", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Color(0xFF222222)),
                title: const Text("About Messages"),
                subtitle: const Text("Long-press your messages in chat to edit or delete"),
                enabled: false,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF222222)),
            onPressed: fetchConversations,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: fetchConversations,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7FD8),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No messages yet",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Start a conversation with property owners",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchConversations,
                      color: const Color(0xFF2E7FD8),
                      child: ListView.builder(
                        itemCount: conversations.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          final userId = conversation['user_id'];
                          final userName = conversation['user_name'] ?? 'Unknown User';
                          final userImage = conversation['user_image'] ?? '';
                          final lastMessage = conversation['last_message'] ?? '';
                          final lastMessageTime = conversation['last_message_time'] ?? '';
                          final isLastMessageMine = conversation['is_last_message_mine'] ?? false;
                          final unreadCount = conversation['unread_count'] ?? 0;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => openConversation(userId, userName, userImage),
                              onLongPress: () => showConversationOptions(userId, userName, userImage),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage: userImage.isNotEmpty
                                              ? NetworkImage(userImage)
                                              : null,
                                          child: userImage.isEmpty
                                              ? const Icon(Icons.person, size: 28, color: Colors.grey)
                                              : null,
                                        ),
                                        if (unreadCount > 0)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2E7FD8),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 20,
                                                minHeight: 20,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  userName,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF222222),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatTime(lastMessageTime),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              if (isLastMessageMine) ...[
                                                Icon(
                                                  Icons.done_all,
                                                  size: 16,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                              ],
                                              Expanded(
                                                child: Text(
                                                  lastMessage,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      onPressed: () => showConversationOptions(userId, userName, userImage),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return "";
    
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return "Just now";
      } else if (difference.inHours < 1) {
        return "${difference.inMinutes}m";
      } else if (difference.inDays == 0) {
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        return "$hour:$minute";
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else if (difference.inDays < 7) {
        return "${difference.inDays}d";
      } else {
        return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      }
    } catch (e) {
      return "";
    }
  }
}
