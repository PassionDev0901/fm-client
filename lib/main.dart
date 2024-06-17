// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'admin_screen.dart';
import 'database_helper.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Colors.blue), // Adjust the primarySwatch as needed
        colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Colors.green.shade50)), // Use primarySwatch directly for ColorScheme
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Fais Mart'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _trefController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();

  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  // Method to show a dialog
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'), // Use const for Text widgets
            ),
          ],
        );
      },
    );
  }

  void _validateInput(BuildContext context) async {
    String inputText = _searchController.text.trim();

    if (inputText.isEmpty) {
      _showDialog(context, 'Validation Error', 'Input cannot be empty.');
      return;
    }

    // Perform database search
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    Map<String, dynamic>? result = await dbHelper.search(inputText);

    if (result != null) {
      // Show dialog with prompt message from database result
      _showDialog(context, 'Prompt', '${result['prompt']}');

      // Update TR REF and Customer ID inputs
      _searchController.text = inputText; // Update search input (optional)
      // Set TR REF and Customer ID inputs from database
      // Assuming your input fields are TextFields with controllers
      _trefController.text = result['tr'];
      _customerController.text = result['customer'];
    } else {
      _showDialog(context, 'Search Result', 'No record found for TR REF: $inputText');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen height and width to make layout responsive
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), // 5% padding from all sides
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    child:Image.asset(
                    'assets/logo.png',
                    height: screenHeight * 0.2, // 20% of screen height
                    fit: BoxFit.contain,
                  )),
                  SizedBox(height: screenHeight * 0.1), // 10% of screen height
                    TextField(
                autofocus: true,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Customer',
                  border: OutlineInputBorder(),
                  labelText: 'Search',
                  // Use focusedBorder to customize the border when TextField is focused
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                cursorColor: Colors.blue, // Set cursor color
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

                  SizedBox(height: screenHeight * 0.1), // 10% of screen height
                  TextField(
                    controller: _trefController,
                    decoration: InputDecoration(
                      hintText: 'TR REF',
                      border: OutlineInputBorder(),
                      enabled: false,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05), // 5% of screen height
                  TextField(
                    controller: _customerController,
                    decoration: InputDecoration(
                      hintText: 'Customer ID',
                      border: OutlineInputBorder(),
                      enabled: false,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.1), 
                  ElevatedButton(
                    onPressed: () {
                      _validateInput(context); // Call method to validate input
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(vertical: 10.0), // Adjust padding as needed
                      ),
                       backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade400)
                    ),
                    child: const Text(
                      'SEARCH',
                      style: TextStyle(color: Colors.white), // Change text color here
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Positioned widget to place the admin button at the left bottom
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: screenWidth / 4, // 1/4 of screen width
              decoration: BoxDecoration(
                color: Colors.green[500], // Example color
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32.0), // Adjust the radius as needed
                ),
              ),
              child: TextButton(
                onPressed: () {
                    // Navigate to admin screen when button is pressed
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminScreen()),
                );
                },
                child: const Text(
                  'Admin',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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