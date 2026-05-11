import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_app/model/procurement_record.dart';
import 'package:smart_app/model/quality_record.dart';
import 'package:smart_app/repositories/quality_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class QualityPage extends StatefulWidget {
  const QualityPage({super.key});

  @override
  State<QualityPage> createState() => _QualityPageState();
}

class _QualityPageState extends State<QualityPage> {
  final imagePicker = ImagePicker();
  final repository = QualityRepository();
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  Offset inspectionAnchor = const Offset(0.5, 0.72);
  List<ProcurementItemRecord> targets = [];
  List<QualityInspectionRecord> inspections = [];
  ProcurementItemRecord? selectedTarget;
  QualityInspectionRecord? analysis;
  bool isLoading = false;
  bool isWorking = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _retrieveLostImage();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final nextTargets = await repository.fetchInspectionTargets();
      final nextInspections = await repository.fetchInspections();
      if (!mounted) return;
      setState(() {
        targets = nextTargets;
        inspections = nextInspections;
        selectedTarget = nextTargets.isEmpty ? null : nextTargets.first;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _openGallery() async {
    try {
      final picked = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (picked == null) return;
      await _setSelectedImage(picked);
    } on PlatformException catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, _galleryErrorMessage(error));
    } on MissingPluginException {
      if (!mounted) return;
      showOwnerSnack(context, '갤러리 플러그인을 사용할 수 없습니다. 앱을 다시 실행하세요.');
    } catch (_) {
      if (!mounted) return;
      showOwnerSnack(context, '갤러리를 여는 중 문제가 발생했습니다.');
    }
  }

  Future<void> _retrieveLostImage() async {
    try {
      final response = await imagePicker.retrieveLostData();
      if (response.isEmpty) return;
      if (response.exception != null) {
        if (mounted) showOwnerSnack(context, _galleryErrorMessage(response.exception!));
        return;
      }

      final files = response.files;
      final picked = files?.isNotEmpty == true ? files!.last : response.file;
      if (picked != null) await _setSelectedImage(picked);
    } catch (_) {
      // retrieveLostData is Android-only in practice; ignore unsupported paths.
    }
  }

  Future<void> _setSelectedImage(XFile picked) async {
    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() {
      selectedImageBytes = bytes;
      selectedImageName = picked.name.isEmpty ? '선택한 이미지' : picked.name;
      inspectionAnchor = const Offset(0.5, 0.72);
      analysis = null;
    });
  }

  Future<void> _analyze() async {
    final target = selectedTarget;
    if (target == null) {
      showOwnerSnack(context, '검사할 발주 품목을 선택하세요.');
      return;
    }
    if (selectedImageName == null) {
      showOwnerSnack(context, '검사 이미지를 선택하세요.');
      return;
    }
    final imageBytes = selectedImageBytes;
    if (imageBytes == null) {
      showOwnerSnack(context, '검사 이미지를 다시 선택하세요.');
      return;
    }
    setState(() => isWorking = true);
    try {
      final imageUrl = await repository.uploadImage(
        bytes: imageBytes,
        filename: selectedImageName!,
      );
      final result = await repository.analyze(
        procurementItemId: target.procurementItemId,
        imageUrl: imageUrl,
      );
      if (!mounted) return;
      setState(() => analysis = result);
      showOwnerSnack(context, '품질 분석을 완료했습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isWorking = false);
    }
  }

  Future<void> _saveInspection() async {
    final target = selectedTarget;
    final result = analysis;
    if (target == null || result == null) {
      showOwnerSnack(context, '분석 결과가 필요합니다.');
      return;
    }
    final imageUrl = result.imageUrl ?? '/mock/quality/$selectedImageName';
    setState(() => isWorking = true);
    try {
      final saved = await repository.saveInspection(
        procurementItemId: target.procurementItemId,
        imageUrl: imageUrl,
        ownerConfirmedGrade: result.modelGrade,
        ownerDecision: result.modelDecision == 'HOLD' ? 'HOLD' : 'PASS',
      );
      if (!mounted) return;
      setState(() => inspections.insert(0, saved));
      showOwnerSnack(context, '품질 검사 결과를 저장했습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isWorking = false);
    }
  }

  String _galleryErrorMessage(PlatformException error) {
    if (error.code == 'photo_access_denied' ||
        error.code == 'camera_access_denied') {
      return '사진 접근 권한을 허용한 뒤 다시 시도하세요.';
    }
    if (error.code == 'already_active') {
      return '갤러리가 이미 열려 있습니다.';
    }
    final detail = error.message ?? error.details?.toString();
    if (detail == null || detail.trim().isEmpty) {
      return '갤러리를 여는 중 문제가 발생했습니다. (${error.code})';
    }
    return '갤러리를 여는 중 문제가 발생했습니다. (${error.code}: $detail)';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedImageBytes != null;
    final targetLabels = [
      for (final target in targets)
        '${target.procurementItemId} · ${target.productName}',
    ];
    final selectedTargetLabel = selectedTarget == null
        ? ''
        : '${selectedTarget!.procurementItemId} · ${selectedTarget!.productName}';
    final current = analysis ?? (inspections.isEmpty ? null : inspections.first);

    return Scaffold(
      body: AppScaffold(
        title: '선별 검사',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionChipIcon(icon: Icons.refresh, onPressed: isLoading ? null : _load),
            const SizedBox(width: 6),
            ActionChipIcon(icon: Icons.image_outlined, onPressed: _openGallery),
          ],
        ),
        children: [
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
          if (targets.isEmpty)
            const NoticeBox(
              color: AppColors.yellow,
              text: '검사할 승인 발주 품목이 없습니다.',
            )
          else
            LabeledDropdown(
              label: '발주 품목',
              value: selectedTargetLabel,
              items: targetLabels,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedTarget = targets.firstWhere(
                    (item) => value.startsWith('${item.procurementItemId} ·'),
                    orElse: () => targets.first,
                  );
                  analysis = null;
                });
              },
            ),
          CameraPreviewCard(
            icon: Icons.image_search_outlined,
            label: hasImage ? selectedImageName : null,
            hasImage: hasImage,
            imageBytes: selectedImageBytes,
            inspectionAnchor: inspectionAnchor,
            onInspectionAnchorChanged: (anchor) {
              setState(() => inspectionAnchor = anchor);
            },
          ),
          const NoticeBox(
            color: AppColors.blue,
            text: '분석 결과는 선별 보조 자료입니다. 최종 등급과 출고 여부는 점주가 확정합니다.',
          ),
          GridCards(
            children: [
              MetricCard(
                icon: Icons.workspace_premium_outlined,
                value: current?.modelGrade ?? '-',
                label: '추천 등급',
              ),
              MetricCard(
                icon: Icons.monitor_heart_outlined,
                value: current == null
                    ? '-'
                    : '${current.freshnessScore.toStringAsFixed(0)}점',
                label: '신선도',
              ),
            ],
          ),
          DataTile(
            icon: Icons.check_circle_outline,
            title: current == null ? '검사 대기' : current.decisionLabel,
            subtitle: current == null
                ? '이미지를 선택하고 분석을 실행하세요.'
                : '색상 ${current.colorScore.toStringAsFixed(0)}점 · 타박 확률 ${(current.bruiseProbability * 100).toStringAsFixed(0)}%',
            badge: current?.modelDecision ?? '',
            badgeColor: current?.decisionColor ?? AppColors.mint,
          ),
          DualActionBar(
            left: isWorking ? '처리 중' : '분석',
            right: isWorking ? '처리 중' : '결과 저장',
            onLeftPressed: isWorking ? null : _analyze,
            onRightPressed: isWorking ? null : _saveInspection,
          ),
        ],
      ),
    );
  }
}
