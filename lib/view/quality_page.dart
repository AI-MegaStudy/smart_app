import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class QualityPage extends StatefulWidget {
  const QualityPage({super.key});

  @override
  State<QualityPage> createState() => _QualityPageState();
}

class _QualityPageState extends State<QualityPage> {
  IconData selectedIcon = Icons.local_florist;
  String selectedLabel = '촬영 대기';

  Future<void> _openGallery() async {
    final selected = await showModalBottomSheet<_GalleryImage>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _GalleryPicker(),
    );
    if (selected != null) {
      setState(() {
        selectedIcon = selected.icon;
        selectedLabel = selected.label;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: '신선도 검사',
        subtitle: '후지 사과 5kg',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: ActionChipIcon(
          icon: Icons.image_outlined,
          onPressed: _openGallery,
        ),
        children: [
          CameraPreviewCard(icon: selectedIcon, label: selectedLabel),
          const NoticeBox(
            color: AppColors.blue,
            text: '판별 결과는 선별 보조 자료입니다. 최종 등급과 출고 여부는 점주가 확정합니다.',
          ),
          const GridCards(
            children: [
              MetricCard(
                icon: Icons.workspace_premium_outlined,
                value: 'A',
                label: '추천 등급',
              ),
              MetricCard(
                icon: Icons.monitor_heart_outlined,
                value: '91점',
                label: '신선도',
              ),
            ],
          ),
          const DataTile(
            icon: Icons.check_circle_outline,
            title: '멍 가능성 낮음',
            subtitle: '색상과 둥근 정도가 출고 기준을 충족합니다.',
            badge: '통과',
            badgeColor: AppColors.mint,
          ),
        ],
      ),
    );
  }
}

class _GalleryPicker extends StatefulWidget {
  const _GalleryPicker();

  @override
  State<_GalleryPicker> createState() => _GalleryPickerState();
}

class _GalleryPickerState extends State<_GalleryPicker> {
  _GalleryImage selected = _GalleryImage.images.first;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SectionHeader(title: '갤러리'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (final image in _GalleryImage.images)
                  InkWell(
                    onTap: () => setState(() => selected = image),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected == image
                            ? AppColors.mint
                            : Colors.white,
                        border: Border.all(
                          color: selected == image
                              ? AppColors.green
                              : AppColors.line,
                          width: selected == image ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(image.icon, size: 42, color: AppColors.green),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryAction(
              label: '선택',
              onPressed: () => Navigator.of(context).pop(selected),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryImage {
  final IconData icon;
  final String label;

  const _GalleryImage(this.icon, this.label);

  static const images = [
    _GalleryImage(Icons.local_florist, '사과 정면'),
    _GalleryImage(Icons.eco_outlined, '색상 확인'),
    _GalleryImage(Icons.spa_outlined, '표면 확대'),
    _GalleryImage(Icons.grass_outlined, '꼭지 확인'),
    _GalleryImage(Icons.yard_outlined, '상처 확인'),
    _GalleryImage(Icons.filter_vintage_outlined, '샘플 컷'),
  ];
}
