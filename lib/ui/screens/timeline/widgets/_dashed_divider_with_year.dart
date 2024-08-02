part of '../timeline_screen.dart';

class _DashedDividerWithYear extends StatelessWidget {
  const _DashedDividerWithYear(this.year, {super.key});
  final int year;

  @override
  Widget build(BuildContext context) {
    int yrGap = 1;
    final roundedYr = (year / yrGap).round() * yrGap;
    return Stack(
      children: [
        Center(child: DashedLine()),
        CenterRight(
          child: FractionalTranslation(
            translation: Offset(0, -.5),
            child: MergeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${roundedYr.abs()}',
                    style: $styles.text.h2.copyWith(color: $styles.colors.white, shadows: $styles.shadows.text),
                  ),
                  Gap($styles.insets.xs),
                  Text(
                    StringUtils.getYrSuffix(roundedYr),
                    style: $styles.text.body.copyWith(
                      color: Colors.white,
                      shadows: $styles.shadows.textStrong,
                    ),
                  ),
                  Gap($styles.insets.xs),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
