import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class MessageUser extends StatefulWidget {
  final int receiverId;
  final String receiverName;
  final String receiverImage;

  const MessageUser({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  }) : super(key: key);

  @override
  State<MessageUser> createState() => _MessageUserState();
}

class _MessageUserState extends State<MessageUser> {
  final tokenstorage = const FlutterSecureStorage();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  List<dynamic> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  int? currentUserId;
  int? editingMessageId;
  String editingMessageContent = "";
  bool isBlocked = false;
  bool theyBlockedMe = false;
  File? _selectedImage;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadMessages();
  }

  Future<void> _initializeAndLoadMessages() async {
    await _getCurrentUserId();
    await checkBlockStatus();
    await fetchMessages();
  }

  Future<void> checkBlockStatus() async {
    try {
      String? token = await tokenstorage.read(key: 'token');
      if (token == null) return;

      final uri = Uri.parse(
        "http://10.0.2.2:8000/check_block_status/${widget.receiverId}",
      );
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
          isBlocked = data['i_blocked_them'] ?? false;
          theyBlockedMe = data['they_blocked_me'] ?? false;
        });
      }
    } catch (e) {
      print("Error checking block status: $e");
    }
  }

  Future<void> blockUser() async {
    try {
      String? token = await tokenstorage.read(key: 'token');
      if (token == null) return;

      final uri = Uri.parse(
        "http://10.0.2.2:8000/block_user/${widget.receiverId}",
      );
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isBlocked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${widget.receiverName} has been blocked"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> unblockUser() async {
    try {
      String? token = await tokenstorage.read(key: 'token');
      if (token == null) return;

      final uri = Uri.parse(
        "http://10.0.2.2:8000/unblock_user/${widget.receiverId}",
      );
      final response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isBlocked = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${widget.receiverName} has been unblocked"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void showBlockOptions() {
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
                leading: Icon(
                  isBlocked ? Icons.block : Icons.block_outlined,
                  color: Colors.red,
                ),
                title: Text(isBlocked ? "Unblock User" : "Block User"),
                subtitle: Text(
                  isBlocked
                      ? "Allow ${widget.receiverName} to message you"
                      : "Stop receiving messages from ${widget.receiverName}",
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (isBlocked) {
                    unblockUser();
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Block User"),
                        content: Text(
                          "Are you sure you want to block ${widget.receiverName}? You won't be able to send or receive messages.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              blockUser();
                            },
                            child: const Text(
                              "Block",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentUserId() async {
    try {
      String? token = await tokenstorage.read(key: 'token');
      if (token == null) return;

      final uri = Uri.parse("http://10.0.2.2:8000/get_profile");
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
    
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          setState(() {
            currentUserId = int.tryParse(payload['sub'].toString());
          });
        }
      }
    } catch (e) {
      print("Error getting current user ID: $e");
    }
  }

  Future<void> fetchMessages() async {
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

      final uri = Uri.parse(
        "http://10.0.2.2:8000/get_conversation/${widget.receiverId}",
      );
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
          messages = data;
          isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          errorMessage = "Failed to load messages: ${response.body}";
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

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $e")),
        );
      }
    }
  }

  void clearSelectedImage() {
    setState(() {
      _selectedImage = null;
      _selectedImagePath = null;
    });
  }

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedImage == null) return;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to identify current user")),
      );
      return;
    }

    if (isBlocked || theyBlockedMe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBlocked
                ? "You have blocked this user. Unblock to send messages."
                : "You cannot send messages to this user.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      String? token = await tokenstorage.read(key: 'token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Authentication token not found")),
          );
        }
        setState(() {
          isSending = false;
        });
        return;
      }

      if (editingMessageId != null) {
        final uri = Uri.parse(
          "http://10.0.2.2:8000/update_message/$editingMessageId",
        );
        final request = http.MultipartRequest('PUT', uri);
        request.headers['Authorization'] = "Bearer $token";
        request.fields['new_content'] = _messageController.text.trim();

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (mounted) {
          if (response.statusCode == 200) {
            _messageController.clear();
            setState(() {
              editingMessageId = null;
              editingMessageContent = "";
            });
            await fetchMessages();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Message updated"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update: ${response.body}")),
            );
          }
        }
      } else {
     
        final uri = Uri.parse("http://10.0.2.2:8000/send_message");
        final request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = "Bearer $token";
        
        request.fields['sender_id'] = currentUserId.toString();
        request.fields['receiver_id'] = widget.receiverId.toString();
        request.fields['content'] = _messageController.text.trim();

        if (_selectedImage != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              _selectedImage!.path,
            ),
          );
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (mounted) {
          if (response.statusCode == 200) {
            _messageController.clear();
            clearSelectedImage();
            await fetchMessages();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to send: ${response.body}")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      String? token = await tokenstorage.read(key: 'token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Authentication token not found")),
          );
        }
        return;
      }

      final uri = Uri.parse("http://10.0.2.2:8000/delete_message/$messageId");
      final response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          await fetchMessages();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Message deleted"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete: ${response.body}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void startEditingMessage(int messageId, String content) {
    setState(() {
      editingMessageId = messageId;
      editingMessageContent = content;
      _messageController.text = content;
    });
  }

  void cancelEditing() {
    setState(() {
      editingMessageId = null;
      editingMessageContent = "";
      _messageController.clear();
    });
  }

  void showMessageOptions(int messageId, String content) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF222222)),
                title: const Text("Edit Message"),
                onTap: () {
                  Navigator.pop(context);
                  startEditingMessage(messageId, content);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Delete Message",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Message"),
                        content: const Text(
                          "Are you sure you want to delete this message?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              deleteMessage(messageId);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'profile_${widget.receiverId}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2E7FD8).withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: widget.receiverImage.isNotEmpty
                      ? NetworkImage(widget.receiverImage)
                      : null,
                  child: widget.receiverImage.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7FD8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF2E7FD8),
                  size: 20,
                ),
              ),
              onPressed: fetchMessages,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7FD8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF2E7FD8),
                  size: 20,
                ),
              ),
              onPressed: showBlockOptions,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2E7FD8),
                      ),
                      strokeWidth: 3,
                    ),
                  )
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
                            onPressed: fetchMessages,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  )
                : messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start the conversation!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message['is_mine'] ?? false;
                      final content = message['content'] ?? '';
                      final imageUrl = message['image_url'];
                      final sentAt = message['sent_at'] ?? '';
                      final messageId = message['id'];

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: isMe
                              ? () => showMessageOptions(messageId, content)
                              : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFF2E7FD8)
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe
                                    ? const Radius.circular(16)
                                    : const Radius.circular(4),
                                bottomRight: isMe
                                    ? const Radius.circular(4)
                                    : const Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (imageUrl != null && imageUrl.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              backgroundColor: Colors.black,
                                              child: Stack(
                                                children: [
                                                  InteractiveViewer(
                                                    child: Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.pop(context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          imageUrl,
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              width: MediaQuery.of(context).size.width * 0.5,
                                              height: 200,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: MediaQuery.of(context).size.width * 0.5,
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.broken_image),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                if (content.isNotEmpty)
                                  Text(
                                    content,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isMe
                                          ? Colors.white
                                          : const Color(0xFF222222),
                                      height: 1.4,
                                    ),
                                  ),
                                if (sentAt.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _formatTime(sentAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isMe
                                            ? Colors.white.withOpacity(0.8)
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (editingMessageId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.amber[50],
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Editing message",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF222222),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: cancelEditing,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                if (_selectedImage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Image selected",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: clearSelectedImage,
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: (!isBlocked && !theyBlockedMe && editingMessageId == null)
                              ? pickImage
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (!isBlocked && !theyBlockedMe && editingMessageId == null)
                                  ? const Color(0xFF2E7FD8).withOpacity(0.1)
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.image,
                              color: (!isBlocked && !theyBlockedMe && editingMessageId == null)
                                  ? const Color(0xFF2E7FD8)
                                  : Colors.grey,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              enabled: !isBlocked && !theyBlockedMe,
                              decoration: InputDecoration(
                                hintText: isBlocked
                                    ? "Unblock to send messages"
                                    : theyBlockedMe
                                    ? "Cannot send messages"
                                    : editingMessageId != null
                                    ? "Edit your message..."
                                    : "Type a message...",
                                border: InputBorder.none,
                                hintStyle: const TextStyle(
                                  color: Color(0xFF717171),
                                  fontSize: 15,
                                ),
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: (isSending || isBlocked || theyBlockedMe)
                              ? null
                              : sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (isSending || isBlocked || theyBlockedMe)
                                  ? Colors.grey[400]
                                  : const Color(0xFF2E7FD8),
                              shape: BoxShape.circle,
                            ),
                            child: isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    editingMessageId != null
                                        ? Icons.check
                                        : Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        return "$hour:$minute";
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
      } else {
        return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      }
    } catch (e) {
      return "";
    }
  }
}
