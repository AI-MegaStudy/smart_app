import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final businessController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    businessController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '입력 형식을 확인하세요.');
      return;
    }
    showConfirmAction(
      context: context,
      title: '회원가입',
      message: '입력한 정보로 계정을 생성할까요?',
      confirmLabel: '가입',
      onConfirm: () {
        showOwnerSnack(context, '회원가입 요청이 완료되었습니다.');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '회원가입',
          subtitle: '점주 계정 생성',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          children: [
            LabeledField(
              label: '이름',
              value: '',
              controller: nameController,
              hintText: '예: 김하늘',
              validator: nameValidator,
            ),
            LabeledField(
              label: '이메일',
              value: '',
              controller: emailController,
              hintText: '예: owner@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
            ),
            LabeledField(
              label: '비밀번호',
              value: '',
              controller: passwordController,
              hintText: '영문과 숫자를 포함해 8자 이상 입력하세요.',
              validator: passwordValidator,
            ),
            LabeledField(
              label: '전화번호',
              value: '',
              controller: phoneController,
              hintText: '예: 010-0000-0000',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                const DashTextInputFormatter([3, 4, 4]),
              ],
              validator: phoneNumberValidator,
            ),
            LabeledField(
              label: '사업자번호',
              value: '',
              controller: businessController,
              hintText: '예: 000-00-00000',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                const DashTextInputFormatter([3, 2, 5]),
              ],
              validator: businessNumberValidator,
            ),
            PrimaryAction(label: '회원가입', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
