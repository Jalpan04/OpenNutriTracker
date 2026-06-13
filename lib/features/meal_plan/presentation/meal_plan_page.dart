import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';

class WeeklyMeal {
  final String label;
  final String name;
  final String? detail;
  final List<String>? dabba;
  final double kcal;
  final double pro;
  final double carb;
  final String? note;

  const WeeklyMeal({
    required this.label,
    required this.name,
    this.detail,
    this.dabba,
    required this.kcal,
    required this.pro,
    required this.carb,
    this.note,
  });

  IntakeTypeEntity get intakeType {
    final lower = label.toLowerCase();
    if (lower.contains('breakfast')) return IntakeTypeEntity.breakfast;
    if (lower.contains('lunch')) return IntakeTypeEntity.lunch;
    if (lower.contains('dinner')) return IntakeTypeEntity.dinner;
    return IntakeTypeEntity.snack;
  }
}

class WeeklyDayPlan {
  final String day;
  final List<WeeklyMeal> meals;
  final double totalKcal;
  final double totalPro;
  final double totalCarb;
  final String? note;

  const WeeklyDayPlan({
    required this.day,
    required this.meals,
    required this.totalKcal,
    required this.totalPro,
    required this.totalCarb,
    this.note,
  });
}

class RecipeIngredient {
  final String name;
  final String quantity;

  const RecipeIngredient({required this.name, required this.quantity});
}

class KeyRecipe {
  final String name;
  final String time;
  final String serves;
  final String cal;
  final String pro;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final String tip;

  const KeyRecipe({
    required this.name,
    required this.time,
    required this.serves,
    required this.cal,
    required this.pro,
    required this.ingredients,
    required this.steps,
    required this.tip,
  });
}

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  int _selectedDayIndex = 0;
  int _selectedRecipeIndex = 0;
  bool _logging = false;

  static const List<WeeklyDayPlan> _days = [
    WeeklyDayPlan(
      day: "Monday",
      totalKcal: 1595,
      totalPro: 96,
      totalCarb: 185,
      meals: [
        WeeklyMeal(
          label: "Breakfast",
          name: "Besan Chilla + Greek Yogurt + Banana",
          detail: "3 medium chillas (besan, onion, tomato, ajwain) / 150g Greek yogurt / 1 banana",
          kcal: 670,
          pro: 42,
          carb: 75,
        ),
        WeeklyMeal(
          label: "Lunch (Dabba)",
          name: "Paneer Bhurji (dry) + 2 Roti",
          dabba: [
            "Box 1: Paneer bhurji dry (150g paneer) + 2 roti",
            "Box 2: Cucumber + tomato + whatever veg + chaat masala",
            "Box 3: 100g Amul dahi"
          ],
          kcal: 420,
          pro: 30,
          carb: 40,
        ),
        WeeklyMeal(
          label: "Snack",
          name: "Roasted Chana + Chaas",
          detail: "30g roasted chana / 200ml chaas",
          kcal: 175,
          pro: 10,
          carb: 22,
        ),
        WeeklyMeal(
          label: "Dinner",
          name: "Chole (thick) + 1 Roti",
          detail: "1.5 katori thick chole / 1 roti / cucumber salad / 50g curd",
          kcal: 330,
          pro: 14,
          carb: 48,
        ),
      ],
    ),
    WeeklyDayPlan(
      day: "Tuesday",
      totalKcal: 1560,
      totalPro: 110,
      totalCarb: 152,
      meals: [
        WeeklyMeal(
          label: "Breakfast",
          name: "Paneer Bhurji + 2 Toast + Milk",
          detail: "150g paneer bhurji with capsicum + tomato / 2 whole wheat toast / 200ml low-fat milk",
          kcal: 680,
          pro: 48,
          carb: 58,
        ),
        WeeklyMeal(
          label: "Lunch (Dabba)",
          name: "Rajma (thick) + 2 Roti",
          dabba: [
            "Box 1: Thick rajma (no extra gravy) + 2 roti",
            "Box 2: Onion + tomato + lemon + chaat masala",
            "Box 3: 100g Amul dahi"
          ],
          kcal: 400,
          pro: 18,
          carb: 60,
        ),
        WeeklyMeal(
          label: "Snack",
          name: "Greek Yogurt",
          detail: "200g plain Greek yogurt",
          kcal: 160,
          pro: 18,
          carb: 10,
        ),
        WeeklyMeal(
          label: "Dinner",
          name: "Paneer Capsicum Dry + 1 Roti",
          detail: "150g paneer + capsicum + onion dry sabzi / 1 roti / salad",
          kcal: 320,
          pro: 26,
          carb: 24,
        ),
      ],
    ),
    WeeklyDayPlan(
      day: "Wednesday",
      totalKcal: 1540,
      totalPro: 89,
      totalCarb: 186,
      meals: [
        WeeklyMeal(
          label: "Breakfast",
          name: "Besan Chilla (palak) + Curd + Orange",
          detail: "3 besan chillas with palak added / 100g curd / 1 orange",
          kcal: 650,
          pro: 40,
          carb: 72,
        ),
        WeeklyMeal(
          label: "Lunch (Dabba)",
          name: "Chana Masala + 2 Roti",
          dabba: [
            "Box 1: Dry chana masala + 2 roti",
            "Box 2: Cucumber + carrot + chaat masala",
            "Box 3: 100g Amul dahi"
          ],
          kcal: 400,
          pro: 16,
          carb: 62,
        ),
        WeeklyMeal(
          label: "Snack",
          name: "Roasted Chana",
          detail: "40g roasted salted chana",
          kcal: 160,
          pro: 9,
          carb: 24,
        ),
        WeeklyMeal(
          label: "Dinner",
          name: "Paneer Matar (semi-dry) + 1 Roti",
          detail: "120g paneer + matar sabzi, keep it semi-dry / 1 roti / salad",
          kcal: 330,
          pro: 24,
          carb: 28,
        ),
      ],
    ),
    WeeklyDayPlan(
      day: "Thursday",
      totalKcal: 1570,
      totalPro: 90,
      totalCarb: 190,
      meals: [
        WeeklyMeal(
          label: "Breakfast",
          name: "Paneer Paratha + Curd",
          detail: "2 small paneer parathas (50g paneer filling, 1 tsp ghee total) / 150g curd / green chutney",
          kcal: 680,
          pro: 36,
          carb: 80,
        ),
        WeeklyMeal(
          label: "Lunch (Dabba)",
          name: "Aloo Matar + 2 Roti",
          dabba: [
            "Box 1: Aloo matar dry (1 small aloo + matar) + 2 roti",
            "Box 2: Tomato + onion + kala namak",
            "Box 3: 100g Amul dahi"
          ],
          kcal: 380,
          pro: 12,
          carb: 62,
          note: "Lower protein day - add Greek yogurt to snack",
        ),
        WeeklyMeal(
          label: "Snack",
          name: "Greek Yogurt + Apple",
          detail: "150g Greek yogurt / 1 apple - extra protein to cover aloo lunch",
          kcal: 190,
          pro: 14,
          carb: 26,
        ),
        WeeklyMeal(
          label: "Dinner",
          name: "Paneer Bhurji + 1 Roti",
          detail: "150g paneer bhurji / 1 roti / cucumber + tomato salad",
          kcal: 320,
          pro: 28,
          carb: 22,
        ),
      ],
    ),
    WeeklyDayPlan(
      day: "Friday",
      totalKcal: 1545,
      totalPro: 92,
      totalCarb: 178,
      meals: [
        WeeklyMeal(
          label: "Breakfast",
          name: "Besan Chilla + Greek Yogurt + Apple",
          detail: "3 chillas / 150g Greek yogurt / 1 apple",
          kcal: 665,
          pro: 43,
          carb: 74,
        ),
        WeeklyMeal(
          label: "Lunch (Dabba)",
          name: "Paneer Capsicum Dry + 2 Roti",
          dabba: [
            "Box 1: Paneer capsicum dry sabzi (150g paneer) + 2 roti",
            "Box 2: Cucumber + tomato + chaat masala",
            "Box 3: 100g Amul dahi"
          ],
          kcal: 420,
          pro: 30,
          carb: 40,
        ),
        WeeklyMeal(
          label: "Snack",
          name: "Roasted Chana + Chaas",
          detail: "30g chana / 200ml chaas",
          kcal: 160,
          pro: 9,
          carb: 20,
        ),
        WeeklyMeal(
          label: "Dinner",
          name: "Aloo Gobi (dry) + 1 Roti",
          detail: "Dry aloo gobi (small portion aloo, more gobi) / 1 roti / 100g dahi",
          kcal: 300,
          pro: 10,
          carb: 44,
        ),
      ],
    ),
    WeeklyDayPlan(
      day: "Saturday",
      totalKcal: 1550,
      totalPro: 91,
      totalCarb: 185,
      meals: [
        WeeklyMeal(
          label: "Breakfast",
          name: "Besan Chilla + Curd + Fruit",
          detail: "3 chillas / 100g curd / seasonal fruit (mango / guava / papaya)",
          kcal: 660,
          pro: 38,
          carb: 78,
        ),
        WeeklyMeal(
          label: "Lunch (Dabba)",
          name: "Rajma (thick) + 2 Roti",
          dabba: [
            "Box 1: Thick rajma + 2 roti",
            "Box 2: Onion + cucumber + lemon + kala namak",
            "Box 3: 100g Amul dahi"
          ],
          kcal: 400,
          pro: 18,
          carb: 60,
        ),
        WeeklyMeal(
          label: "Snack",
          name: "Buttermilk + Roasted Chana",
          detail: "200ml chaas / 25g roasted chana",
          kcal: 160,
          pro: 9,
          carb: 19,
        ),
        WeeklyMeal(
          label: "Dinner",
          name: "Paneer Matar + 1 Roti",
          detail: "130g paneer + matar semi-dry / 1 roti / salad",
          kcal: 330,
          pro: 26,
          carb: 28,
        ),
      ],
    ),
    WeeklyDayPlan(
      day: "Sunday",
      totalKcal: 1535,
      totalPro: 88,
      totalCarb: 177,
      note: "Sunday lunch is relaxed - rice is fine. Keep dinner light and you stay well under 1800 kcal.",
      meals: [
        WeeklyMeal(
          label: "Breakfast",
          name: "Besan Chilla + Greek Yogurt + Fruit",
          detail: "3 chillas / 150g Greek yogurt / fruit of choice",
          kcal: 670,
          pro: 42,
          carb: 75,
        ),
        WeeklyMeal(
          label: "Lunch (relaxed)",
          name: "Dal Rice + Mix Veg + Papad",
          detail: "1 katori rice + dal + mix veg sabzi (aloo carrot peas) + 1 papad - enjoy without stress",
          kcal: 500,
          pro: 14,
          carb: 86,
        ),
        WeeklyMeal(
          label: "Snack",
          name: "Chaas",
          detail: "300ml spiced chaas",
          kcal: 75,
          pro: 4,
          carb: 8,
        ),
        WeeklyMeal(
          label: "Dinner",
          name: "Paneer Salad Bowl",
          detail: "150g dry-roasted/grilled paneer / cucumber, tomato, onion, chaat masala, lemon - no roti",
          kcal: 290,
          pro: 28,
          carb: 8,
        ),
      ],
    ),
  ];

  static const List<KeyRecipe> _recipes = [
    KeyRecipe(
      name: "Besan chilla",
      time: "15 min",
      serves: "3 chillas",
      cal: "380 kcal",
      pro: "22g protein",
      ingredients: [
        RecipeIngredient(name: "Besan (gram flour)", quantity: "90g (6 tbsp)"),
        RecipeIngredient(name: "Water", quantity: "~100ml"),
        RecipeIngredient(name: "Onion, finely chopped", quantity: "30g"),
        RecipeIngredient(name: "Tomato, finely chopped", quantity: "30g"),
        RecipeIngredient(name: "Green chilli", quantity: "1 small"),
        RecipeIngredient(name: "Coriander leaves", quantity: "1 tbsp"),
        RecipeIngredient(name: "Ajwain (carom seeds)", quantity: "1/4 tsp"),
        RecipeIngredient(name: "Haldi, red chilli, salt", quantity: "to taste"),
        RecipeIngredient(name: "Oil", quantity: "1 tsp (5g) per chilla"),
      ],
      steps: [
        "Mix besan + water to a smooth lump-free batter. Should be slightly thicker than dosa batter.",
        "Add onion, tomato, chilli, coriander, ajwain and all spices. Mix well.",
        "Heat tawa on medium. Add 1 tsp oil, spread 3 tbsp batter in a circle.",
        "Cook 2-3 min until edges look dry. Flip and cook 1-2 min. Done.",
        "Repeat for 3 chillas using 1 tsp oil each time.",
      ],
      tip: "Add 1 tbsp Greek yogurt to the batter for extra protein + softer texture. Also add palak (spinach) puree on Wednesdays.",
    ),
    KeyRecipe(
      name: "Paneer bhurji (dry)",
      time: "12 min",
      serves: "1 serving",
      cal: "320 kcal",
      pro: "28g protein",
      ingredients: [
        RecipeIngredient(name: "Paneer", quantity: "150g (weighed)"),
        RecipeIngredient(name: "Onion", quantity: "50g (1 small)"),
        RecipeIngredient(name: "Tomato", quantity: "60g (1 small)"),
        RecipeIngredient(name: "Capsicum", quantity: "40g (1/4 medium)"),
        RecipeIngredient(name: "Green chilli", quantity: "1"),
        RecipeIngredient(name: "Ginger-garlic paste", quantity: "1/2 tsp"),
        RecipeIngredient(name: "Haldi", quantity: "1/4 tsp"),
        RecipeIngredient(name: "Red chilli powder", quantity: "1/2 tsp"),
        RecipeIngredient(name: "Jeera", quantity: "1/2 tsp"),
        RecipeIngredient(name: "Oil", quantity: "1 tsp (5g)"),
        RecipeIngredient(name: "Salt + coriander", quantity: "to taste"),
      ],
      steps: [
        "Crumble paneer into small pieces with your hand. Keep aside.",
        "Heat oil in pan. Add jeera, let it splutter.",
        "Add onion + green chilli, cook 2 min until soft.",
        "Add ginger-garlic paste, cook 30 sec.",
        "Add tomato + capsicum + all spices. Cook 3 min until tomato softens.",
        "Add crumbled paneer. Mix well. Cook 2 min on medium. Done - keep it dry.",
      ],
      tip: "For dabba: make slightly drier than usual so it doesn't get soggy by lunch. Tastes good at room temp.",
    ),
    KeyRecipe(
      name: "Dal tadka",
      time: "25 min",
      serves: "2 servings",
      cal: "180 kcal",
      pro: "10g protein",
      ingredients: [
        RecipeIngredient(name: "Toor dal (arhar)", quantity: "80g dry"),
        RecipeIngredient(name: "Onion", quantity: "50g"),
        RecipeIngredient(name: "Tomato", quantity: "60g"),
        RecipeIngredient(name: "Garlic cloves", quantity: "3"),
        RecipeIngredient(name: "Green chilli", quantity: "1"),
        RecipeIngredient(name: "Haldi", quantity: "1/4 tsp"),
        RecipeIngredient(name: "Red chilli powder", quantity: "1/2 tsp"),
        RecipeIngredient(name: "Jeera", quantity: "1 tsp"),
        RecipeIngredient(name: "Hing (asafoetida)", quantity: "a pinch"),
        RecipeIngredient(name: "Oil or ghee", quantity: "1 tsp"),
        RecipeIngredient(name: "Salt + coriander", quantity: "to taste"),
      ],
      steps: [
        "Wash dal. Pressure cook with 2.5 cups water, haldi and salt - 3 whistles.",
        "In a pan heat oil. Add jeera + hing, let splutter.",
        "Add garlic, cook 30 sec. Add onion, cook 3 min until golden.",
        "Add tomato + chilli + red chilli powder. Cook 4 min until oil separates.",
        "Add cooked dal. Mix. Add water if too thick. Simmer 5 min.",
        "Finish with fresh coriander. Tadka done.",
      ],
      tip: "Make double quantity - lasts 2 days in fridge. Mom can batch cook Sun evening for Mon-Tue lunches.",
    ),
    KeyRecipe(
      name: "Thick chole",
      time: "30 min",
      serves: "3 servings",
      cal: "220 kcal",
      pro: "11g protein",
      ingredients: [
        RecipeIngredient(name: "Kabuli chana (dry)", quantity: "120g"),
        RecipeIngredient(name: "Onion", quantity: "80g"),
        RecipeIngredient(name: "Tomato", quantity: "100g"),
        RecipeIngredient(name: "Ginger-garlic paste", quantity: "1 tsp"),
        RecipeIngredient(name: "Chole masala", quantity: "1.5 tsp"),
        RecipeIngredient(name: "Red chilli powder", quantity: "1/2 tsp"),
        RecipeIngredient(name: "Haldi", quantity: "1/4 tsp"),
        RecipeIngredient(name: "Amchur or lemon", quantity: "1/2 tsp"),
        RecipeIngredient(name: "Oil", quantity: "1.5 tsp"),
        RecipeIngredient(name: "Salt + coriander", quantity: "to taste"),
      ],
      steps: [
        "Soak chana overnight. Pressure cook with salt + 1 tea bag (for dark colour) - 5 whistles.",
        "Heat oil. Add onion, cook on medium 5 min until dark golden.",
        "Add ginger-garlic paste, cook 1 min.",
        "Add tomato + all spices. Cook 5-6 min until oil separates.",
        "Add drained chana. Mash some chanas with the back of spoon for thick gravy.",
        "Add minimal water - keep it dry and thick for dabba. Simmer 8 min.",
      ],
      tip: "Batch cook chana on Sunday - stores 3 days. Use same chana for chana masala by changing spices.",
    ),
    KeyRecipe(
      name: "Thick rajma",
      time: "35 min",
      serves: "3 servings",
      cal: "220 kcal",
      pro: "12g protein",
      ingredients: [
        RecipeIngredient(name: "Rajma (kidney beans)", quantity: "120g dry"),
        RecipeIngredient(name: "Onion", quantity: "80g"),
        RecipeIngredient(name: "Tomato", quantity: "100g"),
        RecipeIngredient(name: "Ginger-garlic paste", quantity: "1 tsp"),
        RecipeIngredient(name: "Rajma masala", quantity: "1.5 tsp"),
        RecipeIngredient(name: "Red chilli powder", quantity: "1/2 tsp"),
        RecipeIngredient(name: "Haldi", quantity: "1/4 tsp"),
        RecipeIngredient(name: "Jeera", quantity: "1/2 tsp"),
        RecipeIngredient(name: "Oil", quantity: "1.5 tsp"),
        RecipeIngredient(name: "Salt + coriander", quantity: "to taste"),
      ],
      steps: [
        "Soak rajma overnight. Pressure cook with salt - 6-7 whistles until very soft.",
        "Heat oil. Add jeera, let splutter. Add onion, cook 5-6 min until golden brown.",
        "Add ginger-garlic paste, cook 1 min.",
        "Add tomato + all spices. Cook 6 min until oil separates.",
        "Add cooked rajma with very little water. Mash some beans for thickness.",
        "Simmer on low 10 min. Keep thick - no gravy for dabba.",
      ],
      tip: "Rajma tastes even better next day. Make Monday evening, pack Tuesday dabba. Stores 3 days.",
    ),
    KeyRecipe(
      name: "Paneer capsicum dry",
      time: "15 min",
      serves: "1 serving",
      cal: "310 kcal",
      pro: "26g protein",
      ingredients: [
        RecipeIngredient(name: "Paneer", quantity: "150g (cubed)"),
        RecipeIngredient(name: "Capsicum (green/red)", quantity: "80g (1 small)"),
        RecipeIngredient(name: "Onion", quantity: "50g"),
        RecipeIngredient(name: "Tomato", quantity: "40g"),
        RecipeIngredient(name: "Ginger-garlic paste", quantity: "1/2 tsp"),
        RecipeIngredient(name: "Red chilli + haldi", quantity: "1/2 tsp each"),
        RecipeIngredient(name: "Garam masala", quantity: "1/4 tsp"),
        RecipeIngredient(name: "Oil", quantity: "1 tsp (5g)"),
        RecipeIngredient(name: "Salt + coriander", quantity: "to taste"),
      ],
      steps: [
        "Cut paneer into 1.5cm cubes. Slice capsicum and onion into strips.",
        "Heat oil on high. Add onion, cook 1-2 min until edges brown.",
        "Add ginger-garlic paste, cook 30 sec.",
        "Add tomato + all spices. Cook 2 min.",
        "Add capsicum. Toss on high flame 2 min - keep slight crunch.",
        "Add paneer cubes. Toss gently 2 min. Finish with garam masala + coriander.",
      ],
      tip: "High flame = less oil needed + better texture. Don't overcook capsicum - it gets watery and ruins the dabba.",
    ),
  ];

  Future<void> _logWheyShake() async {
    setState(() => _logging = true);
    try {
      await _logMeal(
        title: "Whey Protein Shake",
        kcal: 120,
        carbs: 0,
        fat: 2,
        protein: 25,
        mealType: IntakeTypeEntity.snack,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Whey Protein Shake logged (+25g Protein)"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log shake: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _logging = false);
      }
    }
  }

  Future<void> _logWeeklyMeal(WeeklyMeal meal) async {
    setState(() => _logging = true);
    try {
      double fat = (meal.kcal - meal.pro * 4.0 - meal.carb * 4.0) / 9.0;
      if (fat < 0) fat = 0;

      await _logMeal(
        title: meal.name,
        kcal: meal.kcal,
        carbs: meal.carb,
        fat: double.parse(fat.toStringAsFixed(1)),
        protein: meal.pro,
        mealType: meal.intakeType,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Logged: ${meal.name}"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log meal: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _logging = false);
      }
    }
  }

  Future<void> _logFullDay(WeeklyDayPlan dayPlan) async {
    setState(() => _logging = true);
    try {
      for (final meal in dayPlan.meals) {
        double fat = (meal.kcal - meal.pro * 4.0 - meal.carb * 4.0) / 9.0;
        if (fat < 0) fat = 0;

        await _logMeal(
          title: meal.name,
          kcal: meal.kcal,
          carbs: meal.carb,
          fat: double.parse(fat.toStringAsFixed(1)),
          protein: meal.pro,
          mealType: meal.intakeType,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Logged all meals for ${dayPlan.day}"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log day: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _logging = false);
      }
    }
  }

  Future<void> _logMeal({
    required String title,
    required double kcal,
    required double? carbs,
    required double? fat,
    required double? protein,
    required IntakeTypeEntity mealType,
  }) async {
    final day = DateTime.now();
    final nutriments = MealNutrimentsEntity(
      energyKcal100: kcal,
      carbohydrates100: carbs,
      fat100: fat,
      proteins100: protein,
      sugars100: null,
      saturatedFat100: null,
      fiber100: null,
    );
    final meal = MealEntity(
      code: IdGenerator.getUniqueID(),
      name: title,
      url: null,
      mealQuantity: '100',
      mealUnit: 'gml',
      servingQuantity: null,
      servingUnit: 'gml',
      servingSize: '',
      nutriments: nutriments,
      source: MealSourceEntity.custom,
    );
    final intake = IntakeEntity(
      id: IdGenerator.getUniqueID(),
      unit: 'g',
      amount: 100,
      type: mealType,
      meal: meal,
      dateTime: day,
    );

    await locator<AddIntakeUsecase>().addIntake(intake);

    final addTrackedDay = locator<AddTrackedDayUsecase>();
    final hasTrackedDay = await addTrackedDay.hasTrackedDay(day);
    if (!hasTrackedDay) {
      final kcalGoal = await locator<GetKcalGoalUsecase>().getKcalGoal();
      final macroGoal = locator<GetMacroGoalUsecase>();
      await addTrackedDay.addNewTrackedDay(
        day,
        kcalGoal,
        await macroGoal.getCarbsGoal(kcalGoal),
        await macroGoal.getFatsGoal(kcalGoal),
        await macroGoal.getProteinsGoal(kcalGoal),
      );
    }
    await addTrackedDay.addDayCaloriesTracked(day, intake.totalKcal);
    await addTrackedDay.addDayMacrosTracked(
      day,
      carbsTracked: intake.totalCarbsGram,
      fatTracked: intake.totalFatsGram,
      proteinTracked: intake.totalProteinsGram,
    );

    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(text: "Weekly Rotation"),
              Tab(text: "Key Recipes"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildWeeklyTab(),
                _buildRecipesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    final theme = Theme.of(context);
    final dayPlan = _days[_selectedDayIndex];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Whey Shake Banner Card
        _buildWheyShakeBanner(),
        const SizedBox(height: 16),

        // Horizontal day selector
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedDayIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(_days[index].day.substring(0, 3)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDayIndex = index);
                    }
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Day Summary Card
        Card(
          elevation: 0,
          color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${dayPlan.day} Targets",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _logging ? null : () => _logFullDay(dayPlan),
                      icon: const Icon(Icons.playlist_add, size: 18),
                      label: const Text("Log Full Day"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      "${dayPlan.totalKcal.toInt()} kcal",
                      "Calories",
                      theme.colorScheme.primary,
                    ),
                    _buildSummaryItem(
                      "${dayPlan.totalPro.toInt()}g",
                      "Protein",
                      Colors.teal,
                    ),
                    _buildSummaryItem(
                      "${dayPlan.totalCarb.toInt()}g",
                      "Carbs",
                      Colors.orange,
                    ),
                  ],
                ),
                if (dayPlan.note != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      dayPlan.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Meals List
        ...dayPlan.meals.map((meal) {
          final isLunch = meal.label.toLowerCase().contains("lunch");
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLunch
                              ? theme.colorScheme.tertiaryContainer
                              : theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          meal.label.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLunch
                                ? theme.colorScheme.onTertiaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: "Log to Diary",
                        onPressed: _logging ? null : () => _logWeeklyMeal(meal),
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meal.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (meal.dabba != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: meal.dabba!.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "- ",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else if (meal.detail != null)
                    Text(
                      meal.detail!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMacroTag("${meal.kcal.toInt()} kcal", Colors.purple),
                      const SizedBox(width: 8),
                      _buildMacroTag("${meal.pro.toInt()}g Protein", Colors.teal),
                      const SizedBox(width: 8),
                      _buildMacroTag("${meal.carb.toInt()}g Carbs", Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecipesTab() {
    final theme = Theme.of(context);
    final recipe = _recipes[_selectedRecipeIndex];

    return Row(
      children: [
        // Side Navigation for Recipes
        NavigationRail(
          selectedIndex: _selectedRecipeIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedRecipeIndex = index);
          },
          labelType: NavigationRailLabelType.all,
          backgroundColor: theme.colorScheme.surface,
          destinations: _recipes.map((r) {
            final nameShort = r.name.split(" ").first;
            return NavigationRailDestination(
              icon: const Icon(Icons.restaurant_menu),
              selectedIcon: const Icon(Icons.restaurant),
              label: Text(
                nameShort,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),

        // Selected Recipe Details
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                recipe.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Quick details
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildRecipeBadge(Icons.timer_outlined, recipe.time, Colors.purple),
                  _buildRecipeBadge(Icons.room_service_outlined, recipe.serves, Colors.teal),
                  _buildRecipeBadge(Icons.local_fire_department_outlined, recipe.cal, Colors.orange),
                  _buildRecipeBadge(Icons.fitness_center_outlined, recipe.pro, Colors.blue),
                ],
              ),
              const SizedBox(height: 16),

              // Ingredients Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Ingredients",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 16),
                      ...recipe.ingredients.map((ing) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ing.name, style: theme.textTheme.bodyMedium),
                              Text(
                                ing.quantity,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Steps Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Preparation Steps",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 16),
                      ...recipe.steps.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final step = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: theme.colorScheme.surfaceVariant,
                                child: Text(
                                  index.toString(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tip Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recipe.tip,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWheyShakeBanner() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primaryContainer.withOpacity(0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Protein Log",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Add Whey Protein Shake: +25g Protein, 120 kcal",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _logging ? null : _logWheyShake,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text("Log Shake"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroTag(String text, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecipeBadge(IconData icon, String text, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
