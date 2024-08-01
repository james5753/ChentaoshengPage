part of '../timeline_screen.dart';

class _EventPopups extends StatefulWidget {
  const _EventPopups({super.key, required this.currentEvent});
  final TimelineEvent? currentEvent;

  @override
  State<_EventPopups> createState() => _EventPopupsState();
}

class DynamicCharsPerLineCalculator {
  final TextStyle textStyle;
  final double maxWidth;

  DynamicCharsPerLineCalculator({required this.textStyle, required this.maxWidth});

  int calculateCharsPerLine() {
    // 假设一个字符的宽度
    const String sampleText = '你';
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: sampleText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    // 获取一个字符的宽度
    final double charWidth = textPainter.size.width;

    // 计算每行可以容纳的字符数
    return (maxWidth / charWidth).floor();
  }
}

class _EventPopupsState extends State<_EventPopups> {
  final _debouncer = Debouncer(500.ms);
  TimelineEvent? _eventToShow;

  @override
  void dispose() {
    _debouncer.reset();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _EventPopups oldWidget) {
    super.didUpdateWidget(oldWidget);
    _debouncer.call(showCardForCurrentYr);
  }

  void showCardForCurrentYr() {
    setState(() {
      _eventToShow = widget.currentEvent;
    });
  }

  @override
Widget build(BuildContext context) {
  final evt = _eventToShow;
  if (evt == null) {
    return TopCenter(
      child: SizedBox.shrink(),
    );
  }

  // 使用 TextPainter 测量文本尺寸
  final textPainter = TextPainter(
    text: TextSpan(
      text: evt.description,
      style: DefaultTextStyle.of(context).style,
    ),
    textDirection: TextDirection.ltr,
    maxLines: null,
  )..layout(maxWidth: $styles.sizes.maxContentWidth1);

  // 根据文本尺寸设置宽度和高度
  //const int charsPerLine = 34;
  final textStyle = TextStyle(fontSize: 16.0);
  final double maxWidth = MediaQuery.of(context).size.width<800? MediaQuery.of(context).size.width*0.8: 560; 

  final calculator = DynamicCharsPerLineCalculator(textStyle: textStyle, maxWidth: maxWidth);
  final charsPerLine = calculator.calculateCharsPerLine()>34? 34: calculator.calculateCharsPerLine();
  final int lineCount = (evt.description.length / charsPerLine).ceil();
  final width = $styles.sizes.maxContentWidth1;
  //final height = 50 + textPainter.size.height.ceil()*2.8 + $styles.insets.md * 2.5;
  final height = 110.0 + lineCount *  32 ;

  return TopCenter(
    child: ClipRect(
      child: IgnorePointer(
        ignoringSemantics: false,
        child: AnimatedSwitcher(
          duration: $styles.times.fast,
          child: Semantics(
            liveRegion: true,
            child: Animate(
              effects: const [
                SlideEffect(begin: Offset(0, -.1)),
              ],
              key: ValueKey(_eventToShow?.year),
              child: IntrinsicHeight(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Padding(
                    padding: EdgeInsets.all($styles.insets.md),
                    child: TimelineEventCard(
                      text: evt.description,
                      year: evt.year,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}