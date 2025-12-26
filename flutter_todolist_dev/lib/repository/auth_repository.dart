import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AuthRepository {
  // Dio 인스턴스 생성
  final _dio = Dio();
  // 서버 주소
  final _targetUrl = 'http://${_getHost()}:3000/auth';
  
  static String _getHost() {
    if (kIsWeb) {
      return 'localhost';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  // 회원가입 로직
  Future<({String refreshToken, String accessToken})> register({
    required String email,
    required String password,
  }) async {
    // 회원가입 URL에 이메일과 비밀번호를 POST 요청으로 보냅니다.
    final result = await _dio.post(
      '$_targetUrl/register/email',
      data: {
        'email': email,
        'password': password,
      },
    );

    // record 타입으로 토큰을 반환합니다.
    return (refreshToken: result.data['refreshToken'] as String, accessToken:
    result.data['accessToken'] as String);
  }

  // 로그인 로직
  Future<({String refreshToken, String accessToken})> login({
    required String email,
    required String password,
  }) async {
    // 이메일: 비밀번호 형태로 문자열 타입으로 구성합니다.
    final emailAndPassword = '$email:$password';
    // utf8 인코딩으로부터 base64로 변환할 수 있는 코덱을 생성합니다.
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    // emailAndPassword 변수를 base64로 인코딩합니다.
    final encoded = stringToBase64.encode(emailAndPassword);

    // 인코딩된 문자열을 헤더에 담아서 로그인 요청을 보냅니다.
    final result = await _dio.post(
      '$_targetUrl/login/email',
      options: Options(
        headers: {
          'authorization': 'Basic $encoded',
        },
      ),
    );

    // record 타입으로 토큰을 반환합니다.
    return (refreshToken: result.data['refreshToken'] as String, accessToken:
    result.data['accessToken'] as String);
  }

  // 리프레시 토큰 갱신 로직
  Future<String> rotateRefreshToken({
    required String refreshToken,
  }) async {
    // 리프레시 토큰을 헤더에 담아서 리프레시 토큰 재발급 URL에 요청을 보냅니다.
    final result = await _dio.post(
      '$_targetUrl/token/refresh',
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      ),
    );

    return result.data['refreshToken'] as String;
  }

  Future<String> rotateAccessToken({
    required String refreshToken,
  }) async {
    // 리프레시 토큰을 헤더에 담아서 엑세스 토큰 재발금 URL에 요청을 보냅니다.
    final result = await _dio.post(
      '$_targetUrl/token/access',
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      )
    );

    return result.data['accessToken'] as String;
  }
}