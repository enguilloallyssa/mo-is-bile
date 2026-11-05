import 'package:flutter/material.dart';

import '../services/registration_api.dart';
import 'rider_register_screen.dart';

class LogisticsProvider {
  final int id;
  final String name;
  final String location;
  final String coverage;
  final int approvedRiders;

  const LogisticsProvider({
    required this.id,
    required this.name,
    required this.location,
    required this.coverage,
    required this.approvedRiders,
  });

  factory LogisticsProvider.fromMap(
    Map<String, Object> data,
  ) {
    return LogisticsProvider(
      id: _toInt(
        data['id'],
      ),
      name: _text(
        data['name'],
        'Logistics Provider',
      ),
      location: _text(
        data['location'],
        'SARI Logistics Network',
      ),
      coverage: _text(
        data['coverage'],
        'Service area unavailable',
      ),
      approvedRiders: _toInt(
        data['approvedRiders'],
      ),
    );
  }

  static int _toInt(
    Object? value,
  ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          '$value',
        ) ??
        0;
  }

  static String _text(
    Object? value,
    String fallback,
  ) {
    final String result =
        value?.toString().trim() ?? '';

    return result.isEmpty
        ? fallback
        : result;
  }
}

class RiderLogisticsScreen
    extends StatefulWidget {
  const RiderLogisticsScreen({
    super.key,
  });

  @override
  State<RiderLogisticsScreen>
      createState() =>
          _RiderLogisticsScreenState();
}

class _RiderLogisticsScreenState
    extends State<RiderLogisticsScreen> {
  static const Color _background =
      Color(0xFF0B0B0D);

  static const Color _surface =
      Color(0xFF18181C);

  static const Color _surfaceLight =
      Color(0xFF222226);

  static const Color _border =
      Color(0xFF37373D);

  static const Color _gold =
      Color(0xFFD4A62A);

  static const Color _goldSoft =
      Color(0xFF3C321A);

  static const Color _muted =
      Color(0xFFA7A7AF);

  final TextEditingController
      _searchController =
      TextEditingController();

  List<LogisticsProvider> _providers =
      <LogisticsProvider>[];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _loadProviders();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  List<LogisticsProvider>
      get _filtered {
    final String query =
        _searchController.text
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return _providers;
    }

    return _providers.where(
      (LogisticsProvider provider) {
        return provider.name
                .toLowerCase()
                .contains(query) ||
            provider.location
                .toLowerCase()
                .contains(query) ||
            provider.coverage
                .toLowerCase()
                .contains(query);
      },
    ).toList();
  }

  Future<void> _loadProviders()
      async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<Map<String, Object>>
          response =
          await RegistrationApi
              .instance
              .loadRiderLogistics();

      final List<LogisticsProvider>
          providers = response
              .map(
                LogisticsProvider
                    .fromMap,
              )
              .where(
                (
                  LogisticsProvider
                      provider,
                ) =>
                    provider.id > 0,
              )
              .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _providers = providers;
        _loading = false;
      });
    } on RegistrationApiException
        catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            'Unable to load Logistics providers. $error';
        _loading = false;
      });
    }
  }

  void _selectProvider(
    LogisticsProvider provider,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (
          BuildContext context,
        ) {
          return RiderRegisterScreen(
            provider: provider,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LogisticsProvider>
        providers = _filtered;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor:
            Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Choose Logistics',
          style: TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: _gold,
          backgroundColor: _surface,
          onRefresh: _loadProviders,
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              30,
            ),
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                  gradient:
                      const LinearGradient(
                    colors: <Color>[
                      Color(0xFF25262B),
                      Color(0xFF18181C),
                      Color(0xFF312A19),
                    ],
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white
                        .withOpacity(.06),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: <Widget>[
                          const Text(
                            'SARI RIDER NETWORK',
                            style:
                                TextStyle(
                              color: _gold,
                              fontSize: 9,
                              letterSpacing:
                                  1.4,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          const Text(
                            'Choose your\nLogistics team',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 25,
                              height: 1.08,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),

                          const SizedBox(
                            height: 9,
                          ),

                          Text(
                            'Your Rider application will be reviewed by the Logistics provider you select.',
                            style:
                                TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                .65,
                              ),
                              fontSize: 10,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Container(
                      width: 68,
                      height: 68,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white
                                .withOpacity(
                          .09,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .hub_outlined,
                        color:
                            Colors.white,
                        size: 33,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              TextField(
                controller:
                    _searchController,
                onChanged: (_) {
                  setState(() {});
                },
                style:
                    const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                    InputDecoration(
                  hintText:
                      'Search Logistics provider...',
                  hintStyle:
                      const TextStyle(
                    color: Color(
                      0xFF74747B,
                    ),
                  ),
                  prefixIcon:
                      const Icon(
                    Icons
                        .search_rounded,
                    color: _muted,
                  ),
                  suffixIcon:
                      _searchController
                              .text
                              .isEmpty
                          ? null
                          : IconButton(
                              onPressed:
                                  () {
                                _searchController
                                    .clear();

                                setState(
                                    () {});
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                                color:
                                    _muted,
                              ),
                            ),
                  filled: true,
                  fillColor:
                      _surfaceLight,
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                    borderSide:
                        const BorderSide(
                      color: _border,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                    borderSide:
                        const BorderSide(
                      color: _gold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Available Providers',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),
                  Text(
                    '${providers.length}',
                    style:
                        const TextStyle(
                      color: _muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              if (_loading)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 60,
                  ),
                  child: Center(
                    child:
                        CircularProgressIndicator(
                      color: _gold,
                    ),
                  ),
                )
              else if (_error != null)
                _errorCard()
              else if (providers.isEmpty)
                _emptyCard()
              else
                ...providers.map(
                  (
                    LogisticsProvider
                        provider,
                  ) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 11,
                      ),
                      child:
                          _providerCard(
                        provider,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerCard(
    LogisticsProvider provider,
  ) {
    return Material(
      color: _surface,
      borderRadius:
          BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          _selectProvider(provider);
        },
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.all(16),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: _border,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color: _goldSoft,
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                ),
                child: const Icon(
                  Icons
                      .local_shipping_outlined,
                  color: _gold,
                  size: 25,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      provider.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons
                              .location_on_outlined,
                          color: _muted,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            provider.location,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color: _muted,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      provider.coverage,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color: _muted
                            .withOpacity(
                          .78,
                        ),
                        fontSize: 8,
                        height: 1.35,
                      ),
                    ),

                    if (provider
                            .approvedRiders >
                        0) ...<Widget>[
                      const SizedBox(
                        height: 7,
                      ),
                      Text(
                        '${provider.approvedRiders} approved Rider${provider.approvedRiders == 1 ? '' : 's'}',
                        style:
                            const TextStyle(
                          color: _gold,
                          fontSize: 8,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color: _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding:
          const EdgeInsets.all(22),
      decoration:
          BoxDecoration(
        color: _surface,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons
                .cloud_off_outlined,
            color: _muted,
            size: 38,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            _error ??
                'Unable to load providers.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: _muted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          OutlinedButton.icon(
            onPressed:
                _loadProviders,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label:
                const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding:
          const EdgeInsets.all(25),
      decoration:
          BoxDecoration(
        color: _surface,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: _border,
        ),
      ),
      child: const Column(
        children: <Widget>[
          Icon(
            Icons
                .search_off_rounded,
            color: _muted,
            size: 39,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'No Logistics provider found.',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}