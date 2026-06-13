import 'package:opennutritracker/core/data/repository/config_repository.dart';
import 'package:opennutritracker/core/utils/calc/macro_calc.dart';

class GetMacroGoalUsecase {
  final ConfigRepository _configRepository;

  GetMacroGoalUsecase(this._configRepository);

  Future<double> getCarbsGoal(double totalCalorieGoal) async {
    final config = await _configRepository.getConfig();
    if (config.useManualTargets && config.manualCarbsG != null) {
      return config.manualCarbsG!;
    }
    final userCarbGoal = config.userCarbGoalPct;

    return MacroCalc.getTotalCarbsGoal(
      totalCalorieGoal,
      userCarbsGoal: userCarbGoal,
    );
  }

  Future<double> getFatsGoal(double totalCalorieGoal) async {
    final config = await _configRepository.getConfig();
    if (config.useManualTargets && config.manualFatG != null) {
      return config.manualFatG!;
    }
    final userFatGoal = config.userFatGoalPct;

    return MacroCalc.getTotalFatsGoal(
      totalCalorieGoal,
      userFatsGoal: userFatGoal,
    );
  }

  Future<double> getProteinsGoal(double totalCalorieGoal) async {
    final config = await _configRepository.getConfig();
    if (config.useManualTargets && config.manualProteinG != null) {
      return config.manualProteinG!;
    }
    final userProteinGoal = config.userProteinGoalPct;

    return MacroCalc.getTotalProteinsGoal(
      totalCalorieGoal,
      userProteinsGoal: userProteinGoal,
    );
  }
}

