import 'package:flutter/material.dart';
import 'package:frontend/pages/houses/message_user.dart';
import 'dart:convert';

class Housedetails extends StatefulWidget {
  final Map<String, dynamic> house;

  const Housedetails({Key? key, required this.house}) : super(key: key);

  @override
  State<Housedetails> createState() => _HousedetailsState();
}

class _HousedetailsState extends State<Housedetails> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parse images - handle both JSON string and list
    List<String> images = [];
    final housePicture = widget.house['house_picture'];
    if (housePicture != null) {
      if (housePicture is String) {
        // If it's a JSON string, decode it
        try {
          final decoded = jsonDecode(housePicture);
          images = List<String>.from(decoded);
        } catch (e) {
          print('Error decoding images: $e');
          images = [];
        }
      } else if (housePicture is List) {
        // If it's already a list, use it directly
        images = List<String>.from(housePicture);
      }
    }
    
    final String name = widget.house['name'] ?? 'Unnamed';
    final String status = widget.house['status'] ?? 'unknown';
    final String description = widget.house['description'] ?? '';
    final price = widget.house['price'] ?? '';
    final int rooms = widget.house['rooms'] ?? 0;
    
    // Owner information
    final Map<String, dynamic> owner = widget.house['owner'] ?? {};
    final String ownerName = owner['full_name'] ?? 'Unknown Owner';
    final String ownerEmail = owner['email'] ?? '';
    final String ownerPhone = owner['phone_number'] ?? '';
    final String ownerImage = owner['profile_picture'] ?? '';
    final int? ownerId = owner['user_id'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF222222)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF222222)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final url = images[index];
                        return Image.network(
                          url,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: progress.cumulativeBytesLoaded /
                                      (progress.expectedTotalBytes ?? 1),
                                  color: const Color(0xFFFF385C),
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Page indicators
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            images.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            else
              Container(
                height: 300,
                color: Colors.grey[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "No images available",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF222222),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${price is num ? price.toStringAsFixed(0) : price}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status.toLowerCase().contains("rent") ? "/ month" : "",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF717171),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Rooms Information
                  Row(
                    children: [
                      const Icon(
                        Icons.bed_outlined,
                        size: 20,
                        color: Color(0xFF717171),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$rooms ${rooms == 1 ? 'Room' : 'Rooms'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF222222),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  const Text(
                    "About this place",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description.isEmpty ? "No description available." : description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF222222),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Owner Information Section
                  const Text(
                    "Property Owner",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        // Owner profile picture
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: ownerImage.isNotEmpty 
                            ? NetworkImage(ownerImage)
                            : null,
                          child: ownerImage.isEmpty
                            ? const Icon(Icons.person, size: 30, color: Colors.grey)
                            : null,
                        ),
                        const SizedBox(width: 16),
                        
                        // Owner details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ownerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF222222),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (ownerEmail.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 14,
                                      color: Color(0xFF717171),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        ownerEmail,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF717171),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              if (ownerPhone.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 14,
                                      color: Color(0xFF717171),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ownerPhone,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF717171),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: ownerId != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageUser(
                                    receiverId: ownerId,
                                    receiverName: ownerName,
                                    receiverImage: ownerImage,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF385C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        "Contact Owner",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}