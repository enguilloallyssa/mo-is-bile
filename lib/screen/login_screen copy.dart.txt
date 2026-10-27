import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override

  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  bool rememberMe = false;

  static const Color sariYellow = Color(0xFFD48F08);

  static const Color sariBackground = Color(0xFFF7F4EE);

  static const Color sariText = Color(0xFF1F1B16);

  static const Color sariMuted = Color(0xFF756D63);

  static const Color sariBorder = Color(0xFFE4DDD3);

  @override

  void dispose() {

    emailController.dispose();

    passwordController.dispose();

    super.dispose();

  }

  void _login() {

    if (!_formKey.currentState!.validate()) {

      return;

    }

    Navigator.pushReplacementNamed(

      context,

      '/dashboard',

    );

  }

  void _forgotPassword() {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(

          'Password reset is not connected yet.',

        ),

      ),

    );

  }

  void _googleLogin() {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(

          'Google sign-in is not connected yet.',

        ),

      ),

    );

  }

  void _createAccount() {
    Navigator.pushNamed(
      context,
      '/register',
    );
  }

  void _openRolePreview(String route) {
    Navigator.pushReplacementNamed(
      context,
      route,
    );
  }

  InputDecoration _fieldDecoration({

    required String hint,

    required IconData icon,

    Widget? suffixIcon,

  }) {

    return InputDecoration(

      hintText: hint,

      hintStyle: const TextStyle(

        fontSize: 11,

        color: Color(0xFFAAA196),

      ),

      prefixIcon: Icon(

        icon,

        size: 17,

        color: const Color(0xFF9B9287),

      ),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(

        horizontal: 10,

        vertical: 9,

      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(

          color: sariBorder,

          width: 1,

        ),

      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(

          color: sariYellow,

          width: 1,

        ),

      ),

      errorBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(

          color: Colors.redAccent,

          width: 1,

        ),

      ),

      focusedErrorBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(

          color: Colors.redAccent,

          width: 1,

        ),

      ),

    );

  }

  Widget _loginOptions() {

    return Row(

      children: [

        Expanded(

          child: GestureDetector(

            onTap: () {

              setState(() {

                rememberMe = !rememberMe;

              });

            },

            child: Row(

              mainAxisSize: MainAxisSize.min,

              children: [

                SizedBox(

                  width: 17,

                  height: 17,

                  child: Checkbox(

                    value: rememberMe,

                    onChanged: (value) {

                      setState(() {

                        rememberMe = value ?? false;

                      });

                    },

                    activeColor: sariYellow,

                    visualDensity: VisualDensity.compact,

                    materialTapTargetSize:

                        MaterialTapTargetSize.shrinkWrap,

                    side: const BorderSide(

                      color: Color(0xFFCFC6B9),

                      width: 1,

                    ),

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(3),

                    ),

                  ),

                ),

                const SizedBox(width: 5),

                const Flexible(

                  child: Text(

                    'Remember me',

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(

                      fontSize: 10,

                      color: sariMuted,

                    ),

                  ),

                ),

              ],

            ),

          ),

        ),

        const SizedBox(width: 8),

        TextButton(

          onPressed: _forgotPassword,

          style: TextButton.styleFrom(

            padding: EdgeInsets.zero,

            minimumSize: Size.zero,

            tapTargetSize: MaterialTapTargetSize.shrinkWrap,

          ),

          child: const Text(

            'Forgot password?',

            style: TextStyle(

              fontSize: 10,

              color: Color(0xFFA96F06),

              fontWeight: FontWeight.w600,

            ),

          ),

        ),

      ],

    );

  }

  Widget _developerRoleAccess() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE8D7B5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.build_circle_outlined,
                size: 14,
                color: Color(0xFFB97805),
              ),
              SizedBox(width: 5),
              Text(
                'TEMPORARY ROLE ACCESS',
                style: TextStyle(
                  color: Color(0xFF9A6815),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'For UI testing only. Choose a user type without email or password.',
            style: TextStyle(
              color: Color(0xFF81786C),
              fontSize: 7.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _rolePreviewButton(
                  label: 'Buyer',
                  icon: Icons.shopping_bag_outlined,
                  route: '/buyer',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _rolePreviewButton(
                  label: 'Rider',
                  icon: Icons.delivery_dining_outlined,
                  route: '/rider',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _rolePreviewButton(
                  label: 'Logistics',
                  icon: Icons.warehouse_outlined,
                  route: '/logistics',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rolePreviewButton({
    required String label,
    required IconData icon,
    required String route,
  }) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: () => _openRolePreview(route),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          foregroundColor: const Color(0xFF7E5714),
          side: const BorderSide(
            color: Color(0xFFDDBB77),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialDivider() {

    return Row(

      children: [

        const Expanded(

          child: Divider(

            height: 1,

            color: Color(0xFFEEE8DF),

          ),

        ),

        const Padding(

          padding: EdgeInsets.symmetric(horizontal: 6),

          child: Text(

            'OR CONTINUE WITH',

            style: TextStyle(

              fontSize: 6,

              color: Color(0xFF9B9287),

              letterSpacing: 0.9,

              fontWeight: FontWeight.w500,

            ),

          ),

        ),

        const Expanded(

          child: Divider(

            height: 1,

            color: Color(0xFFEEE8DF),

          ),

        ),

      ],

    );

  }

  Widget _footer() {

    return Wrap(

      alignment: WrapAlignment.center,

      spacing: 8,

      runSpacing: 3,

      children: [

        Text(

          '© ${DateTime.now().year} SARI. All rights reserved.',

          textAlign: TextAlign.center,

          style: const TextStyle(

            fontSize: 7.5,

            color: Color(0xFF756B5B),

          ),

        ),

        const Text(

          'Privacy Policy',

          style: TextStyle(

            fontSize: 7.5,

            color: Color(0xFF756B5B),

          ),

        ),

        const Text(

          'Terms of Service',

          style: TextStyle(

            fontSize: 7.5,

            color: Color(0xFF756B5B),

          ),

        ),

      ],

    );

  }

  @override

  Widget build(BuildContext context) {

    return MediaQuery(

      data: MediaQuery.of(context).copyWith(

        textScaler: const TextScaler.linear(0.85),

      ),

      child: Scaffold(

        backgroundColor: sariBackground,

        resizeToAvoidBottomInset: true,

        body: Stack(

          children: [

            // BACKGROUND IMAGE

            Positioned.fill(

              child: Image.asset(

                'assets/images/login-bg.jpg',

                fit: BoxFit.cover,

                alignment: Alignment.center,

                errorBuilder: (

                  context,

                  error,

                  stackTrace,

                ) {

                  return Container(

                    color: sariBackground,

                  );

                },

              ),

            ),

            // WHITE OVERLAY

            Positioned.fill(

              child: Container(

                color: Colors.white.withOpacity(0.70),

              ),

            ),

            // WARM OVERLAY

            Positioned.fill(

              child: Container(

                color: const Color(0xFFFFFAF1).withOpacity(0.12),

              ),

            ),

            SafeArea(

              child: LayoutBuilder(

                builder: (context, constraints) {

                  final width = constraints.maxWidth;

                  final height = constraints.maxHeight;

                  final horizontalPadding =

                      width <= 340 ? 11.0 : 15.0;

                  final cardPadding =

                      width <= 340 ? 13.0 : 16.0;

                  final logoSize =

                      width <= 340 ? 68.0 : 78.0;

                  return SingleChildScrollView(

                    physics:

                        const BouncingScrollPhysics(),

                    keyboardDismissBehavior:

                        ScrollViewKeyboardDismissBehavior.onDrag,

                    padding: EdgeInsets.fromLTRB(

                      horizontalPadding,

                      7,

                      horizontalPadding,

                      10,

                    ),

                    child: ConstrainedBox(

                      constraints: BoxConstraints(

                        minHeight: height - 17,

                      ),

                      child: Center(

                        child: ConstrainedBox(

                          constraints:

                              const BoxConstraints(

                            maxWidth: 400,

                          ),

                          child: Column(

                            mainAxisSize: MainAxisSize.min,

                            children: [

                              // LOGO

                              Image.asset(

                                'assets/images/sari-logo.png',

                                width: logoSize,

                                height: logoSize,

                                fit: BoxFit.contain,

                              ),

                              const SizedBox(height: 2),

                              const Text(

                                'ELEVATED EVERYDAY',

                                style: TextStyle(

                                  fontSize: 6,

                                  letterSpacing: 1.4,

                                  color:

                                      Color(0xFF9A9185),

                                  fontWeight:

                                      FontWeight.w600,

                                ),

                              ),

                              const SizedBox(height: 7),

                              // LOGIN CARD

                              Container(

                                width: double.infinity,

                                padding: EdgeInsets.fromLTRB(

                                  cardPadding,

                                  17,

                                  cardPadding,

                                  15,

                                ),

                                decoration: BoxDecoration(

                                  color: Colors.white,

                                  borderRadius:

                                      BorderRadius.circular(15),

                                  border: Border.all(

                                    color: const Color(

                                      0xFFE7E0D7,

                                    ),

                                  ),

                                  boxShadow: [

                                    BoxShadow(

                                      color: Colors.black

                                          .withOpacity(0.06),

                                      blurRadius: 16,

                                      offset:

                                          const Offset(0, 5),

                                    ),

                                  ],

                                ),

                                child: Form(

                                  key: _formKey,

                                  child: Column(

                                    crossAxisAlignment:

                                        CrossAxisAlignment.stretch,

                                    children: [

                                      const Text(

                                        'WELCOME BACK',

                                        textAlign:

                                            TextAlign.center,

                                        style: TextStyle(

                                          color: sariYellow,

                                          fontSize: 7,

                                          fontWeight:

                                              FontWeight.bold,

                                          letterSpacing: 1.1,

                                        ),

                                      ),

                                      const SizedBox(height: 3),

                                      const Text(

                                        'Sign in to SARI',

                                        textAlign:

                                            TextAlign.center,

                                        style: TextStyle(

                                          color: sariText,

                                          fontSize: 18,

                                          fontWeight:

                                              FontWeight.bold,

                                          letterSpacing: -0.2,

                                        ),

                                      ),

                                      const SizedBox(height: 4),

                                      const Text(

                                        'Access your account to continue shopping, '

                                        'selling, or managing deliveries.',

                                        textAlign:

                                            TextAlign.center,

                                        style: TextStyle(

                                          color: Color(

                                            0xFF81786C,

                                          ),

                                          fontSize: 8.5,

                                          height: 1.3,

                                        ),

                                      ),

                                      const SizedBox(height: 13),

                                      // EMAIL

                                      const Text(

                                        'Email Address',

                                        style: TextStyle(

                                          color: Color(

                                            0xFF383126,

                                          ),

                                          fontSize: 9.5,

                                          fontWeight:

                                              FontWeight.w600,

                                        ),

                                      ),

                                      const SizedBox(height: 3),

                                      SizedBox(

                                        height: 42,

                                        child:

                                            TextFormField(

                                          controller:

                                              emailController,

                                          keyboardType:

                                              TextInputType

                                                  .emailAddress,

                                          textInputAction:

                                              TextInputAction.next,

                                          style:

                                              const TextStyle(

                                            fontSize: 11,

                                            color: sariText,

                                          ),

                                          decoration:

                                              _fieldDecoration(

                                            hint:

                                                'Enter your email',

                                            icon:

                                                Icons.email_outlined,

                                          ),

                                          validator: (value) {

                                            final email =

                                                value?.trim() ??

                                                    '';

                                            if (email

                                                .isEmpty) {

                                              return 'Please enter your email.';

                                            }

                                            if (!email

                                                .contains('@')) {

                                              return 'Please enter a valid email.';

                                            }

                                            return null;

                                          },

                                        ),

                                      ),

                                      const SizedBox(height: 9),

                                      // PASSWORD

                                      const Text(

                                        'Password',

                                        style: TextStyle(

                                          color: Color(

                                            0xFF383126,

                                          ),

                                          fontSize: 9.5,

                                          fontWeight:

                                              FontWeight.w600,

                                        ),

                                      ),

                                      const SizedBox(height: 3),

                                      SizedBox(

                                        height: 42,

                                        child:

                                            TextFormField(

                                          controller:

                                              passwordController,

                                          obscureText:

                                              obscurePassword,

                                          textInputAction:

                                              TextInputAction.done,

                                          onFieldSubmitted:

                                              (_) => _login(),

                                          style:

                                              const TextStyle(

                                            fontSize: 11,

                                            color: sariText,

                                          ),

                                          decoration:

                                              _fieldDecoration(

                                            hint:

                                                'Enter your password',

                                            icon:

                                                Icons.lock_outline,

                                            suffixIcon:

                                                IconButton(

                                              padding:

                                                  EdgeInsets.zero,

                                              onPressed: () {

                                                setState(() {

                                                  obscurePassword =

                                                      !obscurePassword;

                                                });

                                              },

                                              icon: Icon(

                                                obscurePassword

                                                    ? Icons

                                                        .visibility_outlined

                                                    : Icons

                                                        .visibility_off_outlined,

                                                size: 16,

                                                color:

                                                    const Color(

                                                  0xFFA59B8B,

                                                ),

                                              ),

                                            ),

                                          ),

                                          validator: (value) {

                                            if ((value ?? '')

                                                .isEmpty) {

                                              return 'Please enter your password.';

                                            }

                                            return null;

                                          },

                                        ),

                                      ),

                                      const SizedBox(height: 6),

                                      // REMEMBER + FORGOT

                                      _loginOptions(),

                                      const SizedBox(height: 7),

                                      // SIGN IN

                                      SizedBox(

                                        height: 40,

                                        width: double.infinity,

                                        child:

                                            ElevatedButton(

                                          onPressed: _login,

                                          style:

                                              ElevatedButton

                                                  .styleFrom(

                                            backgroundColor:

                                                sariYellow,

                                            foregroundColor:

                                                Colors.white,

                                            elevation: 1,

                                            padding:

                                                EdgeInsets.zero,

                                            shape:

                                                RoundedRectangleBorder(

                                              borderRadius:

                                                  BorderRadius

                                                      .circular(

                                                9,

                                              ),

                                            ),

                                          ),

                                          child: const Row(

                                            mainAxisAlignment:

                                                MainAxisAlignment

                                                    .center,

                                            mainAxisSize:

                                                MainAxisSize.min,

                                            children: [

                                              Text(

                                                'Sign In',

                                                style:

                                                    TextStyle(

                                                  fontSize:

                                                      10,

                                                  fontWeight:

                                                      FontWeight

                                                          .w600,

                                                ),

                                              ),

                                              SizedBox(width: 5),

                                              Icon(

                                                Icons

                                                    .arrow_forward,

                                                size: 13,

                                              ),

                                            ],

                                          ),

                                        ),

                                      ),

                                      const SizedBox(height: 10),

                                      _developerRoleAccess(),

                                      const SizedBox(height: 12),

                                      // DIVIDER

                                      _socialDivider(),

                                      const SizedBox(height: 10),

                                      // GOOGLE

                                      SizedBox(

                                        height: 38,

                                        width: double.infinity,

                                        child:

                                            OutlinedButton(

                                          onPressed:

                                              _googleLogin,

                                          style:

                                              OutlinedButton

                                                  .styleFrom(

                                            padding:

                                                EdgeInsets.zero,

                                            side:

                                                const BorderSide(

                                              color:

                                                  sariBorder,

                                            ),

                                            shape:

                                                RoundedRectangleBorder(

                                              borderRadius:

                                                  BorderRadius

                                                      .circular(

                                                8,

                                              ),

                                            ),

                                          ),

                                          child:

                                              const FittedBox(

                                            fit: BoxFit.scaleDown,

                                            child: Row(

                                              mainAxisSize:

                                                  MainAxisSize

                                                      .min,

                                              children: [

                                                Text(

                                                  'G',

                                                  style:

                                                      TextStyle(

                                                    fontSize:

                                                        15,

                                                    fontWeight:

                                                        FontWeight

                                                            .bold,

                                                    color: Color(

                                                      0xFF4285F4,

                                                    ),

                                                  ),

                                                ),

                                                SizedBox(

                                                    width: 6),

                                                Text(

                                                  'Continue with Google',

                                                  style:

                                                      TextStyle(

                                                    fontSize:

                                                        9.5,

                                                    fontWeight:

                                                        FontWeight

                                                            .w600,

                                                  ),

                                                ),

                                              ],

                                            ),

                                          ),

                                        ),

                                      ),

                                      const SizedBox(height: 10),

                                      // CREATE ACCOUNT

                                      Wrap(

                                        alignment:

                                            WrapAlignment.center,

                                        children: [

                                          const Text(

                                            "Don't have an account?",

                                            style:

                                                TextStyle(

                                              color: Color(

                                                0xFF6F6658,

                                              ),

                                              fontSize: 9.5,

                                            ),

                                          ),

                                          GestureDetector(

                                            onTap:

                                                _createAccount,

                                            child:

                                                const Padding(

                                              padding:

                                                  EdgeInsets.only(

                                                left: 3,

                                              ),

                                              child:

                                                  Text(

                                                'Create one',

                                                style:

                                                    TextStyle(

                                                  color: Color(

                                                    0xFFA96F06,

                                                  ),

                                                  fontSize:

                                                      9.5,

                                                  fontWeight:

                                                      FontWeight

                                                          .w600,

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

                              const SizedBox(height: 8),

                              // FOOTER

                              _footer(),

                            ],

                          ),

                        ),

                      ),

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

  }

}
