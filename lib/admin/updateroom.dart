
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:serenadepalace/widgets/custom_scaffold.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSecondPage extends StatefulWidget {
  final dynamic room;

  const AdminSecondPage({Key? key, required this.room}) : super(key: key);

  @override
  _AdminSecondPageState createState() => _AdminSecondPageState();
}

class _AdminSecondPageState extends State<AdminSecondPage> {
  late List<dynamic> imagesBase64;
  late int currentIndex;
  bool _isUpdating = false; // To track if the update is in progress

  @override
  void initState() {
    super.initState();
    imagesBase64 = widget.room['images'];
    currentIndex = 0;
  }

  // Function to open the update dialog
  void _openUpdateDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _priceController = TextEditingController(text: widget.room['price'].toString());
    String? selectedRoomType = widget.room['type'];
    List<String> selectedImagesBase64 = List.from(imagesBase64);

    Future<void> _updateRoom() async {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isUpdating = true; // Show loading indicator
        });

        try {
          double price = double.parse(_priceController.text);

          // Firestore update logic
          await FirebaseFirestore.instance.collection('Rooms').doc(widget.room['id']).update({
            'type': selectedRoomType,
            'price': price,
            'images': selectedImagesBase64,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room successfully updated!')),
          );

          Navigator.pop(context); // Close the dialog after successful update
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating room: $e')),
          );
        } finally {
          setState(() {
            _isUpdating = false; // Hide loading indicator
          });
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: const Text(
            'Update Room Details',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Open room type selection
                      _openRoomTypeSelectionDialog(context, (type) {
                        setState(() {
                          selectedRoomType = type;
                        });
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown),
                        color: Colors.white,
                      ),
                      child: Text(
                        selectedRoomType ?? 'Choose the type of the room',
                        style: TextStyle(
                          color: selectedRoomType == null
                              ? Color.fromARGB(255, 143, 115, 94)
                              : Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: const Text(
                        'Price in Euro',
                        style: TextStyle(
                          color: Color.fromARGB(255, 143, 115, 94),
                          fontSize: 16.0,
                        ),
                      ),
                      hintText: 'Enter Price',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 143, 115, 94),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 143, 115, 94),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: pickImages,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown),
                        color: Colors.white,
                      ),
                      child: Text(
                        selectedImagesBase64.isEmpty
                            ? 'Images of the Room (1-3)'
                            : '${selectedImagesBase64.length} image(s) selected',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 143, 115, 94),
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (selectedImagesBase64.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      children: selectedImagesBase64
                          .map((imageBase64) => Image.memory(
                                base64Decode(imageBase64),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: _isUpdating
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _updateRoom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 143, 115, 94),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: const Text(
                              'Update Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openRoomTypeSelectionDialog(BuildContext context, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: const Text(
            'Choose the room type',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: ['Standard Room', 'Suite Room', 'Family Room'].map((type) {
                return ListTile(
                  title: Text(
                    type,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onSelect(type);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null) {
        if (result.files.length > 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 3 images only!'),
            ),
          );
          return;
        }

        setState(() {
          imagesBase64 = result.files
              .map((file) => base64Encode(file.bytes!))
              .take(3)
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selection error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String type = widget.room['type'];
    double price = (widget.room['price'] as num).toDouble();

    return CustomScaffold(
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Room Type: $type',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Price: £ ${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _openUpdateDialog(context); // Open the update dialog
                    },
                    child: const Text('Update Room'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
