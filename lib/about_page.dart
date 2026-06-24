import 'package:flutter/material.dart';

import 'widgets/app_header.dart';
import '../utils/design_tokens.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const Color maroon = DesignColors.primary;
  // prefer DesignColors tokens for text and accents

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const AppHeader(),
                        const SizedBox(height: 28),
                        _Hero(),
                      ],
                    ),
                  ),
                ),
              ),
              const _AboutProjectSection(),
              const _VisionMissionSection(),
              const _TeamSection(),
              const _MethodologySection(),
              const _InitiativesSection(),
              const _ImpactSection(),
              const _ContactSection(),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
              const Text('About Our Project', textAlign: TextAlign.center, style: TextStyle(fontSize: 54, fontWeight: FontWeight.w800, color: DesignColors.textPrimary, letterSpacing: -1.0,),),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Text(
              'Our platform helps manage academic and smart city related projects efficiently, making collaboration between teams easier. We provide comprehensive tools to streamline project workflows and enhance productivity.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                height: 1.7,
                color: DesignColors.hint,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Image.asset(
            'assets/imported_ui/PROMANAGE_3/backend/static/images/logo_tim_5.png',
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _AboutProjectSection extends StatelessWidget {
  const _AboutProjectSection();

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('About the Project', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: DesignColors.textPrimary),),
                  SizedBox(height: 18),
                  Text(
                    'Our system is designed to help teams manage projects, tasks, activities, and evaluations in an organized digital platform. We understand the challenges of coordinating multiple stakeholders and activities.\n\nWith ProManage, you can centralize all project information, track progress in real-time, and ensure transparent communication across all team members. Our intuitive interface makes project management accessible to everyone.',
                    style: TextStyle(fontSize: 15.5, color: DesignColors.hint, height: 1.7,),
                  ),
                ],
              );

              final cards = GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
                children: const [
                  _AboutCard(
                    icon: Icons.track_changes,
                    title: 'Goal Oriented',
                    desc: 'Clear project objectives',
                    color: Color(0xFF2563EB),
                  ),
                  _AboutCard(
                    icon: Icons.groups,
                    title: 'Team Work',
                    desc: 'Seamless collaboration',
                    color: Color(0xFF16A34A),
                  ),
                  _AboutCard(
                    icon: Icons.trending_up,
                    title: 'Progress Track',
                    desc: 'Real-time monitoring',
                    color: Color(0xFF7C3AED),
                  ),
                  _AboutCard(
                    icon: Icons.bar_chart,
                    title: 'Analytics',
                    desc: 'Data-driven insights',
                    color: Color(0xFFF97316),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: text),
                    const SizedBox(width: 36),
                    Expanded(child: cards),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [text, const SizedBox(height: 28), cards],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VisionMissionSection extends StatelessWidget {
  const _VisionMissionSection();

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final vision = Container(
            padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignColors.primary, DesignColors.brandDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Vision',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'To become a leading platform that simplifies project management for students while fostering collaboration, transparency, and accountability across academic teams.',
                  style: TextStyle(
                    color: Color(0xFFFECACA),
                    height: 1.7,
                    fontSize: 15.5,
                  ),
                ),
              ],
            ),
          );

          final mission = Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: DesignColors.borderMuted),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Mission',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 18),
                _MissionItem(
                  text: 'Provide clear tools to organize projects and tasks',
                ),
                _MissionItem(
                  text: 'Support seamless collaboration between team members',
                ),
                _MissionItem(
                  text: 'Help monitor progress efficiently and transparently',
                ),
              ],
            ),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: vision),
                const SizedBox(width: 20),
                Expanded(child: mission),
              ],
            );
          }

          return Column(
            children: [vision, const SizedBox(height: 20), mission],
          );
        },
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  const _TeamSection();

  static const members = [
    _TeamMember(
      name: 'Dwi Arbi Nugroho',
      role: 'Konsep Proyek dan Perencanaan Sistem',
      image:
          'https://images.unsplash.com/photo-1629507208649-70919ca33793?w=500',
    ),
    _TeamMember(
      name: 'Muhammad Rizki',
      role: 'Pengembangan Sistem dan Desain Fitur',
      image:
          'https://images.unsplash.com/photo-1621388730896-b0e6b1ba5c51?w=500',
    ),
    _TeamMember(
      name: 'Robin Felix Hama',
      role: 'Desain UI dan Antarmuka',
      image:
          'https://images.unsplash.com/photo-1695712551846-4dc15433fbd4?w=500',
    ),
    _TeamMember(
      name: 'George',
      role: 'Pengujian Sistem dan Evaluasi',
      image:
          'https://images.unsplash.com/photo-1564518534518-e79657852a1a?w=500',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      backgroundColor: Colors.white,
      child: Column(
        children: [
            const Text('Our Team', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: DesignColors.textPrimary,),),
          const SizedBox(height: 10),
          const Text(
            'Meet the people behind ProManage',
            style: TextStyle(fontSize: 18, color: DesignColors.hint),
          ),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1024 ? 4 : 2;
              return GridView.builder(
                itemCount: members.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.76,
                ),
                itemBuilder: (context, index) {
                  final member = members[index];
                  return Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(member.image, fit: BoxFit.cover),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0x00000000),
                                      Color(0x55000000),
                                    ],
                                    begin: Alignment.center,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        member.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                            color: DesignColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.role,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: DesignColors.hint,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MethodologySection extends StatelessWidget {
  const _MethodologySection();

  static const steps = [
    _MethodologyItem(
      step: '1',
      title: 'Research',
      desc: 'Understand user needs and workflow',
    ),
    _MethodologyItem(
      step: '2',
      title: 'Define',
      desc: 'Clarify problems and project scope',
    ),
    _MethodologyItem(
      step: '3',
      title: 'Design',
      desc: 'Create interface concepts and structure',
    ),
    _MethodologyItem(
      step: '4',
      title: 'Develop',
      desc: 'Implement the solution iteratively',
    ),
    _MethodologyItem(
      step: '5',
      title: 'Evaluate',
      desc: 'Test and refine based on feedback',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      child: Column(
        children: [
          const Text(
            'UI/UX Methodology',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: DesignColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: const Text(
              'Our design follows a User Centered Design approach, ensuring every feature is crafted with the end-user in mind.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: DesignColors.hint, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1024
                ? 3
                : constraints.maxWidth >= 640
                    ? 2
                    : 1;

            return GridView.builder(
              itemCount: steps.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final item = steps[index];
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: DesignColors.borderMuted),
                    boxShadow: const [
                      BoxShadow(color: Color(0x08000000), blurRadius: 14, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.step, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: DesignColors.primary)),
                      const SizedBox(height: 10),
                      Text(item.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: DesignColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(item.desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: DesignColors.hint, height: 1.5)),
                    ],
                  ),
                );
              },
            );
          })
        ],
      ),
    );
  }
}

class _InitiativesSection extends StatelessWidget {
  const _InitiativesSection();

  static const items = [
    _Initiative(
      icon: Icons.folder_rounded,
      title: 'Project Profiles',
      color: DesignColors.primary,
    ),
    _Initiative(
      icon: Icons.check_box_rounded,
      title: 'Task Management',
      color: DesignColors.primary,
    ),
    _Initiative(
      icon: Icons.calendar_month_rounded,
      title: 'Activity Planning',
      color: DesignColors.primary,
    ),
    _Initiative(
      icon: Icons.bar_chart_rounded,
      title: 'Real-time Tracking',
      color: DesignColors.primary,
    ),
    _Initiative(
      icon: Icons.lock_rounded,
      title: 'Project Closure',
      color: DesignColors.primary,
    ),
    _Initiative(
      icon: Icons.description_rounded,
      title: 'Documentation',
      color: DesignColors.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const Text(
            'Key Initiatives',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Core features that power your project success',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: DesignColors.hint),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1024
                  ? 3
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;
              return GridView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: DesignColors.borderMuted),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: Colors.white, size: 26),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ImpactSection extends StatelessWidget {
  const _ImpactSection();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('85%', 'Organisasi Proyek yang Lebih Baik'),
      ('92%', 'Kolaborasi Tim yang Meningkat'),
      ('78%', 'Efisiensi Pemantauan yang Lebih Tinggi'),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF111827),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              const Text(
                'Impact & Achievements',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Our system has transformed the way teams work together',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Color(0xFFD1D5DB)),
              ),
              const SizedBox(height: 34),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 860;
                  final children = stats
                      .map(
                        (s) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                Text(
                                  s.$1,
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFF87171),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.$2,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFD1D5DB),
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList();

                  return isWide
                      ? Row(children: children)
                      : Column(
                          children: stats
                              .map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: Column(
                                    children: [
                                      Text(
                                        s.$1,
                                        style: const TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFF87171),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        s.$2,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFFD1D5DB),
                                          fontSize: 14.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    const contacts = [
      _Contact(
        icon: Icons.email_rounded,
        title: 'Email',
        value: 'contact@promanage.com',
        bg: Color(0xFFEFF6FF),
        iconBg: Color(0xFF2563EB),
      ),
      _Contact(
        icon: Icons.phone_rounded,
        title: 'Phone',
        value: '+62 812 3456 7890',
        bg: Color(0xFFF0FDF4),
        iconBg: Color(0xFF16A34A),
      ),
      _Contact(
        icon: Icons.location_on_rounded,
        title: 'Location',
        value: 'Jakarta, Indonesia',
        bg: Color(0xFFF5F3FF),
        iconBg: Color(0xFF7C3AED),
      ),
    ];

    return _SectionShell(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const Text(
            'Contact Us',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "We'd love to hear from you",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 860;
              final cards = contacts
                  .map(
                    (c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [c.bg, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: c.iconBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  c.icon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 14),
                                              Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, color: DesignColors.textPrimary),),
                              const SizedBox(height: 4),
                              Text(
                                c.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList();

              return isWide
                  ? Row(children: cards)
                  : Column(
                      children: contacts
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [c.bg, Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: c.iconBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        c.icon,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      c.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(c.value, textAlign: TextAlign.center, style: const TextStyle(color: DesignColors.hint, fontSize: 13.5,),),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
            },
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _SocialIcon(icon: Icons.facebook_rounded),
              SizedBox(width: 12),
              _SocialIcon(icon: Icons.telegram_rounded),
              SizedBox(width: 12),
              _SocialIcon(icon: Icons.link_rounded),
              SizedBox(width: 12),
              _SocialIcon(icon: Icons.camera_alt_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: DesignColors.bg,
        border: Border(top: BorderSide(color: DesignColors.borderMuted)),
      ),
      child: const Center(
        child: Text(
          '© 2026 ProManage. Platform Manajemen Proyek Mahasiswa.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.child,
    this.backgroundColor = DesignColors.bg,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: child,
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42, color: color),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: DesignColors.textPrimary),),
          const SizedBox(height: 4),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: DesignColors.hint),),
        ],
      ),
    );
  }
}

class _MissionItem extends StatelessWidget {
  const _MissionItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_box_rounded,
            color: DesignColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: DesignColors.hint, height: 1.5, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMember {
  const _TeamMember({
    required this.name,
    required this.role,
    required this.image,
  });

  final String name;
  final String role;
  final String image;
}

class _MethodologyItem {
  const _MethodologyItem({
    required this.step,
    required this.title,
    required this.desc,
  });

  final String step;
  final String title;
  final String desc;
}

class _Initiative {
  const _Initiative({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;
}

class _Contact {
  const _Contact({
    required this.icon,
    required this.title,
    required this.value,
    required this.bg,
    required this.iconBg,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color bg;
  final Color iconBg;
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: DesignColors.surfaceSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF475569), size: 20),
    );
  }
}
