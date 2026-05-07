import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'participant_avatar.dart';

/// Beautiful trip card with gradient cover, status badge and participant avatars.
class TripCard extends StatelessWidget {
  final TripModel trip;
  final List<String> participantNames;
  final List<int> participantColors;
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.trip,
    this.participantNames = const [],
    this.participantColors = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = AppColors.tripCoverGradients[
        trip.coverImageIndex % AppColors.tripCoverGradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Cover gradient
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  // Destination icon
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('✈️', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(
                          trip.destination,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              const Shadow(blurRadius: 8, color: Colors.black38),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trip.statusLabel,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.dateRange(trip.startDate, trip.endDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.daysLeft(trip.startDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (participantNames.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ParticipantAvatarStack(
                          names: participantNames,
                          colorIndices: participantColors,
                          size: 28,
                        ),
                        const Spacer(),
                        if (trip.budget > 0)
                          Text(
                            Formatters.currencyShort(trip.budget),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    if (trip.isOngoing) return AppColors.success;
    if (trip.isUpcoming) return AppColors.info;
    return AppColors.textSecondaryLight;
  }
}
