import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/components/navabr.dart';
import 'package:frontend/pages/houses/housedetails.dart';
import 'package:frontend/pages/houses/edit_property.dart';

class YourProperties extends StatefulWidget {
  const YourProperties({super.key});

  @override
  State<YourProperties> createState() => _YourPropertiesState();
}

class _YourPropertiesState extends State<YourProperties> {
  final tokenstorage = const FlutterSecureStorage();
  List<dynamic> properties = [];
  bool isLoading = true;
  String? errorMessage;

  String selectedFilter = "all"; // all, rent, sale

  @override
  void initState() {
    super.initState();
    fetchUserProperties();
  }

  Future<void> fetchUserProperties() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String? token = await tokenstorage.read(key: 'token');

      if (token == null) {
        setState(() {
          errorMessage = "No authentication token found. Please login.";
          isLoading = false;
        });
        return;
      }

      final uri = Uri.parse("http://10.0.2.2:8000/fetch_user_properties");
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
          properties = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load properties: ${response.body}";
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

  @override
  Widget build(BuildContext context) {
    // Apply filters
    final filteredProperties = selectedFilter == "all"
        ? properties
        : properties.where((p) {
            final status = (p['status'] ?? '').toString().toLowerCase();
            if (selectedFilter == "rent") {
              return status.contains("rent");
            } else if (selectedFilter == "sale") {
              return status.contains("sale");
            }
            return true;
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Your Properties",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF222222)),
            onPressed: fetchUserProperties,
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
                          onPressed: fetchUserProperties,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 12),

                    // Filter Buttons
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterButton("All", "all"),
                          const SizedBox(width: 8),
                          _buildFilterButton("For Rent", "rent"),
                          const SizedBox(width: 8),
                          _buildFilterButton("For Sale", "sale"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: fetchUserProperties,
                        child: filteredProperties.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.home_outlined,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      selectedFilter == "all"
                                          ? "You don't have any properties yet"
                                          : "No properties match this filter",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: filteredProperties.length,
                                itemBuilder: (context, index) {
                                  final property = filteredProperties[index];
                                  return PropertyCard(property: property);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: const Navbar(),
    );
  }

  // Filter Button Widget
  Widget _buildFilterButton(String label, String value) {
    final isSelected = selectedFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF222222) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF222222) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF222222),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class PropertyCard extends StatefulWidget {
  final dynamic property;

  const PropertyCard({super.key, required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final tokenstorage = const FlutterSecureStorage();

  Future<void> deleteProperty() async {
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

      final uri = Uri.parse(
          "http://10.0.2.2:8000/delete_property/${widget.property['id']}");
      final response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Property deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const YourProperties()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete: ${response.body}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Property"),
          content: const Text(
              "Are you sure you want to delete this property? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteProperty();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void showEditOptions() {
    final scaffoldContext = context; // Store the parent context
    showModalBottomSheet(
      context: context,
      builder: (BuildContext modalContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF222222)),
                title: const Text("Edit Property"),
                onTap: () async {
                  Navigator.pop(modalContext);
                  final result = await Navigator.push(
                    scaffoldContext,
                    MaterialPageRoute(
                      builder: (context) => EditProperty(property: widget.property),
                    ),
                  );
                  // Refresh the page if property was updated
                  if (result == true && mounted) {
                    Navigator.of(scaffoldContext).pushReplacement(
                      MaterialPageRoute(builder: (context) => const YourProperties()),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Property",
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(modalContext);
                  showDeleteConfirmation();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse images - handle both JSON string and list
    List<String> images = [];
    final housePicture = widget.property['house_picture'];
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
    final firstImage = images.isNotEmpty ? images[0] : null;

    final status = (widget.property['status'] ?? 'N/A').toString().toLowerCase();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Housedetails(house: widget.property),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: firstImage != null
                      ? Image.network(
                          firstImage,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 280,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.home_outlined,
                            size: 60,
                            color: Colors.grey[500],
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status.contains("rent")
                          ? Colors.blue.withOpacity(0.9)
                          : Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.contains("rent") ? "For Rent" : "For Sale",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: showEditOptions,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF222222),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Property Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property['name'] ?? 'Unnamed Property',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.property['description'] ?? 'No description',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF717171),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.bed_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.property['rooms'] ?? 0} rooms',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '\$${widget.property['price']?.toStringAsFixed(0) ?? '0'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status.contains("rent") ? "/ month" : "",
                            style: const TextStyle(
                              fontSize: 14,
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
          ],
        ),
      ),
    );
  }
}