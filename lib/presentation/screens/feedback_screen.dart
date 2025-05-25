import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';

/// Feedback screen for collecting user feedback and suggestions
/// This is a generic whitelabel screen that can be customized through AppConfig
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedCategory = 'General';
  int _rating = 5;

  final List<String> _categories = [
    'General',
    'Bug Report',
    'Feature Request',
    'User Interface',
    'Performance',
    'Other',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.feedbackTitle(ref)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.feedback,
                      size: AppConstants.iconSizeExtraLarge,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      LocalizationManager.feedbackTitle(ref),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      LocalizationManager.feedbackDescription(ref),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Rating Section
              _buildRatingSection(),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Category Selection
              _buildCategorySection(),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Feedback Text
              _buildFeedbackSection(),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Email (Optional)
              _buildEmailSection(),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Submit Button
              _buildSubmitButton(),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Additional Info
              _buildAdditionalInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: AppConstants.iconSizeMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Rate Your Experience',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: AppConstants.iconSizeLarge,
                    ),
                  );
                }),
              ),
            ),
            Center(
              child: Text(
                '$_rating out of 5 stars',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: AppConstants.iconSizeMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a category',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.message,
                  size: AppConstants.iconSizeMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Your Feedback',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tell us what you think...',
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your feedback';
                }
                if (value.trim().length < 10) {
                  return 'Please provide more detailed feedback';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.email,
                  size: AppConstants.iconSizeMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Email (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Provide your email if you\'d like us to follow up on your feedback.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'your.email@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submitFeedback,
        icon: const Icon(Icons.send),
        label: const Text('Submit Feedback'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: AppConstants.iconSizeMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Privacy Notice',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Your feedback helps us improve ${AppConfig.appName}. We respect your privacy and will only use your information to address your feedback.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement actual feedback submission
      // This could send to an API, email service, or analytics platform
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thank You!'),
          content: Text(
            'Your feedback has been submitted successfully. We appreciate your input and will use it to improve ${AppConfig.appName}.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
