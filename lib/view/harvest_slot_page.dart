import 'package:flutter/material.dart';
import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/harvest_models.dart';
import 'package:smart_app/model/product_record.dart';
import 'package:smart_app/repositories/harvest_repository.dart';
import 'package:smart_app/repositories/product_repository.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class HarvestSlotPage extends StatefulWidget {
  const HarvestSlotPage({super.key});

  @override
  State<HarvestSlotPage> createState() => _HarvestSlotPageState();
}

class _HarvestSlotPageState extends State<HarvestSlotPage> {
  final productRepository = ProductRepository();
  final harvestRepository = HarvestRepository();
  final pastYieldController = TextEditingController(text: '3000');
  final marketPriceController = TextEditingController();
  final varietyController = TextEditingController();
  final marAvgTempController = TextEditingController(text: '8.5');
  final augSunshineController = TextEditingController(text: '210');
  final octRainfallController = TextEditingController(text: '65');
  final augHumidityController = TextEditingController(text: '72');

  List<ProductRecord> products = [];
  List<MLPredictionRecord> predictions = [];
  List<HarvestSlotRecord> slots = [];
  ProductRecord? selectedProduct;
  MLPredictionRecord? selectedPrediction;
  bool isLoading = false;
  bool isWorking = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    pastYieldController.dispose();
    marketPriceController.dispose();
    varietyController.dispose();
    marAvgTempController.dispose();
    augSunshineController.dispose();
    octRainfallController.dispose();
    augHumidityController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final nextProducts = await productRepository.fetchProducts();
      final nextPredictions = await harvestRepository.fetchPredictions();
      final nextSlots = await harvestRepository.fetchSlots();
      if (!mounted) return;
      setState(() {
        products = nextProducts;
        predictions = nextPredictions;
        slots = nextSlots;
        selectedProduct = nextProducts.isEmpty ? null : nextProducts.first;
        _syncProductInputs(selectedProduct);
        selectedPrediction = nextPredictions.isEmpty
            ? null
            : nextPredictions.first;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _createPrediction() async {
    final product = selectedProduct;
    if (product == null) {
      showOwnerSnack(context, '예측할 상품을 먼저 선택하세요.');
      return;
    }
    setState(() => isWorking = true);
    try {
      final variety = varietyController.text.trim();
      final pastYield = _readRequiredDouble(pastYieldController, '과거 수확량');
      final marketPrice = _readRequiredInt(marketPriceController, '시장 가격');
      final marAvgTemp = _readRequiredDouble(
        marAvgTempController,
        '3월 평균기온',
      );
      final augSunshine = _readRequiredDouble(
        augSunshineController,
        '8월 일조시간',
      );
      final octRainfall = _readRequiredDouble(
        octRainfallController,
        '10월 강수량',
      );
      final augHumidity = _readRequiredDouble(
        augHumidityController,
        '8월 습도',
      );
      if (variety.isEmpty) {
        throw ApiException('품종을 입력하세요.');
      }
      if (pastYield <= 0 || marketPrice <= 0) {
        throw ApiException('과거 수확량과 시장 가격은 0보다 커야 합니다.');
      }
      if (marAvgTemp < -5 || marAvgTemp > 25) {
        throw ApiException('3월 평균기온은 -5~25 범위로 입력하세요.');
      }
      if (augSunshine < 50 || augSunshine > 400) {
        throw ApiException('8월 일조시간은 50~400 범위로 입력하세요.');
      }
      if (octRainfall < 0 || octRainfall > 600) {
        throw ApiException('10월 강수량은 0~600 범위로 입력하세요.');
      }
      if (augHumidity < 30 || augHumidity > 100) {
        throw ApiException('8월 습도는 30~100 범위로 입력하세요.');
      }
      final prediction = await harvestRepository.createPrediction(
        product,
        pastYieldKg: pastYield,
        marketPrice: marketPrice,
        variety: variety,
        marAvgTemp: marAvgTemp,
        augSunshine: augSunshine,
        octRainfall: octRainfall,
        augHumidity: augHumidity,
      );
      if (!mounted) return;
      setState(() {
        predictions.insert(0, prediction);
        selectedPrediction = prediction;
      });
      showOwnerSnack(context, 'ML 예측을 생성했습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isWorking = false);
    }
  }

  void _syncProductInputs(ProductRecord? product) {
    marketPriceController.text = product?.price.toString() ?? '';
    varietyController.text = product?.variety ?? '';
  }

  double _readRequiredDouble(TextEditingController controller, String label) {
    final value = double.tryParse(controller.text.trim());
    if (value == null) {
      throw ApiException('$label 값을 숫자로 입력하세요.');
    }
    return value;
  }

  int _readRequiredInt(TextEditingController controller, String label) {
    final value = int.tryParse(controller.text.trim());
    if (value == null) {
      throw ApiException('$label 값을 숫자로 입력하세요.');
    }
    return value;
  }

  Future<void> _createDraftSlot() async {
    final product = selectedProduct;
    final prediction = selectedPrediction;
    if (product == null || prediction == null) {
      showOwnerSnack(context, '상품과 예측 결과가 필요합니다.');
      return;
    }
    setState(() => isWorking = true);
    try {
      final slot = await harvestRepository.createDraftSlot(
        product: product,
        prediction: prediction,
      );
      if (!mounted) return;
      setState(() => slots.insert(0, slot));
      showOwnerSnack(context, '수확 슬롯 초안을 생성했습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isWorking = false);
    }
  }

  Future<void> _openSlotEditor(HarvestSlotRecord slot) async {
    final updated = await Navigator.of(context).push<HarvestSlotRecord>(
      MaterialPageRoute(builder: (_) => _HarvestSlotEditPage(slot: slot)),
    );
    if (updated == null) return;
    setState(() {
      final index = slots.indexWhere((item) => item.slotId == updated.slotId);
      if (index >= 0) slots[index] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productNames = products.map((item) => item.name).toSet().toList();
    final prediction = selectedPrediction;

    return Scaffold(
      body: AppScaffold(
        title: '수확 예측',
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
          if (products.isEmpty)
            const NoticeBox(
              color: Color(0xffF4F7F1),
              text: '예측을 생성할 상품이 없습니다. 상품을 먼저 등록하세요.',
            )
          else
            LabeledDropdown(
              label: '상품',
              value: selectedProduct?.name ?? '',
              items: productNames,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedProduct = products.firstWhere(
                    (item) => item.name == value,
                    orElse: () => products.first,
                  );
                  _syncProductInputs(selectedProduct);
                });
              },
            ),
          LabeledField(
            label: '과거 수확량',
            value: '',
            controller: pastYieldController,
            keyboardType: TextInputType.number,
            inputFormatters: const [DigitsOnlyInputFormatter()],
            validator: numericValidator,
            suffixText: 'kg',
          ),
          LabeledField(
            label: '시장 가격',
            value: '',
            controller: marketPriceController,
            keyboardType: TextInputType.number,
            inputFormatters: const [DigitsOnlyInputFormatter()],
            validator: numericValidator,
            suffixText: '원',
          ),
          LabeledField(
            label: '품종',
            value: '',
            controller: varietyController,
            hintText: '예: 부사',
            validator: (value) => requiredValidator('품종', value),
          ),
          LabeledField(
            label: '3월 평균기온',
            value: '',
            controller: marAvgTempController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: '-5~25',
            suffixText: '℃',
          ),
          LabeledField(
            label: '8월 일조시간',
            value: '',
            controller: augSunshineController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: '50~400',
            suffixText: 'h',
          ),
          LabeledField(
            label: '10월 강수량',
            value: '',
            controller: octRainfallController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: '0~600',
            suffixText: 'mm',
          ),
          LabeledField(
            label: '8월 습도',
            value: '',
            controller: augHumidityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: '30~100',
            suffixText: '%',
          ),
          const YieldChart(),
          GridCards(
            children: [
              MetricCard(
                icon: Icons.calendar_month_outlined,
                value: prediction == null
                    ? '-'
                    : '${prediction.predictedHarvestStart}~'
                          '${prediction.predictedHarvestEnd}',
                label: '예측 수확일',
              ),
              MetricCard(
                icon: Icons.scale_outlined,
                value: prediction == null
                    ? '-'
                    : '${prediction.estimatedYieldKg.toStringAsFixed(0)}kg',
                label: '예상 수확량',
              ),
              MetricCard(
                icon: Icons.agriculture_outlined,
                value: prediction == null
                    ? '-'
                    : '${prediction.unitYieldKg10a.toStringAsFixed(0)}kg',
                label: '10a 단위 수확량',
              ),
              MetricCard(
                icon: Icons.shopping_bag_outlined,
                value: prediction == null
                    ? '-'
                    : '${prediction.suggestedReservableMinKg.toStringAsFixed(0)}-'
                          '${prediction.suggestedReservableMaxKg.toStringAsFixed(0)}kg',
                label: '권장 예약량',
              ),
              MetricCard(
                icon: Icons.paid_outlined,
                value: prediction == null
                    ? '-'
                    : '${prediction.recommendedPrice}원',
                label: '권장 판매가',
              ),
            ],
          ),
          DataTile(
            icon: Icons.verified_outlined,
            title: prediction == null
                ? '예측 결과 없음'
                : '신뢰도 ${(prediction.confidence * 100).toStringAsFixed(0)}%',
            subtitle:
                prediction?.warningMessage ?? '상품을 선택하고 ML 예측을 생성하세요.',
            badge: prediction?.modelVersion ?? '',
            badgeColor: const Color(0xffDFF4E8),
          ),
          DualActionBar(
            left: isWorking ? '처리 중' : 'ML 예측 생성',
            right: isWorking ? '처리 중' : '슬롯 초안 생성',
            onLeftPressed: isWorking ? null : _createPrediction,
            onRightPressed: isWorking ? null : _createDraftSlot,
          ),
          const SectionHeader(title: '수확 슬롯'),
          for (final slot in slots.take(8))
            DataTile(
              icon: Icons.event_available_outlined,
              title: '${slot.productName} · ${slot.slotStatus}',
              subtitle:
                  '${slot.confirmedHarvestStart} ~ ${slot.confirmedHarvestEnd} · ${slot.availableKg.toStringAsFixed(0)}kg',
              badge: '${slot.confirmedPrice}원',
              badgeColor: const Color(0xffDFF4E8),
              onTap: () => _openSlotEditor(slot),
              showChevron: true,
            ),
        ],
      ),
    );
  }
}

class _HarvestSlotEditPage extends StatefulWidget {
  final HarvestSlotRecord slot;

  const _HarvestSlotEditPage({required this.slot});

  @override
  State<_HarvestSlotEditPage> createState() => _HarvestSlotEditPageState();
}

class _HarvestSlotEditPageState extends State<_HarvestSlotEditPage> {
  final formKey = GlobalKey<FormState>();
  final repository = HarvestRepository();
  final startController = TextEditingController();
  final endController = TextEditingController();
  final reservableController = TextEditingController();
  final priceController = TextEditingController();
  final noticeController = TextEditingController();
  late String status;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    startController.text = widget.slot.confirmedHarvestStart;
    endController.text = widget.slot.confirmedHarvestEnd;
    reservableController.text = widget.slot.confirmedReservableKg.toStringAsFixed(0);
    priceController.text = widget.slot.confirmedPrice.toString();
    noticeController.text = widget.slot.customerNotice;
    status = widget.slot.slotStatus;
  }

  @override
  void dispose() {
    startController.dispose();
    endController.dispose();
    reservableController.dispose();
    priceController.dispose();
    noticeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => isSaving = true);
    try {
      final updated = widget.slot.copyWith(
        confirmedHarvestStart: startController.text.trim(),
        confirmedHarvestEnd: endController.text.trim(),
        confirmedReservableKg: double.parse(reservableController.text.trim()),
        confirmedPrice: int.parse(priceController.text.trim()),
        customerNotice: noticeController.text.trim(),
        slotStatus: status,
      );
      var saved = await repository.updateSlot(updated);
      if (saved.slotStatus != status) {
        saved = await repository.updateSlotStatus(slot: saved, status: status);
      }
      if (!mounted) return;
      showOwnerSnack(context, '수확 슬롯을 저장했습니다.');
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
          title: '수확 슬롯 수정',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          children: [
            LabeledField(
              label: '수확 시작일',
              value: '',
              controller: startController,
              hintText: 'YYYY-MM-DD',
            ),
            LabeledField(
              label: '수확 종료일',
              value: '',
              controller: endController,
              hintText: 'YYYY-MM-DD',
            ),
            LabeledField(
              label: '예약 가능 중량',
              value: '',
              controller: reservableController,
              keyboardType: TextInputType.number,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: numericValidator,
              suffixText: 'kg',
            ),
            LabeledField(
              label: '판매가',
              value: '',
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: numericValidator,
              suffixText: '원',
            ),
            LabeledDropdown(
              label: '슬롯 상태',
              value: status,
              items: const ['DRAFT', 'OPEN', 'CLOSED'],
              onChanged: (value) {
                if (value != null) setState(() => status = value);
              },
            ),
            LabeledBox(
              label: '고객 안내',
              value: '',
              controller: noticeController,
              required: false,
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
