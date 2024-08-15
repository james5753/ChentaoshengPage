import 'package:flutter/material.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'package:wonders/ui/common/themed_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;

class TimelineEventCard extends StatelessWidget {
  const TimelineEventCard({super.key, required this.year, required this.text, this.darkMode = false});
  final int year;
  final String text;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.only(bottom: $styles.insets.sm),
        child: DefaultTextColor(
          color: darkMode ? Colors.white : Colors.black,
          child: Container(
            color: darkMode ? $styles.colors.greyStrong : $styles.colors.offWhite,
            padding: EdgeInsets.all($styles.insets.sm),
            child: IntrinsicHeight(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate text height
                  final textPainter = TextPainter(
                    text: TextSpan(text: text, style: $styles.text.body),
                    maxLines: null,
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: constraints.maxWidth - 70 - $styles.insets.sm - 1);

                  return Row(
                    children: [
                      /// Date
                      SizedBox(
                        width: 70,
                        child: Padding(
                          padding: EdgeInsets.only(left: defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS?12.0:0.0), // 增加左侧填充
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (int i = 0; i < year.abs().toString().length; i += 2)
                                              Text(
                                                year.abs().toString().substring(i, i + 2),
                                                style: $styles.text.h3.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  height: 0.8,
                                                ),
                                              ),
                                          ],
                                        )
                                      : Text(
                                          '${year.abs()}',
                                          style: $styles.text.h3.copyWith(
                                            fontWeight: FontWeight.w400,
                                            height: 0.8,
                                          ),
                                        ),
                                ),
                              ),
                              ///Text(StringUtils.getYrSuffix(year), style: $styles.text.bodySmall),
                            ],
                          ),
                        ),
                      ),
                      /// Divider
                      Container(width: 1, color: darkMode ? Colors.white : $styles.colors.black),

                      Gap($styles.insets.s),

                      /// Text content
                      Expanded(
                        child: kIsWeb
                            ? Text(
                                text,
                                style: $styles.text.body.copyWith(
                                  height: 1.5, // 修改行间距
                                ),
                              )
                            : (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)
                                ? SingleChildScrollView(
                                    child: Text(
                                      text,
                                      style: $styles.text.bodySmall.copyWith(
                                        height: 1.3, // 修改行间距
                                      ),
                                    ),
                                  )
                                : Text(
                                    text,
                                    style: $styles.text.body.copyWith(
                                      height: 1.5, // 修改行间距
                                    ),
                                  ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}