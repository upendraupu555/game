import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/navigation/navigation_service.dart';
import '../../core/utils/auth_error_handler.dart';
import '../../core/utils/error_handler.dart';
import '../providers/user_providers.dart';
import '../providers/theme_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(userProvider.notifier)
          .authenticateUser(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        NavigationService.pushReplacementNamed(AppRoutes.profile);
      }
    } catch (error) {
      if (mounted) {
        // Use the enhanced auth error handler with dialog display
        AuthErrorHandler.showAuthErrorDialog(
          context,
          ref,
          error,
          email: _emailController.text.trim(),
          onRetry: () => _handleLogin(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final username = _emailController.text.split('@').first;
      await ref
          .read(userProvider.notifier)
          .registerUser(
            username: username,
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        NavigationService.pushReplacementNamed(AppRoutes.profile);
      }
    } catch (error) {
      if (mounted) {
        // Check if this is an email confirmation error for registration
        if (error is AuthenticationError && error.isEmailNotConfirmed) {
          // For registration, show success message and navigate to profile
          ErrorHandler.showSuccessDialog(
            context,
            ref,
            LocalizationManager.translate(ref, 'email_confirmation_pending'),
            title: LocalizationManager.translate(ref, 'success_dialog_title'),
            onOk: () =>
                NavigationService.pushReplacementNamed(AppRoutes.profile),
          );
        } else {
          // Use the enhanced auth error handler for other registration errors
          AuthErrorHandler.showAuthErrorDialog(
            context,
            ref,
            error,
            email: _emailController.text.trim(),
            onRetry: () => _handleRegister(),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final primaryColor = themeState.when(
      data: (theme) {
        final brightness = Theme.of(context).brightness;
        final colorEntity = brightness == Brightness.light
            ? theme.lightPrimaryColor
            : theme.darkPrimaryColor;
        return colorEntity.toFlutterColor();
      },
      loading: () => Theme.of(context).primaryColor,
      error: (_, __) => Theme.of(context).primaryColor,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationManager.translate(ref, 'login_title')),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Header
                  Icon(Icons.account_circle, size: 80, color: primaryColor),
                  const SizedBox(height: AppConstants.paddingMedium),

                  Text(
                    LocalizationManager.translate(ref, 'login_title'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),

                  Text(
                    LocalizationManager.translate(ref, 'login_description'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingExtraLarge),

                  // Email Field
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: LocalizationManager.translate(
                            ref,
                            'email',
                          ),
                          prefixIcon: Icon(Icons.email, color: primaryColor),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Password Field
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: LocalizationManager.translate(
                            ref,
                            'password',
                          ),
                          prefixIcon: Icon(Icons.lock, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingExtraLarge),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            LocalizationManager.translate(ref, 'sign_in'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Register Button
                  OutlinedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                      ),
                    ),
                    child: Text(
                      LocalizationManager.translate(ref, 'create_account'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Forgot Password Link
                  TextButton(
                    onPressed: () =>
                        NavigationService.pushNamed(AppRoutes.forgotPassword),
                    child: Text(
                      LocalizationManager.translate(ref, 'forgot_password'),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Guest Info
                  Card(
                    elevation: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: primaryColor,
                            size: 24,
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          Text(
                            LocalizationManager.translate(
                              ref,
                              'guest_description',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          Text(
                            LocalizationManager.translate(
                              ref,
                              'sign_in_to_save',
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
