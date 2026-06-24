import 'package:flutter/material.dart';
import 'broadcast_colors.dart';
import '../utils/design_tokens.dart';

/// Reusable badge widget for broadcast types (IE, IC, Implementation)
class BroadcastBadge extends StatelessWidget {
  final String type;
  final double? fontSize;
  
  const BroadcastBadge({
    super.key,
    required this.type,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final colors = BroadcastColors.getBroadcastColors(type);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors['background'],
        border: Border.all(color: colors['border']!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: colors['text'],
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Reusable badge widget for status (BELUM, PROGRESS, SELESAI)
class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  
  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final colors = BroadcastColors.getStatusColors(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors['background'],
        border: Border.all(color: colors['border']!, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: colors['text'],
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Info row with icon and text (for date range, activity count, etc.)
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final double? fontSize;
  
  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? BroadcastColors.iconSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: BroadcastColors.textMeta,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

/// Activity summary item (for the bottom section of card)
class ActivitySummaryItem extends StatelessWidget {
  final String name;
  final String time;
  final IconData? icon;
  final bool isCompleted;
  
  const ActivitySummaryItem({
    super.key,
    required this.name,
    required this.time,
    this.icon = Icons.task_alt,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted 
                ? BroadcastColors.statusSelesaiBg 
                : BroadcastColors.iconMuted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 14,
              color: isCompleted 
                ? BroadcastColors.statusSelesaiText
                : BroadcastColors.iconSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTypography.bodySmall.copyWith(
                color: BroadcastColors.textSubtitle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: AppTypography.caption.copyWith(
              color: BroadcastColors.textMeta,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Main work detail card matching Django broadcast styling
class WorkDetailCard extends StatelessWidget {
  final String title;
  final String broadcastType;
  final String status;
  final String dateRange;
  final int activityCount;
  final List<ActivitySummaryItem> activities;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  
  const WorkDetailCard({
    super.key,
    required this.title,
    required this.broadcastType,
    required this.status,
    required this.dateRange,
    required this.activityCount,
    this.activities = const [],
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: BroadcastColors.cardShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.medium),
        side: BorderSide(
          color: BroadcastColors.cardBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.medium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                children: [
                  // Work icon (matching screenshot style)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: BroadcastColors.iconPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.engineering,
                      size: 18,
                      color: BroadcastColors.iconPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.h3.copyWith(
                            color: BroadcastColors.textTitle,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        
                        // Badges row
                        Row(
                          children: [
                            BroadcastBadge(type: broadcastType),
                            const SizedBox(width: 8),
                            StatusBadge(status: status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: BroadcastColors.iconSecondary,
                          ),
                          onPressed: onEdit,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: BroadcastColors.iconSecondary,
                          ),
                          onPressed: onDelete,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Meta info section
              Row(
                children: [
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: dateRange,
                  ),
                  const SizedBox(width: 16),
                  InfoRow(
                    icon: Icons.assignment_outlined,
                    text: '$activityCount log',
                  ),
                ],
              ),
              
              // Activities section (if any)
              if (activities.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(
                  height: 1,
                  color: BroadcastColors.cardBorder,
                ),
                const SizedBox(height: 12),
                
                ...activities,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Specialized card for work items in a project
class ProjectWorkCard extends StatelessWidget {
  final String workTitle;
  final String projectTitle;
  final String broadcastType;
  final String status;
  final String startDate;
  final String endDate;
  final int activityCount;
  final List<Map<String, dynamic>> activities; // {name, time, completed}
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  
  const ProjectWorkCard({
    super.key,
    required this.workTitle,
    required this.projectTitle,
    required this.broadcastType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.activityCount,
    this.activities = const [],
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  String _formatDateRange(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      
      final startFormatted = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endFormatted = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      
      return '$startFormatted - $endFormatted';
    } catch (e) {
      return '$startDate - $endDate';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = _formatDateRange(startDate, endDate);
    
    final activityItems = activities
        .map((activity) => ActivitySummaryItem(
              name: activity['name'] ?? '',
              time: activity['time'] ?? '',
              isCompleted: activity['completed'] ?? false,
            ))
        .toList();
    
    return WorkDetailCard(
      title: workTitle,
      broadcastType: broadcastType,
      status: status,
      dateRange: dateRange,
      activityCount: activityCount,
      activities: activityItems,
      onEdit: onEdit,
      onDelete: onDelete,
      onTap: onTap,
    );
  }
}