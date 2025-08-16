import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dawam/theme/app-theme.dart';

class TasbeehSet {
  final String id;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String meaning;
  final int recommendedCount;
  final String category;
  final Color accentColor;

  const TasbeehSet({
    required this.id,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.meaning,
    required this.recommendedCount,
    required this.category,
    required this.accentColor,
  });
}

class TasbeehSetsPage extends StatefulWidget {
  const TasbeehSetsPage({super.key});

  @override
  State<TasbeehSetsPage> createState() => _TasbeehSetsPageState();
}

class _TasbeehSetsPageState extends State<TasbeehSetsPage> {
  final List<TasbeehSet> tasbeehSets = [
    TasbeehSet(
      id: 'subhanallah',
      arabicText: 'سُبْحَانَ ٱللَّٰهِ',
      transliteration: 'SubhanAllah',
      translation: 'Glory be to Allah',
      meaning: 'Glorifying Allah and declaring Him free from all imperfections',
      recommendedCount: 33,
      category: 'Essential Dhikr',
      accentColor: Color(0xFF4CAF50),
    ),
    TasbeehSet(
      id: 'alhamdulillah',
      arabicText: 'ٱلْحَمْدُ لِلَّٰهِ',
      transliteration: 'Alhamdulillah',
      translation: 'All praise is due to Allah',
      meaning: 'Expressing gratitude and acknowledging Allah as the source of all blessings',
      recommendedCount: 33,
      category: 'Essential Dhikr',
      accentColor: Color(0xFF2196F3),
    ),
    TasbeehSet(
      id: 'allahu_akbar',
      arabicText: 'ٱللَّٰهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      translation: 'Allah is the Greatest',
      meaning: 'Affirming the supreme greatness and majesty of Allah',
      recommendedCount: 34,
      category: 'Essential Dhikr',
      accentColor: Color(0xFFFF9800),
    ),
    TasbeehSet(
      id: 'la_ilaha_illa_allah',
      arabicText: 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      transliteration: 'La ilaha illa Allah',
      translation: 'There is no god but Allah',
      meaning: 'The fundamental declaration of Islamic monotheism (Tawhid)',
      recommendedCount: 100,
      category: 'Tawhid',
      accentColor: Color(0xFF9C27B0),
    ),
    TasbeehSet(
      id: 'astaghfirullah',
      arabicText: 'أَسْتَغْفِرُ ٱللَّٰهَ',
      transliteration: 'Astaghfirullah',
      translation: 'I seek forgiveness from Allah',
      meaning: 'Seeking Allah\'s forgiveness and repenting for sins',
      recommendedCount: 100,
      category: 'Seeking Forgiveness',
      accentColor: Color(0xFFE91E63),
    ),
    TasbeehSet(
      id: 'la_hawla_wa_la_quwwata',
      arabicText: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّٰهِ',
      transliteration: 'La hawla wa la quwwata illa billah',
      translation: 'There is no power except with Allah',
      meaning: 'Acknowledging that all strength and ability come from Allah alone',
      recommendedCount: 10,
      category: 'Reliance on Allah',
      accentColor: Color(0xFF607D8B),
    ),
    TasbeehSet(
      id: 'hasbi_allah',
      arabicText: 'حَسْبِيَ ٱللَّٰهُ وَنِعْمَ ٱلْوَكِيلُ',
      transliteration: 'HasbiyAllahu wa ni\'mal wakeel',
      translation: 'Allah is sufficient for me, and He is the best Disposer of affairs',
      meaning: 'Expressing complete trust and reliance in Allah\'s protection and guidance',
      recommendedCount: 7,
      category: 'Trust in Allah',
      accentColor: Color(0xFF795548),
    ),
    TasbeehSet(
      id: 'salawat',
      arabicText: 'ٱللَّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ',
      transliteration: 'Allahumma salli \'ala Muhammad wa \'ala ali Muhammad',
      translation: 'O Allah, send blessings upon Muhammad and the family of Muhammad',
      meaning: 'Sending prayers and blessings upon Prophet Muhammad (peace be upon him)',
      recommendedCount: 10,
      category: 'Salawat',
      accentColor: Color(0xFF00BCD4),
    ),
  ];

  String selectedCategory = 'All';

  List<String> get categories {
    final cats = ['All'] + tasbeehSets.map((set) => set.category).toSet().toList();
    return cats;
  }

  List<TasbeehSet> get filteredSets {
    if (selectedCategory == 'All') return tasbeehSets;
    return tasbeehSets.where((set) => set.category == selectedCategory).toList();
  }

  void _navigateToTasbeehCounter(TasbeehSet set) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TasbeehCounterPage(tasbeehSet: set),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.appColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.appColors.divider,
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: context.appColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tasbeeh Sets",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: context.appColors.onBackground,
                              letterSpacing: -0.8,
                            ),
                          ),
                          Text(
                            "Pre-Made",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: context.appColors.onSurfaceVariant,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == selectedCategory;

                      return Padding(
                        padding: EdgeInsets.only(right: index < categories.length - 1 ? 12 : 0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : context.appColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : context.appColors.divider,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.black
                                    : context.appColors.onSurface,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Tasbeeh Sets Grid
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredSets.length,
                  itemBuilder: (context, index) {
                    final set = filteredSets[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < filteredSets.length - 1 ? 16 : 0),
                      child: TasbeehSetCard(
                        set: set,
                        onTap: () => _navigateToTasbeehCounter(set),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TasbeehSetCard extends StatefulWidget {
  final TasbeehSet set;
  final VoidCallback onTap;

  const TasbeehSetCard({
    super.key,
    required this.set,
    required this.onTap,
  });

  @override
  State<TasbeehSetCard> createState() => _TasbeehSetCardState();
}

class _TasbeehSetCardState extends State<TasbeehSetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.appColors.divider,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with category and count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.set.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.set.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.set.accentColor,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${widget.set.recommendedCount}x",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Arabic text
                  Center(
                    child: Text(
                      widget.set.arabicText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.onSurface,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Transliteration
                  Center(
                    child: Text(
                      widget.set.transliteration,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.set.accentColor,
                        letterSpacing: -0.3,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Translation
                  Center(
                    child: Text(
                      widget.set.translation,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.onSurface,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Meaning
                  Text(
                    widget.set.meaning,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.onSurfaceVariant,
                      letterSpacing: -0.1,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Start button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.set.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.set.accentColor.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 18,
                          color: widget.set.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Start Dhikr",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.set.accentColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Placeholder for the individual Tasbeeh Counter page
class TasbeehCounterPage extends StatelessWidget {
  final TasbeehSet tasbeehSet;

  const TasbeehCounterPage({super.key, required this.tasbeehSet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.appColors.divider,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: context.appColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Dhikr Counter",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.onBackground,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Content placeholder
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tasbeehSet.arabicText,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.onSurface,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Counter Page Coming Soon",
                        style: TextStyle(
                          fontSize: 18,
                          color: context.appColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}