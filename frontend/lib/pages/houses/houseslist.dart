import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/components/navabr.dart';
import 'package:frontend/pages/houses//housedetails.dart';

class HousesList extends StatefulWidget {
  const HousesList({super.key});

  @override
  State<HousesList> createState() => _HousesListState();
}

class _HousesListState extends State<HousesList> {
  final tokenstorage = const FlutterSecureStorage();
  List<dynamic> houses = [];
  bool isLoading = true;
  String? errorMessage;

  String selectedFilter = "all"; // NEW: all, rent, sale
  
  // Price range filters
  double minPrice = 0;
  double maxPrice = 1000000;
  
  // Room number filters
  int? selectedRooms; // null means all

  @override
  void initState() {
    super.initState();
    fetchHouses();
  }

  Future<void> fetchHouses() async {
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

      final uri = Uri.parse("http://10.0.2.2:8000/fetch_houses");
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
          houses = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load houses: ${response.body}";
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

  void showFilterDialog() {
    double tempMinPrice = minPrice;
    double tempMaxPrice = maxPrice;
    int? tempSelectedRooms = selectedRooms;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Filter Properties"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Price Range",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Min Price",
                              prefixText: "\$",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: tempMinPrice.toStringAsFixed(0),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null) {
                                setDialogState(() {
                                  tempMinPrice = parsed;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Max Price",
                              prefixText: "\$",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: tempMaxPrice.toStringAsFixed(0),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null) {
                                setDialogState(() {
                                  tempMaxPrice = parsed;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Number of Rooms",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: tempSelectedRooms == null,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempSelectedRooms = null;
                            });
                          },
                        ),
                        for (int i = 1; i <= 5; i++)
                          ChoiceChip(
                            label: Text("$i"),
                            selected: tempSelectedRooms == i,
                            onSelected: (selected) {
                              setDialogState(() {
                                tempSelectedRooms = i;
                              });
                            },
                          ),
                        ChoiceChip(
                          label: const Text("6+"),
                          selected: tempSelectedRooms == 6,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempSelectedRooms = 6;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      minPrice = 0;
                      maxPrice = 1000000;
                      selectedRooms = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Reset"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      minPrice = tempMinPrice;
                      maxPrice = tempMaxPrice;
                      selectedRooms = tempSelectedRooms;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Apply filters
    var filteredHouses = houses;

    // Filter by status (rent/sale)
    if (selectedFilter != "all") {
      filteredHouses = filteredHouses.where((h) {
        final status = (h['status'] ?? '').toString().toLowerCase();
        if (selectedFilter == "rent") {
          return status.contains("rent");
        } else if (selectedFilter == "sale") {
          return status.contains("sale");
        }
        return true;
      }).toList();
    }

    // Filter by price range
    filteredHouses = filteredHouses.where((h) {
      final price = (h['price'] ?? 0).toDouble();
      return price >= minPrice && price <= maxPrice;
    }).toList();

    // Filter by number of rooms
    if (selectedRooms != null) {
      filteredHouses = filteredHouses.where((h) {
        final rooms = h['rooms'] ?? 0;
        if (selectedRooms == 6) {
          return rooms >= 6;
        }
        return rooms == selectedRooms;
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Explore Properties",
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
            icon: const Icon(Icons.tune, color: Color(0xFF222222)),
            onPressed: showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF222222)),
            onPressed: fetchHouses,
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
                onPressed: fetchHouses,
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

          // Active filters indicator
          if (minPrice > 0 || maxPrice < 1000000 || selectedRooms != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (minPrice > 0 || maxPrice < 1000000)
                    Chip(
                      label: Text(
                        "Price: \$${minPrice.toStringAsFixed(0)} - \$${maxPrice.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          minPrice = 0;
                          maxPrice = 1000000;
                        });
                      },
                    ),
                  if (selectedRooms != null)
                    Chip(
                      label: Text(
                        selectedRooms == 6 ? "6+ Rooms" : "$selectedRooms Room${selectedRooms! > 1 ? 's' : ''}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          selectedRooms = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          if (minPrice > 0 || maxPrice < 1000000 || selectedRooms != null)
            const SizedBox(height: 12),

          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchHouses,
              child: filteredHouses.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No properties match your filters",
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
                itemCount: filteredHouses.length,
                itemBuilder: (context, index) {
                  final house = filteredHouses[index];
                  return HouseCard(house: house);
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
              color: isSelected ? const Color(0xFF222222) : Colors.grey.shade300,
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

class HouseCard extends StatefulWidget {
  final dynamic house;

  const HouseCard({super.key, required this.house});

  @override
  State<HouseCard> createState() => _HouseCardState();
}

class _HouseCardState extends State<HouseCard> {
  final tokenStorage = const FlutterSecureStorage();
  late bool isFavourite;
  bool isLoadingFavourite = false;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.house['is_favourite'] ?? false;
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
                isFavourite
                    ? "Added to favourites"
                    : "Removed from favourites",
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
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
    final firstImage = images.isNotEmpty ? images[0] : null;

    final status = (widget.house['status'] ?? 'N/A').toString().toLowerCase();
    
    // Owner information
    final owner = widget.house['owner'] as Map<String, dynamic>?;
    final ownerName = owner?['full_name'] ?? 'Unknown Owner';
    final ownerProfilePicture = owner?['profile_picture'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Housedetails(house: widget.house),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // House Image
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
                  child: GestureDetector(
                    onTap: isLoadingFavourite ? null : toggleFavourite,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: isLoadingFavourite
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF385C),
                                ),
                              ),
                            )
                          : Icon(
                              isFavourite ? Icons.favorite : Icons.favorite_border,
                              color: isFavourite
                                  ? const Color(0xFFFF385C)
                                  : const Color(0xFF222222),
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // House Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.house['name'] ?? 'Unnamed Property',
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
                        widget.house['description'] ?? 'No description',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF717171),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '\$${widget.house['price']?.toStringAsFixed(0) ?? '0'}',
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
                      const SizedBox(height: 8),
                      // Rooms Info
                      Row(
                        children: [
                          const Icon(
                            Icons.bed_outlined,
                            size: 16,
                            color: Color(0xFF717171),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.house['rooms'] ?? 0} ${(widget.house['rooms'] ?? 0) == 1 ? 'Room' : 'Rooms'}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF717171),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Owner Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: ownerProfilePicture.isNotEmpty
                                ? NetworkImage(ownerProfilePicture)
                                : null,
                            child: ownerProfilePicture.isEmpty
                                ? const Icon(Icons.person, size: 14, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ownerName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF717171),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
