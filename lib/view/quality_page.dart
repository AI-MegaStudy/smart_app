import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class QualityPage extends StatelessWidget {
  const QualityPage({super.key});

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
          onPressed: () => showOwnerSnack(context, '촬영 이미지를 선택합니다.'),
        ),
        children: const [
          CameraPreviewCard(),
          NoticeBox(
            color: AppColors.blue,
            text: '판별 결과는 선별 보조 자료입니다. 최종 등급과 출고 여부는 점주가 확정합니다.',
          ),
          GridCards(
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
          DataTile(
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
