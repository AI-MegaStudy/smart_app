import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_app/model/product_record.dart';
import 'package:smart_app/repositories/product_repository.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProductEditPage extends StatefulWidget {
  final ProductRecord product;

  const ProductEditPage({super.key, required this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final formKey = GlobalKey<FormState>();
  final repository = ProductRepository();
  final imagePicker = ImagePicker();
  final productNameController = TextEditingController();
  final varietyController = TextEditingController();
  final packageController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  late ProductRecord product;
  late String fruitType;
  late String status;
  bool isSaving = false;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    productNameController.text = product.name;
    varietyController.text = product.variety;
    packageController.text = product.packageUnitKg > 0
        ? product.packageUnitKg.toStringAsFixed(0)
        : product.packageUnit.replaceAll(RegExp(r'\D'), '');
    priceController.text = product.price.toString();
    descriptionController.text = product.description ?? '';
    fruitType = product.fruitType;
    status = product.status;
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

  Future<void> _uploadImage() async {
    if (product.productId == null) {
      showOwnerSnack(context, '저장된 상품만 이미지를 업로드할 수 있습니다.');
      return;
    }
    try {
      final picked = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => isUploadingImage = true);
      final updated = await repository.uploadProductImage(
        product: product,
        bytes: bytes,
        filename: picked.name.isEmpty ? 'product.jpg' : picked.name,
      );
      if (!mounted) return;
      setState(() => product = updated);
      showOwnerSnack(context, '상품 이미지를 업로드했습니다.');
    } on PlatformException catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.message ?? '이미지를 선택할 수 없습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isUploadingImage = false);
    }
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 필수 항목을 입력한 뒤 수정하세요.');
      return;
    }

    setState(() => isSaving = true);
    try {
      final statusCode = ProductRecord.statusCodeFromLabel(status);
      final updated = product.copyWith(
        name: productNameController.text.trim(),
        fruitType: fruitType,
        variety: varietyController.text.trim(),
        packageUnit: '${packageController.text.trim()}kg 박스',
        packageUnitKg: double.parse(packageController.text.trim()),
        price: int.parse(priceController.text.trim()),
        statusCode: statusCode,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      );
      final saved = await repository.updateProduct(updated);
      if (!mounted) return;
      showOwnerSnack(context, '상품 정보를 수정했습니다.');
      Navigator.of(context).pop(saved);
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
          title: '상품 수정',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          trailing: ActionChipIcon(
            icon: Icons.image_outlined,
            onPressed: isUploadingImage ? null : _uploadImage,
          ),
          children: [
            if (product.imageUrl != null)
              NoticeBox(
                color: const Color(0xffF4F7F1),
                text: '등록 이미지: ${product.imageUrl}',
              ),
            LabeledField(
              label: '상품명',
              value: '',
              controller: productNameController,
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
            ),
            LabeledField(
              label: '포장 단위',
              value: '',
              controller: packageController,
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
              right: isSaving ? '수정 중' : '수정',
              onLeftPressed: isSaving ? null : () => Navigator.of(context).pop(),
              onRightPressed: isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
