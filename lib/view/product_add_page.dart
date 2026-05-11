import 'package:flutter/material.dart';
import 'package:smart_app/model/farm_record.dart';
import 'package:smart_app/model/product_record.dart';
import 'package:smart_app/repositories/farm_repository.dart';
import 'package:smart_app/repositories/product_repository.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({super.key});

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final formKey = GlobalKey<FormState>();
  final repository = ProductRepository();
  final farmRepository = FarmRepository();
  final productNameController = TextEditingController();
  final varietyController = TextEditingController();
  final packageController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  List<FarmRecord> farms = [];
  FarmRecord? selectedFarm;
  String fruitType = 'apple';
  String status = '준비 중';
  bool isLoadingFarms = false;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  @override
  void dispose() {
    productNameController.dispose();
    varietyController.dispose();
    packageController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFarms() async {
    setState(() {
      isLoadingFarms = true;
      errorMessage = null;
    });
    try {
      final records = await farmRepository.fetchMyFarms();
      if (!mounted) return;
      setState(() {
        farms = records;
        selectedFarm = records.isEmpty ? null : records.first;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isLoadingFarms = false);
    }
  }

  Future<void> _save() async {
    final farm = selectedFarm;
    if (farm == null) {
      showOwnerSnack(context, '상품을 등록할 농장을 선택하세요.');
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 필수 항목을 입력한 뒤 등록하세요.');
      return;
    }

    setState(() => isSaving = true);
    try {
      final statusCode = ProductRecord.statusCodeFromLabel(status);
      final product = ProductRecord(
        productNameController.text.trim(),
        '${packageController.text.trim()}kg 박스',
        int.parse(priceController.text.trim()),
        0,
        ProductRecord.statusLabel(statusCode),
        ProductRecord.statusColor(statusCode),
        farmId: farm.farmId,
        fruitType: fruitType,
        variety: varietyController.text.trim(),
        packageUnitKg: double.parse(packageController.text.trim()),
        statusCode: statusCode,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      );
      final created = await repository.createProduct(product);
      if (!mounted) return;
      showOwnerSnack(context, '상품을 등록했습니다.');
      Navigator.of(context).pop(created);
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmLabel = selectedFarm?.farmName ?? '';

    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '상품 추가',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          trailing: ActionChipIcon(
            icon: Icons.refresh,
            onPressed: isLoadingFarms ? null : _loadFarms,
          ),
          children: [
            if (isLoadingFarms) const LinearProgressIndicator(),
            if (errorMessage != null)
              NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
            if (farms.isEmpty)
              const NoticeBox(
                color: Color(0xffFFE9E2),
                text:
                    '등록 가능한 농장이 없습니다. 현재 최종 백엔드 명세에는 농장 생성 API가 없어 상품 등록을 진행할 수 없습니다.',
              )
            else
              LabeledDropdown(
                label: '농장',
                value: farmLabel,
                items: [for (final farm in farms) farm.farmName],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedFarm = farms.firstWhere(
                      (farm) => farm.farmName == value,
                      orElse: () => farms.first,
                    );
                  });
                },
              ),
            LabeledField(
              label: '상품명',
              value: '',
              controller: productNameController,
              hintText: '예: 양광 사과',
            ),
            LabeledDropdown(
              label: '품목',
              value: fruitType,
              items: const ['apple', 'pear', 'peach', 'grape'],
              onChanged: (value) {
                if (value != null) setState(() => fruitType = value);
              },
            ),
            LabeledField(
              label: '품종',
              value: '',
              controller: varietyController,
              hintText: '예: 양광',
            ),
            LabeledField(
              label: '포장 단위',
              value: '',
              controller: packageController,
              hintText: '5',
              keyboardType: TextInputType.number,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: (text) {
                final required = requiredValidator('포장 단위', text);
                if (required != null) return required;
                return RegExp(r'^\d+$').hasMatch(text!.trim())
                    ? null
                    : '포장 단위는 숫자로 입력하세요.';
              },
              suffixText: 'kg 박스',
            ),
            LabeledField(
              label: '기본 판매가',
              value: '',
              controller: priceController,
              hintText: '39000',
              keyboardType: TextInputType.number,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: (text) {
                final required = requiredValidator('기본 판매가', text);
                if (required != null) return required;
                return RegExp(r'^\d+$').hasMatch(text!.trim())
                    ? null
                    : '기본 판매가는 숫자로 입력하세요.';
              },
              suffixText: '원',
            ),
            LabeledDropdown(
              label: '판매 상태',
              value: status,
              items: const ['판매 중', '준비 중', '판매 중지'],
              onChanged: (value) {
                if (value != null) setState(() => status = value);
              },
            ),
            LabeledBox(
              label: '상품 설명',
              value: '',
              controller: descriptionController,
              required: false,
            ),
            DualActionBar(
              left: '취소',
              right: isSaving ? '등록 중' : '등록',
              onLeftPressed: isSaving ? null : () => Navigator.of(context).pop(),
              onRightPressed: isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
