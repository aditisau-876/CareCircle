import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/auth/data/auth_service.dart';
import '../helper/helper_registration_screen.dart';
import 'elderly_profile_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final String role;

  const RegistrationScreen({
    super.key,
    required this.role,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  String get roleTitle {
    switch (widget.role) {
      case 'family':
        return 'Family member';
      case 'elderly':
        return 'Care recipient';
      case 'helper':
        return 'Care helper';
      default:
        return 'CareCircle member';
    }
  }

  String get roleDescription {
    switch (widget.role) {
      case 'family':
        return 'Create an account to arrange and monitor care for your loved one.';
      case 'elderly':
        return 'Create your profile so your care and assistance can be arranged easily.';
      case 'helper':
        return 'Create your profile to become a trusted CareCircle helper.';
      default:
        return 'Create your CareCircle account.';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the Terms of Service and Privacy Policy.',
          ),
        ),
      );
      return;
    }

    if (!['family', 'elderly', 'helper'].contains(widget.role)) {
      _showError('Please select a valid account type.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Register the account with the FastAPI backend.
      // The AuthService also saves the returned authentication token.
      await AuthService.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: '+91${_phoneController.text.trim().replaceAll(' ', '')}',
        password: _passwordController.text,
        role: widget.role,
      );

      if (!mounted) return;

      // Continue to the appropriate profile-registration flow.
      if (widget.role == 'helper') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const HelperRegistrationScreen(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ElderlyProfileScreen(
              role: widget.role,
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      _showError(_friendlyErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyErrorMessage(Object error) {
    final message = error.toString();
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('socketexception') ||
        lowerMessage.contains('failed host lookup') ||
        lowerMessage.contains('connection refused') ||
        lowerMessage.contains('connection error') ||
        lowerMessage.contains('timed out') ||
        lowerMessage.contains('timeout')) {
      return 'Cannot connect to CareCircle right now. Check that the '
          'backend is running and your phone is connected to the same Wi-Fi.';
    }

    if (lowerMessage.contains('already registered') ||
        lowerMessage.contains('already exists') ||
        lowerMessage.contains('already taken') ||
        lowerMessage.contains('duplicate')) {
      return 'An account with this email or phone number may already exist. '
          'Please sign in or use different details.';
    }

    // ApiClient may include a useful server message in its exception.
    // Keep this fallback readable if the error is not a network issue.
    if (message.startsWith('ApiException:')) {
      return message.substring('ApiException:'.length).trim();
    }

    return 'We could not create your account. Please check your details '
        'and try again.';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgress(),

                const SizedBox(height: 30),

                Text(
                  'Create your account',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                const SizedBox(height: 10),

                Text(
                  roleDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: 30),

                _buildRoleBadge(),

                const SizedBox(height: 28),

                Text(
                  'Your name',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 9),

                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }

                    if (value.trim().length < 2) {
                      return 'Please enter a valid name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Phone number',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 9),

                TextFormField(
                  controller: _phoneController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    prefixText: '+91  ',
                  ),
                  validator: (value) {
                    final phone =
                        value?.replaceAll(RegExp(r'\s+'), '') ?? '';

                    if (phone.isEmpty) {
                      return 'Please enter your phone number';
                    }

                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
                      return 'Enter a valid 10-digit Indian mobile number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Email address',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 9),

                TextFormField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(email)) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Password',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 9),

                TextFormField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Create a secure password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please create a password';
                    }

                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildTermsCheckbox(),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    child: _isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Text('Create account'),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text(
                      'Already have an account? Sign in',
                      style: TextStyle(
                        color: CareCircleColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: CareCircleColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: CareCircleColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: CareCircleColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge() {
    IconData icon;

    switch (widget.role) {
      case 'family':
        icon = Icons.family_restroom_rounded;
        break;
      case 'elderly':
        icon = Icons.elderly_rounded;
        break;
      case 'helper':
        icon = Icons.volunteer_activism_rounded;
        break;
      default:
        icon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: CareCircleColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: 2),
          Icon(
            icon,
            color: CareCircleColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            roleTitle,
            style: const TextStyle(
              color: CareCircleColors.primaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.check_circle_rounded,
            color: CareCircleColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedTerms,
          activeColor: CareCircleColors.primary,
          onChanged: _isLoading
              ? null
              : (value) {
            setState(() {
              _acceptedTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 11),
            child: Text(
              'I agree to the CareCircle Terms of Service and Privacy Policy.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}