import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/profile/profile_controller.dart';
import 'package:mobile_app/features/profile/profile_models.dart';

/// "Add your details" — Personal + Business tabbed form (Figma 371:2185 /
/// 371:3567). Loads from `GET /api/profile`, saves via `PUT /api/profile`.
class EditDetailsScreen extends ConsumerWidget {
  const EditDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Profile> profile = ref.watch(profileProvider);
    final Color primary = Theme.of(context).colorScheme.primary;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          title: const Text('Add your details'),
          bottom: TabBar(
            labelColor: primary,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: primary,
            indicatorWeight: 3,
            labelStyle: Theme.of(context).textTheme.titleMedium,
            tabs: const <Widget>[
              Tab(text: 'Personal'),
              Tab(text: 'Business'),
            ],
          ),
        ),
        body: profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(profileProvider),
              child: const Text('Could not load profile — Retry'),
            ),
          ),
          data: (Profile p) => TabBarView(
            children: <Widget>[
              _PersonalForm(profile: p),
              _BusinessForm(profile: p),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared save handler: writes the patch, shows feedback, pops on success.
Future<void> _save(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> patch,
) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final NavigatorState navigator = Navigator.of(context);
  try {
    await ref.read(profileActionsProvider).save(patch);
    messenger.showSnackBar(const SnackBar(content: Text('Saved')));
    navigator.maybePop();
  } catch (_) {
    messenger.showSnackBar(const SnackBar(content: Text('Could not save')));
  }
}

class _PersonalForm extends ConsumerStatefulWidget {
  const _PersonalForm({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_PersonalForm> createState() => _PersonalFormState();
}

class _PersonalFormState extends ConsumerState<_PersonalForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.md,
      ),
      children: <Widget>[
        const Center(child: _AvatarPicker()),
        const SizedBox(height: AppSpacing.xl),
        _LabeledField(label: 'Your name', controller: _name),
        const SizedBox(height: AppSpacing.lg),
        _SaveButton(
          onPressed: () =>
              _save(context, ref, <String, dynamic>{'name': _name.text}),
        ),
      ],
    );
  }
}

class _BusinessForm extends ConsumerStatefulWidget {
  const _BusinessForm({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends ConsumerState<_BusinessForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.businessName);
  late final TextEditingController _details =
      TextEditingController(text: widget.profile.businessDetails);
  late final TextEditingController _mobile =
      TextEditingController(text: widget.profile.businessMobile);

  @override
  void dispose() {
    _name.dispose();
    _details.dispose();
    _mobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      children: <Widget>[
        Text(
          'Business Information',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.grey400),
        ),
        const SizedBox(height: AppSpacing.sm),
        _LabeledField(label: 'Business name', controller: _name),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(label: 'Business details', controller: _details),
        const SizedBox(height: AppSpacing.md),
        _LabeledField(
          label: 'Business mobile number',
          controller: _mobile,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSpacing.lg),
        _SaveButton(
          onPressed: () => _save(context, ref, <String, dynamic>{
            'businessName': _name.text,
            'businessDetails': _details.text,
            'businessMobile': _mobile.text,
          }),
        ),
      ],
    );
  }
}

/// A pill-shaped text field with a floating label (Figma style).
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: AppColors.grey300),
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        enabledBorder: border,
        border: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Save'),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker();

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: <Widget>[
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey200, width: 2),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 56,
              color: AppColors.grey300,
            ),
          ),
          Positioned(
            right: 6,
            bottom: 6,
            child: Builder(
              builder: (BuildContext context) => GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo upload coming soon')),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: primary,
                  child: const Icon(
                    Icons.photo_camera,
                    size: 18,
                    color: AppColors.white,
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
