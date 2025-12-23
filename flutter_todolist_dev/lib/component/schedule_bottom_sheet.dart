import 'package:flutter/material.dart';
import 'package:TODO_APP_DEV/const/colors.dart';
import 'package:TODO_APP_DEV/component/custom_text_field.dart';
import 'package:TODO_APP_DEV/model/schedule_model.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:TODO_APP_DEV/provider/schedule_provider.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const ScheduleBottomSheet({
    required this.selectedDate,
    Key? key,
    }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;  // 시작 시간 저장 변수
  int? endTime;  // 종료 시간 저장 변수
  String? content;  // 일정 내용 저장 변수

  @override
  Widget build(BuildContext context) {
    // 키보드 높이 가져오기
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Form(
      key: formKey,
      child: Container(
        // 키보드 높이 만큼 높이 조절
        height: MediaQuery.of(context).size.height / 2 + bottomInset,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: bottomInset),
          child: Column(
            // 시간 관련 텍스트 필드와 내용 관련 텍스트 필드 세로로 배치
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: '시작 시간',
                      isTime: true,
                      onSaved: (String? val) {
                        // 저장이 실행되면 startTime 변수에 텍스트 필드값 저장
                        startTime = int.parse(val!);
                      },
                      validator: timeValidator,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: CustomTextField(
                      label: '종료 시간',
                      isTime: true,
                      onSaved: (String? val) {
                        // 저장이 실행되면 endTime 변수에 텍스트 필드값 저장
                        endTime = int.parse(val!);
                      },
                      validator: timeValidator,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Expanded(
                child: CustomTextField(
                  label: '내용',
                  isTime: false,
                  onSaved: (String? val) {
                    // 저장이 실행되면 content 변수에 텍스트 필드값 저장
                    content = val;
                  },
                  validator: contentValidator,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // [저장] 버튼
                  onPressed: () => onSavePressed(context),  // 함수에 context 전달
                  style: ElevatedButton.styleFrom(
                    foregroundColor: PRIMARY_COLOR,
                  ),
                  child: Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onSavePressed(BuildContext context) async {
    // 저장 버튼 눌렀을 때 실행할 함수
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // 스케줄 모델 생성하기
      final schedule = ScheduleModel(
        id: Uuid().v4(),
        content: content!,
        date: widget.selectedDate,
        startTime: startTime!,
        endTime: endTime!,
      );

      // ScheduleProvider를 통해 일정 생성 (캐시 자동 업데이트)
      final provider = context.read<ScheduleProvider>();
      provider.createSchedule(schedule: schedule, accessToken: provider.accessToken!);

      Navigator.of(context).pop();  // 일정 생성 후 화면 뒤로 가기
    }
  }
  String? timeValidator(String? val) {
    // 시간값 검증
    if (val == null) {
      return '값을 입력해주세요';
    }
    
    int? number;

    try {
      number = int.parse(val);
    }catch (e) {
      return '숫자를 입력해주세요';
    }

    if (number < 0 || number > 24) {
      return '0시부터 24시 사이를 입력해주세요';
    }

    return null;
  }
  String? contentValidator(String? val) {
    if (val == null || val.length == 0) {
      return '값을 입력해주세요';
    }

    return null;
  }
}