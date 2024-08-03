part of '../timeline_screen.dart';

class _EventPopups extends StatefulWidget {
  const _EventPopups({super.key, required this.currentEvent});
  final TimelineEvent? currentEvent;

  @override
  State<_EventPopups> createState() => _EventPopupsState();
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
  final width = $styles.sizes.maxContentWidth1;
  final height = 50 +textPainter.size.height*2 + $styles.insets.md * 3;

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