import 'package:wonders/common_libs.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;

// 这个文件可以修改tabbar
class WonderDetailsTabMenu extends StatelessWidget {
  // 定义了几个静态常量，用于按钮的各种尺寸设置
  static const double buttonInset = 12;
  static const double homeBtnSize = 60;
  static const double minTabSize = 25;
  static const double maxTabSize = 100;

  // 构造函数，初始化类的各个属性
  const WonderDetailsTabMenu({
    super.key,
    required this.tabController,
    this.showBg = false,
//    required this.wonderType,
    this.axis = Axis.horizontal,
    required this.onTap,
  });

  // tabController 控制tab的切换
  final TabController tabController;
  // showBg 控制是否显示背景
  final bool showBg;
//  final WonderType wonderType;
  // axis 决定排列方向，水平还是垂直
  final Axis axis;
  // 判断是否为垂直布局
  bool get isVertical => axis == Axis.vertical;

  // 定义一个函数类型的属性 onTap，供外部传入点击tab后的处理逻辑
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    // 根据 showBg 值设置图标颜色
    Color iconColor = showBg ? $styles.colors.black : $styles.colors.white;
    // 计算可用空间大小
    final availableSize = ((isVertical ? context.heightPx : context.widthPx) - homeBtnSize - $styles.insets.md);
    // 根据可用空间大小计算tab按钮大小，将其限制在minTabSize和maxTabSize之间
    final double tabBtnSize = (availableSize / 7).clamp(minTabSize, maxTabSize);
    // 计算额外的间隙量，如果tab按钮比home按钮宽
    final double gapAmt = max(0, tabBtnSize - homeBtnSize);
    // 获取安全区域的填充
    final double safeAreaBtm = context.mq.padding.bottom, safeAreaTop = context.mq.padding.top;
    // 设置按钮内部填充
    final buttonInsetPadding = isVertical ? EdgeInsets.only(right: buttonInset) : EdgeInsets.only(top: buttonInset);
    
    // 返回一个Padding布局
    return Padding(
      padding: isVertical ? EdgeInsets.only(top: safeAreaTop) : EdgeInsets.zero,
      child: Container(
        width: defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS?50.0:60.0,
        child: Stack(
          children: [
            // 背景，基于 showBg 属性的变换动画
            Positioned.fill(
              child: Padding(
                padding: buttonInsetPadding,
                child: AnimatedOpacity(
                  duration: $styles.times.fast,
                  opacity: showBg ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: $styles.colors.white,
                      borderRadius: isVertical ? BorderRadius.only(topRight: Radius.circular(32)) : null,
                    ),
                  ),
                ),
              ),
            ),

            // 按钮部分，包括home按钮和tab按钮
            Padding(
              // 水平模式添加安全区域底部填充，垂直布局则不需要
              padding: EdgeInsets.only(bottom: isVertical ? 0 : safeAreaBtm),
              child: SizedBox(
                width: isVertical ? null : double.infinity,
                height: isVertical ? double.infinity : null,
                child: FocusTraversalGroup(
                  child: Flex(
                    direction: axis,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Home 按钮，暂时注释掉
                      Padding(
                        // Home按钮的填充
                        padding: isVertical
                            ? EdgeInsets.only(left: $styles.insets.xs)
                            : EdgeInsets.only(bottom: $styles.insets.xs),
  //                      child: _WonderHomeBtn(
  //                        size: homeBtnSize,
  //                        wonderType: wonderType,
  //                        borderSize: showBg ? 6 : 2,
  //                      ),
                      ),
                      Gap(gapAmt),

                      // Tab 按钮部分，设置填充以确保它们在有色背景上居中
                      Padding(
                        padding: buttonInsetPadding,
                        child: Flex(
                            direction: axis,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 定义每个Tab按钮
                              _TabBtn(
                                0,
                                tabController,
                                iconImg: 'editorial',
                                label: $strings.wonderDetailsTabLabelInformation,
                                color: iconColor,
                                axis: axis,
                                mainAxisSize: tabBtnSize,
                                onTap: onTap,
                              ),
                              _TabBtn(
                                1,
                                tabController,
                                iconImg: 'search',
                                label: $strings.wonderDetailsTabLabelImages,
                                color: iconColor,
                                axis: axis,
                                mainAxisSize: tabBtnSize,
                                onTap: onTap,
                              ),
                              // _TabBtn(
                              //   2,
                              //   tabController,
                              //   iconImg: 'artifacts',
                              //   label: $strings.wonderDetailsTabLabelArtifacts,
                              //   color: iconColor,
                              //   axis: axis,
                              //   mainAxisSize: tabBtnSize,
                              //   onTap: onTap,
                              //),
                              _TabBtn(
                                2,
                                tabController,
                                iconImg: 'timeline',
                                label: $strings.wonderDetailsTabLabelEvents,
                                color: iconColor,
                                axis: axis,
                                mainAxisSize: tabBtnSize,
                                onTap: onTap,
                              ),
                              _TabBtn(
                                3,
                                tabController,
                                iconImg: 'aichat',
                                label:'ChatBox',
                                color: iconColor,
                                axis: axis,
                                mainAxisSize: tabBtnSize,
                                onTap: onTap,
                              ),
                              _TabBtn(
                                4,
                                tabController,
                                iconImg: 'map',
                                label:'Map',
                                color: iconColor,
                                axis: axis,
                                mainAxisSize: tabBtnSize,
                                onTap: onTap,
                              ),
                              _TabBtn(
                                5,
                                tabController,
                                iconImg: 'photo',
                                label:'Photo',
                                color: iconColor,
                                axis: axis,
                                mainAxisSize: tabBtnSize,
                                onTap: onTap,
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home 按钮部件，已注释掉未使用
class _WonderHomeBtn extends StatelessWidget {
  const _WonderHomeBtn({required this.size, required this.wonderType, required this.borderSize});

  final double size;
  final WonderType wonderType;
  final double borderSize;

  @override
  Widget build(BuildContext context) {
    return CircleBtn(
      onPressed: () => context.go(ScreenPaths.home),
      bgColor: $styles.colors.white,
      semanticLabel: $strings.wonderDetailsTabSemanticBack,
      child: AnimatedContainer(
        curve: Curves.easeOut,
        duration: $styles.times.fast,
        width: size - borderSize * 2,
        height: size - borderSize * 2,
        margin: EdgeInsets.all(borderSize),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: wonderType.fgColor,
          image: DecorationImage(image: AssetImage(wonderType.homeBtn), fit: BoxFit.fill),
        ),
      ),
    );
  }
}

// Tab 按钮部件
class _TabBtn extends StatelessWidget {
  const _TabBtn(
    this.index,
    this.tabController, {
    required this.iconImg,
    required this.color,
    required this.label,
    required this.axis,
    required this.mainAxisSize,
    required this.onTap,
  });

  static const double crossBtnSize = 60;

  final int index;
  final TabController tabController;
  final String iconImg;
  final Color color;
  final String label;
  final Axis axis;
  final double mainAxisSize;
  final void Function(int index) onTap;//length

  // 判断是否为垂直布局
  bool get _isVertical => axis == Axis.vertical;

  @override
  Widget build(BuildContext context) {
    // 判断当前tab是否被选中
    bool selected = tabController.index == index;
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    // 根据选中状态设置不同的图标路径
    final iconImgPath = '${ImagePaths.common}/tab-$iconImg${selected ? '-active' : ''}.png';
    // 设置tab标签
    String tabLabel = localizations.tabLabel(tabIndex: index + 1, tabCount: tabController.length);
    tabLabel = '$label: $tabLabel';

    final double iconSize = min(mainAxisSize, 32);

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        label: tabLabel,
        child: ExcludeSemantics(
          child: AppBtn.basic(
            onPressed: () => onTap(index),
            semanticLabel: label,
            minimumSize: _isVertical ? Size(crossBtnSize, mainAxisSize) : Size(mainAxisSize, crossBtnSize),
            // 图标
            child: Image.asset(
              iconImgPath,
              height: iconSize,
              width: iconSize,
              color: selected ? null : color,
            ),
          ),
        ),
      ),
    );
  }
}