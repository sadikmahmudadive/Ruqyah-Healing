import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String therapistName;
  final int basePrice;

  const BookAppointmentScreen({
    super.key,
    this.therapistName = 'Dr. Salma Rahman',
    this.basePrice = 1200,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  String _selectedService = 'Ruqyah Healing (In-person)';
  String _consultationMode = 'In-person'; // 'In-person' or 'Video Call'
  int _selectedDay = 20;
  String _selectedSlot = '10:30 AM';
  String _selectedPatient = 'Aamina Begum';
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _services = const [
    'Ruqyah Healing (In-person)',
    'Hijama Therapy (In-person)',
    'Acupuncture Consultation',
    'Online Ruqyah Video Session',
  ];

  final List<String> _timeSlots = const [
    '9:00 AM',
    '10:30 AM',
    '12:30 PM',
    '3:00 PM',
    '4:30 PM',
    '6:00 PM',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _showServiceDropdown() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Therapy Service',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF15221D),
              ),
            ),
            const SizedBox(height: 14),
            ..._services.map((service) {
              final isSelected = service == _selectedService;
              return ListTile(
                title: Text(
                  service,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF0B4632) : const Color(0xFF15221D),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0B4632))
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedService = service;
                  });
                  Navigator.of(context).pop();
                },
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment booked for $_selectedService on May $_selectedDay at $_selectedSlot!',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: const Color(0xFF0B4632),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F6),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF15221D),
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'Book Appointment',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15221D),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Select Service Dropdown Card
              _buildSelectServiceCard(),

              const SizedBox(height: 16),

              // 2. Consultation Mode Segmented Toggle (In-person vs Video Call)
              _buildConsultationModeSegment(),

              const SizedBox(height: 20),

              // 3. Calendar Card (May 2024)
              _buildCalendarCard(),

              const SizedBox(height: 20),

              // 4. Available Slots Section
              _buildAvailableSlotsSection(),

              const SizedBox(height: 20),

              // 5. Pricing & Patient Profile Summary Card
              _buildSummaryCard(),

              const SizedBox(height: 20),

              // 6. Reason for Visit Input Field
              _buildReasonInputSection(),

              const SizedBox(height: 24),

              // 7. Bottom Primary Action Button: Continue
              _buildContinueButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Select Service Dropdown Card
  Widget _buildSelectServiceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showServiceDropdown,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Crescent Moon Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B4632),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.nights_stay_rounded,
                      color: Color(0xFFE0E0E0),
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Service',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6E7E77),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedService,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15221D),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dropdown Arrow
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF6E7E77),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2. Consultation Mode Segmented Toggle (In-person / Video Call)
  Widget _buildConsultationModeSegment() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentOption(
              label: 'In-person',
              icon: null,
              isSelected: _consultationMode == 'In-person',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _consultationMode = 'In-person');
              },
            ),
          ),
          Expanded(
            child: _buildSegmentOption(
              label: 'Video Call',
              icon: Icons.desktop_windows_outlined,
              isSelected: _consultationMode == 'Video Call',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _consultationMode = 'Video Call');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentOption({
    required String label,
    required IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B4632) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF6E7E77),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF6E7E77),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Calendar Card (May 2024)
  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Navigation Header
          Row(
            children: [
              const Text(
                'May 2024',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15221D),
                ),
              ),
              const Spacer(),
              _buildCalendarNavArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  HapticFeedback.selectionClick();
                },
              ),
              const SizedBox(width: 8),
              _buildCalendarNavArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  HapticFeedback.selectionClick();
                },
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Days of Week Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              SizedBox(
                width: 32,
                child: Text(
                  'SUN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  'MON',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  'TUE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  'WED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  'THU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  'FRI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  'SAT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Calendar Days Grid (5 Rows x 7 Days)
          _buildCalendarGrid(),
        ],
      ),
    );
  }



  Widget _buildCalendarNavArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF15221D), size: 20),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // 35 Calendar Cells for May 2024
    // Row 1: 28, 29, 30 (prev month disabled), 1, 2, 3, 4
    // Row 2: 5, 6, 7, 8, 9, 10, 11
    // Row 3: 12, 13, 14, 15, 16, 17, 18
    // Row 4: 19 (today outline), 20 (selected active), 21, 22, 23, 24, 25
    // Row 5: 26, 27, 28, 29, 30, 31, 1 (next month disabled)

    final List<int?> daysGrid = [
      null, null, null, 1, 2, 3, 4,
      5, 6, 7, 8, 9, 10, 11,
      12, 13, 14, 15, 16, 17, 18,
      19, 20, 21, 22, 23, 24, 25,
      26, 27, 28, 29, 30, 31, -1,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 35,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final dayNum = daysGrid[index];

        if (dayNum == null) {
          // Disabled previous month day (28, 29, 30)
          final prevDay = 27 + (index + 1);
          return Center(
            child: Text(
              '$prevDay',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFFCFD8DC),
              ),
            ),
          );
        }

        if (dayNum == -1) {
          // Disabled next month day (1)
          return const Center(
            child: Text(
              '1',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFFCFD8DC),
              ),
            ),
          );
        }

        final isToday = dayNum == 19;
        final isSelected = dayNum == _selectedDay;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedDay = dayNum;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color(0xFF0B4632)
                  : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF0B4632), width: 1.5)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            const Color(0xFF0B4632).withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                '$dayNum',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF15221D),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 4. Available Slots Section
  Widget _buildAvailableSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available on Mon, May $_selectedDay',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15221D),
          ),
        ),

        const SizedBox(height: 12),

        // Grid of 6 Slots (2 Rows x 3 Columns)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _timeSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 46,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final slot = _timeSlots[index];
            final isSelected = slot == _selectedSlot;

            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedSlot = slot;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0B4632) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0B4632)
                        : const Color(0xFFE2E8E5),
                    width: 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF0B4632).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    slot,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF6E7E77),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 5. Pricing & Patient Profile Summary Card
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Session Fee Row
          Row(
            children: [
              const Text(
                'Session Fee',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: Color(0xFF90A4AE),
                ),
              ),
              const Spacer(),
              Text(
                '৳${widget.basePrice}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Duration Row
          Row(
            children: const [
              Text(
                'Duration',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: Color(0xFF90A4AE),
                ),
              ),
              Spacer(),
              Text(
                '45 minutes',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15221D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFE2E8E5)),
          const SizedBox(height: 12),

          // Patient Profile Row
          Row(
            children: [
              const Text(
                'Patient Profile',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: Color(0xFF90A4AE),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                },
                child: Row(
                  children: [
                    Text(
                      _selectedPatient,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF0B4632),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. Reason for Visit Input Field
  Widget _buildReasonInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason for Visit',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15221D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _reasonController,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.5,
              color: Color(0xFF15221D),
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Anxiety, Jinn, Evil Eye',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: const Color(0xFFB0BEC5),
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  // 7. Bottom Primary Action Button: Continue
  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0B4632),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4632).withValues(alpha: 0.30),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleContinue,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: const Center(
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
