import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:yajid/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:yajid/locale_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yajid/bloc/auth/auth_bloc.dart';
import 'package:yajid/bloc/auth/auth_event.dart';
import 'package:yajid/bloc/auth/auth_state.dart';
import 'dart:io';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;

  @override
  bool get wantKeepAlive => true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredFirstName = '';
  var _enteredLastName = '';
  var _enteredPhoneNumber = '';
  var _selectedCountryCode = '+1';
  var _selectedGender = '';
  DateTime? _selectedBirthday;

  bool _isHoveringLogin = false;
  bool _isHoveringCreateAccount = false;
  bool _isHoveringGoogleSignIn = false;
  bool _isHoveringAppleSignIn = false;
  bool _isPasswordVisible = false;
  bool _isHoveringForgotPassword = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    if (_isLogin) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _enteredEmail,
          password: _enteredPassword,
        ),
      );
    } else {
      final fullPhoneNumber = '$_selectedCountryCode$_enteredPhoneNumber';
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: _enteredEmail,
          password: _enteredPassword,
          firstName: _enteredFirstName,
          lastName: _enteredLastName,
          phoneNumber: fullPhoneNumber,
          gender: _selectedGender,
          birthday: _selectedBirthday,
        ),
      );
    }
  }





  void _resetPassword() {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    context.read<AuthBloc>().add(
      AuthPasswordResetRequested(email: _enteredEmail),
    );
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  void _signInWithApple() {
    context.read<AuthBloc>().add(const AuthAppleSignInRequested());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  void _showLanguageDialog() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                AppLocalizations.of(context)!.selectLanguage,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: RadioGroup<Locale>(
                groupValue: localeProvider.locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    localeProvider.setLocale(value);
                    Navigator.of(context).pop();
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<Locale>(
                      title: const Text('English'),
                      value: const Locale('en'),
                    ),
                    RadioListTile<Locale>(
                      title: const Text('Español'),
                      value: const Locale('es'),
                    ),
                    RadioListTile<Locale>(
                      title: const Text('Français'),
                      value: const Locale('fr'),
                    ),
                    RadioListTile<Locale>(
                      title: const Text('العربية'),
                      value: const Locale('ar'),
                    ),
                    RadioListTile<Locale>(
                      title: const Text('Português'),
                      value: const Locale('pt'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            leading: !_isLogin
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _isLogin = true;
                      });
                    },
                  )
                : null,
            centerTitle: true,
            title: Image.asset(
              'assets/images/light_yajid_logo.png',
              height: 48,
              fit: BoxFit.contain,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.language,
                    color: Colors.black,
                  ),
                  onPressed: _showLanguageDialog,
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Card(
                    elevation: 8,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.firstName,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .pleaseEnterYourFirstName;
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredFirstName = value!;
                                },
                              ),
                              ],
                            ),
                          if (!_isLogin) const SizedBox(height: 16),
                          if (!_isLogin)
                            TextFormField(
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              ),
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.lastName,
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  floatingLabelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .pleaseEnterYourLastName;
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredLastName = value!;
                                },
                            ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.emailAddress,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                    return AppLocalizations.of(context)!.pleaseEnterAValidEmailAddress;
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredEmail = value!;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.password,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outlined,
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: !_isPasswordVisible,
                                validator: (value) {
                                  if (value == null || value.trim().length < 6) {
                                    return AppLocalizations.of(context)!
                                        .passwordMustBeAtLeast6CharactersLong;
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredPassword = value!;
                                },
                              ),
                            ],
                          ),
                          if (!_isLogin) const SizedBox(height: 16),
                          if (!_isLogin)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.phoneNumber,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: CountryCodePicker(
                                      onChanged: (country) {
                                        _selectedCountryCode = country.dialCode!;
                                      },
                                      initialSelection: 'US',
                                      favorite: const ['+1', 'US'],
                                      showCountryOnly: false,
                                      showOnlyCountryWhenClosed: false,
                                      alignLeft: false,
                                      textStyle: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      ),
                                      dialogTextStyle: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      ),
                                      searchStyle: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      ),
                                      dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.white,
                                      barrierColor: Colors.black54,
                                      boxDecoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey.shade800
                                          : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade300,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade300,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.5,
                                          ),
                                        ),
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.phone,
                                          color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .pleaseEnterYourPhoneNumber;
                                        }

                                        // Remove all non-digit characters for validation
                                        final cleanedNumber = value.replaceAll(RegExp(r'[^\d]'), '');

                                        if (cleanedNumber.length < 10) {
                                          return AppLocalizations.of(context)!.pleaseEnterValidPhoneNumber;
                                        }

                                        if (cleanedNumber.length > 15) {
                                          return AppLocalizations.of(context)!.phoneNumberTooLong;
                                        }

                                        // Basic phone number pattern validation
                                        if (!RegExp(r'^[0-9]+$').hasMatch(cleanedNumber)) {
                                          return AppLocalizations.of(context)!.pleaseEnterOnlyNumbers;
                                        }

                                        return null;
                                      },
                                      onSaved: (value) {
                                        _enteredPhoneNumber = value!;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              ],
                            ),
                          if (!_isLogin) const SizedBox(height: 16),
                          if (!_isLogin)
                            DropdownButtonFormField<String>(
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              ),
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.sex,
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  floatingLabelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              items: [
                                DropdownMenuItem(
                                    value: 'Male',
                                    child: Text(
                                        AppLocalizations.of(context)!.male)),
                                DropdownMenuItem(
                                    value: 'Female',
                                    child: Text(
                                        AppLocalizations.of(context)!.female)),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return AppLocalizations.of(context)!
                                      .pleaseSelectYourSex;
                                }
                                return null;
                              },
                            ),
                          if (!_isLogin) const SizedBox(height: 16),
                          if (!_isLogin)
                            TextFormField(
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              ),
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.birthday,
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  floatingLabelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  ),
                                ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              controller: TextEditingController(
                                text: _selectedBirthday == null
                                    ? ''
                                    : '${_selectedBirthday!.toLocal()}'
                                        .split(' ')[0],
                              ),
                              validator: (value) {
                                if (_selectedBirthday == null) {
                                  return AppLocalizations.of(context)!
                                      .pleaseSelectYourBirthday;
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 12),
                          BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state is AuthError) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(child: Text(state.message)),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else if (state is AuthPasswordResetSent) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(child: Text(AppLocalizations.of(context)!.passwordResetEmailSent)),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;

                              if (isLoading) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 20),
                                  child: const Column(
                                    children: [
                                      CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Please wait...',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  MouseRegion(
                                    onEnter: (_) =>
                                        setState(() => _isHoveringLogin = true),
                                    onExit: (_) =>
                                        setState(() => _isHoveringLogin = false),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      transform: Matrix4.translationValues(0, _isHoveringLogin ? -3 : 0, 0),
                                      child: AnimatedScale(
                                        scale: _isHoveringLogin ? 1.02 : 1.0,
                                        duration: const Duration(milliseconds: 300),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: _isHoveringLogin
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: isLoading ? null : _submit,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(double.infinity, 48),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              _isLogin
                                                  ? AppLocalizations.of(context)!.login
                                                  : AppLocalizations.of(context)!.signup,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isLogin) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            AppLocalizations.of(context)!.or,
                                            style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.grey.shade300
                                                : Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Google Sign-In Button
                                    MouseRegion(
                                      onEnter: (_) =>
                                          setState(() => _isHoveringGoogleSignIn = true),
                                      onExit: (_) =>
                                          setState(() => _isHoveringGoogleSignIn = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        transform: Matrix4.translationValues(0, _isHoveringGoogleSignIn ? -2 : 0, 0),
                                        child: OutlinedButton.icon(
                                          onPressed: isLoading ? null : _signInWithGoogle,
                                          icon: SvgPicture.asset(
                                            'assets/images/google_icon.svg',
                                            height: 24,
                                            width: 24,
                                            colorFilter: null, // Keep original colors
                                          ),
                                          label: Text(
                                            AppLocalizations.of(context)!.signInWithGoogle,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(color: Colors.black),
                                            minimumSize: const Size(double.infinity, 48),
                                            elevation: _isHoveringGoogleSignIn ? 3 : 1,
                                            animationDuration: const Duration(milliseconds: 200),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Apple Sign-In Button
                                    MouseRegion(
                                      onEnter: (_) =>
                                          setState(() => _isHoveringAppleSignIn = true),
                                      onExit: (_) =>
                                          setState(() => _isHoveringAppleSignIn = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        transform: Matrix4.translationValues(0, _isHoveringAppleSignIn ? -2 : 0, 0),
                                        child: OutlinedButton.icon(
                                          onPressed: isLoading ? null : (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
                                              ? _signInWithApple
                                              : () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Center(child: Text('Apple Sign-In is only available on iOS and macOS')),
                                                    ),
                                                  );
                                                },
                                          icon: const Icon(Icons.apple, size: 24, color: Colors.white),
                                          label: Text(
                                            AppLocalizations.of(context)!.signInWithApple,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(color: Colors.black),
                                            minimumSize: const Size(double.infinity, 48),
                                            elevation: _isHoveringAppleSignIn ? 3 : 1,
                                            animationDuration: const Duration(milliseconds: 200),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  const SizedBox(height: 16),
                                  if (_isLogin)
                                    MouseRegion(
                                      onEnter: (_) => setState(
                                          () => _isHoveringCreateAccount = true),
                                      onExit: (_) => setState(
                                          () => _isHoveringCreateAccount = false),
                                      child: TextButton(
                                        onPressed: isLoading ? null : () {
                                          setState(() {
                                            _isLogin = false;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: _isHoveringCreateAccount
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                            decoration: _isHoveringCreateAccount
                                                ? TextDecoration.underline
                                                : TextDecoration.none,
                                          ),
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .createAnAccount),
                                        ),
                                      ),
                                    ),
                                  if (_isLogin)
                                    MouseRegion(
                                      onEnter: (_) => setState(
                                          () => _isHoveringForgotPassword = true),
                                      onExit: (_) => setState(
                                          () => _isHoveringForgotPassword = false),
                                      child: TextButton(
                                        onPressed: isLoading ? null : _resetPassword,
                                        style: TextButton.styleFrom(
                                          foregroundColor: _isHoveringForgotPassword
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                            decoration: _isHoveringForgotPassword
                                                ? TextDecoration.underline
                                                : TextDecoration.none,
                                          ),
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .forgotPassword),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
