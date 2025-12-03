import 'package:flutter/material.dart';
import 'package:frontend/pages/houses/message_user.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Housedetails extends StatefulWidget {
  final Map<String, dynamic> house;

  const Housedetails({Key? key, required this.house}) : super(key: key);

  @override
  State<Housedetails> createState() => _HousedetailsState();
}

class _HousedetailsState extends State<Housedetails> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  final tokenStorage = const FlutterSecureStorage();
  late bool isFavourite;
  bool isLoadingFavourite = false;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.house['is_favourite'] ?? false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> toggleFavourite() async {
    setState(() {
      isLoadingFavourite = true;
    });

    try {
      String? token = await tokenStorage.read(key: 'token');
      if (token == null) return;

      final houseId = widget.house['id'];
      final uri = isFavourite
          ? Uri.parse("http://10.0.2.2:8000/remove_from_favourites/$houseId")
          : Uri.parse("http://10.0.2.2:8000/add_to_favourites/$houseId");

      final response = isFavourite
          ? await http.delete(
              uri,
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            )
          : await http.post(
              uri,
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
            );

      if (response.statusCode == 200) {
        setState(() {
          isFavourite = !isFavourite;
          isLoadingFavourite = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFavourite ? "Added to favourites" : "Removed from favourites",
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          isLoadingFavourite = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingFavourite = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = [];
    final housePicture = widget.house['house_picture'];
    if (housePicture != null) {
      if (housePicture is String) {
        try {
          final decoded = jsonDecode(housePicture);
          images = List<String>.from(decoded);
        } catch (e) {
          print('Error decoding images: $e');
          images = [];
        }
      } else if (housePicture is List) {
        images = List<String>.from(housePicture);
      }
    }

    final String name = widget.house['name'] ?? 'Unnamed';
    final String status = widget.house['status'] ?? 'unknown';
    final String description = widget.house['description'] ?? '';
    final price = widget.house['price'] ?? '';
    final int rooms = widget.house['rooms'] ?? 0;

    final Map<String, dynamic> owner = widget.house['owner'] ?? {};
    final String ownerName = owner['full_name'] ?? 'you ';
    final String ownerEmail = owner['email'] ?? '';
    final String ownerPhone = owner['phone_number'] ?? '';
    final String ownerImage = owner['profile_picture'] ?? '';
    final int? ownerId = owner['user_id'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1A1A1A),
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: isFavourite
                      ? const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF2E7FD8)],
                        )
                      : null,
                  color: isFavourite ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isFavourite
                          ? const Color(0xFF2E7FD8).withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFavourite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavourite ? Colors.white : const Color(0xFF1A1A1A),
                  size: 20,
                ),
              ),
              onPressed: isLoadingFavourite ? null : toggleFavourite,
            ),
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
                                  value:
                                      progress.cumulativeBytesLoaded /
                                      (progress.expectedTotalBytes ?? 1),
                                  color: const Color(0xFF2E7FD8),
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
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
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
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
                    description.isEmpty
                        ? "No description available."
                        : description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF222222),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),

                  const Text(
                    "Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Color(0xFF717171),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lat: ${widget.house['latitude']}, Long: ${widget.house['longitude']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF717171),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.house['latitude'] is String
                                ? double.tryParse(widget.house['latitude']) ??
                                      0.0
                                : (widget.house['latitude'] ?? 0.0).toDouble(),
                            widget.house['longitude'] is String
                                ? double.tryParse(widget.house['longitude']) ??
                                      0.0
                                : (widget.house['longitude'] ?? 0.0).toDouble(),
                          ),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('property_location'),
                            position: LatLng(
                              widget.house['latitude'] is String
                                  ? double.tryParse(widget.house['latitude']) ??
                                        0.0
                                  : (widget.house['latitude'] ?? 0.0)
                                        .toDouble(),
                              widget.house['longitude'] is String
                                  ? double.tryParse(
                                          widget.house['longitude'],
                                        ) ??
                                        0.0
                                  : (widget.house['longitude'] ?? 0.0)
                                        .toDouble(),
                            ),
                            infoWindow: InfoWindow(
                              title: name,
                              snippet: status,
                            ),
                          ),
                        },
                        zoomControlsEnabled: true,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        liteModeEnabled: false,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),

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
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: ownerImage.isNotEmpty
                              ? NetworkImage(ownerImage)
                              : null,
                          child: ownerImage.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),

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
                        backgroundColor: const Color(0xFF2E7FD8),
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
