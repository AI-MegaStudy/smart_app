import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/util/app_colors.dart';

void showOwnerSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

Future<void> showConfirmAction({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = '확인',
  required VoidCallback onConfirm,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    onConfirm();
  }
}

String objectParticle(String text) {
  if (text.isEmpty) {
    return '을';
  }
  final code = text.characters.last.runes.first;
  if (code < 0xAC00 || code > 0xD7A3) {
    return '을';
  }
  return (code - 0xAC00) % 28 == 0 ? '를' : '을';
}

String requiredMessage(String label) => '$label${objectParticle(label)} 입력하세요.';

String selectMessage(String label) => '$label${objectParticle(label)} 선택하세요.';

class AppScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> children;

  const AppScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 14)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
          SliverList.separated(
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: children[index],
            ),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemCount: children.length,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class HeroPanel extends StatelessWidget {
  final String eyebrow;
  final String title;
  final IconData icon;
  final bool compact;
  final double? height;

  const HeroPanel({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.icon,
    this.compact = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 176,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 4,
            bottom: -10,
            child: Icon(
              icon,
              size: compact ? 112 : 132,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 28 : 26,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GridCards extends StatelessWidget {
  final List<Widget> children;

  const GridCards({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: constraints.maxWidth > 520 ? 4 : 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.22,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.text, size: 24),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final VoidCallback? onTap;

  const DataTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusBadge(text: badge, color: badgeColor),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.green,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;

  const SectionHeader({super.key, required this.title, this.actionText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionText != null)
          Text(
            actionText!,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class LabeledField extends StatelessWidget {
  final String label;
  final String value;
  final String? hintText;
  final bool enabled;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  const LabeledField({
    super.key,
    required this.label,
    required this.value,
    this.hintText,
    this.enabled = true,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator:
              validator ??
              (enabled
                  ? (text) {
                      if ((text ?? '').trim().isEmpty) {
                        return requiredMessage(label);
                      }
                      return null;
                    }
                  : null),
          decoration: InputDecoration(
            hintText: hintText ?? '$label 입력 규칙에 맞게 작성하세요.',
          ),
        ),
      ],
    );
  }
}

class LabeledBox extends StatelessWidget {
  final String label;
  final String value;
  final String? hintText;
  final bool enabled;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  const LabeledBox({
    super.key,
    required this.label,
    required this.value,
    this.hintText,
    this.enabled = true,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          enabled: enabled,
          minLines: 3,
          maxLines: 4,
          validator:
              validator ??
              (enabled
                  ? (text) {
                      if ((text ?? '').trim().isEmpty) {
                        return requiredMessage(label);
                      }
                      return null;
                    }
                  : null),
          decoration: InputDecoration(
            hintText: hintText ?? '$label 내용을 입력하세요.',
          ),
        ),
      ],
    );
  }
}

class LabeledDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          menuMaxHeight: kMinInteractiveDimension * 5,
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: onChanged,
          validator: (text) {
            if ((text ?? '').trim().isEmpty) {
              return selectMessage(label);
            }
            return null;
          },
          decoration: InputDecoration(hintText: hintText ?? '$label을 선택하세요.'),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class NoticeBox extends StatelessWidget {
  final Color color;
  final String text;

  const NoticeBox({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w900,
          height: 1.45,
        ),
      ),
    );
  }
}

class ChipRow extends StatelessWidget {
  final List<String> labels;

  const ChipRow({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return _SelectableChipRow(labels: labels);
  }
}

class _SelectableChipRow extends StatefulWidget {
  final List<String> labels;

  const _SelectableChipRow({required this.labels});

  @override
  State<_SelectableChipRow> createState() => _SelectableChipRowState();
}

class _SelectableChipRowState extends State<_SelectableChipRow> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < widget.labels.length; i++) ...[
            ChoiceChip(
              selected: selectedIndex == i,
              label: Text(widget.labels[i]),
              showCheckmark: true,
              checkmarkColor: Colors.white,
              selectedColor: AppColors.green,
              labelStyle: TextStyle(
                color: selectedIndex == i ? Colors.white : AppColors.muted,
                fontWeight: FontWeight.w900,
              ),
              onSelected: (_) {
                setState(() {
                  selectedIndex = i;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class FilterTabs extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const FilterTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final label in labels) ...[
            ChoiceChip(
              selected: selected == label,
              label: Text(label),
              showCheckmark: true,
              checkmarkColor: Colors.white,
              selectedColor: AppColors.green,
              labelStyle: TextStyle(
                color: selected == label ? Colors.white : AppColors.muted,
                fontWeight: FontWeight.w900,
              ),
              onSelected: (_) => onChanged(label),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class ActionChipIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const ActionChipIcon({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        backgroundColor: AppColors.mint,
        foregroundColor: AppColors.green,
      ),
      onPressed: onPressed ?? () {},
      icon: Icon(icon),
    );
  }
}

class ActionChipText extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const ActionChipText({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed ?? () {},
      icon: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class DualActionBar extends StatelessWidget {
  final String left;
  final String right;
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;

  const DualActionBar({
    super.key,
    required this.left,
    required this.right,
    this.onLeftPressed,
    this.onRightPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.tonal(
              onPressed: onLeftPressed ?? () {},
              child: Text(left),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: onRightPressed ?? () {},
              child: Text(right),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryAction({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: FilledButton(onPressed: onPressed ?? () {}, child: Text(label)),
    );
  }
}

class YieldChart extends StatelessWidget {
  const YieldChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          _Bar(height: 54),
          _Bar(height: 74),
          _Bar(height: 94),
          _Bar(height: 82),
          _Bar(height: 62),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;

  const _Bar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.green, AppColors.mint],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
      ),
    );
  }
}

class CameraPreviewCard extends StatelessWidget {
  final IconData icon;
  final String? label;

  const CameraPreviewCard({
    super.key,
    this.icon = Icons.local_florist,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xffB64033), Color(0xffF1B095)],
        ),
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, color: Colors.white, size: 92)),
          if (label != null)
            Positioned(
              left: 16,
              top: 16,
              child: StatusBadge(text: label!, color: Colors.white),
            ),
          Center(
            child: Container(
              width: 166,
              height: 116,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, 18),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashTextInputFormatter extends TextInputFormatter {
  final List<int> groups;

  const DashTextInputFormatter(this.groups);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    var offset = 0;
    for (final size in groups) {
      if (offset >= digits.length) {
        break;
      }
      final end = (offset + size).clamp(0, digits.length);
      if (buffer.isNotEmpty) {
        buffer.write('-');
      }
      buffer.write(digits.substring(offset, end));
      offset = end;
    }
    if (offset < digits.length) {
      if (buffer.isNotEmpty) {
        buffer.write('-');
      }
      buffer.write(digits.substring(offset));
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
