import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kpostal_plus/kpostal_plus.dart';
import 'package:smart_app/model/owner_profile_record.dart';
import 'package:smart_app/repositories/auth_repository.dart';
import 'package:smart_app/repositories/owner_profile_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final repository = AuthRepository();
  final profileRepository = OwnerProfileRepository();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final verificationCodeController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final phoneController = TextEditingController();
  final businessController = TextEditingController();
  final farmController = TextEditingController();
  final addressController = TextEditingController();
  final emailFocusNode = FocusNode();

  bool emailVerificationSent = false;
  bool emailVerified = false;
  bool isSendingCode = false;
  bool isVerifyingCode = false;
  bool isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    verificationCodeController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    phoneController.dispose();
    businessController.dispose();
    farmController.dispose();
    addressController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  String get email => emailController.text.trim();

  Future<void> _sendVerificationCode() async {
    if (emailValidator(emailController.text) != null) {
      formKey.currentState?.validate();
      emailFocusNode.requestFocus();
      return;
    }

    setState(() => isSendingCode = true);
    try {
      await repository.sendSignupVerification(email);
      if (!mounted) return;
      setState(() {
        emailVerificationSent = true;
        emailVerified = false;
        verificationCodeController.clear();
      });
      showOwnerSnack(context, '인증번호를 이메일로 보냈습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isSendingCode = false);
    }
  }

  Future<void> _verifyCode() async {
    if (emailValidator(emailController.text) != null) {
      formKey.currentState?.validate();
      emailFocusNode.requestFocus();
      return;
    }
    if (verificationCodeController.text.trim().isEmpty) {
      showOwnerSnack(context, '이메일로 받은 인증번호를 입력하세요.');
      return;
    }

    setState(() => isVerifyingCode = true);
    try {
      await repository.verifySignupEmail(
        email: email,
        code: verificationCodeController.text.trim(),
      );
      if (!mounted) return;
      setState(() => emailVerified = true);
      showOwnerSnack(context, '이메일 인증이 완료되었습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isVerifyingCode = false);
    }
  }

  Future<void> _searchAddress() async {
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      await showInfoAction(
        context: context,
        title: '주소 검색',
        message: '현재 주소 검색은 Android/iOS 환경에서만 사용할 수 있습니다.',
      );
      return;
    }

    final result = await Navigator.of(context).push<Kpostal>(
      MaterialPageRoute(
        builder: (_) => KpostalPlusView(
          title: '주소 검색',
          appBarColor: AppColors.green,
          titleColor: Colors.white,
        ),
      ),
    );
    if (result == null) return;
    final selected = result.userSelectedAddress.isNotEmpty
        ? result.userSelectedAddress
        : result.address;
    setState(() => addressController.text = selected);
  }

  Future<void> _submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!emailVerified) {
      showOwnerSnack(context, '이메일 인증을 먼저 완료하세요.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원가입'),
        content: const Text('입력한 정보로 점주 계정을 생성할까요?'),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('가입'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => isSubmitting = true);
    try {
      await repository.signupOwner(
        email: email,
        password: passwordController.text,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      final businessNumber = businessController.text.trim();
      var businessNumberSaved = businessNumber.isEmpty;
      if (businessNumber.isNotEmpty) {
        try {
          await repository.login(
            email: email,
            password: passwordController.text,
          );
          await profileRepository.updateProfile(
            OwnerProfileRecord(
              ownerId: 0,
              ownerName: nameController.text.trim(),
              ownerPhone: phoneController.text.trim(),
              businessNumber: businessNumber,
              email: email,
              accountStatus: '',
            ),
          );
          businessNumberSaved = true;
        } catch (_) {
          businessNumberSaved = false;
        } finally {
          repository.logout();
        }
      }
      if (!mounted) return;
      await showInfoAction(
        context: context,
        title: '회원가입 완료',
        message: businessNumberSaved
            ? '점주 계정이 생성되었습니다. 농장 정보는 로그인 후 농장 관리에서 이어서 등록하세요.'
            : '점주 계정은 생성되었습니다. 사업자번호와 농장 정보는 로그인 후 프로필과 농장 관리에서 이어서 등록하세요.',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = isSendingCode || isVerifyingCode || isSubmitting;

    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '회원가입',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: busy ? null : () => Navigator.of(context).pop(),
          ),
          children: [
            if (busy) const LinearProgressIndicator(),
            const SectionHeader(title: '계정 정보'),
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
              focusNode: emailFocusNode,
              hintText: 'owner@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
              onChanged: (_) {
                setState(() {
                  emailVerificationSent = false;
                  emailVerified = false;
                  verificationCodeController.clear();
                });
              },
            ),
            DualActionBar(
              left: emailVerificationSent ? '재발송' : '인증번호 발송',
              right: emailVerified ? '인증 완료' : '인증 확인',
              onLeftPressed: isSendingCode ? null : _sendVerificationCode,
              onRightPressed:
                  isVerifyingCode || !emailVerificationSent || emailVerified
                  ? null
                  : _verifyCode,
            ),
            LabeledField(
              label: '인증번호',
              value: '',
              controller: verificationCodeController,
              hintText: '6자리 인증번호',
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: (value) {
                if (emailVerified) return null;
                return requiredValidator('인증번호', value);
              },
            ),
            LabeledField(
              label: '비밀번호',
              value: '',
              controller: passwordController,
              hintText: '비밀번호',
              helperText: '영문과 숫자를 포함해 8~20자로 입력하세요.',
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
              hintText: '01012345678',
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
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return null;
                return businessValidator(value);
              },
            ),
            const SizedBox(height: 6),
            const SectionHeader(title: '농장 정보'),
            LabeledField(
              label: '농장명',
              value: '',
              controller: farmController,
              hintText: '농장명',
              validator: (_) => null,
            ),
            LabeledField(
              label: '주소',
              value: '',
              controller: addressController,
              hintText: '주소',
              readOnly: true,
              validator: (_) => null,
            ),
            FilledButton.tonalIcon(
              onPressed: busy ? null : _searchAddress,
              icon: const Icon(Icons.search),
              label: const Text('주소 검색'),
            ),
            NoticeBox(
              color: const Color(0xffF4F7F1),
              text: '현재 백엔드 회원가입 API는 계정 생성만 처리합니다. 사업자번호와 농장 정보는 가입 후 프로필/농장 관리에서 저장하세요.',
            ),
            DualActionBar(
              left: '취소',
              right: isSubmitting ? '가입 중' : '회원가입',
              onLeftPressed: busy ? null : () => Navigator.of(context).pop(),
              onRightPressed: busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
