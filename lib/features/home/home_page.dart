import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/calories_profile_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/low_kcal_warning_card.dart';
import 'package:opennutritracker/core/utils/calc/calorie_goal_calc.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:opennutritracker/core/presentation/widgets/edit_activity_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/edit_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:opennutritracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:opennutritracker/features/home/presentation/widgets/fasting_home_chip.dart';
import 'package:opennutritracker/features/home/presentation/widgets/quick_water_widget.dart';
import 'package:opennutritracker/features/home/presentation/widgets/quick_weight_widget.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final log = Logger('HomePage');

  late HomeBloc _homeBloc;
  bool _isIntakeDragging = false;
  bool _isActivityDragging = false;
  bool get _isDragging => _isIntakeDragging || _isActivityDragging;
  bool _sleepChecked = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is HomeInitial) {
          _homeBloc.add(const LoadItemsEvent());
          return _getLoadingContent();
        } else if (state is HomeLoadingState) {
          return _getLoadingContent();
        } else if (state is HomeLoadedState) {
          return _getLoadedContent(
            context,
            state.showDisclaimerDialog,
            state.totalKcalDaily,
            state.userGender,
            state.userCaloriesProfile,
            state.totalKcalLeft,
            state.totalKcalSupplied,
            state.totalKcalBurned,
            state.totalCarbsIntake,
            state.totalFatsIntake,
            state.totalProteinsIntake,
            state.totalCarbsGoal,
            state.totalFatsGoal,
            state.totalProteinsGoal,
            state.breakfastIntakeList,
            state.lunchIntakeList,
            state.dinnerIntakeList,
            state.snackIntakeList,
            state.userActivityList,
            state.usesImperialUnits,
            state.showActivityTracking,
            state.showMealMacros,
            state.userWeightKg,
            state.breakfastKcalTarget,
            state.lunchKcalTarget,
            state.dinnerKcalTarget,
            state.snackKcalTarget,
            state.breakfastSharePct,
            state.lunchSharePct,
            state.dinnerSharePct,
            state.snackSharePct,
            state.waterMlToday,
            state.waterGoalMl,
            state.stepsTracked,
          );
        } else {
          return _getLoadingContent();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log.info('App resumed');
      _refreshPageOnDayChange();
    }
    super.didChangeAppLifecycleState(state);
  }

  Widget _getLoadingContent() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _getLoadedContent(
    BuildContext context,
    bool showDisclaimerDialog,
    double totalKcalDaily,
    UserGenderEntity userGender,
    CaloriesProfileEntity? userCaloriesProfile,
    double totalKcalLeft,
    double totalKcalSupplied,
    double totalKcalBurned,
    double totalCarbsIntake,
    double totalFatsIntake,
    double totalProteinsIntake,
    double totalCarbsGoal,
    double totalFatsGoal,
    double totalProteinsGoal,
    List<IntakeEntity> breakfastIntakeList,
    List<IntakeEntity> lunchIntakeList,
    List<IntakeEntity> dinnerIntakeList,
    List<IntakeEntity> snackIntakeList,
    List<UserActivityEntity> userActivities,
    bool usesImperialUnits,
    bool showActivityTracking,
    bool showMealMacros,
    double userWeightKg,
    double breakfastKcalTarget,
    double lunchKcalTarget,
    double dinnerKcalTarget,
    double snackKcalTarget,
    int breakfastSharePct,
    int lunchSharePct,
    int dinnerSharePct,
    int snackSharePct,
    int waterMlToday,
    int waterGoalMl,
    int stepsTracked,
  ) {
    if (showDisclaimerDialog) {
      _showDisclaimerDialog(context);
    }
    return Stack(
      children: [
        ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  QuickWeightWidget(
                    weightKg: userWeightKg,
                    usesImperialUnits: usesImperialUnits,
                  ),
                  const Spacer(),
                  QuickWaterWidget(
                    waterMlToday: waterMlToday,
                    waterGoalMl: waterGoalMl,
                  ),
                ],
              ),
            ),
            const FastingHomeChip(),
            const SizedBox(height: 8.0),
            DashboardWidget(
              totalKcalDaily: totalKcalDaily,
              totalKcalLeft: totalKcalLeft,
              totalKcalSupplied: totalKcalSupplied,
              totalKcalBurned: totalKcalBurned,
              totalCarbsIntake: totalCarbsIntake,
              totalFatsIntake: totalFatsIntake,
              totalProteinsIntake: totalProteinsIntake,
              totalCarbsGoal: totalCarbsGoal,
              totalFatsGoal: totalFatsGoal,
              totalProteinsGoal: totalProteinsGoal,
            ),
            if (CalorieGoalCalc.isBelowRecommendedDailyKcalFloor(
              goalKcal: totalKcalDaily,
              gender: userGender,
              caloriesProfile: userCaloriesProfile,
            ))
              LowKcalWarningCard(
                thresholdKcal: CalorieGoalCalc.recommendedDailyKcalFloor(
                  gender: userGender,
                  caloriesProfile: userCaloriesProfile,
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step Tracker',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Icon(Icons.directions_walk_outlined, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 40.0,
                            lineWidth: 8.0,
                            percent: (stepsTracked / 8000).clamp(0.0, 1.0),
                            center: Text(
                              '${((stepsTracked / 8000) * 100).toInt()}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            progressColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                            circularStrokeCap: CircularStrokeCap.round,
                            animation: true,
                            animateFromLastPercent: true,
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$stepsTracked / 8000 steps',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  stepsTracked >= 8000
                                      ? 'Daily goal achieved!'
                                      : '${8000 - stepsTracked} steps remaining',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: stepsTracked >= 8000
                                            ? Colors.green
                                            : Theme.of(context).hintColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Semantics(
                                identifier: 'home-steps-decrement',
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Theme.of(context).colorScheme.primary,
                                  onPressed: () {
                                    _homeBloc.add(const UpdateStepsEvent(-1000));
                                  },
                                ),
                              ),
                              Text(
                                '1k steps',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Semantics(
                                identifier: 'home-steps-increment',
                                child: IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Theme.of(context).colorScheme.primary,
                                  onPressed: () {
                                    _homeBloc.add(const UpdateStepsEvent(1000));
                                  },
                                ),
                              ),
                            ],
                          ),
                          Semantics(
                            identifier: 'home-log-morning-walk',
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _homeBloc.add(const LogMorningWalkEvent());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Logged morning walk activity and +8000 steps'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.directions_walk, size: 16),
                              label: const Text('Morning Walk'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sleep & Walk Schedule',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.secondary),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      CheckboxListTile(
                        value: _sleepChecked,
                        onChanged: (val) {
                          setState(() {
                            _sleepChecked = val ?? false;
                          });
                        },
                        title: const Text('Sleep Schedule'),
                        subtitle: const Text('11:00 PM - 6:00 AM (7 hours)'),
                        secondary: const Icon(Icons.bedtime_outlined, color: Colors.indigo),
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        value: stepsTracked >= 8000,
                        onChanged: null,
                        title: const Text('Morning Walk'),
                        subtitle: const Text('60 mins walk / 8000 steps target'),
                        secondary: const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (showActivityTracking)
              ActivityVerticalList(
                day: DateTime.now(),
                title: S.of(context).activityLabel,
                userActivityList: userActivities,
                onItemLongPressedCallback: onActivityItemLongPressed,
                onItemTappedCallback: onActivityItemTapped,
                onItemDragCallback: onActivityItemDrag,
              ),
            // #150 follow-up: a 0% share (e.g. OMAD sets snack to 0) hides the
            // section entirely so the home view doesn't carry an empty header
            // the user explicitly opted out of. Already-logged intakes for a
            // hidden section still count toward daily totals.
            if (breakfastSharePct > 0)
              IntakeVerticalList(
                day: DateTime.now(),
                title: S.of(context).breakfastLabel,
                listIcon: IntakeTypeEntity.breakfast.getIconData(),
                addMealType: AddMealType.breakfastType,
                intakeList: breakfastIntakeList,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemDragCallback: onIntakeItemDrag,
                onItemTappedCallback: onIntakeItemTapped,
                usesImperialUnits: usesImperialUnits,
                showMealMacros: showMealMacros,
                mealKcalTarget: breakfastKcalTarget,
              ),
            if (lunchSharePct > 0)
              IntakeVerticalList(
                day: DateTime.now(),
                title: S.of(context).lunchLabel,
                listIcon: IntakeTypeEntity.lunch.getIconData(),
                addMealType: AddMealType.lunchType,
                intakeList: lunchIntakeList,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemDragCallback: onIntakeItemDrag,
                onItemTappedCallback: onIntakeItemTapped,
                usesImperialUnits: usesImperialUnits,
                showMealMacros: showMealMacros,
                mealKcalTarget: lunchKcalTarget,
              ),
            if (dinnerSharePct > 0)
              IntakeVerticalList(
                day: DateTime.now(),
                title: S.of(context).dinnerLabel,
                addMealType: AddMealType.dinnerType,
                listIcon: IntakeTypeEntity.dinner.getIconData(),
                intakeList: dinnerIntakeList,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemDragCallback: onIntakeItemDrag,
                onItemTappedCallback: onIntakeItemTapped,
                usesImperialUnits: usesImperialUnits,
                showMealMacros: showMealMacros,
                mealKcalTarget: dinnerKcalTarget,
              ),
            if (snackSharePct > 0)
              IntakeVerticalList(
                day: DateTime.now(),
                title: S.of(context).snackLabel,
                listIcon: IntakeTypeEntity.snack.getIconData(),
                addMealType: AddMealType.snackType,
                intakeList: snackIntakeList,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemDragCallback: onIntakeItemDrag,
                onItemTappedCallback: onIntakeItemTapped,
                usesImperialUnits: usesImperialUnits,
                showMealMacros: showMealMacros,
                mealKcalTarget: snackKcalTarget,
              ),
            const SizedBox(height: 48.0),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
            visible: _isDragging,
            child: SizedBox(
              height: 70,
              child: Stack(
                children: [
                  DragTarget<IntakeEntity>(
                    onAcceptWithDetails: (data) {
                      _confirmDelete(context, data.data);
                    },
                    onLeave: (data) {
                      setState(() {
                        _isIntakeDragging = false;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        color: Theme.of(context).colorScheme.error,
                        child: const Center(
                          child: Icon(
                            Icons.delete_outline,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  DragTarget<UserActivityEntity>(
                    onAcceptWithDetails: (data) {
                      _confirmDeleteActivity(context, data.data);
                    },
                    onLeave: (data) {
                      setState(() {
                        _isActivityDragging = false;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return const SizedBox.expand();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onActivityItemLongPressed(
    BuildContext context,
    UserActivityEntity activityEntity,
  ) async {
    final deleteIntake = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteDialog(),
    );

    if (deleteIntake != null) {
      _homeBloc.deleteUserActivityItem(activityEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).itemDeletedSnackbar)),
        );
      }
    }
  }

  void onIntakeItemLongPressed(
    BuildContext context,
    IntakeEntity intakeEntity,
  ) async {
    final deleteIntake = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteDialog(),
    );

    if (deleteIntake != null) {
      _homeBloc.deleteIntakeItem(intakeEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).itemDeletedSnackbar)),
        );
      }
    }
  }

  void onIntakeItemDrag(bool isDragging) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isIntakeDragging = isDragging;
      });
    });
  }

  void onActivityItemDrag(bool isDragging) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isActivityDragging = isDragging;
      });
    });
  }

  void onActivityItemTapped(
    BuildContext context,
    UserActivityEntity activityEntity,
  ) async {
    final newDuration = await showDialog<double>(
      context: context,
      builder: (context) => EditActivityDialog(activityEntity: activityEntity),
    );
    if (newDuration != null) {
      await _homeBloc.updateUserActivityItem(activityEntity, newDuration);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).itemUpdatedSnackbar)),
        );
      }
    }
  }

  void onIntakeItemTapped(
    BuildContext context,
    IntakeEntity intakeEntity,
    bool usesImperialUnits,
  ) async {
    final changeIntakeAmount = await showDialog<double>(
      context: context,
      builder: (context) => EditDialog(
        intakeEntity: intakeEntity,
        usesImperialUnits: usesImperialUnits,
      ),
    );
    if (changeIntakeAmount != null) {
      _homeBloc.updateIntakeItem(intakeEntity.id, {
        'amount': changeIntakeAmount,
      });
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).itemUpdatedSnackbar)),
        );
      }
    }
  }

  void onDeleteIntake(IntakeEntity intake, TrackedDayEntity? trackedDayEntity) {
    _homeBloc.deleteIntakeItem(intake);
    _homeBloc.add(const LoadItemsEvent());
  }

  void _confirmDelete(BuildContext context, IntakeEntity intake) async {
    bool? delete = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteDialog(),
    );

    if (delete == true) {
      onDeleteIntake(intake, null);
    }
    setState(() {
      _isIntakeDragging = false;
    });
  }

  void _confirmDeleteActivity(
    BuildContext context,
    UserActivityEntity activity,
  ) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteDialog(),
    );
    if (delete == true) {
      _homeBloc.deleteUserActivityItem(activity);
      _homeBloc.add(const LoadItemsEvent());
    }
    setState(() {
      _isActivityDragging = false;
    });
  }

  /// Show disclaimer dialog after build method
  void _showDisclaimerDialog(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dialogConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return const DisclaimerDialog();
        },
      );
      if (dialogConfirmed != null) {
        _homeBloc.saveConfigData(dialogConfirmed);
        _homeBloc.add(const LoadItemsEvent());
      }
    });
  }

  /// Refresh page when day changes
  ///
  /// #139: HomeBloc.currentDay is the logical "today" (midnight of the
  /// configured day boundary). Comparing against a fresh logical "today"
  /// from the same wall clock requires knowing the offset, which we'd
  /// have to fetch from config asynchronously. Letting LoadItemsEvent
  /// re-resolve the offset and reload unconditionally on resume is the
  /// honest cheap path: it costs one config read plus a few Hive scans,
  /// and it is correct under any boundary setting.
  void _refreshPageOnDayChange() {
    _homeBloc.add(const LoadItemsEvent());
  }
}
