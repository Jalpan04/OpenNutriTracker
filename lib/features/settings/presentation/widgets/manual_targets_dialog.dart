import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ManualTargetsDialog extends StatefulWidget {
  final SettingsBloc settingsBloc;
  final HomeBloc homeBloc;

  const ManualTargetsDialog({
    super.key,
    required this.settingsBloc,
    required this.homeBloc,
  });

  @override
  State<ManualTargetsDialog> createState() => _ManualTargetsDialogState();
}

class _ManualTargetsDialogState extends State<ManualTargetsDialog> {
  bool _useManualTargets = false;
  double _manualKcalTarget = 1500.0;
  double _manualProteinG = 120.0;
  double _manualCarbsG = 150.0;
  double _manualFatG = 45.0;
  bool _loaded = false;

  late final TextEditingController _kcalController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    _kcalController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _kcalController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final state = widget.settingsBloc.state;
    if (state is SettingsLoadedState) {
      setState(() {
        _useManualTargets = state.useManualTargets;
        _manualKcalTarget = state.manualKcalTarget ?? 1500.0;
        _manualProteinG = state.manualProteinG ?? 120.0;
        _manualCarbsG = state.manualCarbsG ?? 150.0;
        _manualFatG = state.manualFatG ?? 45.0;
        
        _kcalController.text = _manualKcalTarget.round().toString();
        _proteinController.text = _manualProteinG.round().toString();
        _carbsController.text = _manualCarbsG.round().toString();
        _fatController.text = _manualFatG.round().toString();
        _loaded = true;
      });
    }
  }

  void _applyTextInputs() {
    final kcal = double.tryParse(_kcalController.text) ?? _manualKcalTarget;
    final protein = double.tryParse(_proteinController.text) ?? _manualProteinG;
    final carbs = double.tryParse(_carbsController.text) ?? _manualCarbsG;
    final fat = double.tryParse(_fatController.text) ?? _manualFatG;

    setState(() {
      _manualKcalTarget = kcal;
      _manualProteinG = protein;
      _manualCarbsG = carbs;
      _manualFatG = fat;
    });
  }

  Future<void> _save() async {
    _applyTextInputs();
    widget.settingsBloc.setManualTargetsEnabled(_useManualTargets);
    if (_useManualTargets) {
      widget.settingsBloc.setManualTargets(
        kcal: _manualKcalTarget,
        protein: _manualProteinG,
        carbs: _manualCarbsG,
        fat: _manualFatG,
      );
    }
    
    widget.settingsBloc.add(LoadSettingsEvent());
    widget.homeBloc.add(const LoadItemsEvent());
    await widget.settingsBloc.updateTrackedDay(DateTime.now());
    
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(
        s.settingsKcalAdjustmentLabel.contains('Calorie')
            ? 'Manual Target Goals'
            : 'Custom Nutrient Targets',
      ),
      content: !_loaded
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use Manual Targets'),
                    subtitle: const Text('Override TDEE calculation with flat goals'),
                    value: _useManualTargets,
                    onChanged: (v) {
                      setState(() {
                        _useManualTargets = v;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_useManualTargets) ...[
                    _buildInputField(
                      controller: _kcalController,
                      label: 'Daily Calories',
                      suffix: 'kcal',
                      identifier: 'manual-kcal-input',
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _proteinController,
                      label: 'Protein Goal',
                      suffix: 'g',
                      identifier: 'manual-protein-input',
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _carbsController,
                      label: 'Carbohydrates Goal',
                      suffix: 'g',
                      identifier: 'manual-carbs-input',
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _fatController,
                      label: 'Fat Goal',
                      suffix: 'g',
                      identifier: 'manual-fat-input',
                    ),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.dialogCancelLabel),
        ),
        Semantics(
          identifier: 'manual-targets-save',
          child: TextButton(
            onPressed: _loaded ? _save : null,
            child: Text(s.dialogOKLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String identifier,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SizedBox(
          width: 100,
          child: Semantics(
            identifier: identifier,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                suffixText: suffix,
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
