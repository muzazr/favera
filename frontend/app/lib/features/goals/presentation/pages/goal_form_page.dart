import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/app/theme/app_spacing.dart';
import 'package:app/core/formatters/currency_formatter.dart';
import 'package:app/core/widgets/app_gradient_background.dart';
import 'package:app/features/goals/application/goal_controller.dart';
import 'package:app/shared/models/goal_model.dart';

class GoalFormPage extends ConsumerStatefulWidget {
  final String? goalId;

  const GoalFormPage({super.key, this.goalId});

  @override
  ConsumerState<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends ConsumerState<GoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();

  int _targetAmount = 50000000; // Default 50.000.000 per mockup
  String _deadline = 'Desember 2027';
  String _selectedTheme = 'house';
  String _contributionScheme = 'Dari Saldo Bersama';
  String _priority = 'Penting';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _targetAmountController.text =
        CurrencyFormatter.formatNumber(_targetAmount);

    if (widget.goalId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final goal =
            await ref.read(goalDetailControllerProvider(widget.goalId!).future);
        if (goal != null && mounted) {
          setState(() {
            _nameController.text = goal.name;
            _targetAmount = goal.targetAmount;
            _targetAmountController.text =
                CurrencyFormatter.formatNumber(goal.targetAmount);
            _deadline = goal.deadline;
            _selectedTheme = goal.themeIcon;
            _contributionScheme = goal.contributionScheme;
            _priority = goal.priority;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  void _addAmount(int delta) {
    setState(() {
      _targetAmount += delta;
      _targetAmountController.text =
          CurrencyFormatter.formatNumber(_targetAmount);
    });
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2027, 12, 1),
      firstDate: now,
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      setState(() {
        _deadline = '${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama target tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.goalId != null) {
        await ref.read(goalListControllerProvider.notifier).updateGoal(
          widget.goalId!,
          {
            'name': _nameController.text.trim(),
            'target_amount': _targetAmount,
            'deadline': _deadline,
            'theme_icon': _selectedTheme,
            'contribution_scheme': _contributionScheme,
            'priority': _priority,
          },
        );
      } else {
        final newGoal = FinancialGoal(
          id: 'goal-${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          targetAmount: _targetAmount,
          currentAmount: 0,
          deadline: _deadline,
          status: GoalStatus.active,
          approvedByPartner: true,
          themeIcon: _selectedTheme,
          contributionScheme: _contributionScheme,
          priority: _priority,
          createdAt: DateTime.now(),
        );
        await ref.read(goalListControllerProvider.notifier).createGoal(newGoal);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.goalId != null
                  ? 'Target berhasil diperbarui'
                  : 'Target baru berhasil dibuat!',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan target: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF111827),
              size: 28,
            ),
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          title: const Text(
            'Goal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: TARGET DANA Display Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
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
                              const Text(
                                'TARGET DANA',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const Text(
                                    'Rp ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  IntrinsicWidth(
                                    child: TextFormField(
                                      controller: _targetAmountController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        ThousandsSeparatorInputFormatter(),
                                      ],
                                      onChanged: (val) {
                                        final parsed =
                                            CurrencyFormatter.parse(val);
                                        setState(() {
                                          _targetAmount = parsed;
                                        });
                                      },
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111827),
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Quick amount chips (+1 Juta, +5 Juta, +10 Juta)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildQuickChip('+1 Juta', 1000000),
                                  const SizedBox(width: 8),
                                  _buildQuickChip('+5 Juta', 5000000),
                                  const SizedBox(width: 8),
                                  _buildQuickChip('+10 Juta', 10000000),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),

                        // Field 1: Nama Target
                        _buildLabel('Nama Target'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Misal: DP Rumah, Liburan',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),

                        // Field 2: Deadline
                        _buildLabel('Deadline'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectDeadline,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _deadline,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE0F2FE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),

                        // Field 3: Visual Tema
                        _buildLabel('Visual Tema'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildThemeCircle('house', '🏠'),
                            const SizedBox(width: 12),
                            _buildThemeCircle('plane', '✈️'),
                            const SizedBox(width: 12),
                            _buildThemeCircle('baby', '👶'),
                            const SizedBox(width: 12),
                            _buildThemeCircle('car', '🚗'),
                            const SizedBox(width: 12),
                            _buildAddThemeCircle(),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s20),

                        // Field 4: Skema Kontribusi Bulanan
                        _buildLabel('Skema Kontribusi Bulanan'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSchemeTab('Dari Saldo Bersama'),
                              ),
                              Expanded(
                                child: _buildSchemeTab('Patungan Proporsional'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),

                        // Field 5: Tingkat Prioritas
                        _buildLabel('Tingkat Prioritas'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPriorityChip('Sangat Penting', '☕'),
                            _buildPriorityChip('Penting', '⭐'),
                            _buildPriorityChip('Fleksibel', '📍'),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                    label: Text(
                      widget.goalId != null
                          ? 'Simpan Perubahan'
                          : 'Buat Target & Kunci Komitmen',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4B5563),
      ),
    );
  }

  Widget _buildQuickChip(String label, int amount) {
    return GestureDetector(
      onTap: () => _addAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0369A1),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCircle(String themeKey, String emoji) {
    final isSelected = _selectedTheme == themeKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = themeKey),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE6F7F0)
                  : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: const Color(0xFF10B981), width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddThemeCircle() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFC7D2FE),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.add_rounded,
          color: Color(0xFF4338CA),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSchemeTab(String label) {
    final isSelected = _contributionScheme == label;
    return GestureDetector(
      onTap: () => setState(() => _contributionScheme = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF111827)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label, String emoji) {
    final isSelected = _priority == label;
    final isOrange = label == 'Penting';

    return GestureDetector(
      onTap: () => setState(() => _priority = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isOrange ? const Color(0xFFFF7418) : Colors.white)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected && !isOrange
              ? Border.all(color: const Color(0xFF10B981), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected && isOrange
                    ? Colors.white
                    : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
