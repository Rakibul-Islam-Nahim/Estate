import 'package:flutter/material.dart';
import 'package:real_state/pages/ProfilePage.dart';
import 'package:real_state/pages/ContributionPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<dynamic> properties = [];
  List<dynamic> filteredProperties = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String _selectedDivision = 'All';
  final Set<int> favoriteIds = {};
  final List<String> _divisionOptions = const [
    'All',
    'Dhaka',
    'Chattogram',
    'Sylhet',
    'Khulna',
    'Rajshahi',
    'Barishal',
    'Rangpur',
    'Mymensingh',
    'Cox Bazar',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProperties);
    _minPriceController.addListener(_filterProperties);
    _maxPriceController.addListener(_filterProperties);
    _loadProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/properties'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          properties = decoded;
          _isLoading = false;
        });
        _filterProperties();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading properties: $e');
    }
  }

  void _filterProperties() {
    final query = _searchController.text.toLowerCase();
    final minPrice = double.tryParse(
      _minPriceController.text.replaceAll(',', ''),
    );
    final maxPrice = double.tryParse(
      _maxPriceController.text.replaceAll(',', ''),
    );

    setState(() {
      filteredProperties = properties.where((property) {
        final title = (property['title'] ?? '').toString().toLowerCase();
        final location = (property['location'] ?? '').toString().toLowerCase();
        final price = double.tryParse((property['price'] ?? 0).toString()) ?? 0;

        final matchesSearch =
            query.isEmpty || title.contains(query) || location.contains(query);

        final matchesPrice =
            (minPrice == null || price >= minPrice) &&
            (maxPrice == null || price <= maxPrice);

        final matchesDivision = _selectedDivision == 'All'
            ? true
            : location.contains(_selectedDivision.toLowerCase());

        return matchesSearch && matchesPrice && matchesDivision;
      }).toList();
    });
  }

  int? _extractPropertyId(Map<String, dynamic> property) {
    final id = property['id'];
    if (id is int) return id;
    if (id is String) {
      return int.tryParse(id);
    }
    return null;
  }

  void _toggleFavorite(Map<String, dynamic> property) {
    final propertyId = _extractPropertyId(property);
    if (propertyId == null) return;

    setState(() {
      if (favoriteIds.contains(propertyId)) {
        favoriteIds.remove(propertyId);
      } else {
        favoriteIds.add(propertyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E5E5),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Real Estate',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(userName: widget.userName),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Color(0xFF9ACD32),
                child: Text(
                  widget.userName[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5E5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              // Navigate to Contribution page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContributionPage(),
                ),
              );
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFE5E5E5),
          selectedItemColor: Color(0xFF9ACD32),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_upload_outlined),
              activeIcon: Icon(Icons.cloud_upload),
              label: 'Contribution',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF32CD32)),
      );
    }

    if (_currentIndex == 3) {
      return _buildFavoritesContent();
    }

    if (_currentIndex == 2) {
      return _buildPlaceholderPage(
        title: 'Chat coming soon',
        subtitle: 'Conversations and inquiries will appear here.',
      );
    }

    return _buildHomeContent();
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.userName}!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find your dream property',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildDivisionFilter(),
            const SizedBox(height: 16),
            _buildPriceFilters(),
            const SizedBox(height: 24),
            Text(
              'Properties (${filteredProperties.length})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            if (filteredProperties.isEmpty)
              _buildEmptyState(
                icon: Icons.search_off,
                message: 'No properties match your search',
              )
            else
              ...filteredProperties.map((property) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPropertyCard(property),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesContent() {
    final favoriteProperties = properties.where((property) {
      final id = _extractPropertyId(property);
      return id != null && favoriteIds.contains(id);
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Favorites',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            if (favoriteProperties.isEmpty)
              _buildEmptyState(
                icon: Icons.favorite_outline,
                message: 'No favorite properties yet',
              )
            else
              ...favoriteProperties.map((property) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPropertyCard(property),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPage({
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by title or location...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
        fillColor: const Color(0xFFDCDCDC),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDivisionFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedDivision,
      items: _divisionOptions
          .map(
            (division) =>
                DropdownMenuItem(value: division, child: Text(division)),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedDivision = value;
        });
        _filterProperties();
      },
      decoration: InputDecoration(
        labelText: 'Division',
        labelStyle: TextStyle(color: Colors.grey[700]),
        fillColor: const Color(0xFFDCDCDC),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildPriceFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Min price',
              labelStyle: TextStyle(color: Colors.grey[700]),
              fillColor: const Color(0xFFDCDCDC),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max price',
              labelStyle: TextStyle(color: Colors.grey[700]),
              fillColor: const Color(0xFFDCDCDC),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(icon, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    final propertyId = _extractPropertyId(property);
    final isFavorite = propertyId != null && favoriteIds.contains(propertyId);
    return GestureDetector(
      onTap: () => _showPropertyDetails(property),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDCDCDC),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF9ACD32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.home_work, size: 30, color: Color(0xFF9ACD32)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['title'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    property['location'] ?? 'No Location',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '৳${property['price'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9ACD32),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: const Color(0xFF32CD32),
                  ),
                  onPressed: propertyId == null
                      ? null
                      : () {
                          _toggleFavorite(property);
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPropertyDetails(Map<String, dynamic> property) {
    final propertyId = _extractPropertyId(property);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isFavorite =
              propertyId != null && favoriteIds.contains(propertyId);
          return AlertDialog(
            backgroundColor: const Color(0xFFDCDCDC),
            title: Text(
              property['title'] ?? 'Property Details',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Location', property['location'] ?? 'N/A'),
                  _buildDetailRow(
                    'Total Area',
                    '${property['total_area'] ?? 'N/A'} sq ft',
                  ),
                  _buildDetailRow(
                    'Total Units',
                    '${property['total_units'] ?? 'N/A'}',
                  ),
                  _buildDetailRow(
                    'Bedrooms',
                    '${property['bedrooms'] ?? 'N/A'} per unit',
                  ),
                  _buildDetailRow(
                    'Bathrooms',
                    '${property['bathrooms'] ?? 'N/A'} per unit',
                  ),
                  _buildDetailRow('Price', '৳${property['price'] ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property['description'] ?? 'No description available',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  if (propertyId == null) return;
                  final wasFavorite = favoriteIds.contains(propertyId);
                  _toggleFavorite(property);
                  setDialogState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wasFavorite
                            ? 'Removed from favorites!'
                            : 'Added to favorites!',
                      ),
                      backgroundColor: const Color(0xFF32CD32),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.white,
                ),
                label: Text(
                  isFavorite ? 'Favorited' : 'Favourite',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32CD32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
