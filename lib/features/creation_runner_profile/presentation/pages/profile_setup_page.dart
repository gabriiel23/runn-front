import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String _selectedGender = 'male';
  DateTime? _selectedDate;

  final _genderOptions = [
    ('male', 'Hombre'),
    ('female', 'Mujer'),
    ('other', 'Otro'),
  ];

  Future<void> _pickDate() async {
    final c = context.colors;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: c.primaryDeep,
              onPrimary: Colors.white,
              surface: c.card,
              onSurface: c.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} / '
        '${date.month.toString().padLeft(2, '0')} / '
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // ── Decorative gradient bottom ───────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    c.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 16,
                    bottom: 0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/register'),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: c.textPrimary,
                        iconSize: 24,
                      ),
                      Expanded(
                        child: Text(
                          'Configura tu perfil',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Divider(),

                // ── Progress bar ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Paso 1 de 3',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          Text(
                            '33% completado',
                            style: TextStyle(
                              fontSize: 13,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: LinearProgressIndicator(
                          value: 1 / 3,
                          minHeight: 8,
                          backgroundColor: c.primary.withValues(alpha: 0.25),
                          valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Scrollable content ─────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Háblanos de ti',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Necesitamos estos datos para personalizar tu plan de entrenamiento.',
                          style: TextStyle(
                            fontSize: 14,
                            color: c.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Gender selector ────────────────────────────
                        Text(
                          'Género',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 52,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: c.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: c.primaryMid.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: _genderOptions.map((option) {
                              final isSelected = _selectedGender == option.$1;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedGender = option.$1,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? c.card
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: c.primary.withValues(
                                                  alpha: 0.4,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        option.$2,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? c.textPrimary
                                              : c.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Date of birth ──────────────────────────────
                        Text(
                          'Fecha de nacimiento',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: c.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: c.primaryMid.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? _formatDate(_selectedDate!)
                                        : 'DD / MM / AAAA',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _selectedDate != null
                                          ? c.textPrimary
                                          : c.textSecondary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: c.textSecondary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Info card ──────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                c.primary.withValues(alpha: 0.35),
                                c.primary.withValues(alpha: 0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: c.primaryMid.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: c.card,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.directions_run_rounded,
                                  color: c.primaryDeep,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¡Casi listo!',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: c.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tu edad y género nos ayudan a calcular el ritmo ideal para tu corazón.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Continue button ────────────────────────────
                        GestureDetector(
                          onTap: () => context.go('/physical_metrics'),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: c.primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: c.primary.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: c.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: c.textPrimary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
