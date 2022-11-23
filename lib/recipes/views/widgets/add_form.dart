import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/common/models/utils.dart';
import 'package:recipe_app/dashboard/models/constants.dart';
import 'package:recipe_app/dashboard/models/data/recipe.dart';
import 'package:recipe_app/recipes/controllers/recipes_providers.dart';
import 'package:recipe_app/recipes/views/widgets/form_field.dart';
import 'package:recipe_app/recipes/views/widgets/multi_select_tags.dart';

class AddRecipeForm extends StatefulWidget {
  const AddRecipeForm({super.key, required this.onFormSaved});
  final Function(Recipe recipe) onFormSaved;

  @override
  State<AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  List<String> tags = [];
  List<String> selectedTags = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _readyInMinutesController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    tags = TagEnum.values
        .where((element) => element.value.toLowerCase() != 'all')
        .map((e) => e.value)
        .toList();
  }

  // Validations for all fields
  String? _textValidator(String? value) {
    final text = Validator.isNotEmpty(value);
    if (text != null) {
      return text;
    }
    return null;
  }

  _saveButton() => ElevatedButton.icon(
        onPressed: saveRecipe,
        icon: const Icon(Icons.save_alt_rounded),
        label: const Text('Save'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xff129575),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: const StadiumBorder(),
        ),
      );

  _loadingButton() => ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xff129575),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: const StadiumBorder(),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );

  saveRecipe() {
    debugPrint('saveRecipe()');
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    // Create recipe object and call onFormSaved with it
    final recipe = Recipe()
      ..title = _titleController.text
      ..summary = _summaryController.text
      ..servings = int.parse(_servingsController.text)
      ..calories = double.parse(_caloriesController.text)
      ..readyInMinutes = int.parse(_readyInMinutesController.text)
      ..tags = selectedTags;
    widget.onFormSaved(recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 8,
          ),
          MultiSelectTags(
            tagList: tags,
            onSelectionChanged: (tags) {
              setState(() {
                selectedTags = tags;
              });
            },
          ),
          const SizedBox(
            height: 8,
          ),
          RecipeFormField(
            inputKey: const Key('new_recipe_title_form_field'),
            controller: _titleController,
            label: 'Title',
            placeholder: 'Title...',
            validator: _textValidator,
          ),
          const SizedBox(
            height: 8,
          ),
          RecipeFormField(
            inputKey: const Key('new_recipe_summary_form_field'),
            controller: _summaryController,
            label: 'Summary',
            placeholder: 'Recipe summary...',
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            maxLength: 250,
            validator: _textValidator,
          ),
          const SizedBox(
            height: 8,
          ),
          RecipeFormField(
            inputKey: const Key('new_recipe_servings_form_field'),
            controller: _servingsController,
            label: 'Servings',
            placeholder: 'Amount of servings...',
            keyboardType: TextInputType.number,
            validator: _textValidator,
          ),
          const SizedBox(
            height: 8,
          ),
          RecipeFormField(
            inputKey: const Key('new_recipe_calories_form_field'),
            controller: _caloriesController,
            label: 'Calories',
            placeholder: 'Amount of calories...',
            keyboardType: TextInputType.number,
            validator: _textValidator,
          ),
          const SizedBox(
            height: 8,
          ),
          RecipeFormField(
            inputKey: const Key('new_recipe_readyIn_form_field'),
            controller: _readyInMinutesController,
            label: 'Cook time (minutes)',
            placeholder: 'Time in minutes...',
            keyboardType: TextInputType.number,
            keyboardAction: TextInputAction.done,
            validator: _textValidator,
          ),
          const SizedBox(height: 20),
          // Watch changes and show loading indicator while saving.
          Consumer(
            builder: (context, ref, child) {
              final status = ref.watch(recipeManagementProvider);
              return status.when(
                data: (data) {
                  if (data == RecipeStatus.initial) {
                    return _saveButton();
                  }
                  if (data == RecipeStatus.done) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        context.router.pop('saved');
                      }
                    });
                  }
                  return const SizedBox.shrink();
                },
                error: (error, stack) {
                  debugPrint(error.toString());
                  showSnackBarMessage(context, error.toString());
                  return _saveButton();
                },
                loading: () {
                  debugPrint('Saving recipe...');
                  return _loadingButton();
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
