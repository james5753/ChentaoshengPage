import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/wonders_data/great_wall_data.dart';
import 'package:wonders/ui/common/search_page.dart';
import 'package:wonders/ui/common/lazy_indexed_stack.dart';
import 'package:wonders/ui/common/measurable_widget.dart';
import 'package:wonders/ui/screens/artifact/artifact_carousel/artifact_carousel_screen.dart';
import 'package:wonders/ui/screens/collection/collection_screen.dart';
import 'package:wonders/ui/screens/editorial/editorial_screen.dart';
import 'package:wonders/ui/screens/photo_gallery/photo_gallery.dart';
import 'package:wonders/ui/screens/wonder_details/wonder_details_tab_menu.dart';
import 'package:wonders/ui/screens/wonder_events/wonder_events.dart';
import 'package:wonders/ui/screens/timeline/timeline_screen.dart';
import 'package:wonders/ui/common/chat_page.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/ui/common/app_icons.dart';
import 'package:wonders/ui/common/controls/app_header.dart';
import 'package:wonders/ui/common/controls/app_page_indicator.dart';
import 'package:wonders/ui/common/gradient_container.dart';
import 'package:wonders/ui/common/previous_next_navigation.dart';
import 'package:wonders/ui/common/themed_text.dart';
import 'package:wonders/ui/common/utils/app_haptics.dart';
import 'package:wonders/ui/screens/home_menu/home_menu.dart';
import 'package:wonders/ui/wonder_illustrations/common/animated_clouds.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration_config.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_title_text.dart';
import 'package:wonders/ui/screens/wonder_details/wonder_details_tab_menu.dart';
part '_vertical_swipe_controller.dart';
part 'widgets/_animated_arrow_button.dart';
class HomeScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  HomeScreen({super.key, this.tabIndex = 0});
  final int tabIndex;

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> with GetItStateMixin, SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 7,
    vsync: this,
    initialIndex: _clampIndex(widget.tabIndex),
  )..addListener(_handleTabChanged);

  double? _tabBarSize;
  bool _useNavRail = false;

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    if (oldWidget.tabIndex != widget.tabIndex) {
      _tabController.index = _clampIndex(widget.tabIndex);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _clampIndex(int index) => index.clamp(0, 7);

  void _handleTabChanged() {
    setState(() {});
  }

  void _handleTabTapped(int index) {
    setState(() {
      _tabController.index = index;
    });
  }

  void _handleTabMenuSized(Size size) {
    setState(() {
      _tabBarSize = (_useNavRail ? size.width : size.height) - WonderDetailsTabMenu.buttonInset;
    });
  }

  @override
  Widget build(BuildContext context) {
    _useNavRail = true; // 设置为false以使用水平导航栏

    final tabBarSize = _tabBarSize ?? 0;
    final menuPadding = _useNavRail ? EdgeInsets.only(left: tabBarSize) : EdgeInsets.only(bottom: tabBarSize);
    return Scaffold(
      body: ColoredBox(
        color: Colors.white,
        child: Stack(
          children: [
            /// Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/christ_the_redeemer/3.0x/photo-4.jpg', // 添加你的图片路径
                fit: BoxFit.none,//更改适配
              ),
            ),

            /// Fullscreen tab views
            LazyIndexedStack(
              index: _tabController.index,
              children: [
                FirstScreen(),//首页
                MyHomePage(),//检索
//                Center(child: Text('资源IIIF')),
                TimelineScreen(),//年表
                ChatPage(),//chat
                MapScreen(),//gis
                Center(child: Text('图谱')),
                Center(child: Text('介绍')),//团队介绍
              ],
            ),

            /// Tab menu
            Align(
              alignment: _useNavRail ? Alignment.centerLeft : Alignment.centerLeft,
              child: MeasurableWidget(
                onChange: _handleTabMenuSized,
                child: WonderDetailsTabMenu(
                  tabController: _tabController,
                  onTap: _handleTabTapped,
                  showBg: true,
                  axis: _useNavRail ? Axis.vertical : Axis.vertical,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FirstScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

// class FirstPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Home')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.pushNamed(context, '/chat');
//           },
//           child: Text('Go to Chat'),
//         ),
//       ),
//     );
//   }
// }

/// Shows a horizontally scrollable list PageView sandwiched between Foreground and Background layers
/// arranged in a parallax style.
class _FirstScreenState extends State<FirstScreen> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  List<WonderData> get _wonders => wondersLogic.all;
  bool _isMenuOpen = false;

  /// Set initial wonderIndex
  late int _wonderIndex = 0;
  int get _numWonders => _wonders.length;

  /// Used to polish the transition when leaving this page for the details view.
  /// Used to capture the _swipeAmt at the time of transition, and freeze the wonder foreground in place as we transition away.
  double? _swipeOverride;

  /// Used to let the foreground fade in when this view is returned to (from details)
  bool _fadeInOnNextBuild = false;

  /// All of the items that should fade in when returning from details view.
  /// Using individual tweens is more efficient than tween the entire parent
  final _fadeAnims = <AnimationController>[];

  WonderData get currentWonder => _wonders[_wonderIndex];

  late final _VerticalSwipeController _swipeController = _VerticalSwipeController(this, _showDetailsPage);

  bool _isSelected(WonderType t) => t == currentWonder.type;

  @override
  void initState() {
    super.initState();
    // Load previously saved wonderIndex if we have one
    _wonderIndex = settingsLogic.prevWonderIndex.value ?? 0;
    // allow 'infinite' scrolling by starting at a very high page number, add wonderIndex to start on the correct page
    final initialPage = _numWonders * 100 + _wonderIndex;
    // Create page controller,
    _pageController = PageController(viewportFraction: 1, initialPage: initialPage);
  }

  //void _handlePageChanged(value) {
    // final newIndex = value % _numWonders;
    // if (newIndex == _wonderIndex) {
    //   return; // Exit early if we're already on this page
    // }
    // setState(() {
    //   _wonderIndex = newIndex;
    //   settingsLogic.prevWonderIndex.value = _wonderIndex;
    // });
    // AppHaptics.lightImpact();
  //}

  // void _handleOpenMenuPressed() async {
  //   setState(() => _isMenuOpen = true);
  //   WonderType? pickedWonder = await appLogic.showFullscreenDialogRoute<WonderType>(
  //     context,
  //     HomeMenu(data: currentWonder),
  //     transparent: true,
  //   );
  //   setState(() => _isMenuOpen = false);
  //   if (pickedWonder != null) {
  //     _setPageIndex(_wonders.indexWhere((w) => w.type == pickedWonder));
  //   }
  // }

  void _handleFadeAnimInit(AnimationController controller) {
    _fadeAnims.add(controller);
    controller.value = 1;
  }

  void _handlePageIndicatorDotPressed(int index) => _setPageIndex(index);

  //void _handlePrevNext(int i) => _setPageIndex(_wonderIndex + i, animate: true);

  void _setPageIndex(int index, {bool animate = false}) {
    if (index == _wonderIndex) return;
    // To support infinite scrolling, we can't jump directly to the pressed index. Instead, make it relative to our current position.
    final pos = ((_pageController.page ?? 0) / _numWonders).floor() * _numWonders;
    final newIndex = pos + index;
    if (animate == true) {
      _pageController.animateToPage(newIndex, duration: $styles.times.med, curve: Curves.easeOutCubic);
    } else {
      _pageController.jumpToPage(newIndex);
    }
  }

  void _showDetailsPage() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WonderEditorialScreen(
          GreatWallData(),
          contentPadding: EdgeInsets.all(16.0), // 根据需要设置 contentPadding
        ),
      ),
    );
  }

  void _startDelayedFgFade() async {
    try {
      for (var a in _fadeAnims) {
        a.value = 0;
      }
      await Future.delayed(300.ms);
      for (var a in _fadeAnims) {
        a.forward();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fadeInOnNextBuild == true) {
      _startDelayedFgFade();
      _fadeInOnNextBuild = false;
    }

    return _swipeController.wrapGestureDetector(Container(
      color: $styles.colors.black,
      //child: PreviousNextNavigation(
        //listenToMouseWheel: false,
        //onPreviousPressed: () => _handlePrevNext(-1),
        //onNextPressed: () => _handlePrevNext(1),
        child: Stack(
          children: [
            /// Background
            ..._buildBgAndClouds(),

            /// Wonders Illustrations (main content)
            _buildMgPageView(),

            /// Foreground illustrations and gradients
            _buildFgAndGradients(),

            /// Controls that float on top of the various illustrations
            _buildFloatingUi(),
          ],
        ).animate().fadeIn(),
      //),
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  Widget _buildMgPageView() {
    return ExcludeSemantics(
      child: PageView.builder(
        controller: _pageController,
        //onPageChanged: _handlePageChanged,
        itemBuilder: (_, index) {
          final wonder = _wonders[index % _wonders.length];
          final wonderType = wonder.type;
          bool isShowing = _isSelected(wonderType);
          return _swipeController.buildListener(
            builder: (swipeAmt, _, child) {
              final config = WonderIllustrationConfig.mg(
                isShowing: isShowing,
                zoom: .05 * swipeAmt,
              );
              return WonderIllustration(wonderType, config: config);
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildBgAndClouds() {
    return [
      // Background
      ..._wonders.map((e) {
        final config = WonderIllustrationConfig.bg(isShowing: _isSelected(e.type));
        return WonderIllustration(e.type, config: config);
      }),
      // Clouds
      // FractionallySizedBox(
      //   widthFactor: 1,
      //   heightFactor: .5,
      //   child: AnimatedClouds(wonderType: currentWonder.type, opacity: 1),
      // )
    ];
  }

  Widget _buildFgAndGradients() {
    Widget buildSwipeableBgGradient(Color fgColor) {
      return _swipeController.buildListener(builder: (swipeAmt, isPointerDown, _) {
        return IgnorePointer(
          child: FractionallySizedBox(
            heightFactor: .6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fgColor.withOpacity(0),
                    fgColor.withOpacity(.5 + fgColor.opacity * .25 + (isPointerDown ? .05 : 0) + swipeAmt * .20),
                  ],
                  stops: const [0, 1],
                ),
              ),
            ),
          ),
        );
      });
    }

    final gradientColor = currentWonder.type.bgColor;
    return Stack(children: [
      /// Foreground gradient-1, gets darker when swiping up
      BottomCenter(
        child: buildSwipeableBgGradient(gradientColor.withOpacity(.5)),
      ),

      /// Foreground decorators
      ..._wonders.map((e) {
        return _swipeController.buildListener(builder: (swipeAmt, _, child) {
          final config = WonderIllustrationConfig.fg(
            isShowing: _isSelected(e.type),
            zoom: .4 * (_swipeOverride ?? swipeAmt),
          );
          return Animate(
              effects: const [FadeEffect()],
              onPlay: _handleFadeAnimInit,
              child: IgnorePointer(child: WonderIllustration(e.type, config: config)));
        });
      }),

      /// Foreground gradient-2, gets darker when swiping up
      BottomCenter(
        child: buildSwipeableBgGradient(gradientColor),
      ),
    ]);
  }

  Widget _buildFloatingUi() {
    return Stack(children: [
      /// Floating controls / UI
      AnimatedSwitcher(
        duration: $styles.times.fast,
        child: AnimatedOpacity(
          opacity: _isMenuOpen ? 0 : 1,
          duration: $styles.times.med,
          child: RepaintBoundary(
            child: OverflowBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: double.infinity),
                  const Spacer(),

                  /// Title Content
                  LightText(
                    child: IgnorePointer(
                      ignoringSemantics: false,
                      child: Transform.translate(
                        offset: Offset(0, 30),
                        child: Column(
                          children: [
                            Semantics(
                              liveRegion: false,
                              button: true,
                              header: true,
                              // onIncrease: () => _setPageIndex(_wonderIndex + 1),
                              // onDecrease: () => _setPageIndex(_wonderIndex - 1),
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => WonderEditorialScreen(
                                      GreatWallData(),
                                      contentPadding: EdgeInsets.all(16.0), // 根据需要设置 contentPadding
                                    ),
                                  ),
                                ),
                              // Hide the title when the menu is open for visual polish
                              child: Padding(
                                padding: const EdgeInsets.only(left: 30.0), // 设置左边的填充
                                child: WonderTitleText(currentWonder, enableShadows: true),
                              ),
                            ),
                            Gap($styles.insets.md),
                            // AppPageIndicator(
                            //   count: _numWonders,
                            //   controller: _pageController,
                            //   color: $styles.colors.white,
                            //   dotSize: 8,
                            //   onDotPressed: _handlePageIndicatorDotPressed,
                            //   semanticPageTitle: $strings.homeSemanticWonder,
                            // ),
                            Gap($styles.insets.md),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Animated arrow and background
                  /// Wrap in a container that is full-width to make it easier to find for screen readers
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,

                    /// Lose state of child objects when index changes, this will re-run all the animated switcher and the arrow anim
                    key: ValueKey(_wonderIndex),
                    child: Stack(
                      children: [
                        /// Expanding rounded rect that grows in height as user swipes up
                        // Positioned.fill(
                        //     child: _swipeController.buildListener(
                        //   builder: (swipeAmt, _, child) {
                        //     double heightFactor = .5 + .5 * (1 + swipeAmt * 4);
                        //     return FractionallySizedBox(
                        //       alignment: Alignment.bottomCenter,
                        //       heightFactor: heightFactor,
                        //       child: Opacity(opacity: swipeAmt * .5, child: child),
                        //     );
                        //   },
                        //   child: VtGradient(
                        //     [$styles.colors.white.withOpacity(0), $styles.colors.white.withOpacity(1)],
                        //     const [.3, 1],
                        //     borderRadius: BorderRadius.circular(99),
                        //   ),
                        // )),

                        /// Arrow Btn that fades in and out
                        _AnimatedArrowButton(onTap: _showDetailsPage, semanticTitle: currentWonder.title),
                      ],
                    ),
                  ),
                  Gap($styles.insets.md),
                ],
              ),
            ),
          ),
        ),
      ),

      /// Menu Btn
      // TopLeft(
      //   child: AnimatedOpacity(
      //     duration: $styles.times.fast,
      //     opacity: _isMenuOpen ? 0 : 1,
      //     child: AppHeader(
      //       backIcon: AppIcons.menu,
      //       backBtnSemantics: $strings.homeSemanticOpenMain,
      //       onBack: _handleOpenMenuPressed,
      //       isTransparent: true,
      //     ),
      //   ),
      // ),
    ]);
  }
//   Widget _buildFloatingUi() {
//   return GestureDetector(
//     onVerticalDragUpdate: (details) {
//       if (details.primaryDelta! < -1) {
//         // 向上滑动超过一定距离，导航到 WonderEditorialScreen 页面
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => WonderEditorialScreen(
//               GreatWallData(),
//               contentPadding: EdgeInsets.all(16.0), // 根据需要设置 contentPadding
//             ),
//           ),
//         );
//       }
//     },
//     child: Stack(
//       children: [
//         /// Floating controls / UI
//         AnimatedSwitcher(
//           duration: $styles.times.fast,
//           child: AnimatedOpacity(
//             opacity: _isMenuOpen ? 0 : 1,
//             duration: $styles.times.med,
//             child: RepaintBoundary(
//               child: OverflowBox(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(width: double.infinity),
//                     const Spacer(),

//                     /// Title Content
//                     LightText(
//                       child: IgnorePointer(
//                         ignoringSemantics: false,
//                         child: Transform.translate(
//                           offset: Offset(0, 30),
//                           child: Column(
//                             children: [
//                               Semantics(
//                                 liveRegion: false,
//                                 button: true,
//                                 header: true,
//                                 onTap: () => Navigator.of(context).push(
//                                   MaterialPageRoute(
//                                     builder: (context) => WonderEditorialScreen(
//                                       GreatWallData(),
//                                       contentPadding: EdgeInsets.all(16.0), // 根据需要设置 contentPadding
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Gap($styles.insets.md),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),

//                     /// Animated arrow and background
//                     /// Wrap in a container that is full-width to make it easier to find for screen readers
//                     Container(
//                       width: double.infinity,
//                       alignment: Alignment.center,
//                       key: ValueKey(_wonderIndex),
//                       child: Stack(
//                         children: [
//                           /// Arrow Btn that fades in and out
//                           _AnimatedArrowButton(onTap: _showDetailsPage, semanticTitle: currentWonder.title),
//                         ],
//                       ),
//                     ),
//                     Gap($styles.insets.md),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
}

