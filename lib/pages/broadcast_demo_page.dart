import 'package:flutter/material.dart';
import '../widgets/work_detail_card.dart';
import '../widgets/broadcast_colors.dart';
import '../utils/design_tokens.dart';

/// Demo page to showcase the broadcast-styled cards exactly like Django
class BroadcastDemoPage extends StatelessWidget {
  const BroadcastDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.almostWhite,
      appBar: AppBar(
        title: Text(
          'Broadcast Cards Demo',
          style: AppTypography.h3.copyWith(
            color: BroadcastColors.textTitle,
          ),
        ),
        backgroundColor: DesignColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: BroadcastColors.textTitle,
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Cards matching Django broadcast system',
              style: AppTypography.bodyLarge.copyWith(
                color: BroadcastColors.textSubtitle,
              ),
            ),
            const SizedBox(height: 24),
            
            // Badges showcase
            _buildBadgesSection(),
            const SizedBox(height: 32),
            
            // Cards showcase
            _buildCardsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Broadcast Badges & Status',
          style: AppTypography.h3.copyWith(
            color: BroadcastColors.textTitle,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DesignColors.bg,
            borderRadius: BorderRadius.circular(Radii.medium),
            border: Border.all(
              color: BroadcastColors.cardBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Broadcast type badges
              Text(
                'Broadcast Types:',
                style: AppTypography.labelMedium.copyWith(
                  color: BroadcastColors.textSubtitle,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  BroadcastBadge(type: 'IE'),
                  BroadcastBadge(type: 'IC'),
                  BroadcastBadge(type: 'IMPLEMENTATION'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Status badges
              Text(
                'Status Types:',
                style: AppTypography.labelMedium.copyWith(
                  color: BroadcastColors.textSubtitle,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  StatusBadge(status: 'BELUM'),
                  StatusBadge(status: 'PROGRESS'),
                  StatusBadge(status: 'SELESAI'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work Detail Cards',
          style: AppTypography.h3.copyWith(
            color: BroadcastColors.textTitle,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        
        // Card 1: Exact match to screenshot
        WorkDetailCard(
          title: 'asdas',
          broadcastType: 'IE',
          status: 'BELUM',
          dateRange: '2026-06-23 - 2026-06-25',
          activityCount: 1,
          activities: const [
            ActivitySummaryItem(
              name: 'dfadf',
              time: '13:13',
              isCompleted: false,
            ),
          ],
          onEdit: () => _showSnackBar(context, 'Edit: asdas'),
          onDelete: () => _showSnackBar(context, 'Delete: asdas'),
          onTap: () => _showSnackBar(context, 'View: asdas'),
        ),
        
        // Card 2: IC type with progress
        WorkDetailCard(
          title: 'System Configuration',
          broadcastType: 'IC',
          status: 'PROGRESS',
          dateRange: '2026-06-24 - 2026-06-28',
          activityCount: 3,
          activities: const [
            ActivitySummaryItem(
              name: 'Database setup',
              time: '09:15',
              isCompleted: true,
            ),
            ActivitySummaryItem(
              name: 'API configuration',
              time: '14:30',
              isCompleted: true,
            ),
            ActivitySummaryItem(
              name: 'Testing phase',
              time: '16:00',
              isCompleted: false,
            ),
          ],
          onEdit: () => _showSnackBar(context, 'Edit: System Configuration'),
          onDelete: () => _showSnackBar(context, 'Delete: System Configuration'),
          onTap: () => _showSnackBar(context, 'View: System Configuration'),
        ),
        
        // Card 3: Implementation completed
        WorkDetailCard(
          title: 'Final Deployment',
          broadcastType: 'IMPLEMENTATION',
          status: 'SELESAI',
          dateRange: '2026-06-26 - 2026-07-02',
          activityCount: 4,
          activities: const [
            ActivitySummaryItem(
              name: 'Production deployment',
              time: '08:00',
              isCompleted: true,
            ),
            ActivitySummaryItem(
              name: 'User acceptance testing',
              time: '11:30',
              isCompleted: true,
            ),
            ActivitySummaryItem(
              name: 'Documentation review',
              time: '15:45',
              isCompleted: true,
            ),
            ActivitySummaryItem(
              name: 'Project handover',
              time: '17:00',
              isCompleted: true,
            ),
          ],
          onEdit: () => _showSnackBar(context, 'Edit: Final Deployment'),
          onDelete: () => _showSnackBar(context, 'Delete: Final Deployment'),
          onTap: () => _showSnackBar(context, 'View: Final Deployment'),
        ),
        
        // Card 4: Minimal card without activities
        WorkDetailCard(
          title: 'Planning Phase',
          broadcastType: 'IE',
          status: 'BELUM',
          dateRange: '2026-07-01 - 2026-07-05',
          activityCount: 0,
          onEdit: () => _showSnackBar(context, 'Edit: Planning Phase'),
          onDelete: () => _showSnackBar(context, 'Delete: Planning Phase'),
          onTap: () => _showSnackBar(context, 'View: Planning Phase'),
        ),
      ],
    );
  }
  
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Widget to demonstrate color palette
class ColorPaletteDemo extends StatelessWidget {
  const ColorPaletteDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Color Palette'),
        backgroundColor: DesignColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColorSection('IE Colors', {
              'Primary': BroadcastColors.iePrimary,
              'Background': BroadcastColors.ieBackground,
              'Border': BroadcastColors.ieBorder,
              'Text': BroadcastColors.ieText,
            }),
            
            _buildColorSection('IC Colors', {
              'Primary': BroadcastColors.icPrimary,
              'Background': BroadcastColors.icBackground,
              'Border': BroadcastColors.icBorder,
              'Text': BroadcastColors.icText,
            }),
            
            _buildColorSection('Implementation Colors', {
              'Primary': BroadcastColors.implPrimary,
              'Background': BroadcastColors.implBackground,
              'Border': BroadcastColors.implBorder,
              'Text': BroadcastColors.implText,
            }),
            
            _buildColorSection('Status Colors', {
              'Belum': BroadcastColors.statusBelum,
              'Progress': BroadcastColors.statusProgress,
              'Selesai': BroadcastColors.statusSelesai,
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorSection(String title, Map<String, Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h3.copyWith(
            color: BroadcastColors.textTitle,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        ...colors.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: BroadcastColors.cardBorder,
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: AppTypography.labelMedium,
                    ),
                    Text(
                      entry.value.toString(),
                      style: AppTypography.caption.copyWith(
                        color: BroadcastColors.textMeta,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
        
        const SizedBox(height: 24),
      ],
    );
  }
}