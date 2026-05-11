import 'package:flutter/material.dart';
import 'package:smart_app/model/shipment_record.dart';
import 'package:smart_app/repositories/shipment_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/view/shipment_status_page.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ShipmentPage extends StatefulWidget {
  const ShipmentPage({super.key});

  @override
  State<ShipmentPage> createState() => _ShipmentPageState();
}

class _ShipmentPageState extends State<ShipmentPage> {
  final formKey = GlobalKey<FormState>();
  final repository = ShipmentRepository();
  final invoiceController = TextEditingController();
  final boxesController = TextEditingController();
  final weightController = TextEditingController();

  List<ShipmentTargetRecord> targets = [];
  ShipmentTargetRecord? selectedTarget;
  String courier = '';
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  @override
  void dispose() {
    invoiceController.dispose();
    boxesController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> _loadTargets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final nextTargets = await repository.fetchShipmentTargets();
      if (!mounted) return;
      setState(() {
        targets = nextTargets;
        selectedTarget = nextTargets.isEmpty ? null : nextTargets.first;
        _fillTargetFields(selectedTarget);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _selectTarget(String value) {
    final target = targets.firstWhere(
      (item) => item.label == value,
      orElse: () => targets.first,
    );
    setState(() {
      selectedTarget = target;
      _fillTargetFields(target);
    });
  }

  void _fillTargetFields(ShipmentTargetRecord? target) {
    if (target == null) {
      boxesController.clear();
      weightController.clear();
      return;
    }
    boxesController.text = target.packageCount.toString();
    weightController.text = target.orderedKg.toStringAsFixed(0);
  }

  Future<void> _registerShipment() async {
    final target = selectedTarget;
    if (target == null) {
      showOwnerSnack(context, '배송 등록할 주문을 선택하세요.');
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 정보를 입력해야 등록할 수 있습니다.');
      return;
    }

    setState(() => isSaving = true);
    try {
      final shipment = await repository.createShipment(
        orderId: target.orderId,
        carrierName: courier,
        trackingNo: invoiceController.text.trim(),
        shippedPackageCount: int.parse(boxesController.text.trim()),
        shippedKg: double.parse(weightController.text.trim()),
      );
      if (!mounted) return;
      shipmentStatusRecords.insert(
        0,
        ShipmentRecord(
          target.label,
          '${shipment.carrierName} · ${shipment.trackingNo}',
          shipment.statusLabel,
          shipment.color,
          shipmentId: shipment.shipmentId,
        ),
      );
      setState(() {
        targets.removeWhere((item) => item.orderId == target.orderId);
        selectedTarget = targets.isEmpty ? null : targets.first;
        courier = '';
        invoiceController.clear();
        _fillTargetFields(selectedTarget);
      });
      showOwnerSnack(context, '${target.productName} 배송 정보를 등록했습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetLabel = selectedTarget?.label ?? '';

    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '배송 관리',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionChipIcon(
                icon: Icons.refresh,
                onPressed: isLoading ? null : _loadTargets,
              ),
              const SizedBox(width: 6),
              ActionChipIcon(
                icon: Icons.qr_code_scanner,
                onPressed: () => showOwnerSnack(context, '포장 바코드 스캔은 준비 중입니다.'),
              ),
            ],
          ),
          children: [
            if (isLoading) const LinearProgressIndicator(),
            if (errorMessage != null)
              NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
            if (targets.isEmpty)
              const NoticeBox(
                color: AppColors.yellow,
                text: '배송 등록 가능한 주문이 없습니다.',
              )
            else
              LabeledDropdown(
                label: '배송 대상 주문',
                value: targetLabel,
                items: [for (final target in targets) target.label],
                onChanged: (value) {
                  if (value != null) _selectTarget(value);
                },
              ),
            LabeledDropdown(
              label: '택배사',
              value: courier,
              items: const ['CJ대한통운', '롯데택배', '한진택배', '우체국택배', '로젠택배'],
              onChanged: (value) {
                if (value != null) setState(() => courier = value);
              },
            ),
            LabeledField(
              label: '송장번호',
              value: '',
              controller: invoiceController,
              hintText: '송장번호',
              keyboardType: TextInputType.number,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: invoiceNumberValidator,
            ),
            LabeledField(
              label: '배송 중량',
              value: '',
              controller: weightController,
              keyboardType: TextInputType.number,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: (text) {
                final required = requiredValidator('배송 중량', text);
                if (required != null) return required;
                return RegExp(r'^\d+$').hasMatch(text!.trim())
                    ? null
                    : '배송 중량은 숫자로 입력하세요.';
              },
              suffixText: 'kg',
            ),
            LabeledField(
              label: '배송 박스 수',
              value: '',
              controller: boxesController,
              keyboardType: TextInputType.number,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: (text) {
                final required = requiredValidator('배송 박스 수', text);
                if (required != null) return required;
                return RegExp(r'^\d+$').hasMatch(text!.trim())
                    ? null
                    : '배송 박스 수에는 숫자만 입력하세요.';
              },
              suffixText: '박스',
            ),
            DualActionBar(
              left: '취소',
              right: isSaving ? '등록 중' : '등록',
              onLeftPressed: isSaving ? null : () => Navigator.of(context).pop(),
              onRightPressed: isSaving ? null : _registerShipment,
            ),
          ],
        ),
      ),
    );
  }
}
