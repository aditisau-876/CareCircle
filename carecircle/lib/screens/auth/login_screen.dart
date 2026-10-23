import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/data/auth_service.dart';
import '../../core/navigation/auth_navigation.dart';

class LoginScreen extends StatefulWidget {
const LoginScreen({super.key});

@override
State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final _formKey = GlobalKey<FormState>();

final _emailController = TextEditingController();
final _passwordController = TextEditingController();

bool _isLoading = false;
bool _obscurePassword = true;
bool _rememberMe = true;

@override
void dispose() {
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}

Future<void> _login() async {
FocusScope.of(context).unfocus();

if (_isLoading) return;
if (!_formKey.currentState!.validate()) return;

setState(() {
_isLoading = true;
});

try {
await AuthService.login(
email: _emailController.text.trim(),
password: _passwordController.text,
);

final destination = await AuthNavigation.dashboardForCurrentUser();

if (!mounted) return;

Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute<void>(
builder: (_) => destination,
),
(route) => false,
);
} catch (error) {
if (!mounted) return;

debugPrint('CareCircle login error: $error');

final message = error is ApiException
? error.message
: 'Login failed. Please check your details and internet connection.';

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
duration: const Duration(seconds: 5),
),
);
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
return Scaffold(
appBar: AppBar(
leading: IconButton(
icon: const Icon(Icons.arrow_back_rounded),
onPressed: _isLoading
? null
    : () => Navigator.of(context).pop(),
),
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const SizedBox(height: 20),

// Header icon
Center(
child: Container(
width: 76,
height: 76,
decoration: BoxDecoration(
color: CareCircleColors.primaryLight,
borderRadius: BorderRadius.circular(24),
),
child: const Icon(
Icons.favorite_rounded,
size: 40,
color: CareCircleColors.primary,
),
),
),

const SizedBox(height: 28),

Center(
child: Text(
'Welcome back',
style: Theme.of(context).textTheme.headlineLarge,
),
),

const SizedBox(height: 8),

Center(
child: Text(
'Sign in to continue caring for your circle.',
textAlign: TextAlign.center,
style: Theme.of(context).textTheme.bodyLarge,
),
),

const SizedBox(height: 36),

Text(
'Email or phone number',
style: Theme.of(context).textTheme.titleMedium,
),

const SizedBox(height: 10),

TextFormField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
textInputAction: TextInputAction.next,
enabled: !_isLoading,
autofillHints: const [AutofillHints.username],
decoration: const InputDecoration(
hintText: 'Enter your email or phone',
prefixIcon: Icon(Icons.person_outline_rounded),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Please enter your email address';
}

// The current backend uses email and password.
if (!value.trim().contains('@')) {
return 'Please enter the email used to register';
}

return null;
},
),

const SizedBox(height: 22),

Text(
'Password',
style: Theme.of(context).textTheme.titleMedium,
),

const SizedBox(height: 10),

TextFormField(
controller: _passwordController,
obscureText: _obscurePassword,
textInputAction: TextInputAction.done,
enabled: !_isLoading,
autofillHints: const [AutofillHints.password],
onFieldSubmitted: (_) {
if (!_isLoading) {
_login();
}
},
decoration: InputDecoration(
hintText: 'Enter your password',
prefixIcon: const Icon(
Icons.lock_outline_rounded,
),
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
return 'Please enter your password';
}

return null;
},
),

const SizedBox(height: 12),

Row(
children: [
Checkbox(
value: _rememberMe,
activeColor: CareCircleColors.primary,
onChanged: _isLoading
? null
    : (value) {
setState(() {
_rememberMe = value ?? false;
});
},
),
const Expanded(
child: Text('Remember me'),
),
TextButton(
onPressed: _isLoading
? null
    : () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Password recovery will be available soon.',
),
),
);
},
child: const Text(
'Forgot password?',
style: TextStyle(
color: CareCircleColors.primary,
fontWeight: FontWeight.w600,
),
),
),
],
),

const SizedBox(height: 18),

SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: _isLoading ? null : _login,
child: _isLoading
? const SizedBox(
width: 22,
height: 22,
child: CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Text('Log in'),
),
),

const SizedBox(height: 24),

Row(
children: [
const Expanded(child: Divider()),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 14),
child: Text(
'New to CareCircle?',
style: Theme.of(context).textTheme.bodyMedium,
),
),
const Expanded(child: Divider()),
],
),

const SizedBox(height: 16),

SizedBox(
width: double.infinity,
child: OutlinedButton(
onPressed: _isLoading
? null
    : () {
Navigator.of(context).pop();
},
style: OutlinedButton.styleFrom(
minimumSize: const Size(double.infinity, 54),
foregroundColor: CareCircleColors.primary,
side: const BorderSide(
color: CareCircleColors.primary,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(17),
),
),
child: const Text('Create a new account'),
),
),
],
),
),
),
),
);
}
}
