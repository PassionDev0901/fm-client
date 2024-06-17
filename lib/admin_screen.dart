import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'database_helper.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite FFI if on a desktop platform
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AdminScreen(),
        theme: ThemeData(
        primarySwatch: createMaterialColor(Colors.blue), // Adjust the primarySwatch as needed
        colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Colors.green.shade50)), // Use primarySwatch directly for ColorScheme
        useMaterial3: true,
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _trefController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Method to search for a customer in the database and fill the fields
  void _searchCustomer(BuildContext context) async {
    String searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      _showDialog(context, 'Validation Error', 'Search input cannot be empty.');
      return;
    }

    Map<String, dynamic>? result = await _dbHelper.search(searchQuery);
    if (result != null) {
      setState(() {
        _trefController.text = result['tr'];
        _customerController.text = result['customer'];
        _promptController.text = result['prompt'];
      });
      // _showDialog(context, 'Search Success', 'Data found and populated.');
    } else {
      _showDialog(context, 'Search Error', 'No data found for the provided customer.');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Section with Search Input and Button
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Customer',
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _searchCustomer(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                      ),
                      child: const Text(
                        'SEARCH',
                     
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Middle Section with remaining elements
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ENTER DATA:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _trefController,
                    decoration: InputDecoration(
                      labelText: 'TRREF',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _customerController,
                    decoration: InputDecoration(
                      labelText: 'CUSTOMER',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.07),
                  TextField(
                    controller: _promptController,
                    maxLines: 7,
                    decoration: InputDecoration(
                      labelText: 'PROMPT MESSAGE',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Section with Save and Delete Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _deleteData(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                      child: Text('DELETE'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _insertData(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                      child: Text('SAVE'),
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

  // Validation logic method
  void _validateInput(BuildContext context) {
    String inputText = _searchController.text.trim();
    if (inputText.isEmpty) {
      _showDialog(context, 'Validation Error', 'Input cannot be empty.');
    } else if (inputText.length < 3) {
      _showDialog(context, 'Validation Error',
          'Input must be at least 3 characters long.');
    } else {
      _showDialog(context, 'Validation Success', 'Input is valid: $inputText');
    }
  }

  // Show dialog method
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
 // Method to delete data from database
  void _deleteData(BuildContext context) async {
    String trRef = _trefController.text.trim();
    if (trRef.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot delete: TR Ref (Phone number) is empty')),
      );
      return;
    }

    int result = await _dbHelper.delete(trRef);
    if (result != 0) {
      // Clear text fields after successful deletion
      _trefController.clear();
      _customerController.clear();
      _promptController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete data')),
      );
    }
  }
 void _insertData(BuildContext context) async {
  String trRef = _trefController.text.trim();
  String customerId = _customerController.text.trim();
  String prompt = _promptController.text.trim();

  // Validate TR Ref format (phone number format)
  if (!validateTRRef(trRef)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid TR Ref (phone number) format')),
    );
    return;
  }

  // Proceed with insertion or update
  int result = await _dbHelper.insertOrUpdate({
    'tr': trRef,
    'customer': customerId,
    'prompt': prompt,
  });

  if (result != 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data inserted/updated successfully')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to insert/update data')),
    );
  }
}
// Validate TR Ref (phone number format)
bool validateTRRef(String input) {
  final RegExp phoneRegex = RegExp(r'^\d{3}[-\s]?\d{3}[-\s]?\d{4}$');
  return phoneRegex.hasMatch(input.trim());
}

}

// Function to create a custom MaterialColor
MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}