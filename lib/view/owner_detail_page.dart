import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class OwnerDetailPage extends StatefulWidget {
  const OwnerDetailPage({super.key});

  @override
  State<OwnerDetailPage> createState() => _OwnerDetailPageState();
}

class _OwnerDetailPageState extends State<OwnerDetailPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: '김하늘');
  final emailController = TextEditingController(text: 'owner@harvestslot.kr');
  final passwordController = TextEditingController(text: 'owner1234');
  final passwordConfirmController = TextEditingController(text: 'owner1234');
  final phoneController = TextEditingController(text: '1022223344');
  final businessController = TextEditingController(text: '3124567890');
  String orderNotice = '즉시 알림';
  String returnNotice = '즉시 알림';
  String shipmentNotice = '즉시 알림';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    phoneController.dispose();
    businessController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    showConfirmAction(
      context: context,
      title: '내 정보 저장',
      message: '입력한 내 정보로 갱신할까요?',
      confirmLabel: '확인',
      onConfirm: () => showOwnerSnack(context, '내 정보가 저장되었습니다.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '내 정보 수정',
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
              label: '이메일',
              value: '',
              controller: emailController,
              hintText: '이메일',
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
            ),
            LabeledField(
              label: '비밀번호',
              value: '',
              controller: passwordController,
              hintText: '비밀번호',
              helperText: '영문과 숫자를 포함해 8~20자',
              obscureText: true,
              validator: passwordValidator,
            ),
            LabeledField(
              label: '비밀번호 확인',
              value: '',
              controller: passwordConfirmController,
              hintText: '비밀번호 확인',
              obscureText: true,
              validator: (value) {
                final required = requiredValidator('비밀번호 확인', value);
                if (required != null) return required;
                return value == passwordController.text
                    ? null
                    : '비밀번호가 일치하지 않습니다.';
              },
            ),
            LabeledField(
              label: '전화번호',
              value: '',
              controller: phoneController,
              hintText: '전화번호',
              keyboardType: TextInputType.number,
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: phoneValidator,
            ),
            LabeledField(
              label: '사업자번호',
              value: '',
              controller: businessController,
              hintText: '사업자번호',
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: businessValidator,
            ),
            NoticeRadioGroup(
              title: '발주 알림',
              value: orderNotice,
              onChanged: (v) => setState(() => orderNotice = v),
            ),
            NoticeRadioGroup(
              title: '반품 알림',
              value: returnNotice,
              onChanged: (v) => setState(() => returnNotice = v),
            ),
            NoticeRadioGroup(
              title: '배송 알림',
              value: shipmentNotice,
              onChanged: (v) => setState(() => shipmentNotice = v),
            ),
            DualActionBar(
              left: '취소',
              right: '저장',
              onLeftPressed: () => Navigator.of(context).pop(),
              onRightPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeRadioGroup extends StatelessWidget {
  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  const NoticeRadioGroup({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = ['즉시 알림', '하루 1회 요약', '알림 끄기'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        RadioGroup<String>(
          groupValue: value,
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
          child: Column(
            children: [
              for (final option in options)
                RadioListTile<String>(
                  value: option,
                  title: Text(option),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
