import 'package:flutter/material.dart';
import 'package:TODO_APP_DEV/component/login_text_field.dart';
import 'package:TODO_APP_DEV/const/colors.dart';
import 'package:provider/provider.dart';
import 'package:TODO_APP_DEV/provider/schedule_provider.dart';
import 'package:dio/dio.dart';
import 'package:TODO_APP_DEV/screen/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Form을 제어할 때 사용되는 GlobalKey입니다. 이 값을 제어하고 싶은
  // Form의 key 매개변수에 입력해주면 됩니다.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form을 저장했을 때 이메일을 저장할 프로퍼티
  String email = '';

  // Form을 저장했을 때 비밀번호를 저장할 프로퍼티
  String password = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: formKey,
          child: Column(
            // 세로로 중앙 배치합니다.
            mainAxisAlignment: MainAxisAlignment.center,
            // 가로는 최대한의 크기로 늘려줍니다.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // 로고의 화면 너비의 절반만큼의 크기로 렌더링하고 가운데 정렬합니다.
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/img/logo.png',
              width: MediaQuery.of(context).size.width * 0.5,
              ),
            ),
            const SizedBox(height: 16.0),
            // 로그인 텍스트 필드
            LoginTextField(
              onSaved: (String? val) {
                email = val!;
              },
              validator: (String? val) {
                // 이메일이 입력되지 않았으면 에러 메시지를 반환합니다.
                if (val == null) {
                  return '이메일을 입력해주세요';
                }

                // 이메일 형식이 올바르지 않으면 에러 메시지를 반환합니다.
                if (!val.contains('@')) {
                  return '올바른 이메일 형식이 아닙니다.';
                }

                // 입력값에 문제가 없다면 null을 반환합니다.
                return null;
              },
              hintText: '이메일',
            ),
            const SizedBox(height: 8.0),
            // 비밀번호 텍스트 필드
            LoginTextField(
              onSaved: (String? val) {
                password = val!;
              },
              validator: (String? val) {
                // 비밀번호가 입력되지 않았으면 에러 메시지를 반환합니다.
                if (val == null) {
                  return '비밀번호를 입력해주세요';
                }

                // 비밀번호가 4자리 미만이면 에러 메시지를 반환합니다.
                if (val.length < 4) {
                  return '비밀번호는 4자리 이상이어야 합니다.';
                }

                // 입력값에 문제가 없다면 null을 반환합니다.
                return null;
              },
              hintText: '비밀번호',
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            // [회원가입] 버튼
            ElevatedButton(
              // 버튼 배경 색상 로고 색으로 변경
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: SECONDARY_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                )
              ),
              onPressed: () {
                onRegisterPress(provider);
              },
              child: Text('회원가입'),
            ),
            const SizedBox(height: 8.0),
            // [로그인] 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: SECONDARY_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                )
              ),
              onPressed: () async {
                onLoginPress(provider);
              },
              child: Text('로그인'),
            ),
            ],
          ),
        ),
      ),
    );
  }

  bool saveAndValidateForm() {
    // form을 검증하는 함수를 실행함니다.
    if (!formKey.currentState!.validate()) {
      return false;
    }
    // form을 저장하는 함수를 실행합니다.
    formKey.currentState!.save();

    return true;
  }

  onRegisterPress(ScheduleProvider provider) async {
    // 미리 만들어둔 함수로 form을 검증합니다.
    if (!saveAndValidateForm()) {
      return;
    }

    // 에러가 있을 경우 값을 이 변수에 저장합니다.
    String? message;

    try {
      // 회원가입 로직을 실행합니다.
      await provider.register(email: email, password: password);
    } on DioException catch (e) {
      // 에러가 있을 경우 message 변수에 저장합니다. 만약 에러 메시지가 없다면 기본값을 입력합니다.
      message = e.response?.data['message'] as String? ?? '알 수 없는 오류가 발생했습니다.';
    } catch (e) {
      message = '알 수 없는 오류가 발생했습니다.';
    } finally {
      // 에러 메세지가 null이 아닐 경우 스낵바에 값을 담아서 사용자에게 보여줍니다.
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      } else {
        // 에러가 없을 경우 홈 스크린으로 이동합니다.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      }
    }
  }

  onLoginPress(ScheduleProvider provider) async {
    if (!saveAndValidateForm()) {
      return;
    }

    String? message;

    try {
      // register() 함수 대신에 logiin() 함수를 실행합니다.
      await provider.login(email: email, password: password);
    } on DioException catch (e) {
      message = e.response?.data['message'] as String? ?? '알 수 없는 오류가 발생했습니다.';
    } catch (e) {
      message = '알 수 없는 오류가 발생했습니다.';
    } finally {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
      );
      }
    }
  }
}
