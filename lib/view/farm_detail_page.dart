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
  final farmNameController = TextEditingController(text: '충주 햇살농원');
  final addressController = TextEditingController(text: '충북 충주시 산척면 과수원길 24');
  final introController = TextEditingController(
    text: '당도 선별 사과를 수확 일정에 맞춰 직배송합니다.',
  );
  final shippingPolicyController = TextEditingController(
    text: '수확 후 24시간 안에 포장하고 산지에서 바로 발송합니다.',
  );
  final returnPolicyController = TextEditingController(
    text: '배송 중 파손 또는 품질 이상 확인 시 사진 확인 후 환불을 처리합니다.',
  );
  String region = '충북 충주시';

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
              eyebrow: region,
              title: farmNameController.text,
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
              hintText: '예: 충주 햇살농원',
            ),
            LabeledDropdown(
              label: '지역',
              value: region,
              items: regions,
              hintText: '도시까지 선택하세요.',
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
              hintText: '검색 버튼을 눌러 주소를 선택하세요.',
            ),
            FilledButton.tonalIcon(
              onPressed: _searchAddress,
              icon: const Icon(Icons.search),
              label: const Text('주소 검색'),
            ),
            LabeledBox(
              label: '소개',
              value: '',
              controller: introController,
              hintText: '고객에게 보일 농장 소개를 입력하세요.',
            ),
            LabeledBox(
              label: '배송 정책',
              value: '',
              controller: shippingPolicyController,
              hintText: '발송 기준과 배송 소요 시간을 입력하세요.',
            ),
            LabeledBox(
              label: '반품 정책',
              value: '',
              controller: returnPolicyController,
              hintText: '환불 가능 조건과 확인 절차를 입력하세요.',
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
