import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, bool> restaurantPreferences;
  final Function(Map<String, bool>) onSave;

  const SettingsScreen({
    super.key,
    required this.restaurantPreferences,
    required this.onSave,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Map<String, bool> _preferences;
  late List<String> _customRestaurants = []; // Initialize as an empty list
  final TextEditingController _restaurantController = TextEditingController();
  late ScrollController _scrollController; // Add a ScrollController

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // Initialize the ScrollController
    _preferences = Map.from(widget.restaurantPreferences);
    _loadCustomRestaurants();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the ScrollController
    super.dispose();
  }

  /// Load custom restaurants from SharedPreferences
  Future<void> _loadCustomRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final customRestaurants = prefs.getStringList('customRestaurants') ?? [];
    if (!mounted) return; // Ensure the widget is still mounted
    setState(() {
      _customRestaurants = customRestaurants;
      for (var restaurant in customRestaurants) {
        _preferences[restaurant] =
            true; // Add custom restaurants to preferences
      }
    });
  }

  /// Save custom restaurants to SharedPreferences
  Future<void> _saveCustomRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('customRestaurants', _customRestaurants);
  }

  /// Save all preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _preferences.entries) {
      await prefs.setBool(entry.key, entry.value);
    }
    await _saveCustomRestaurants(); // Save custom restaurants
    if (!mounted) return; // Check if the widget is still mounted
  }

  /// Add a new restaurant to the list
  void _addRestaurant() {
    final newRestaurant = _restaurantController.text.trim();
    if (newRestaurant.isNotEmpty && !_preferences.containsKey(newRestaurant)) {
      setState(() {
        _preferences[newRestaurant] = true;
        _customRestaurants.add(newRestaurant);
        _restaurantController.clear();
      });
      _savePreferences();
    }
  }

  /// Delete a custom-added restaurant
  void _deleteRestaurant(String restaurant) {
    setState(() {
      _preferences.remove(restaurant);
      _customRestaurants.remove(restaurant);
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Color.fromARGB(255, 62, 69, 74),
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'Arial',
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 47, 168, 156),
                Color(0xFF40E0D0),
              ], // Turquoise to dark blue-grey
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await _savePreferences();
              if (!mounted) return;
              widget.onSave(_preferences);
              if (!mounted) return;
              final navigator = Navigator.of(context);
              if (!mounted) return;
              navigator.pop();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 72, 80, 85),
              Color.fromARGB(255, 35, 38, 40),
            ], // Dark blue-grey gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _restaurantController,
                          decoration: const InputDecoration(
                            hintText: "Add a new restaurant",
                            hintStyle: TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Color.fromARGB(255, 47, 168, 156),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addRestaurant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            253,
                            139,
                            69,
                          ), // Orange
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Color.fromARGB(
                                255,
                                253,
                                139,
                                69,
                              ), // Orange border
                              width: 2, // Border width
                            ),
                          ),
                        ),
                        child: const Text(
                          "Add",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Add spacing between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Select all restaurants
                            _preferences.updateAll((key, value) => true);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            253,
                            139,
                            69,
                          ), // Orange
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Color.fromARGB(
                                255,
                                253,
                                139,
                                69,
                              ), // Orange border
                              width: 2, // Border width
                            ),
                          ),
                        ),
                        child: const Text(
                          "Select All",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ), // Add spacing between the buttons
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Deselect all restaurants
                            _preferences.updateAll((key, value) => false);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            253,
                            139,
                            69,
                          ), // Orange
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Color.fromARGB(
                                255,
                                253,
                                139,
                                69,
                              ), // Orange border
                              width: 2, // Border width
                            ),
                          ),
                        ),
                        child: const Text(
                          "Deselect All",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController, // Attach the ScrollController
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(10),
                // Removed thumbColor as it is not a valid parameter
                child: ListView(
                  controller: _scrollController, // Attach the ScrollController
                  padding: const EdgeInsets.all(20),
                  children:
                      _preferences.keys.map((restaurant) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              checkboxTheme: CheckboxThemeData(
                                side: const BorderSide(
                                  color: Color.fromARGB(
                                    255,
                                    253,
                                    139,
                                    69,
                                  ), // Orange outline
                                  width: 2, // Thickness of the outline
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    5,
                                  ), // Rounded corners
                                ),
                              ),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                restaurant,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              value: _preferences[restaurant],
                              activeColor: const Color.fromARGB(
                                255,
                                253,
                                139,
                                69,
                              ), // Orange for the checkbox fill
                              checkColor: const Color.fromARGB(
                                255,
                                35,
                                38,
                                40,
                              ), // Dark text for the checkmark
                              onChanged: (bool? value) {
                                setState(() {
                                  _preferences[restaurant] = value ?? false;
                                });
                              },
                              tileColor: const Color.fromARGB(
                                255,
                                47,
                                168,
                                156,
                              ).withValues(
                                alpha: 10,
                              ), // Slight turquoise background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              secondary:
                                  _customRestaurants.contains(restaurant)
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () =>
                                                _deleteRestaurant(restaurant),
                                      )
                                      : null,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
