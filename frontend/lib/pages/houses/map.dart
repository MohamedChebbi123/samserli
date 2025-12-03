import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/components/navabr.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/pages/houses//housedetails.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<Map> createState() => _MapPageState();
}

class _MapPageState extends State<Map> {
  final tokenStorage = const FlutterSecureStorage();
  GoogleMapController? _mapController;
  bool _permissionGranted = false;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isAddingProperty = false;

  final TextEditingController statusController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  int? selectedRooms;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<XFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      _getCurrentLocation();
      await gethouses();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => selectedImages = images);
    }
  }

  Future<void> _sendHouseData(double latitude, double longitude) async {
    setState(() {
      _isAddingProperty = true;
    });

    try {
      String? token = await tokenStorage.read(key: 'token');

      var uri = Uri.parse('http://10.0.2.2:8000/add_house');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['rooms'] = selectedRooms?.toString() ?? '0';
      request.fields['status'] = statusController.text;
      request.fields['price'] = priceController.text;
      request.fields['name'] = nameController.text;
      request.fields['description'] = descriptionController.text;

      for (var img in selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath('house_pictures', img.path),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        await gethouses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("House added successfully")),
        );

        statusController.clear();
        priceController.clear();
        selectedRooms = null;
        nameController.clear();
        descriptionController.clear();
        setState(() => selectedImages.clear());
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed: $responseBody")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isAddingProperty = false;
      });
    }
  }

  Future<BitmapDescriptor> getResizedMarker(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> gethouses() async {
    BitmapDescriptor rentImage = await getResizedMarker(
      'lib/assets/rent (1).png',
      80,
    );
    BitmapDescriptor saleImage = await getResizedMarker(
      'lib/assets/sign.png',
      80,
    );

    String? token = await tokenStorage.read(key: 'token');
    final uri = Uri.parse('http://10.0.2.2:8000/fetch_houses');
    final response = await http.get(
      uri,
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      Set<Marker> newMarkers = {};

      for (var house in data) {
        double? lat = double.tryParse(house["latitude"].toString());
        double? long = double.tryParse(house["longitude"].toString());
        String? name = house["name"];
        String? status = house["status"];
        BitmapDescriptor imageIcon = (status == "rent") ? rentImage : saleImage;

        if (lat != null && long != null) {
          newMarkers.add(
            Marker(
              markerId: MarkerId(name ?? 'unknown'),
              position: LatLng(lat, long),
              icon: imageIcon,
              infoWindow: InfoWindow(
                title: name ?? 'Unnamed House',
                snippet: 'Lat: $lat, Long: $long  Status: $status',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Housedetails(house: house),
                  ),
                );
              },
            ),
          );
        }
      }

      setState(() {
        _markers = newMarkers;
      });
    } else if (response.statusCode == 401) {
      print('Unauthorized — invalid or expired token');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> getlocation(LatLng position) async {
    var longitude = position.longitude;
    var latitude = position.latitude;

    String? selectedStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Add Property",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF222222),
                      ),
                      decoration: const InputDecoration(
                        labelText: "Property Name",
                        hintText: "Enter property name",
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF222222),
                      ),
                      decoration: const InputDecoration(
                        labelText: "Price",
                        hintText: "Enter price",
                        prefixText: '\$ ',
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<int>(
                      value: selectedRooms,
                      decoration: const InputDecoration(
                        labelText: "Number of Rooms",
                        hintText: "Select rooms",
                      ),
                      items: List.generate(20, (index) => index + 1)
                          .map(
                            (num) => DropdownMenuItem(
                              value: num,
                              child: Text(num.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRooms = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Listing Type",
                        hintText: "Select type",
                      ),
                      items: const [
                        DropdownMenuItem(value: "rent", child: Text("Rent")),
                        DropdownMenuItem(value: "sale", child: Text("Sale")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                          statusController.text = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF222222),
                      ),
                      decoration: const InputDecoration(
                        labelText: "Description",
                        hintText: "Describe your property",
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text("Add Photos"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF222222),
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedImages.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${selectedImages.length} photo(s) selected",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF717171),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedImages
                                  .map(
                                    (img) => ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.file(
                                        File(img.path),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF717171),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF717171),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _isAddingProperty
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E5FB8), Color(0xFF2E7FD8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _sendHouseData(latitude, longitude),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7FD8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Add Property",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Map',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) => _mapController = controller,
        mapType: MapType.normal,
        myLocationEnabled: _permissionGranted,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        onTap: getlocation,
        markers: _markers,
      ),
      bottomNavigationBar: const Navbar(),
    );
  }
}
