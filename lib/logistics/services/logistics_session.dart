import '../../services/sari_live_data.dart';

class LogisticsSession {
  const LogisticsSession({
    this.name = 'Logistics Team',
    this.email = '',
    this.role = 'Logistics',
    this.business = '',
    this.branch = '',
  });

  final String name;
  final String email;
  final String role;
  final String business;
  final String branch;

  static String _str(
    dynamic v,
  ) =>
      v == null
          ? ''
          : v.toString().trim();

  static Map<String, dynamic> _map(
    dynamic v,
  ) =>
      v is Map
          ? Map<String, dynamic>.from(
              v,
            )
          : const <String, dynamic>{};

  static LogisticsSession fromApi(
    Map<String, dynamic> response,
  ) {
    final data =
        _map(
      response['data'],
    );

    final user =
        _map(
      data['user'] is Map
          ? data['user']
          : data,
    );

    final account =
        _map(
      user['account'],
    );

    final logistics =
        _map(
      user['logistics'],
    );

    final first =
        _str(
      user['first_name'] ??
          account['first_name'],
    );

    final last =
        _str(
      user['last_name'] ??
          account['last_name'],
    );

    final full =
        _str(
      user['name'] ??
          user['full_name'],
    );

    final fallbackName =
        [
      first,
      last,
    ]
            .where(
              (
                s,
              ) =>
                  s.isNotEmpty,
            )
            .join(
              ' ',
            );

    return LogisticsSession(
      name:
          full.isNotEmpty
              ? full
              : fallbackName
                      .isNotEmpty
                  ? fallbackName
                  : 'Logistics Team',
      email:
          _str(
        user['email'] ??
            account['email'],
      ),
      role:
          _str(
        user['role'],
      ).isNotEmpty
              ? _str(
                  user['role'],
                )
              : 'Logistics',
      business:
          _str(
        logistics['business_name'] ??
            user['business_name'] ??
            account['business_name'],
      ),
      branch:
          _str(
        user['hub_name'] ??
            user[
                'operating_branch'] ??
            logistics[
                'hub_name'] ??
            account[
                'hub_name'],
      ),
    );
  }
}

class LogisticsSessionService {
  const LogisticsSessionService._();

  static Future<LogisticsSession>
      load() async {
    final me =
        await SariLiveData
            .instance
            .currentAccount();

    final base =
        LogisticsSession.fromApi(
      me,
    );

    try {
      final profile =
          await SariLiveData
              .instance
              .logisticsProfile();

      final raw =
          profile['data'];

      final data =
          raw is Map
              ? Map<String, dynamic>.from(
                  raw,
                )
              : <String, dynamic>{};

      return LogisticsSession(
        name:
            _pick(
          data['name'],
          base.name,
        ),
        email:
            _pick(
          data['email'],
          base.email,
        ),
        role:
            _pick(
          data['role'],
          base.role,
        ),
        business:
            _pick(
          data['business_name'],
          base.business,
        ),
        branch:
            base.branch,
      );
    } catch (_) {
      return base;
    }
  }

  static String _pick(
    dynamic value,
    String fallback,
  ) {
    final text =
        value?.toString().trim() ??
            '';

    return text.isEmpty
        ? fallback
        : text;
  }
}