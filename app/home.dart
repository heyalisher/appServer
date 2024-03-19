import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart'; // Import the path package
import 'ocr_page.dart'; // Import the OCRPage widget

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _inputTextController = TextEditingController();
  String? _pickedFilePath;
  int _selectedIndex = 0;

  @override
  void dispose() {
    _inputTextController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

    // Function to summarize text or file
  Future<String> summarize(String? text, String? filePath) async {
    try {
      var response;
      if (filePath != null) {
        File file = File(filePath);
        String fileContent = await file.readAsString();
        response = await http.post(
          Uri.parse('http://10.0.2.2:9001/summarize'),
          body: {'file': fileContent},
        );
      } else {
        response = await http.post(
          Uri.parse('http://10.0.2.2:9001/summarize'),
          body: {'text': text},
        );
      }
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print('Response from server: $responseData');
        return responseData['summary'];
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Error: $e';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Home'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Feedback'),
                  value: 'feedback',
                ),
                PopupMenuItem(
                  child: Text('Logout'),
                  value: 'logout',
                ),
              ];
            },
            onSelected: (String value) {
              if (value == 'logout') {
                Navigator.pushNamed(context, '/login_page');
              } else if (value == 'feedback') {
                Navigator.pushNamed(context, '/feedback_page');
              }
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100),
                    child: Image.asset(
                      'assets/file.png', // Replace 'your_image.png' with your image path
                      width: double.infinity, // Adjust width to fit the screen
                      fit: BoxFit
                          .cover, // Adjust fit to cover the available space
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'UPLOAD FILES',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Black color for "Upload"
                              ),
                            ),
                            SizedBox(height: 10), // Adjust spacing
                            Text(
                              'HERE!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 98,
                                    0), // Orange color for "Here!"
                              ),
                            ),
                            SizedBox(height: 30),
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  // Upload document button pressed
                                  String? filePath =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf', 'txt'],
                                  ).then((value) => value?.files.single.path);
                                  if (filePath != null) {
                                    print('File picked: $filePath');
                                    setState(() {
                                      _pickedFilePath = basename(
                                          filePath); // Extract and set only the file name
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _pickedFilePath ?? 'Choose a file',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors
                                              .black, // Black color for file name
                                        ),
                                      ),
                                      Icon(Icons.upload_file,
                                          color: Colors.orange),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      controller: _inputTextController,
                      maxLines: null, // Allow unlimited lines of text
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Enter text here',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Summarize button pressed
                        String text = _inputTextController.text;
                        String? filePath = _pickedFilePath;
                        String summary = await summarize(text, filePath);
                        // Navigate to Summarize page and pass the summary
                        Navigator.pushNamed(
                          context,
                          '/summarize',
                          arguments: summary,
                        );
                      },


                      // onPressed: () async {
                      //   // Summarize button pressed

                      //   if (_pickedFilePath != null) {
                      //     // Check if the file exists before trying to read it
                      //     try {
                      //       String fileContent =
                      //           await File(_pickedFilePath!).readAsString();

                      //       // Navigate to Summarize page and pass the file content
                      //       Navigator.pushNamed(
                      //         context,
                      //         '/summarize',
                      //         arguments: fileContent,
                      //       );
                      //     } catch (e) {
                      //       // Handle any errors, and print the error message
                      //       print("Error reading file: $e");
                      //     }
                      //   } else {
                      //     // If no file is picked, pass the text from the TextField
                      //     Navigator.pushNamed(
                      //       context,
                      //       '/summarize',
                      //       arguments: _inputTextController.text,
                      //     );
                      //   }
                      // },
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.orange),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Summarize',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : OCRPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'OCR', // Label for the new OCR page
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }
}
