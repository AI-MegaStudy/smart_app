import 'package:flutter/material.dart';
import 'package:smart_app/model/owner_profile_record.dart';
import 'package:smart_app/repositories/owner_profile_repository.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class OwnerDetailPage extends StatefulWidget {
  const OwnerDetailPage({super.key});

  @override
  State<OwnerDetailPage> createState() => _OwnerDetailPageState();
}

class _OwnerDetailPageState extends State<OwnerDetailPage> {
  final formKey = GlobalKey<FormState>();
  final repository = OwnerProfileRepository();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final businessController = TextEditingController();

  OwnerProfileRecord? profile;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final record = await repository.fetchProfile();
      if (!mounted) return;
      setState(() {
        profile = record;
        nameController.text = record.ownerName;
        emailController.text = record.email;
        phoneController.text = record.ownerPhone;
        businessController.text = record.businessNumber ?? '';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _save() async {
    final current = profile;
    if (current == null) {
      showOwnerSnack(context, '저장할 점주 정보가 없습니다.');
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => isSaving = true);
    try {
      final updated = current.copyWith(
        ownerName: nameController.text.trim(),
        ownerPhone: phoneController.text.trim(),
        businessNumber: businessController.text.trim().isEmpty
            ? null
            : businessController.text.trim(),
      );
      final saved = await repository.updateProfile(updated);
      if (!mounted) return;
      setState(() => profile = saved);
      showOwnerSnack(context, '점주 정보를 저장했습니다.');
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
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
          trailing: ActionChipIcon(
            icon: Icons.refresh,
            onPressed: isLoading ? null : _load,
          ),
          children: [
            if (isLoading) const LinearProgressIndicator(),
            if (errorMessage != null)
              NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
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
              readOnly: true,
              validator: emailValidator,
            ),
            LabeledField(
              label: '전화번호',
              value: '',
              controller: phoneController,
              hintText: '전화번호',
              keyboardType: TextInputType.number,
              maxLength: 11,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: phoneValidator,
            ),
            LabeledField(
              label: '사업자번호',
              value: '',
              controller: businessController,
              hintText: '사업자번호',
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: businessValidator,
            ),
            const NoticeBox(
              color: Color(0xffF4F7F1),
              text: '이메일과 비밀번호 변경은 현재 백엔드 API 범위에 없어 읽기 전용입니다.',
            ),
            DualActionBar(
              left: '취소',
              right: isSaving ? '저장 중' : '저장',
              onLeftPressed: isSaving ? null : () => Navigator.of(context).pop(),
              onRightPressed: isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
