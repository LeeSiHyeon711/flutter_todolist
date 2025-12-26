import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/material.dart';
import 'package:TODO_APP_DEV/const/colors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:TODO_APP_DEV/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthLoginScreen extends StatelessWidget {
  const AuthLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // 로고 이미지
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Image.asset('assets/img/logo.png'),
              ),
            ),
            SizedBox(height: 16.0),

            // 구글 로그인 버튼
            ElevatedButton(
              onPressed: () => onGoogleLoginPress(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: SECONDARY_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
              ),
              child: Text('구글 로그인')
            ),
          ],
        ),
      )
    );
  }

  onGoogleLoginPress(BuildContext context) async {
    try {
      // 웹과 모바일/데스크톱 모두 google_sign_in 사용
      GoogleSignIn googleSignIn = GoogleSignIn(
        // 웹에서 idToken을 얻기 위해 profile scope 필요
        scopes: kIsWeb ? ['email', 'profile', 'openid'] : ['email', 'profile'],
        // 웹용 Google OAuth Client ID
        clientId: kIsWeb 
          ? '1047247760638-1sadm0ts6k9o0h0mmjupvga8b6bc6imr.apps.googleusercontent.com'
          : null,
      );

      // macOS에서는 이전 세션 정리 (웹에서는 실행 안 함)
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
        await googleSignIn.signOut();
      }

      // signIn 함수를 실행해서 로그인을 진행합니다.
      GoogleSignInAccount? account = await googleSignIn.signIn();

      // 사용자가 로그인을 취소한 경우
      if (account == null) {
        return;
      }

      // AccessToken과 idToken을 가져올 수 있는 GoogleSignInAuthentication 객체를 불러옵니다.
      GoogleSignInAuthentication? googleAuth;
      
      try {
        googleAuth = await account.authentication;
      } catch (e) {
        // 웹에서 People API 오류가 발생할 수 있음
        if (kIsWeb) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('로그인 실패: People API 오류'),
                  SizedBox(height: 4),
                  Text(
                    'People API가 활성화되어 있는지 확인하세요:\n'
                    'https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=1047247760638',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              duration: Duration(seconds: 10),
            ),
          );
          return;
        } else {
          rethrow;
        }
      }

      // idToken은 선택사항입니다 (웹에서는 없을 수 있음)
      String? idToken = googleAuth.idToken;

      // AuthCredential 객체를 상속받는 GoogleAuthProvider 객체를 생성합니다.
      // accessToken만으로도 Firebase Auth가 작동할 수 있습니다.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: idToken, // null일 수 있음
      );

      // signInWithCredential() 함수를 이용하면 파이어베이스 인증을 할 수 있습니다.
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // 사용자 확인
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception('로그인 후에도 사용자 정보가 없습니다');
      }

      // 인증이 끝나면 홈 스크린으로 이동합니다.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
      );
    } catch(error) {
      // 로그인 에러 상세 정보 수집
      String errorMessage = '로그인 실패';
      String errorDetails = '';
      
      if (error is FirebaseAuthException) {
        errorDetails = '\n코드: ${error.code}\n메시지: ${error.message ?? "없음"}';
        errorMessage = '로그인 실패: ${error.code}';
      } else if (error is FirebaseException) {
        errorDetails = '\n코드: ${error.code}\n메시지: ${error.message ?? "없음"}\n플러그인: ${error.plugin}';
        errorMessage = 'Firebase 오류: ${error.code}';
      } else {
        errorDetails = '\n$error';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage$errorDetails'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}