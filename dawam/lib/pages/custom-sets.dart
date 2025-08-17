import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dawam/services/supabase_service.dart';
import 'package:dawam/models/tasbeeh_models.dart';

// iOS-inspired Color Scheme
class AppColors {
  static const primary = Color(0xFFD4AF37); // Elegant Gold
  static const primaryLight = Color(0xFFF5E6A3);
  static const secondary = Color(0xFF8B4513); // Saddle Brown
  static const background = Color(0xFFFCFBF8); // Off-white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFF8F7F4);
  static const onBackground = Color(0xFF1C1B1A);
  static const onSurface = Color(0xFF2C2B28);
  static const onSurfaceVariant = Color(0xFF8A8983);
  static const accent = Color(0xFFA0785A); // Warm brown
  static const accentLight = Color(0xFFE8DDD4);
  static const divider = Color(0xFFEDE9E4);
  static const shadow = Color(0x08000000);
}

// Model for selected supplications in a custom set
class SelectedSupplication {
  final TasbeehSet supplication;
  int count;

  SelectedSupplication({
    required this.supplication,
    required this.count,
  });
}

class CustomSetsPage extends StatefulWidget {
  const CustomSetsPage({super.key});

  @override
  State<CustomSetsPage> createState() => _CustomSetsPageState();
}

class _CustomSetsPageState extends State<CustomSetsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<TasbeehSet> _userSets = [];
  List<TasbeehSet> _allSets = [];
  String _searchQuery = '';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final sets = await _supabaseService.getTasbeehSets();

      print('DEBUG: Total sets loaded: ${sets.length}');
      for (var set in sets) {
        print('DEBUG: Set - Name: ${set.name}, UserId: ${set.userId}, IsDefault: ${set.isDefault}, Category: ${set.category}');
      }

      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      print('DEBUG: Current User ID: $currentUserId');

      setState(() {
        _allSets = sets;
        // Filter user sets: either has userId matching current user OR is a custom collection
        _userSets = sets.where((set) =>
        (set.userId != null && set.userId == currentUserId) ||
            (!set.isDefault && set.category == 'Custom Collection')
        ).toList();

        print('DEBUG: Filtered user sets: ${_userSets.length}');
        for (var set in _userSets) {
          print('DEBUG: User Set - Name: ${set.name}, UserId: ${set.userId}');
        }

        // Sort user sets by most recently created/updated
        _userSets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading custom sets: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showCreateSetDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateCustomSetDialog(
        availableSupplications: _allSets.where((set) => set.isDefault).toList(),
        onSetCreated: (setName, selectedSupplications, color) async {
          try {
            // Check if user is logged in
            final currentUser = Supabase.instance.client.auth.currentUser;
            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please log in to create custom sets'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // For now, create a single set with the first supplication
            // TODO: Extend schema to support collections of multiple supplications
            if (selectedSupplications.isNotEmpty) {
              final firstSupplication = selectedSupplications.first;
              final customSet = TasbeehSet(
                id: '',
                userId: currentUser.id, // Use the current user's ID
                name: setName,
                arabicText: firstSupplication.supplication.arabicText,
                transliteration: firstSupplication.supplication.transliteration,
                translation: firstSupplication.supplication.translation,
                meaning: firstSupplication.supplication.meaning,
                recommendedCount: firstSupplication.count,
                category: 'Custom Collection',
                accentColorHex: '#${color.value.toRadixString(16).substring(2)}',
                isDefault: false,
                isActive: true,
                createdAt: DateTime.now(),
              );

              final setId = await _supabaseService.createCustomTasbeehSet(customSet);
              print('DEBUG: Created set with ID: $setId');

              if (setId != null) {
                print('DEBUG: Adding new set to local lists');

                // Immediately add to local list for instant UI update
                final newSet = customSet.copyWith(id: setId);
                setState(() {
                  _userSets.insert(0, newSet); // Add to top of list
                  _allSets.add(newSet);
                });

                // Also refresh from database to ensure consistency
                await _loadData();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Custom set "$setName" created successfully!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              } else {
                print('DEBUG: Failed to create set - setId is null');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create set: No ID returned'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create set: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "today";
    } else if (difference.inDays == 1) {
      return "yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Back button and title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.divider,
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Custom Sets",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onBackground,
                                letterSpacing: -0.8,
                              ),
                            ),
                            Text(
                              "Create your own dhikr collections",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create new set button
                    GestureDetector(
                      onTap: _showCreateSetDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 30,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Create New Collection",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Mix and match supplications with custom counts",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: -0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Your Custom Sets section
                    if (_userSets.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your Collections",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            "${_userSets.length} sets",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // User's custom sets list
                      ...(_userSets.map((set) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomSetCard(
                          set: set,
                          onTap: () {
                            // TODO: Navigate to set details/edit page
                          },
                          onDelete: () async {
                            final success = await _supabaseService.deleteTasbeehSet(set.id);
                            if (success) {
                              _loadData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Set "${set.name}" deleted'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ))),

                      const SizedBox(height: 24),
                    ] else ...[
                      // Empty state
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 64,
                              color: AppColors.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Custom Sets Yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Create your first collection by tapping the + above",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Create Custom Set Dialog
class CreateCustomSetDialog extends StatefulWidget {
  final List<TasbeehSet> availableSupplications;
  final Function(String, List<SelectedSupplication>, Color) onSetCreated;

  const CreateCustomSetDialog({
    super.key,
    required this.availableSupplications,
    required this.onSetCreated,
  });

  @override
  State<CreateCustomSetDialog> createState() => _CreateCustomSetDialogState();
}

class _CreateCustomSetDialogState extends State<CreateCustomSetDialog> {
  final _setNameController = TextEditingController();
  List<SelectedSupplication> _selectedSupplications = [];
  Color _selectedColor = const Color(0xFF4CAF50);
  String _searchQuery = '';

  final List<Color> _colorOptions = [
    const Color(0xFF4CAF50), // Green
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF795548), // Brown
    const Color(0xFF00BCD4), // Cyan
  ];

  List<TasbeehSet> get _filteredSupplications {
    if (_searchQuery.isEmpty) {
      return widget.availableSupplications;
    }
    return widget.availableSupplications.where((sup) =>
    sup.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        sup.transliteration.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        sup.translation.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _setNameController.dispose();
    super.dispose();
  }

  void _addSupplication(TasbeehSet supplication) {
    // Check if already added
    final exists = _selectedSupplications.any(
            (selected) => selected.supplication.id == supplication.id
    );

    if (!exists) {
      setState(() {
        _selectedSupplications.add(SelectedSupplication(
          supplication: supplication,
          count: supplication.recommendedCount,
        ));
      });
      HapticFeedback.lightImpact();
    }
  }

  void _removeSupplication(int index) {
    setState(() {
      _selectedSupplications.removeAt(index);
    });
    HapticFeedback.lightImpact();
  }

  void _updateCount(int index, int newCount) {
    setState(() {
      _selectedSupplications[index].count = newCount;
    });
  }

  void _createSet() {
    if (_setNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a set name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSupplications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one supplication'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);
    widget.onSetCreated(
      _setNameController.text.trim(),
      _selectedSupplications,
      _selectedColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Create Collection",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Set name input
                  TextField(
                    controller: _setNameController,
                    decoration: InputDecoration(
                      hintText: "Collection name (e.g., 'Morning Dhikr')",
                      hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5)),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: TextStyle(color: AppColors.onSurface),
                  ),

                  const SizedBox(height: 16),

                  // Color selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Color:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _colorOptions.map((color) {
                          final isSelected = color == _selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                              child: isSelected ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ) : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Selected supplications section
            if (_selectedSupplications.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Added Supplications (${_selectedSupplications.length})",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedSupplications.length,
                        itemBuilder: (context, index) {
                          final selected = _selectedSupplications[index];
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selected.supplication.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected.supplication.accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selected.supplication.transliteration,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _removeSupplication(index),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.red.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  selected.supplication.translation,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      "Count:",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          isDense: true,
                                        ),
                                        controller: TextEditingController(
                                            text: selected.count.toString()),
                                        onChanged: (value) {
                                          final newCount = int.tryParse(value) ?? 1;
                                          _updateCount(index, newCount);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search supplications...",
                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Available supplications list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredSupplications.length,
                itemBuilder: (context, index) {
                  final supplication = _filteredSupplications[index];
                  final isAdded = _selectedSupplications.any(
                          (selected) => selected.supplication.id == supplication.id
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => _addSupplication(supplication),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isAdded
                              ? supplication.accentColor.withOpacity(0.1)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAdded
                                ? supplication.accentColor.withOpacity(0.3)
                                : AppColors.divider,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: supplication.accentColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supplication.transliteration,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    supplication.translation,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: supplication.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${supplication.recommendedCount}x",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: supplication.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isAdded ? Icons.check_circle : Icons.add_circle_outline,
                              color: isAdded
                                  ? supplication.accentColor
                                  : AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Create button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createSet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Create Collection",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Set Card Widget
class CustomSetCard extends StatelessWidget {
  final TasbeehSet set;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CustomSetCard({
    super.key,
    required this.set,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "today";
    } else if (difference.inDays == 1) {
      return "yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    set.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: set.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${set.recommendedCount}x",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: set.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              set.translation,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    set.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "Created ${_formatDate(set.createdAt)}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}