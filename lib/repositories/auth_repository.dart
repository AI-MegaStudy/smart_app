import 'package:smart_app/core/api_service.dart';

class AuthRepository {
  Future<void> sendSignupVerification(String email) async {
    await ApiService.post(
      '/auth/email/send',
      body: {
        'email': email,
        'purpose': 'SIGNUP',
      },
    );
  }

  Future<void> verifySignupEmail({
    required String email,
    required String code,
  }) async {
    final data = await ApiService.post(
      '/auth/email/verify',
      body: {
        'email': email,
        'code': code,
        'purpose': 'SIGNUP',
      },
    );

    if (data['verified'] != true) {
      throw ApiException('이메일 인증이 완료되지 않았습니다.');
    }
  }

  Future<void> signupOwner({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    await ApiService.post(
      '/auth/owners/signup',
      body: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final token = data['access_token'];
    if (token is! String || token.isEmpty) {
      throw ApiException('로그인 응답에 access_token이 없습니다.');
    }

    ApiService.setAccessToken(token);

    final me = await ApiService.get('/me');
    final role = me['role'];
    if (role != 'OWNER') {
      ApiService.clearAccessToken();
      throw ApiException('점주 계정으로 로그인해야 합니다.');
    }
  }

  void logout() {
    ApiService.clearAccessToken();
  }
}
