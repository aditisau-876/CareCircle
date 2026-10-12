

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
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

  void _createAccount() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms to continue.'),
        ),
      );
      return;
    }

    // Frontend demonstration only.
    // Real account creation will be connected to FastAPI later.

    if (widget.role == 'helper') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HelperRegistrationScreen(),
        ),
      );
      return;
    }

    // Family members and care recipients complete the care profile
    // before entering their role-specific dashboard.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ElderlyProfileScreen(
          role: widget.role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
                  textCapitalization: TextCapitalization.words,
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
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    prefixText: '+91  ',
                  ),
                  validator: (value) {
                    final phone = value?.replaceAll(' ', '') ?? '';

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
                  keyboardType: TextInputType.emailAddress,
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
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Create a secure password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
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

                ElevatedButton(
                  onPressed: _createAccount,
                  child: const Text('Create account'),
                ),

                const SizedBox(height: 18),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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
          onChanged: (value) {
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
