import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart'; // REQUIRED for searchCities
import '../models/city_suggestion.dart'; // REQUIRED for suggestion model

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _cityController = TextEditingController();

  // Renamed from _savedCities for clarity
  final List<String> _previouslySearched = [];

  // Debouncing logic
  final WeatherService _weatherService = WeatherService();
  List<CitySuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreviousSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cityController.dispose();
    super.dispose();
  }

  // --- Location Management ---
  Future<void> _loadPreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _previouslySearched.addAll(prefs.getStringList('previousSearches') ?? []);
    });
  }

  // Updated to save to 'previousSearches' key
  Future<void> _saveSearch(String city) async {
    final normalizedCity = city.trim();

    // Remove if exists and add to the top to act as 'Most Recently Used'
    if (_previouslySearched.contains(normalizedCity)) {
      _previouslySearched.remove(normalizedCity);
    }
    _previouslySearched.insert(0, normalizedCity);

    // Limit history to 10 items
    if (_previouslySearched.length > 10) {
      _previouslySearched.removeLast();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('previousSearches', _previouslySearched);
    setState(() {});
  }

  void _removeSearch(String city) async {
    _previouslySearched.remove(city);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('previousSearches', _previouslySearched);
    setState(() {});
  }

  // --- Live Search Logic (Debounced) ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _suggestions = [];
        });
        return;
      }
      try {
        final results = await _weatherService.searchCities(query);
        setState(() {
          _suggestions = results;
        });
      } catch (e) {
        _suggestions = [];
        setState(() {});
      }
    });
  }

  // --- Search Execution Logic ---
  Future<void> _searchAndDisplay(String cityName, {bool save = true}) async {
    final trimmedCity = cityName.trim();
    if (trimmedCity.isEmpty) return;

    setState(() {
      _isLoading = true;
      _suggestions = []; // Clear suggestions list
    });

    try {
      final provider = Provider.of<WeatherProvider>(context, listen: false);
      await provider.fetchWeatherForCity(trimmedCity);

      if (save) await _saveSearch(trimmedCity);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString().split(': ')[1])));
    }
  }

  // Function to handle selecting a suggestion
  void _selectSuggestion(CitySuggestion suggestion) async {
    // Clear search field after selection for clean UX
    _cityController.text = '';
    await _searchAndDisplay(suggestion.name, save: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Search Field ---
            TextField(
              controller: _cityController,
              onChanged: _onSearchChanged, // Hook up live search
              decoration: InputDecoration(
                hintText: 'Enter city name (e.g., London)',
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blueAccent,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search, color: Colors.white70),
                        onPressed: () =>
                            _searchAndDisplay(_cityController.text),
                      ),
              ),
              onSubmitted: (value) => _searchAndDisplay(value),
              style: const TextStyle(color: Colors.white),
            ),

            // --- 2. Live Search Suggestions List ---
            if (_suggestions.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      title: Text(
                        suggestion.displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () => _selectSuggestion(suggestion),
                    );
                  },
                ),
              )
            else
              const SizedBox(
                height: 40,
              ), // Spacer if suggestions are not visible
            // --- 3. Previously Searched Locations List ---
            const Text(
              'Previously Searched Locations:', // Updated title
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(color: Colors.white24),

            _previouslySearched.isEmpty
                ? const Text(
                    'Search history is empty.',
                    style: TextStyle(color: Colors.white54),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _previouslySearched.length,
                    itemBuilder: (context, index) {
                      final city = _previouslySearched[index];
                      return Dismissible(
                        key: Key(city),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _removeSearch(city);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$city removed.')),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            city,
                            style: const TextStyle(color: Colors.white),
                          ),
                          leading: const Icon(
                            Icons.history,
                            color: Colors.white54,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white54,
                            ),
                            onPressed: () =>
                                _searchAndDisplay(city, save: false),
                          ),
                          onTap: () => _searchAndDisplay(city, save: false),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
