import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/community_models.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../app_toast.dart';
import '../islamic_pattern.dart';

class CreateStorySheet extends StatefulWidget {
  final Function(StorySlide slide) onStoryCreated;

  const CreateStorySheet({super.key, required this.onStoryCreated});

  @override
  State<CreateStorySheet> createState() => _CreateStorySheetState();
}

class _CreateStorySheetState extends State<CreateStorySheet> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _verseController = TextEditingController();

  int _selectedGradientIndex = 0;
  String? _selectedAyahSnippet;

  final List<({String name, LinearGradient gradient})> _availableGradients = [
    (
      name: 'Emerald Shifa',
      gradient: const LinearGradient(
        colors: [Color(0xFF082F21), Color(0xFF0F593D), Color(0xFF1B7A54)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    (
      name: 'Golden Shifa',
      gradient: const LinearGradient(
        colors: [Color(0xFF7A4E0B), Color(0xFFC68A1F), Color(0xFFD49E35)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    (
      name: 'Midnight Noor',
      gradient: const LinearGradient(
        colors: [Color(0xFF0B192C), Color(0xFF1E3E62), Color(0xFF000000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    (
      name: 'Sage Serenity',
      gradient: const LinearGradient(
        colors: [Color(0xFF1C3B2B), Color(0xFF2E6047), Color(0xFF4B8B67)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    (
      name: 'Warm Sunset',
      gradient: const LinearGradient(
        colors: [Color(0xFF5C2C16), Color(0xFF9E4B27), Color(0xFFC97A3E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  final List<({String arabic, String ref, String meaning})> _suggestedVerses = [
    (
      arabic: 'وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ',
      ref: 'Ash-Shu\'ara 26:80',
      meaning: 'And when I am ill, it is He who cures me.',
    ),
    (
      arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      ref: 'Ali \'Imran 3:173',
      meaning: 'Sufficient for us is Allah, and He is the best Disposer of affairs.',
    ),
    (
      arabic: 'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ',
      ref: 'Al-Anbiya 21:83',
      meaning: 'Indeed, adversity has touched me, and You are the Most Merciful.',
    ),
    (
      arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      ref: 'Ar-Ra\'d 13:28',
      meaning: 'Unquestionably, by the remembrance of Allah hearts are assured.',
    ),
  ];

  @override
  void dispose() {
    _captionController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  void _publishStory() {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _selectedAyahSnippet == null) {
      AppToast.show(
        context,
        title: 'Story Empty',
        message: 'Please write a reflection or select an Ayah.',
        type: ToastType.warning,
      );
      return;
    }

    HapticFeedback.lightImpact();

    String? arabic;
    String? ref;
    if (_selectedAyahSnippet != null) {
      final verse = _suggestedVerses.firstWhere((v) => v.arabic == _selectedAyahSnippet);
      arabic = verse.arabic;
      ref = verse.ref;
    }

    final newSlide = StorySlide(
      id: 'slide_${DateTime.now().millisecondsSinceEpoch}',
      caption: caption.isNotEmpty ? caption : 'May Allah grant ease and complete Shifa to everyone in our community. Ameen.',
      arabicVerse: arabic,
      verseReference: ref,
      bgGradient: _availableGradients[_selectedGradientIndex].gradient,
      timestamp: 'Just now',
    );

    widget.onStoryCreated(newSlide);
    Navigator.of(context).pop();

    AppToast.show(
      context,
      title: 'Story Added',
      message: 'Your story has been shared to Community Stories.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentGrad = _availableGradients[_selectedGradientIndex].gradient;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: context.pageBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.cardBorderStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Add to Your Story',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: context.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live Story Preview Box
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: currentGrad,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Geometric pattern
                        const Positioned.fill(
                          child: IslamicPattern(
                            color: Colors.white,
                            opacity: 0.12,
                            cell: 64,
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_selectedAyahSnippet != null) ...[
                                  Text(
                                    _selectedAyahSnippet!,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 18,
                                      color: Color(0xFFFDE68A),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                Text(
                                  _captionController.text.isNotEmpty
                                      ? _captionController.text
                                      : 'Tap below to type your reflection or du\'a...',
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 15,
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Background Gradient Selector
                  Text(
                    'Story Theme',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableGradients.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedGradientIndex;
                        return InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedGradientIndex = index);
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: _availableGradients[index].gradient,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 22)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Caption Input
                  Text(
                    'Your Reflection / Du\'a',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _captionController,
                    maxLines: 3,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: context.textPrimary,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Share a blessing, prayer request, or recovery milestone...',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        color: context.textSecondary.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: context.cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: context.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: context.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF0B4632),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Suggested Quranic Verses for Story
                  Row(
                    children: [
                      Text(
                        'Attach Quranic Shifa Ayah',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedAyahSnippet != null)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedAyahSnippet = null);
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedVerses.map((v) {
                      final isSelected = _selectedAyahSnippet == v.arabic;
                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedAyahSnippet = isSelected ? null : v.arabic;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (context.isDarkMode
                                    ? const Color(0xFF182E25)
                                    : AppColors.tintMint)
                                : context.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0B4632)
                                  : context.cardBorder,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                v.arabic,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFF0B4632)
                                      : context.textPrimary,
                                ),
                              ),
                              Text(
                                v.ref,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.greenButtonGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF082F21).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _publishStory,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Share to Story',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
