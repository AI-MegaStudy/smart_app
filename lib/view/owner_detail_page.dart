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
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final businessController = TextEditingController();
  String orderNotice = '즉시 알림';
  String returnNotice = '즉시 알림';
  String shipmentNotice = '즉시 알림';

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    businessController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 항목을 입력한 뒤 저장하세요.');
      return;
    }
    showConfirmAction(
      context: context,
      title: '내 정보 저장',
      message: '입력한 내 정보로 갱신할까요?',
      confirmLabel: '저장',
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
          subtitle: '점주 기본 정보',
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
              regexHint: '한글/영문 2-20자',
              validator: nameValidator,
            ),
            LabeledField(
              label: '전화번호',
              value: '',
              controller: phoneController,
              hintText: '전화번호',
              regexHint: '010-0000-0000',
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
              hintText: '사업자번호',
              regexHint: '000-00-00000',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                const DashTextInputFormatter([3, 2, 5]),
              ],
              validator: businessNumberValidator,
            ),
            NoticeRadioGroup(
              title: '발주 알림',
              value: orderNotice,
              onChanged: (value) => setState(() => orderNotice = value),
            ),
            NoticeRadioGroup(
              title: '반품 알림',
              value: returnNotice,
              onChanged: (value) => setState(() => returnNotice = value),
            ),
            NoticeRadioGroup(
              title: '배송 알림',
              value: shipmentNotice,
              onChanged: (value) => setState(() => shipmentNotice = value),
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
        const SizedBox(height: 6),
        RadioGroup<String>(
          groupValue: value,
          onChanged: (next) {
            if (next != null) {
              onChanged(next);
            }
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
