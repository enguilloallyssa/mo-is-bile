import 'package:flutter/material.dart';

class RegistrationPendingScreen
    extends StatelessWidget {
  final String role;
  final String email;
  final String reviewerName;

  final bool previewMode;

  const RegistrationPendingScreen({
    super.key,
    required this.role,
    required this.email,
    required this.reviewerName,
    this.previewMode = false,
  });

  static const Color _background =
      Color(0xFF0B0B0D);

  static const Color _surface =
      Color(0xFF18181C);

  static const Color _border =
      Color(0xFF37373D);

  static const Color _gold =
      Color(0xFFD4A62A);

  static const Color _green =
      Color(0xFF70C68C);

  static const Color _muted =
      Color(0xFFA7A7AF);

  bool get _isBuyer =>
      role.toLowerCase() ==
      'buyer';

  bool get _isRider =>
      role.toLowerCase() ==
      'rider';

  String get _title {
    if (_isBuyer) {
      return 'Buyer account ready';
    }

    if (_isRider) {
      return 'Application submitted';
    }

    return 'Registration submitted';
  }

  String get _message {
    if (_isBuyer) {
      return 'Your email has been verified and your SARI Buyer account is ready to use.';
    }

    if (_isRider) {
      return 'Your Rider application has been sent to $reviewerName for review.';
    }

    return 'Your registration has been submitted successfully.';
  }

  List<_Step> get _steps {
    if (_isBuyer) {
      return const <_Step>[
        _Step(
          icon:
              Icons.person_add_alt_1_outlined,
          title:
              'Registration submitted',
          complete: true,
        ),
        _Step(
          icon:
              Icons.mark_email_read_outlined,
          title:
              'Email verified',
          complete: true,
        ),
        _Step(
          icon:
              Icons.check_circle_outline_rounded,
          title:
              'Buyer account activated',
          complete: true,
        ),
      ];
    }

    if (_isRider) {
      return const <_Step>[
        _Step(
          icon:
              Icons.hub_outlined,
          title:
              'Logistics provider selected',
          complete: true,
        ),
        _Step(
          icon:
              Icons.description_outlined,
          title:
              'Application submitted',
          complete: true,
        ),
        _Step(
          icon:
              Icons.mark_email_read_outlined,
          title:
              'Email verified',
          complete: true,
        ),
        _Step(
          icon:
              Icons.fact_check_outlined,
          title:
              'Provider review',
          current: true,
        ),
        _Step(
          icon:
              Icons.check_circle_outline_rounded,
          title:
              'Rider approval',
        ),
      ];
    }

    return const <_Step>[
      _Step(
        icon:
            Icons.description_outlined,
        title:
            'Registration submitted',
        complete: true,
      ),
      _Step(
        icon:
            Icons.fact_check_outlined,
        title:
            'Account review',
        current: true,
      ),
    ];
  }

  void _login(
    BuildContext context,
  ) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      '/login',
      (
        Route<dynamic> route,
      ) =>
          false,
    );
  }

  void _welcome(
    BuildContext context,
  ) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      '/welcome',
      (
        Route<dynamic> route,
      ) =>
          false,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor:
            _background,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const DecoratedBox(
              decoration:
                  BoxDecoration(
                gradient:
                    RadialGradient(
                  center:
                      Alignment(
                    0,
                    -.7,
                  ),
                  radius: 1.15,
                  colors: <Color>[
                    Color(
                      0xFF302D26,
                    ),
                    Color(
                      0xFF151518,
                    ),
                    Color(
                      0xFF09090A,
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  17,
                  30,
                  17,
                  30,
                ),
                child: Center(
                  child:
                      ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 560,
                    ),
                    child: Container(
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        25,
                        20,
                        22,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            _surface,
                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),
                        border:
                            Border.all(
                          color:
                              _border,
                        ),
                        boxShadow:
                            const <BoxShadow>[
                          BoxShadow(
                            color:
                                Color(
                              0x55000000,
                            ),
                            blurRadius:
                                30,
                            offset:
                                Offset(
                              0,
                              14,
                            ),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .stretch,
                        children: <Widget>[
                          Center(
                            child: Container(
                              width: 76,
                              height: 76,
                              alignment:
                                  Alignment.center,
                              decoration:
                                  BoxDecoration(
                                color: _isBuyer
                                    ? const Color(
                                        0xFF1D3024,
                                      )
                                    : const Color(
                                        0xFF312A18,
                                      ),
                                borderRadius:
                                    BorderRadius.circular(
                                  23,
                                ),
                              ),
                              child: Icon(
                                _isBuyer
                                    ? Icons
                                        .verified_rounded
                                    : Icons
                                        .hourglass_top_rounded,
                                color: _isBuyer
                                    ? _green
                                    : _gold,
                                size: 39,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          Text(
                            _isBuyer
                                ? 'VERIFIED'
                                : 'APPLICATION STATUS',
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color: _isBuyer
                                  ? _green
                                  : _gold,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing:
                                  1.3,
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          Text(
                            _title,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing:
                                  -.5,
                            ),
                          ),

                          const SizedBox(
                            height: 9,
                          ),

                          Text(
                            _message,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color: _muted,
                              fontSize: 10.5,
                              height: 1.55,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          Container(
                            padding:
                                const EdgeInsets.all(
                              13,
                            ),
                            decoration:
                                BoxDecoration(
                              color: const Color(
                                0xFF222226,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                              border:
                                  Border.all(
                                color:
                                    _border,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 38,
                                  height: 38,
                                  alignment:
                                      Alignment.center,
                                  decoration:
                                      BoxDecoration(
                                    color: const Color(
                                      0xFF292820,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      11,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .mail_outline_rounded,
                                    color:
                                        _gold,
                                    size: 19,
                                  ),
                                ),

                                const SizedBox(
                                  width: 11,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _isBuyer
                                            ? 'Verified email'
                                            : 'Application email',
                                        style:
                                            const TextStyle(
                                          color:
                                              _muted,
                                          fontSize:
                                              8,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 3,
                                      ),

                                      Text(
                                        email,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              11,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          ...List<Widget>.generate(
                            _steps.length,
                            (
                              int index,
                            ) {
                              return _stepTile(
                                _steps[index],
                                index ==
                                    _steps.length -
                                        1,
                              );
                            },
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          Container(
                            padding:
                                const EdgeInsets.all(
                              13,
                            ),
                            decoration:
                                BoxDecoration(
                              color: _isBuyer
                                  ? const Color(
                                      0xFF1D2922,
                                    )
                                  : const Color(
                                      0xFF29261D,
                                    ),
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons
                                      .info_outline_rounded,
                                  color: _isBuyer
                                      ? _green
                                      : _gold,
                                  size: 18,
                                ),

                                const SizedBox(
                                  width: 9,
                                ),

                                Expanded(
                                  child: Text(
                                    _isBuyer
                                        ? 'You can now sign in using your Buyer email and password.'
                                        : 'Your Rider account will become available after the Logistics provider approves your application.',
                                    style:
                                        TextStyle(
                                      color: _isBuyer
                                          ? const Color(
                                              0xFFB8D8C1,
                                            )
                                          : const Color(
                                              0xFFE2D2A7,
                                            ),
                                      fontSize: 9.5,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          SizedBox(
                            height: 51,
                            child:
                                FilledButton.icon(
                              onPressed: () {
                                _login(
                                  context,
                                );
                              },
                              style:
                                  FilledButton.styleFrom(
                                backgroundColor:
                                    _gold,
                                foregroundColor:
                                    Colors.black,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    15,
                                  ),
                                ),
                              ),
                              icon:
                                  const Icon(
                                Icons
                                    .login_rounded,
                              ),
                              label: Text(
                                _isBuyer
                                    ? 'Sign In to Buyer'
                                    : 'Go to Login',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          TextButton(
                            onPressed: () {
                              _welcome(
                                context,
                              );
                            },
                            child:
                                const Text(
                              'Back to Welcome',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepTile(
    _Step step,
    bool last,
  ) {
    final Color color =
        step.complete
            ? _green
            : step.current
                ? _gold
                : _muted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 40,
            child: Column(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color: step.complete
                        ? const Color(
                            0xFF1D3024,
                          )
                        : step.current
                            ? const Color(
                                0xFF312A18,
                              )
                            : const Color(
                                0xFF222226,
                              ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    step.complete
                        ? Icons
                            .check_rounded
                        : step.icon,
                    color: color,
                    size: 17,
                  ),
                ),

                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints:
                          const BoxConstraints(
                        minHeight: 22,
                      ),
                      color: step.complete
                          ? const Color(
                              0xFF355542,
                            )
                          : _border,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(
                top: 7,
                bottom:
                    last ? 0 : 22,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      step.title,
                      style:
                          TextStyle(
                        color: step.complete ||
                                step.current
                            ? Colors.white
                            : _muted,
                        fontSize: 11,
                        fontWeight:
                            step.current
                                ? FontWeight.w800
                                : FontWeight.w600,
                      ),
                    ),
                  ),

                  Text(
                    step.complete
                        ? 'DONE'
                        : step.current
                            ? 'CURRENT'
                            : 'PENDING',
                    style:
                        TextStyle(
                      color: color,
                      fontSize: 7,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final String title;
  final bool complete;
  final bool current;

  const _Step({
    required this.icon,
    required this.title,
    this.complete = false,
    this.current = false,
  });
}