import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/user_profile_provider.dart';
import '../core/models/user_profile.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_progress_ring.dart';

/// Profile Screen – shows user stats and allows editing their profile.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _stepGoalCtrl;
  late TextEditingController _calGoalCtrl;
  late TextEditingController _distGoalCtrl;
  String _selectedLevel = 'beginner';
  String _selectedGender = 'not specified';

  @override
  void initState() {
    super.initState();
    final p = Provider.of<UserProfileProvider>(context, listen: false).profile;
    _nameCtrl = TextEditingController(text: p.name);
    _ageCtrl = TextEditingController(text: p.age.toString());
    _heightCtrl = TextEditingController(text: p.heightCm.toStringAsFixed(0));
    _weightCtrl = TextEditingController(text: p.weightKg.toStringAsFixed(1));
    _stepGoalCtrl = TextEditingController(text: p.dailyStepGoal.toString());
    _calGoalCtrl =
        TextEditingController(text: p.dailyCalorieGoal.toStringAsFixed(0));
    _distGoalCtrl =
        TextEditingController(text: p.dailyDistanceGoal.toStringAsFixed(1));
    _selectedLevel = p.fitnessLevel;
    _selectedGender = p.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _stepGoalCtrl.dispose();
    _calGoalCtrl.dispose();
    _distGoalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final provider = context.read<UserProfileProvider>();
    await provider.updateField(
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text),
      heightCm: double.tryParse(_heightCtrl.text),
      weightKg: double.tryParse(_weightCtrl.text),
      fitnessLevel: _selectedLevel,
      gender: _selectedGender,
      dailyStepGoal: int.tryParse(_stepGoalCtrl.text),
      dailyCalorieGoal: double.tryParse(_calGoalCtrl.text),
      dailyDistanceGoal: double.tryParse(_distGoalCtrl.text),
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.success),
              onPressed: () => _save(context),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: _isEditing
                ? _buildEditForm(context)
                : _buildView(context, profile),
          ),
        ),
      ),
    );
  }

  Widget _buildView(BuildContext context, UserProfile profile) {
    final bmiColor = profile.bmi < 25
        ? AppColors.success
        : profile.bmi < 30
            ? AppColors.warning
            : AppColors.error;

    return Column(
      children: [
        // Avatar + name card
        GlassCard(
          child: Column(
            children: [
              Hero(
                tag: 'profile-avatar',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Center(
                      child: Text('🏃', style: TextStyle(fontSize: 40))),
                ),
              ),
              const SizedBox(height: 12),
              Text(profile.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(profile.fitnessLevel,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.primary)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _infoCard(context, 'Age', '${profile.age} yrs', Icons.cake),
            _infoCard(context, 'Height',
                '${profile.heightCm.toStringAsFixed(0)} cm', Icons.height),
            _infoCard(
                context,
                'Weight',
                '${profile.weightKg.toStringAsFixed(1)} kg',
                Icons.monitor_weight),
            _infoCard(context, 'Gender', profile.gender, Icons.person),
          ],
        ),

        const SizedBox(height: 16),

        // BMI Card
        GlassCard(
          child: Row(
            children: [
              AnimatedProgressRing(
                progress: (profile.bmi / 40.0).clamp(0.0, 1.0),
                size: 100,
                strokeWidth: 10,
                progressColor: bmiColor,
                centerChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(profile.bmi.toStringAsFixed(1),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: bmiColor,
                            fontSize: 18)),
                    const Text('BMI', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BMI Analysis',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(profile.bmiCategory,
                        style: TextStyle(
                            color: bmiColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Healthy range: 18.5 – 24.9',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Goals summary
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Goals',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _goalRow('👣 Steps', '${profile.dailyStepGoal}'),
              _goalRow('🔥 Calories',
                  '${profile.dailyCalorieGoal.toStringAsFixed(0)} kcal'),
              _goalRow('📍 Distance',
                  '${profile.dailyDistanceGoal.toStringAsFixed(1)} km'),
              _goalRow(
                  '⏱ Active Time', '${profile.dailyActiveMinutesGoal} min'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _goalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _infoCard(
      BuildContext context, String label, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Edit Profile',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            children: [
              _field('Full Name', _nameCtrl),
              const SizedBox(height: 12),
              _field('Age', _ageCtrl, type: TextInputType.number),
              const SizedBox(height: 12),
              _field('Height (cm)', _heightCtrl, type: TextInputType.number),
              const SizedBox(height: 12),
              _field('Weight (kg)', _weightCtrl, type: TextInputType.number),
              const SizedBox(height: 16),
              // Gender
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['not specified', 'male', 'female', 'other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGender = v!),
              ),
              const SizedBox(height: 12),
              // Fitness level
              DropdownButtonFormField<String>(
                initialValue: _selectedLevel,
                decoration: const InputDecoration(labelText: 'Fitness Level'),
                items: ['beginner', 'intermediate', 'advanced']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLevel = v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Daily Goals',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              _field('Step Goal', _stepGoalCtrl, type: TextInputType.number),
              const SizedBox(height: 12),
              _field('Calorie Goal (kcal)', _calGoalCtrl,
                  type: TextInputType.number),
              const SizedBox(height: 12),
              _field('Distance Goal (km)', _distGoalCtrl,
                  type: TextInputType.number),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _save(context),
            child: const Text('Save Profile'),
          ),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
    );
  }
}
