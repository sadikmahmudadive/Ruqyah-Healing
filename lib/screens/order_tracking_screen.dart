import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'secure_messages_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String orderDate;
  final String courierName;
  final String destination;
  final String deliveryDate;
  final String status;

  const OrderTrackingScreen({
    super.key,
    this.orderId = 'RH1024',
    this.orderDate = '13 May 2024',
    this.courierName = 'Pathao Courier',
    this.destination = 'Dhaka, BD',
    this.deliveryDate = '15 May 2024',
    this.status = 'Delivered',
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        body: Column(
          children: [
            // 1. Top Dark Green Header Area
            _buildTopHeader(),

            // 2. Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Order Overview Card
                    _buildOrderOverviewCard(),

                    const SizedBox(height: 20),

                    // 2. Section Sub-Header
                    Row(
                      children: [
                        Container(
                          width: 3.5,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B4632),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'TRACKING TIMELINE',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFF90A4AE),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 3. Tracking Timeline Card
                    _buildTrackingTimelineCard(),

                    const SizedBox(height: 16),

                    // 4. View Invoice Button
                    _buildViewInvoiceButton(),

                    const SizedBox(height: 20),

                    // 5. Need Help with Order Banner
                    _buildSupportBanner(),

                    const SizedBox(height: 12),

                    // 6. Action Buttons Row (Reorder & Return / Refund)
                    _buildActionButtonsRow(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top Dark Green Header Area
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B4632),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),

          const Text(
            'Order Tracking',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 1. Order Overview Card
  Widget _buildOrderOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
          // Top Row: Icon + Order ID + Status Badge
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF0B4632),
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${widget.orderId}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Placed on ${widget.orderDate}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: Color(0xFF6E7E77),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.status,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B4632),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFE2E8E5)),
          const SizedBox(height: 14),

          // Bottom Details Row: Courier, Location, Date
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xFF90A4AE),
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.courierName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF6E7E77),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF90A4AE),
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.destination,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF6E7E77),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF90A4AE),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.deliveryDate,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF6E7E77),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Tracking Timeline Card
  Widget _buildTrackingTimelineCard() {
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
          _buildTimelineStep(
            title: 'Order Confirmed',
            timestamp: '13 May 2024 · 10:30 AM',
            isDone: true,
            isLast: false,
          ),
          _buildTimelineStep(
            title: 'Packed',
            timestamp: '13 May 2024 · 04:15 PM',
            isDone: true,
            isLast: false,
          ),
          _buildTimelineStep(
            title: 'Shipped',
            timestamp: '14 May 2024 · 09:20 AM · Pathao',
            isDone: true,
            isLast: false,
          ),
          _buildTimelineStep(
            title: 'Delivered',
            timestamp: '15 May 2024 · 12:45 PM · Dhaka, BD',
            isDone: true,
            isLast: true,
            showDoneBadge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String timestamp,
    required bool isDone,
    required bool isLast,
    bool showDoneBadge = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Check Icon + Vertical Line
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B4632),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8E5),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // Text Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15221D),
                        ),
                      ),
                      if (showDoneBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF7F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_rounded,
                                color: Color(0xFF0B4632),
                                size: 11,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Done',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0B4632),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF90A4AE),
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

  // 4. View Invoice Button
  Widget _buildViewInvoiceButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEBF7F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B4632).withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Downloading Order Invoice PDF...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                color: Color(0xFF0B4632),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'View Invoice',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B4632),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Need Help Banner
  Widget _buildSupportBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Need help with your order?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF6E7E77),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const SecureMessagesScreen(),
                ),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF0B4632),
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Chat with Support',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B4632),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Action Buttons Row (Reorder & Return / Refund)
  Widget _buildActionButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF7F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0B4632).withValues(alpha: 0.20),
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reordering items from Order #RH1024...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFF0B4632),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Reorder',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE74C3C).withValues(alpha: 0.20),
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Initiating return / refund request...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFFE74C3C),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Return / Refund',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
