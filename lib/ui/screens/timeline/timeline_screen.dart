import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/debouncer.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'package:wonders/logic/data/timeline_data.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/ui/common/blend_mask.dart';
import 'package:wonders/ui/common/centered_box.dart';
import 'package:wonders/ui/common/controls/app_header.dart';
import 'package:wonders/ui/common/dashed_line.dart';
import 'package:wonders/ui/common/list_gradient.dart';
import 'package:wonders/ui/common/timeline_event_card.dart';
import 'package:wonders/ui/common/utils/app_haptics.dart';
import 'package:wonders/ui/common/wonders_timeline_builder.dart';
import 'package:wonders/ui/screens/home_menu/home_menu.dart';
import 'package:wonders/logic/data/wonders_data/great_wall_data.dart';

part 'widgets/_animated_era_text.dart';
part 'widgets/_bottom_scrubber.dart';
part 'widgets/_dashed_divider_with_year.dart';
part 'widgets/_event_markers.dart';
part 'widgets/_event_popups.dart';
part 'widgets/_scrolling_viewport.dart';
part 'widgets/_scrolling_viewport_controller.dart';
part 'widgets/_timeline_section.dart';
part 'widgets/_year_markers.dart';

class TimelineScreen extends StatefulWidget {
  //final WonderType? type;

  const TimelineScreen({super.key/*, required this.type*/});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  /// Create a scroll controller that the top and bottom timelines can share
  final ScrollController _scroller = ScrollController();
  final _year = ValueNotifier<int>(0);

  void _handleViewportYearChanged(int value) => _year.value = value;

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body:LayoutBuilder(builder: (_, constraints) {
    // Determine min and max size of the timeline based on the size available to this widget
    const double scrubberSize = 80;
    const double minSize = 1200;
    const double maxSize = 5500;
    return Container(
      color: $styles.colors.black,
      child: Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: Column(
          children: [
            Stack(
              children: [
                AppHeader(
                  title: $strings.timelineTitleGlobalTimeline,
                ),
                 Positioned(
                right: 40,
                top: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // 设置背景颜色和透明度
                    shape: BoxShape.circle, // 设置圆形背景
                  ),
                  child: IconButton(
                    icon: Icon(Icons.menu, color: Colors.white), // 设置图标颜色为白色以便在黑色背景上可见
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => HomeMenu(data: GreatWallData()),
                      );
                    },
                  ),
                ),
              ),
              ],
            ),

            /// Vertically scrolling timeline, manages a ScrollController.
            
            Expanded(
              child: _ScrollingViewport(
                scroller: _scroller,
                minSize: maxSize,
                maxSize: maxSize,
                // selectedWonder: widget.type,
                onYearChanged: _handleViewportYearChanged,
              ),
            ),

            /// Mini Horizontal timeline, reacts to the state of the larger scrolling timeline,
            /// and changes the timelines scroll position on Hz drag
            Transform.translate(
              offset: Offset(0, 0), // 设置偏移量，(20, 0) 表示向右偏移 20 像素
              child: CenteredBox(
                width: $styles.sizes.maxContentWidth1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: $styles.insets.lg),
                  child: _BottomScrubber(
                    _scroller,
                    size: scrubberSize,
                    timelineMinSize: minSize,
                    // selectedWonder: widget.type,
                  ),
                ),
              ),
            ),
            Gap($styles.insets.lg),
          ],
        ),
      ),
    );
  })
  );
}
}
