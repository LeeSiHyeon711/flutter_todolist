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
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );

    try {
      // signIn 함수를 실행해서 로그인을 진행합니다.
      GoogleSignInAccount? account = await googleSignIn.signIn();

      // 사용자가 로그인을 취소한 경우
      if (account == null) {
        return;
      }

      // AccessToken과 idToken을 가져올 수 있는 GoogleSignInAuthentication 객체를 불러옵니다.
      final GoogleSignInAuthentication? googleAuth = await account.authentication;

      // googleAuth가 null이거나 토큰이 없는 경우
      if (googleAuth == null || googleAuth.accessToken == null || googleAuth.idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: 인증 정보를 가져올 수 없습니다.')),
        );
        return;
      }

      // AuthCredential 객체를 상속받는 GoogleAuthProvider 객체를 생성합니다.
      // accessToken과 idToken만 제공하면 생성됩니다.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // signInWithCredential() 함수를 이용하면 파이어베이스 인증을 할 수 있습니다.
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 인증이 끝나면 홈 스크린으로 이동합니다.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
      );
    } catch(error) {
      // 로그인 에러가 나면 Snackbar를 보여줍니다.
      String errorMessage = '로그인 실패';
      print(error);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      
    }
  }
}