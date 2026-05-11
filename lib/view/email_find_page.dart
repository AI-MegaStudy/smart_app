import 'package:flutter/material.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class EmailFindPage extends StatefulWidget {
  const EmailFindPage({super.key});

  @override
  State<EmailFindPage> createState() => _EmailFindPageState();
}

class _EmailFindPageState extends State<EmailFindPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _find() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    showInfoAction(
      context: context,
      title: '이메일 찾기',
      message: '이메일 찾기 API가 아직 백엔드 최종 명세에 없습니다. 관리자 또는 고객센터 확인이 필요합니다.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '이메일 찾기',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          children: [
            LabeledField(
              label: '이름',
              value: '',
              controller: nameController,
              hintText: '이름',
              validator: nameValidator,
            ),
            LabeledField(
              label: '전화번호',
              value: '',
              controller: phoneController,
              hintText: '01012345678',
              keyboardType: TextInputType.number,
              maxLength: 11,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: phoneValidator,
            ),
            DualActionBar(
              left: '취소',
              right: '확인',
              onLeftPressed: () => Navigator.of(context).pop(),
              onRightPressed: _find,
            ),
          ],
        ),
      ),
    );
  }
}
