import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CountryCode {
  final String flag;
  final String name;
  final String code;

  const CountryCode({
    required this.flag,
    required this.name,
    required this.code,
  });
}

const List<CountryCode> kDefaultCountryCodes = [
  CountryCode(flag: '🇧🇩', name: 'Bangladesh', code: '+880'),
  CountryCode(flag: '🇸🇦', name: 'Saudi Arabia', code: '+966'),
  CountryCode(flag: '🇦🇪', name: 'United Arab Emirates', code: '+971'),
  CountryCode(flag: '🇮🇩', name: 'Indonesia', code: '+62'),
  CountryCode(flag: '🇵🇰', name: 'Pakistan', code: '+92'),
  CountryCode(flag: '🇲🇾', name: 'Malaysia', code: '+60'),
  CountryCode(flag: '🇹🇷', name: 'Turkey', code: '+90'),
  CountryCode(flag: '🇪🇬', name: 'Egypt', code: '+20'),
  CountryCode(flag: '🇶🇦', name: 'Qatar', code: '+974'),
  CountryCode(flag: '🇰🇼', name: 'Kuwait', code: '+965'),
  CountryCode(flag: '🇴🇲', name: 'Oman', code: '+968'),
  CountryCode(flag: '🇧🇭', name: 'Bahrain', code: '+973'),
  CountryCode(flag: '🇯🇴', name: 'Jordan', code: '+962'),
  CountryCode(flag: '🇮🇶', name: 'Iraq', code: '+964'),
  CountryCode(flag: '🇱🇧', name: 'Lebanon', code: '+961'),
  CountryCode(flag: '🇵🇸', name: 'Palestine', code: '+970'),
  CountryCode(flag: '🇸🇾', name: 'Syria', code: '+963'),
  CountryCode(flag: '🇾🇪', name: 'Yemen', code: '+967'),
  CountryCode(flag: '🇮🇷', name: 'Iran', code: '+98'),
  CountryCode(flag: '🇲🇦', name: 'Morocco', code: '+212'),
  CountryCode(flag: '🇩🇿', name: 'Algeria', code: '+213'),
  CountryCode(flag: '🇹🇳', name: 'Tunisia', code: '+216'),
  CountryCode(flag: '🇱🇾', name: 'Libya', code: '+218'),
  CountryCode(flag: '🇸🇩', name: 'Sudan', code: '+249'),
  CountryCode(flag: '🇸🇴', name: 'Somalia', code: '+252'),
  CountryCode(flag: '🇦🇫', name: 'Afghanistan', code: '+93'),
  CountryCode(flag: '🇺🇿', name: 'Uzbekistan', code: '+998'),
  CountryCode(flag: '🇰🇿', name: 'Kazakhstan', code: '+7'),
  CountryCode(flag: '🇦🇿', name: 'Azerbaijan', code: '+994'),
  CountryCode(flag: '🇹🇲', name: 'Turkmenistan', code: '+993'),
  CountryCode(flag: '🇹🇯', name: 'Tajikistan', code: '+992'),
  CountryCode(flag: '🇰🇬', name: 'Kyrgyzstan', code: '+996'),
  CountryCode(flag: '🇲🇻', name: 'Maldives', code: '+960'),
  CountryCode(flag: '🇧🇳', name: 'Brunei', code: '+673'),
  CountryCode(flag: '🇲🇷', name: 'Mauritania', code: '+222'),
  CountryCode(flag: '🇸🇳', name: 'Senegal', code: '+221'),
  CountryCode(flag: '🇲🇱', name: 'Mali', code: '+223'),
  CountryCode(flag: '🇳🇪', name: 'Niger', code: '+227'),
  CountryCode(flag: '🇹🇩', name: 'Chad', code: '+235'),
  CountryCode(flag: '🇬🇲', name: 'Gambia', code: '+220'),
  CountryCode(flag: '🇬🇳', name: 'Guinea', code: '+224'),
  CountryCode(flag: '🇸🇱', name: 'Sierra Leone', code: '+232'),
  CountryCode(flag: '🇩🇯', name: 'Djibouti', code: '+253'),
  CountryCode(flag: '🇰🇲', name: 'Comoros', code: '+269'),
  CountryCode(flag: '🇳🇬', name: 'Nigeria', code: '+234'),
  CountryCode(flag: '🇦🇱', name: 'Albania', code: '+355'),
  CountryCode(flag: '🇽🇰', name: 'Kosovo', code: '+383'),
  CountryCode(flag: '🇧🇦', name: 'Bosnia & Herzegovina', code: '+387'),
  CountryCode(flag: '🇺🇸', name: 'United States', code: '+1'),
  CountryCode(flag: '🇬🇧', name: 'United Kingdom', code: '+44'),
  CountryCode(flag: '🇨🇦', name: 'Canada', code: '+1'),
  CountryCode(flag: '🇦🇺', name: 'Australia', code: '+61'),
  CountryCode(flag: '🇩🇪', name: 'Germany', code: '+49'),
  CountryCode(flag: '🇫🇷', name: 'France', code: '+33'),
  CountryCode(flag: '🇮🇳', name: 'India', code: '+91'),
];

Future<CountryCode?> showCountryCodePicker({
  required BuildContext context,
  required CountryCode selectedCountry,
}) {
  return showModalBottomSheet<CountryCode>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _CountryCodePickerSheet(
      selectedCountry: selectedCountry,
    ),
  );
}

class _CountryCodePickerSheet extends StatefulWidget {
  final CountryCode selectedCountry;

  const _CountryCodePickerSheet({
    required this.selectedCountry,
  });

  @override
  State<_CountryCodePickerSheet> createState() =>
      __CountryCodePickerSheetState();
}

class __CountryCodePickerSheetState extends State<_CountryCodePickerSheet> {
  late List<CountryCode> _filteredCountries;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = List.from(kDefaultCountryCodes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filteredCountries = List.from(kDefaultCountryCodes);
      } else {
        _filteredCountries = kDefaultCountryCodes.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF121820).withValues(alpha: 0.94),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title Header
                Row(
                  children: [
                    const Text(
                      'Select Country Code',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.70),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Search Bar
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: Colors.white.withValues(alpha: 0.55),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterCountries,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.5,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search country or code...',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.40),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Country List
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: _filteredCountries.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No matching country found',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.50),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredCountries.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                          itemBuilder: (context, index) {
                            final country = _filteredCountries[index];
                            final isSelected = country.code ==
                                    widget.selectedCountry.code &&
                                country.name == widget.selectedCountry.name;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  Navigator.of(context).pop(country);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        country.flag,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          country.name,
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        country.code,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFF2ECC71)
                                              : Colors.white
                                                  .withValues(alpha: 0.70),
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF2ECC71),
                                          size: 18,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
