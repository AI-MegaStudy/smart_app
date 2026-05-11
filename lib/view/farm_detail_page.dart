import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kpostal_plus/kpostal_plus.dart';
import 'package:smart_app/model/farm_record.dart';
import 'package:smart_app/repositories/farm_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class FarmDetailPage extends StatefulWidget {
  const FarmDetailPage({super.key});

  @override
  State<FarmDetailPage> createState() => _FarmDetailPageState();
}

class _FarmDetailPageState extends State<FarmDetailPage> {
  final formKey = GlobalKey<FormState>();
  final repository = FarmRepository();
  final farmNameController = TextEditingController();
  final regionController = TextEditingController();
  final addressController = TextEditingController();
  final imageUrlController = TextEditingController();
  final introController = TextEditingController();
  final shippingPolicyController = TextEditingController();
  final returnPolicyController = TextEditingController();

  List<FarmRecord> farms = [];
  FarmRecord? farm;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  @override
  void dispose() {
    farmNameController.dispose();
    regionController.dispose();
    addressController.dispose();
    imageUrlController.dispose();
    introController.dispose();
    shippingPolicyController.dispose();
    returnPolicyController.dispose();
    super.dispose();
  }

  Future<void> _loadFarms() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final records = await repository.fetchMyFarms();
      if (!mounted) return;
      setState(() {
        farms = records;
        _setFarm(records.isEmpty ? null : records.first);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _setFarm(FarmRecord? record) {
    farm = record;
    farmNameController.text = record?.farmName ?? '';
    regionController.text = record?.farmRegion ?? '';
    addressController.text = record?.farmAddress ?? '';
    imageUrlController.text = record?.farmImageUrl ?? '';
    introController.text = record?.farmDescription ?? '';
    shippingPolicyController.text = record?.deliveryPolicy ?? '';
    returnPolicyController.text = record?.returnPolicy ?? '';
  }

  Future<void> _save() async {
    final current = farm;
    if (current == null) {
      showOwnerSnack(context, '수정할 농장 정보가 없습니다.');
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => isSaving = true);
    try {
      final updated = current.copyWith(
        farmName: farmNameController.text.trim(),
        farmRegion: regionController.text.trim(),
        farmAddress: addressController.text.trim(),
        farmImageUrl: imageUrlController.text.trim().isEmpty
            ? null
            : imageUrlController.text.trim(),
        farmDescription: introController.text.trim().isEmpty
            ? null
            : introController.text.trim(),
        deliveryPolicy: shippingPolicyController.text.trim().isEmpty
            ? null
            : shippingPolicyController.text.trim(),
        returnPolicy: returnPolicyController.text.trim().isEmpty
            ? null
            : returnPolicyController.text.trim(),
      );
      final saved = await repository.updateFarm(updated);
      if (!mounted) return;
      setState(() {
        final index = farms.indexWhere((item) => item.farmId == saved.farmId);
        if (index >= 0) farms[index] = saved;
        _setFarm(saved);
      });
      showOwnerSnack(context, '농장 정보를 저장했습니다.');
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isSaving = false);
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

  @override
  Widget build(BuildContext context) {
    final farmLabel = farm?.farmName ?? '';

    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '농장 정보 수정',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          trailing: ActionChipIcon(
            icon: Icons.refresh,
            onPressed: isLoading ? null : _loadFarms,
          ),
          children: [
            if (isLoading) const LinearProgressIndicator(),
            if (errorMessage != null)
              NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
            if (!isLoading && errorMessage == null && farms.isEmpty)
              const NoticeBox(
                color: Color(0xffFFE9E2),
                text:
                    '등록된 농장이 없습니다. 현재 최종 백엔드 명세에는 농장 생성 API가 없어 이 화면에서는 기존 농장만 수정할 수 있습니다.',
              ),
            if (farms.length > 1)
              LabeledDropdown(
                label: '수정할 농장',
                value: farmLabel,
                items: [for (final item in farms) item.farmName],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _setFarm(
                      farms.firstWhere(
                        (item) => item.farmName == value,
                        orElse: () => farms.first,
                      ),
                    );
                  });
                },
              ),
            if (farm != null) ...[
            LabeledField(
              label: '농장명',
              value: '',
              controller: farmNameController,
              hintText: '농장명',
            ),
            LabeledField(
              label: '지역',
              value: '',
              controller: regionController,
              hintText: '예: 충북 충주',
            ),
            LabeledField(
              label: '주소',
              value: '',
              controller: addressController,
              hintText: '주소',
              readOnly: true,
              validator: (value) => requiredValidator('주소', value),
            ),
            FilledButton.tonalIcon(
              onPressed: _searchAddress,
              icon: const Icon(Icons.search),
              label: const Text('주소 검색'),
            ),
            LabeledField(
              label: '농장 이미지 URL',
              value: '',
              controller: imageUrlController,
              hintText: 'https://...',
              validator: (_) => null,
            ),
            LabeledBox(
              label: '농장 소개',
              value: '',
              controller: introController,
              required: false,
              showCounter: true,
            ),
            LabeledBox(
              label: '배송 정책',
              value: '',
              controller: shippingPolicyController,
              required: false,
              showCounter: true,
            ),
            LabeledBox(
              label: '반품 정책',
              value: '',
              controller: returnPolicyController,
              required: false,
              showCounter: true,
            ),
            DualActionBar(
              left: '취소',
              right: isSaving ? '저장 중' : '저장',
              onLeftPressed: isSaving ? null : () => Navigator.of(context).pop(),
              onRightPressed: isSaving ? null : _save,
            ),
            ],
          ],
        ),
      ),
    );
  }
}
