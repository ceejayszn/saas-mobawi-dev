import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/security/auth_service.dart';
import '../../core/utils/input_validator.dart';
import '../../theme/app_colors.dart';

class SecuritySettings extends StatefulWidget {
  const SecuritySettings({super.key});

  @override
  State<SecuritySettings> createState() => _SecuritySettingsState();
}

class _SecuritySettingsState extends State<SecuritySettings> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: const Text('Security & Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Primary PIN'),
            Tab(text: 'Backup PIN'),
            Tab(text: 'Security Q\'s'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChangePasswordTab(isPrimary: true, isDark: isDark),
          _ChangePasswordTab(isPrimary: false, isDark: isDark),
          _SecurityQuestionsTab(isDark: isDark),
        ],
      ),
    );
  }
}

// ── Change Password Tab ───────────────────────────────────────────────────────

class _ChangePasswordTab extends StatefulWidget {
  final bool isPrimary;
  final bool isDark;
  const _ChangePasswordTab({required this.isPrimary, required this.isDark});

  @override
  State<_ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends State<_ChangePasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSaving = false;
  int _newPinStrength = 0;

  @override
  void initState() {
    super.initState();
    _newCtrl.addListener(() {
      setState(() {
        _newPinStrength = _strengthScore(_newCtrl.text);
      });
    });
  }

  int _strengthScore(String pin) {
    if (pin.isEmpty) return 0;
    if (pin.length < 4) return 0;
    if (pin.length < 6) return 1;
    if (pin.length >= 8) return 3;
    return 2;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final error = await AuthService.instance.changePassword(
      currentPin: _currentCtrl.text,
      newPin: _newCtrl.text,
      confirmPin: _confirmCtrl.text,
      isPrimary: widget.isPrimary,
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (error == null) {
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.isPrimary ? 'Primary' : 'Backup'} PIN updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isPrimary
                          ? 'This changes your main admin PIN. You will need your current PIN to proceed.'
                          : 'Set a backup PIN for emergency access. Leave current PIN blank for new setup.',
                      style: const TextStyle(color: AppColors.warning, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _card(widget.isDark, [
              if (widget.isPrimary) ...[
                _pinField('Current PIN', _currentCtrl, _showCurrent, () => setState(() => _showCurrent = !_showCurrent),
                    validator: (v) => InputValidator.validatePin(v)),
                const SizedBox(height: 16),
              ],
              _pinField('New PIN', _newCtrl, _showNew, () => setState(() => _showNew = !_showNew),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'New PIN is required.';
                    if (v.length < AppConstants.minPinLength) return 'PIN must be at least ${AppConstants.minPinLength} digits.';
                    return null;
                  }),
              const SizedBox(height: 8),
              // Strength indicator
              if (_newCtrl.text.isNotEmpty) _strengthBar(_newPinStrength),
              const SizedBox(height: 16),
              _pinField('Confirm New PIN', _confirmCtrl, _showConfirm, () => setState(() => _showConfirm = !_showConfirm),
                  validator: (v) {
                    if (v != _newCtrl.text) return 'PINs do not match.';
                    return null;
                  }),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _changePassword,
                child: _isSaving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Update ${widget.isPrimary ? 'Primary' : 'Backup'} PIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(bool isDark, List<Widget> children) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
    ),
    child: Column(children: children),
  );

  Widget _pinField(String label, TextEditingController ctrl, bool show, VoidCallback toggle, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: !show,
      keyboardType: TextInputType.number,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primaryGreen, size: 20),
        suffixIcon: IconButton(
          icon: Icon(show ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textSecondary, size: 20),
          onPressed: toggle,
        ),
      ),
    );
  }

  Widget _strengthBar(int strength) {
    final colors = [Colors.transparent, AppColors.error, AppColors.warning, AppColors.success];
    final labels = ['', 'Weak', 'Fair', 'Strong'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: i < strength ? colors[strength] : AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 4),
        Text(labels[strength], style: TextStyle(color: colors[strength], fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Security Questions Tab ────────────────────────────────────────────────────

class _SecurityQuestionsTab extends StatefulWidget {
  final bool isDark;
  const _SecurityQuestionsTab({required this.isDark});

  @override
  State<_SecurityQuestionsTab> createState() => _SecurityQuestionsTabState();
}

class _SecurityQuestionsTabState extends State<_SecurityQuestionsTab> {
  final List<String> _selectedQuestions = List.filled(5, AppConstants.securityQuestions[0]);
  final List<TextEditingController> _answerCtrls = List.generate(5, (_) => TextEditingController());
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final saved = await AuthService.instance.getSecurityQuestions();
    if (saved.isNotEmpty && mounted) {
      setState(() {
        for (int i = 0; i < saved.length && i < 5; i++) {
          if (AppConstants.securityQuestions.contains(saved[i])) {
            _selectedQuestions[i] = saved[i];
          }
        }
      });
    }
  }

  Future<void> _saveQuestions() async {
    // Validate all answers filled
    for (int i = 0; i < 5; i++) {
      if (_answerCtrls[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please answer question ${i + 1}'), backgroundColor: AppColors.error),
        );
        return;
      }
    }
    setState(() => _isSaving = true);
    final qaPairs = List.generate(5, (i) => MapEntry(_selectedQuestions[i], _answerCtrls[i].text));
    await AuthService.instance.saveSecurityQuestions(qaPairs);
    setState(() => _isSaving = false);
    if (mounted) {
      for (final c in _answerCtrls) {
        c.clear();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security questions saved'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _answerCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_reset_rounded, color: AppColors.info, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Security questions allow you to reset your PIN if you forget it. Answers are hashed and stored securely.',
                    style: TextStyle(color: AppColors.info, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(5, (i) => _buildQuestionCard(i)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveQuestions,
              child: _isSaving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Security Questions'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ${index + 1}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedQuestions[index],
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            isExpanded: true,
            items: AppConstants.securityQuestions
                .map((q) => DropdownMenuItem(value: q, child: Text(q, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _selectedQuestions[index] = v ?? _selectedQuestions[index]),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _answerCtrls[index],
            decoration: const InputDecoration(
              hintText: 'Your answer (case-insensitive)',
              prefixIcon: Icon(Icons.edit_rounded, color: AppColors.primaryGreen, size: 18),
            ),
            validator: InputValidator.validateSecurityAnswer,
          ),
        ],
      ),
    );
  }
}
