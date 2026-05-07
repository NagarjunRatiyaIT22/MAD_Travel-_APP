import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Circular avatar widget for participants.
class ParticipantAvatar extends StatelessWidget {
  final String name;
  final int colorIndex;
  final double size;
  final bool showBorder;

  const ParticipantAvatar({
    super.key,
    required this.name,
    this.colorIndex = 0,
    this.size = 40,
    this.showBorder = false,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.avatarColors[colorIndex % AppColors.avatarColors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: Colors.white, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Overlapping row of participant avatars.
class ParticipantAvatarStack extends StatelessWidget {
  final List<String> names;
  final List<int> colorIndices;
  final double size;
  final int maxDisplay;

  const ParticipantAvatarStack({
    super.key,
    required this.names,
    required this.colorIndices,
    this.size = 32,
    this.maxDisplay = 4,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = names.length > maxDisplay ? maxDisplay : names.length;
    final remaining = names.length - displayCount;

    return SizedBox(
      height: size,
      width: size + (displayCount - 1) * (size * 0.65) + (remaining > 0 ? size * 0.65 : 0),
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * (size * 0.65),
              child: ParticipantAvatar(
                name: names[i],
                colorIndex: i < colorIndices.length ? colorIndices[i] : i,
                size: size,
                showBorder: true,
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: displayCount * (size * 0.65),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
