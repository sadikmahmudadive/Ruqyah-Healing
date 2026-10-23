import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/community_models.dart';
import '../../theme/app_theme.dart';

class ReactionPickerOverlay extends StatefulWidget {
  final Function(PostReactionType reaction) onReactionSelected;
  final VoidCallback onDismiss;

  const ReactionPickerOverlay({
    super.key,
    required this.onReactionSelected,
    required this.onDismiss,
  });

  @override
  State<ReactionPickerOverlay> createState() => _ReactionPickerOverlayState();
}

class _ReactionPickerOverlayState extends State<ReactionPickerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  PostReactionType? _hoveredReaction;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(PostReactionType reaction) {
    HapticFeedback.mediumImpact();
    widget.onReactionSelected(reaction);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.bottomLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? const Color(0xFF132820)
                : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: context.isDarkMode
                  ? const Color(0xFF27493B)
                  : const Color(0xFFCFD8D0),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDarkMode ? 0.35 : 0.14),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: PostReactionType.values.map((reaction) {
              final isHovered = _hoveredReaction == reaction;
              return GestureDetector(
                onTap: () => _select(reaction),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredReaction = reaction),
                  onExit: (_) => setState(() => _hoveredReaction = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    transform: Matrix4.diagonal3Values(
                            isHovered ? 1.28 : 1.0,
                            isHovered ? 1.28 : 1.0,
                            1.0)
                        ..setTranslationRaw(0.0, isHovered ? -8.0 : 0.0, 0.0),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isHovered)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              reaction.label,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Text(
                          reaction.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
