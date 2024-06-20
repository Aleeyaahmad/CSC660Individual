import 'package:flutter/material.dart';
import 'package:aleeyadiary/database_helper.dart';
import 'package:aleeyadiary/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  HomeScreen({this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> entries = [];
  List<Map<String, dynamic>> filteredEntries = [];
  bool isDarkMode = false;
  String? username;

  Color fabLightModeColor = Color(0xFF7D8BE0); // Hex code #7D8BE0 for light mode
  Color fabDarkModeColor = Colors.white; // White color for dark mode

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    username = widget.user?['username'] ?? 'User';
    _loadEntries(); // Load initial entries when the screen initializes
  }
void _loadEntries() async {
  try {
    // Fetch entries for the logged-in user
    List<Map<String, dynamic>> loadedEntries = await _dbHelper.getAllEntries(username!);
    
    // Update the state with the retrieved entries
    setState(() {
      entries = loadedEntries;
      filteredEntries = entries; // Initialize filteredEntries with all entries
    });
  } catch (e) {
    print("Error loading entries: $e");
    // Handle error loading entries, such as showing a snackbar or error message
  }
}

  void _addOrEditEntry({Map<String, dynamic>? entry, int? index}) {
    TextEditingController titleController =
        TextEditingController(text: entry?['feeling'] ?? '');
    TextEditingController contentController =
        TextEditingController(text: entry?['description'] ?? '');

    String? selectedImagePath = entry?['image'];

    void _selectImage(String imagePath) {
      setState(() {
        selectedImagePath = imagePath;
      });
    }

    void _clearImage() {
      setState(() {
        selectedImagePath = null;
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(entry == null ? 'Create New Diary' : 'Update Diary'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Select your feeling:'),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectImage('assets/happy.png');
                              });
                            },
                            child: Column(
                              children: [
                                Image.asset('assets/happy.png', width: 50, height: 50),
                                Text('Happy'),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectImage('assets/angry.png');
                              });
                            },
                            child: Column(
                              children: [
                                Image.asset('assets/angry.png', width: 50, height: 50),
                                Text('Angry'),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectImage('assets/sad.png');
                              });
                            },
                            child: Column(
                              children: [
                                Image.asset('assets/sad.png', width: 50, height: 50),
                                Text('Sad'),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectImage('assets/neutral.png');
                              });
                            },
                            child: Column(
                              children: [
                                Image.asset('assets/neutral.png', width: 50, height: 50),
                                Text('Neutral'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Placeholder to handle any future actions when the image is tapped
                          },
                          child: selectedImagePath != null
                              ? Image.asset(
                                  selectedImagePath!,
                                  height: 100,
                                )
                              : Container(
                                  width: 100, // Placeholder width for image space
                                  height: 100, // Placeholder height for image space
                                  color: Colors.grey[300],
                                  child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]),
                                ),
                        ),
                        if (selectedImagePath != null)
                          Positioned(
                            top: 8.0,
                            right: 8.0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImagePath = null;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 12,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Feeling',
                        icon: Icon(Icons.sentiment_satisfied),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        icon: Icon(Icons.description),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Map<String, dynamic> entryData = {
                      'feeling': titleController.text,
                      'description': contentController.text,
                    };

                    if (selectedImagePath != null) {
                      entryData['image'] = selectedImagePath;
                    } else {
                      entryData['image'] = null;
                    }

                    if (entry == null) {
                      await _dbHelper.insertEntry(entryData);
                    } else {
                      entryData['id'] = entry['id'];
                      await _dbHelper.updateEntry(entryData);
                    }
                    _loadEntries();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(entry == null ? 'Diary entry succesfully saved' : 'Diary entry successfully updated'),
                    ));
                    Navigator.of(context).pop();
                  },
                  child: Text(entry == null ? 'Save' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleTheme(bool newValue) {
    setState(() {
      isDarkMode = newValue;
    });
  }

  Color _getBackgroundColor() {
    return isDarkMode ? Colors.grey[900]! : Color(0xFFABCDDE);
  }

  Color _getFloatingActionButtonColor() {
    return isDarkMode ? fabDarkModeColor : fabLightModeColor;
  }

  void _signOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _filterEntries(String query) {
    List<Map<String, dynamic>> filteredList = entries.where((entry) {
      return entry['feeling'].toLowerCase().startsWith(query.toLowerCase()) ||
          entry['description'].toLowerCase().startsWith(query.toLowerCase());
    }).toList();

    setState(() {
      filteredEntries = filteredList;
    });
  }

  Future<void> _confirmDeleteEntry(Map<String, dynamic> entry) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Diary'),
          content: Text('Are you sure you want to delete this diary? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed deletion
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _dbHelper.deleteEntry(entry['id']);
      _loadEntries();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diary entry successfully deleted'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username != null && username!.isNotEmpty
            ? "${username}'s Diary"
            : "Aleeya's Diary"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DiarySearchDelegate(entries, _filterEntries),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200, // Adjust the height as needed
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Color(0xFF7D8BE0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24), // Increased top padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28, // Increased font size
                      ),
                    ),
                  ),
                  SizedBox(height: 12), // Added space between text and username
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Hello! ${username ?? "User"}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
              
                ],
              ),
            ),
            ListTile(
              title: Text('Theme Mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: _toggleTheme,
                activeColor: Colors.amber,
              ),
            ),
            ListTile(
              title: Text('Log Out'),
              trailing: Icon(Icons.logout),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      backgroundColor: _getBackgroundColor(),
      body: ListView.builder(
        itemCount: filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = filteredEntries[index];
          Color cardColor = Colors.grey[300]!; // Default color if no image

          if (entry['image'] != null) {
            if (entry['image'] == 'assets/happy.png') {
              cardColor =  Color(0xFFF2C6DE);
            } else if (entry['image'] == 'assets/angry.png') {
              cardColor = Color(0xFFFFADAD);
            } else if (entry['image'] == 'assets/sad.png') {
              cardColor =  Color(0xFFC6DEF1);
            } else if (entry['image'] == 'assets/neutral.png') {
              cardColor =  Color(0xFFFAEDCB);
            }
          }

          return Dismissible(
            key: Key(entry['id'].toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Diary'),
                    content: Text('Are you sure you want to delete this diary entry? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // User pressed cancel
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // User confirmed deletion
                        },
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) async {
              await _dbHelper.deleteEntry(entry['id']);
              _loadEntries();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Diary entry successfully deleted'),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(10.0),
              color: cardColor,
              child: ListTile(
                leading: Container(
                  width: 50, // Placeholder width for image space
                  height: 50, // Placeholder height for image space
                  color: Colors.grey[300],
                  child: entry['image'] != null
                      ? Image.asset(
                          entry['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : null, // Display no image if entry['image'] is null
                ),
                title: Text(entry['feeling']),
                subtitle: Text(entry['description']),
                onTap: () {}, // Disable onTap for the whole tile
                trailing: GestureDetector(
                  onTap: () {
                    _addOrEditEntry(entry: entry, index: index);
                  },
                  child: Icon(Icons.edit),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditEntry();
        },
        backgroundColor: _getFloatingActionButtonColor(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class DiarySearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> entries;
  final Function(String) filterFunction;

  DiarySearchDelegate(this.entries, this.filterFunction);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          filterFunction(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Not used, results are shown in the buildSuggestions method
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> suggestionList = query.isEmpty
        ? []
        : entries.where((entry) {
            return entry['feeling'].toLowerCase().startsWith(query.toLowerCase()) ||
                entry['description'].toLowerCase().startsWith(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final entry = suggestionList[index];
        return ListTile(
          title: Text(entry['feeling']),
          subtitle: Text(entry['description']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EntryDetailScreen(entry: entry),
              ),
            );
          },
        );
      },
    );
  }
}

class EntryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> entry;

  EntryDetailScreen({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry['image'] != null)
              Image.asset(
                entry['image'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 8.0),
            Text(
              'Feeling: ${entry['feeling']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Description: ${entry['description']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
