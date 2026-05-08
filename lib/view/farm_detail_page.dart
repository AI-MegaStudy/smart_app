import 'package:flutter/material.dart';
import 'package:kpostal_plus/kpostal_plus.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class FarmDetailPage extends StatefulWidget {
  const FarmDetailPage({super.key});

  @override
  State<FarmDetailPage> createState() => _FarmDetailPageState();
}

class _FarmDetailPageState extends State<FarmDetailPage> {
  final formKey = GlobalKey<FormState>();
  final farmNameController = TextEditingController();
  final addressController = TextEditingController();
  final introController = TextEditingController();
  final shippingPolicyController = TextEditingController();
  final returnPolicyController = TextEditingController();
  String region = '';

  static const regions = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기 수원시',
    '강원 춘천시',
    '충북 충주시',
    '충남 천안시',
    '전북 전주시',
    '전남 나주시',
    '경북 안동시',
    '경남 진주시',
    '제주 제주시',
  ];

  @override
  void dispose() {
    farmNameController.dispose();
    addressController.dispose();
    introController.dispose();
    shippingPolicyController.dispose();
    returnPolicyController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final selected = await Navigator.of(context).push<Kpostal>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => KpostalPlusView(
          title: '주소 검색',
          appBarColor: Theme.of(context).colorScheme.surface,
          titleColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
    if (!mounted || selected == null) return;

    setState(() {
      addressController.text = selected.address;
    });
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 항목을 입력한 뒤 저장하세요.');
      return;
    }
    showConfirmAction(
      context: context,
      title: '농장 정보 저장',
      message: '입력한 농장 정보로 갱신할까요?',
      confirmLabel: '저장',
      onConfirm: () => showOwnerSnack(context, '농장 정보가 저장되었습니다.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '농장 정보 수정',
          subtitle: '고객에게 보이는 농장 기본 정보',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          children: [
            HeroPanel(
              eyebrow: region.isEmpty ? '지역' : region,
              title: farmNameController.text.isEmpty
                  ? '농장명'
                  : farmNameController.text,
              icon: Icons.local_florist,
              compact: true,
            ),
            const NoticeBox(
              color: AppColors.yellow,
              text: '농장 기본 정보는 고객 상품 상세와 예약 화면에 노출됩니다.',
            ),
            LabeledField(
              label: '농장명',
              value: '',
              controller: farmNameController,
              hintText: '농장명',
            ),
            LabeledDropdown(
              label: '지역',
              value: region,
              items: regions,
              hintText: '지역',
              onChanged: (value) {
                if (value != null) {
                  setState(() => region = value);
                }
              },
            ),
            LabeledField(
              label: '주소',
              value: '',
              controller: addressController,
              enabled: false,
              hintText: '주소',
            ),
            FilledButton.tonalIcon(
              onPressed: _searchAddress,
              icon: const Icon(Icons.search),
              label: const Text('주소 검색'),
            ),
            LabeledBox(
              label: '농장 소개',
              value: '',
              controller: introController,
              hintText: '농장 소개',
            ),
            LabeledBox(
              label: '배송 정책',
              value: '',
              controller: shippingPolicyController,
              hintText: '배송 정책',
            ),
            LabeledBox(
              label: '반품 정책',
              value: '',
              controller: returnPolicyController,
              hintText: '반품 정책',
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
