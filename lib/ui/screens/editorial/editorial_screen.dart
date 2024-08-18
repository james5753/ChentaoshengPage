import 'dart:async';

import 'package:drop_cap_text/drop_cap_text.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_circular_text/circular_text.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/platform_info.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/ui/common/app_icons.dart';
import 'package:wonders/ui/common/blend_mask.dart';
import 'package:wonders/ui/common/centered_box.dart';
import 'package:wonders/ui/common/compass_divider.dart';
import 'package:wonders/ui/common/curved_clippers.dart';
import 'package:wonders/ui/common/fullscreen_keyboard_list_scroller.dart';
import 'package:wonders/ui/common/google_maps_marker.dart';
import 'package:wonders/ui/common/gradient_container.dart';
import 'package:wonders/ui/common/hidden_collectible.dart';
import 'package:wonders/ui/common/pop_router_on_over_scroll.dart';
import 'package:wonders/ui/common/scaling_list_item.dart';
import 'package:wonders/ui/common/static_text_scale.dart';
import 'package:wonders/ui/common/themed_text.dart';
import 'package:wonders/ui/common/utils/context_utils.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration_config.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_title_text.dart';
import 'package:wonders/ui/screens/home/wonders_home_screen.dart';

part 'widgets/_app_bar.dart';
part 'widgets/_callout.dart';
part 'widgets/_circular_title_bar.dart';
part 'widgets/_collapsing_pull_quote_image.dart';
part 'widgets/_large_simple_quote.dart';
part 'widgets/_scrolling_content.dart';
part 'widgets/_section_divider.dart';
part 'widgets/_sliding_image_stack.dart';
part 'widgets/_title_text.dart';
part 'widgets/_top_illustration.dart';

class WonderEditorialScreen extends StatefulWidget {
  const WonderEditorialScreen(this.data, {super.key, required this.contentPadding});
  final WonderData data;
  final EdgeInsets contentPadding;

  @override
  State<WonderEditorialScreen> createState() => _WonderEditorialScreenState();
}

class _WonderEditorialScreenState extends State<WonderEditorialScreen> {
  late final ScrollController _scroller = ScrollController()..addListener(_handleScrollChanged);
  final _scrollPos = ValueNotifier(0.0);
  final _sectionIndex = ValueNotifier(0);

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  /// Various [ValueListenableBuilders] are mapped to the _scrollPos and will rebuild when it changes
  void _handleScrollChanged() {
    _scrollPos.value = _scroller.position.pixels;
  }

  void _handleBackPressed() => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => HomeScreen()),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      bool shortMode = constraints.biggest.height < 700;
      double illustrationHeight = shortMode ? 250 : 280;
      double minAppBarHeight = shortMode ? 80 : 150;
      double maxAppBarHeight = min(context.widthPx, $styles.sizes.maxContentWidth1) * 1.2;

      return PopRouterOnOverScroll(
        controller: _scroller,
        child: ColoredBox(
          color: $styles.colors.offWhite,
          child: Stack(
            children: [
              /// Background
              Positioned.fill(
                child: ColoredBox(color: widget.data.type.bgColor),
              ),

              /// Top Illustration - Sits underneath the scrolling content
              SizedBox(
                height: illustrationHeight,
                child: ValueListenableBuilder<double>(
                  valueListenable: _scrollPos,
                  builder: (_, value, child) {
                    double opacity = (1 - value / 700).clamp(0, 1);
                    return Opacity(opacity: opacity, child: child);
                  },
                  child: RepaintBoundary(
                    child: _TopIllustration(
                      widget.data.type,
                      fgOffset: Offset(widget.contentPadding.left / 2, 0),
                    ),
                  ),
                ),
              ),

              /// Scrolling content
              TopCenter(
                child: Padding(
                  padding: widget.contentPadding,
                  child: SizedBox(
                    child: FocusTraversalGroup(
                      child: FullscreenKeyboardListScroller(
                        scrollController: _scroller,
                        child: CustomScrollView(
                          controller: _scroller,
                          scrollBehavior: ScrollConfiguration.of(context).copyWith(),
                          key: PageStorageKey('editorial'),
                          slivers: [
                            SliverToBoxAdapter(
                              child: SizedBox(height: illustrationHeight),
                            ),
                            SliverToBoxAdapter(
                              child: ValueListenableBuilder<double>(
                                valueListenable: _scrollPos,
                                builder: (_, value, child) {
                                  double offsetAmt = max(0, value * .3);
                                  double opacity = (1 - offsetAmt / 150).clamp(0, 1);
                                  return Transform.translate(
                                    offset: Offset(0, offsetAmt),
                                    child: Opacity(opacity: opacity, child: child),
                                  );
                                },
                                child: _TitleText(widget.data, scroller: _scroller),
                              ),
                            ),
                            SliverAppBar(
                              pinned: true,
                              collapsedHeight: minAppBarHeight,
                              toolbarHeight: minAppBarHeight,
                              expandedHeight: maxAppBarHeight,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              leading: SizedBox.shrink(),
                              flexibleSpace: SizedBox.expand(
                                child: _AppBar(
                                  widget.data.type,
                                  scrollPos: _scrollPos,
                                  sectionIndex: _sectionIndex,
                                ),
                              ),
                            ),
                            _ScrollingContent(widget.data, scrollPos: _scrollPos, sectionNotifier: _sectionIndex),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Back Button - Always visible in the top left corner
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all($styles.insets.sm),
                  child: BackBtn(icon: AppIcons.north, onPressed: _handleBackPressed),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
