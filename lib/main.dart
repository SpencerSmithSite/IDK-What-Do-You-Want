import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'settings.dart'; // Add this import

void main() {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  } catch (e) {
    rethrow;
  }
}

/// The root widget of your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return MaterialApp(
        title: 'IDK, What do you want?',
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// The stateful widget for your app's main screen.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _restaurants = [];
  Map<String, bool> _restaurantPreferences = {};
  String? _chosenRestaurant;
  String? _optionA;
  String? _optionB;
  String? _errorMessage;

  // Flags to manage app modes
  bool _helpMeDecideMode = false;
  bool _randomChoiceMode = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _loadRestaurants();
      setState(() {
        _restaurantPreferences = {
          for (var item in _restaurants) item: prefs.getBool(item) ?? true,
        };
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Initialization failed.";
      });
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/restaurants.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _restaurants = jsonList.cast<String>();
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load restaurants.";
      });
    }
  }

  /// Resets the app state.
  void _resetApp() {
    setState(() {
      _helpMeDecideMode = false;
      _randomChoiceMode = false;
      _chosenRestaurant = null;
      _optionA = null;
      _optionB = null;
    });
  }

  /// Picks a random restaurant from the list and shows it.
  void _chooseRandom() {
    setState(() {
      _helpMeDecideMode = false;
      _randomChoiceMode = true;
      _restaurants.shuffle();
      _chosenRestaurant = _restaurants.isNotEmpty ? _restaurants.first : null;
      _optionA = null;
      _optionB = null;
    });
  }

  /// Sets the screen to show head-to-head mode (two restaurants to compare).
  void _startHeadToHead() {
    setState(() {
      _randomChoiceMode = false;
      _helpMeDecideMode = true;
      _restaurants.shuffle();

      if (_restaurants.length >= 2) {
        _optionA = _restaurants[0];
        _optionB = _restaurants[1];
      } else if (_restaurants.isNotEmpty) {
        _chosenRestaurant = _restaurants.first;
        _optionA = null;
        _optionB = null;
      }
    });
  }

  /// Picks a winner between two restaurants and removes the loser from the list.
  void _pickWinner(String winner, String loser) {
    setState(() {
      _restaurants.remove(loser);
      _chosenRestaurant = winner;

      if (_restaurants.length >= 2) {
        _optionA = winner;
        final nextIndex = _restaurants.indexWhere((r) => r != winner);
        if (nextIndex != -1) {
          _optionB = _restaurants[nextIndex];
        } else {
          _optionB = null;
        }
      } else {
        _optionA = null;
        _optionB = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadRestaurants,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "IDK, What do you want?",
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
              colors: [Color.fromARGB(255, 47, 168, 156), Color(0xFF40E0D0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SettingsScreen(
                        restaurantPreferences: _restaurantPreferences,
                        onSave: (newPreferences) {
                          setState(() {
                            _restaurantPreferences = newPreferences;
                          });
                        },
                      ),
                ),
              );
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
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child:
              _helpMeDecideMode
                  ? _buildHelpMeDecideView()
                  : _randomChoiceMode
                  ? _buildRandomChoiceView()
                  : _buildDefaultView(),
        ),
      ),
    );
  }

  /// The default view with "Choose Random" and "Help Me Decide."
  Widget _buildDefaultView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Not sure where to eat? \nLet's decide!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _chooseRandom,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color.fromARGB(255, 253, 139, 69),
            shadowColor: Colors.black.withAlpha(10),
            elevation: 5,
          ),
          child: const Text(
            "Choose For Me",
            style: TextStyle(
              color: Color.fromARGB(255, 35, 38, 40),
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _startHeadToHead,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color.fromARGB(255, 253, 139, 69),
            shadowColor: Colors.black.withAlpha(10),
            elevation: 5,
          ),
          child: const Text(
            "Help Me Decide",
            style: TextStyle(
              color: Color.fromARGB(255, 35, 38, 40),
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// The view for a random choice result.
  Widget _buildRandomChoiceView() {
    if (_chosenRestaurant != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Random choice:",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              _chosenRestaurant!,
              style: const TextStyle(
                color: Color(0xFF40E0D0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetApp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color.fromARGB(255, 253, 139, 69),
                shadowColor: Colors.black.withAlpha(10),
                elevation: 5,
              ),
              child: const Text(
                "Start Over",
                style: TextStyle(
                  color: Color.fromARGB(255, 35, 38, 40),
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "No restaurants available.",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              () => setState(() {
                _helpMeDecideMode = false;
                _randomChoiceMode = false;
              }),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color.fromARGB(255, 253, 139, 69),
            shadowColor: Colors.black.withAlpha(10),
            elevation: 5,
          ),
          child: const Text(
            "Return Home",
            style: TextStyle(
              color: Color.fromARGB(255, 35, 38, 40),
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// The head-to-head view: pick between two restaurants, or show the final winner.
  Widget _buildHelpMeDecideView() {
    if (_optionA != null && _optionB != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Which one do you prefer?",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _pickWinner(_optionA!, _optionB!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color.fromARGB(255, 253, 139, 69),
              shadowColor: Colors.black.withAlpha(10),
              elevation: 5,
            ),
            child: Text(
              _optionA!,
              style: const TextStyle(
                color: Color.fromARGB(255, 35, 38, 40),
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _pickWinner(_optionB!, _optionA!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color.fromARGB(255, 253, 139, 69),
              shadowColor: Colors.black.withAlpha(10),
              elevation: 5,
            ),
            child: Text(
              _optionB!,
              style: const TextStyle(
                color: Color.fromARGB(255, 35, 38, 40),
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _resetApp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color.fromARGB(255, 72, 80, 85),
                  shadowColor: Colors.black.withAlpha(10),
                  elevation: 5,
                ),
                child: const Text(
                  "Start Over",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_chosenRestaurant != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "The winner is:",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              _chosenRestaurant!,
              style: const TextStyle(
                color: Color(0xFF40E0D0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetApp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color.fromARGB(255, 253, 139, 69),
                shadowColor: Colors.black.withAlpha(10),
                elevation: 5,
              ),
              child: const Text(
                "Start Over",
                style: TextStyle(
                  color: Color.fromARGB(255, 35, 38, 40),
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "No restaurants available.",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed:
              () => setState(() {
                _helpMeDecideMode = false;
                _randomChoiceMode = false;
              }),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color.fromARGB(255, 253, 139, 69),
            shadowColor: Colors.black.withAlpha(10),
            elevation: 5,
          ),
          child: const Text(
            "Return Home",
            style: TextStyle(
              color: Color.fromARGB(255, 35, 38, 40),
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
