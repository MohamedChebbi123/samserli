import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui; // for resizing marker
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for rootBundle
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/components/navabr.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

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

  final TextEditingController statusController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
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
    try {
      String? token = await tokenStorage.read(key: 'token');

      var uri = Uri.parse('http://10.0.2.2:8000/add_house');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['status'] = statusController.text;
      request.fields['price'] = priceController.text;
      request.fields['name'] = nameController.text;
      request.fields['description'] = descriptionController.text;

      for (var img in selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'house_pictures',
          img.path,
        ));
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
        nameController.clear();
        descriptionController.clear();
        setState(() => selectedImages.clear());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $responseBody")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Helper function to resize marker icons
  Future<BitmapDescriptor> getResizedMarker(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData =
    await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> gethouses() async {
    // Resize markers to a proper size (e.g., 80px)
    BitmapDescriptor rentImage =
    await getResizedMarker('lib/assets/rent (1).png', 80);
    BitmapDescriptor saleImage =
    await getResizedMarker('lib/assets/sign.png', 80);

    String? token = await tokenStorage.read(key: 'token');
    final uri = Uri.parse('http://10.0.2.2:8000/fetch_houses');
    final response = await http.get(uri, headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      Set<Marker> newMarkers = {};

      for (var house in data) {
        double? lat = double.tryParse(house["latitude"].toString());
        double? long = double.tryParse(house["longitude"].toString());
        String? name = house["name"];
        String? status = house["status"];
        BitmapDescriptor imageIcon =
        (status == "rent") ? rentImage : saleImage;

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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Enter House Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text("Select Images"),
                ),
                const SizedBox(height: 10),
                if (selectedImages.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedImages
                        .map((img) => SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.file(
                          File(img.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                const SizedBox(height: 10),
                Text(
                  "Latitude: $latitude\nLongitude: $longitude",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => _sendHouseData(latitude, longitude),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    _currentPosition =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps Example')),
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
