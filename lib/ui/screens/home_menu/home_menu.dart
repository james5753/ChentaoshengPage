import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/ui/common/app_backdrop.dart';
import 'package:wonders/ui/common/app_icons.dart';
import 'package:wonders/ui/common/controls/app_header.dart';
import 'package:wonders/ui/common/controls/locale_switcher.dart';
import 'package:wonders/ui/common/pop_navigator_underlay.dart';
import 'package:wonders/ui/common/wonderous_logo.dart';
import 'package:wonders/ui/screens/home_menu/about_dialog_content.dart';
import 'package:wonders/ui/common/search_page.dart';
import 'package:wonders/ui/screens/collection/collection_screen.dart';
import 'package:wonders/ui/screens/photo_gallery/photo_gallery.dart';
import 'package:wonders/ui/common/chat_page.dart';
import 'package:wonders/ui/screens/webview_screen/webpage.dart';
import 'package:wonders/ui/screens/webview_screen/webview_screen.dart';
import 'package:wonders/ui/screens/timeline/timeline_screen.dart';
import 'package:wonders/ui/screens/home/wonders_home_screen.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key, required this.data});
  final WonderData data;

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  double _btnSize(BuildContext context) => (context.sizePx.shortestSide / 5).clamp(60, 100);

  void _handleAboutPressed(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    showAboutDialog(
      context: context,
      applicationName: $strings.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: '© 2022 gskinner',
      children: [AboutDialogContent()],
      applicationIcon: Container(
        color: $styles.colors.black,
        padding: EdgeInsets.all($styles.insets.xs),
        child: WonderousLogo(width: 52),
      ),
    );
  }

  void _handleCollectionPressed(BuildContext context) => context.go(ScreenPaths.collection(''));

  void _handleTimelinePressed(BuildContext context) => context.go(ScreenPaths.timeline(widget.data.type));

  void _handleWonderPressed(BuildContext context, WonderData data) => Navigator.pop(context, data.type);

 @override
Widget build(BuildContext context) {
  final double gridWidth = _btnSize(context) * 3 * 1.2;
  return Stack(
    children: [
      /// Backdrop / Underlay
      AppBackdrop(
        strength: .5,
        child: Container(color: $styles.colors.greyStrong.withOpacity(.5)),
      ),

      PopNavigatorUnderlay(),

      /// Content
      SafeArea(
        child: Center(
          child: SizedBox(
            width: gridWidth,
            child: ExpandedScrollingColumn(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gap(50),
                Text(
                  '功能选择菜单',
                  style: TextStyle(
                    fontFamily: 'Tenor',
                    color: Colors.white,
                    fontSize: 32, // 可以根据需要调整字体大小
                  ),
                ),
                Gap($styles.insets.xl),
                _buildIconGrid(context)
                    .animate()
                    .fade(duration: $styles.times.fast)
                    .scale(begin: Offset(.8, .8), curve: Curves.easeOut),
                Gap($styles.insets.lg),
                _buildBottomBtns(context),
                //Spacer(),
                Gap($styles.insets.md),
              ],
            ),
          ),
        ),
      ),

      AppHeader(
        isTransparent: true,
        backIcon: AppIcons.close,
        trailing: (_) => LocaleSwitcher(),
      ),
    ],
  );
}

  Widget _buildIconGrid(BuildContext context) {
  Widget buildRow(List<Widget> children) => SeparatedRow(
        mainAxisAlignment: MainAxisAlignment.center,
        separatorBuilder: () => Gap($styles.insets.xs),
        children: children.map((child) => Flexible(child: child)).toList(),
      );
  return SingleChildScrollView(
    child: Center(
      child: SeparatedColumn(
        separatorBuilder: () => Gap($styles.insets.xs),
        mainAxisSize: MainAxisSize.min,
        children: [
          buildRow([
            _buildGridBtn(context, 0, wondersLogic.all[0], FirstScreen()),
            _buildGridBtn(context, 1, wondersLogic.all[1], PhotoGallery(collectionId: 'Kg_h04xvZEo', wonderType: WonderType.greatWall)),
            _buildGridBtn(context, 2, wondersLogic.all[2], TimelineScreen()),
          ]),
          buildRow([
            _buildGridBtn(context, 3, wondersLogic.all[3], ChatPage()),
            SizedBox(
              width: 96,
              child: SvgPicture.asset(SvgPaths.compassFull, colorFilter: $styles.colors.offWhite.colorFilter),
            ),
            _buildGridBtn(context, 4, wondersLogic.all[4], MapScreen()),
          ]),
          buildRow([
            _buildGridBtn(context, 5, wondersLogic.all[5], WebViewPage()),
            _buildGridBtn(context, 6, wondersLogic.all[6], MyHomePage()),
            _buildGridBtn(context, 7, wondersLogic.all[7], WebPage()),
          ]),
        ],
      ),
    ),
  );
}

  Widget _buildBottomBtns(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: settingsLogic.currentLocale,
        builder: (_, __, ___) {
          return SeparatedColumn(
            separatorBuilder: () => Divider(thickness: 1.5, height: 1).animate().scale(
                  duration: $styles.times.slow,
                  delay: $styles.times.pageTransition + 200.ms,
                  curve: Curves.easeOutBack,
                ),
            children: [
              _MenuTextBtn(
                  label: $strings.homeMenuButtonExplore,
                  icon: AppIcons.timeline,
                  onPressed: () => _handleTimelinePressed(context)),
              _MenuTextBtn(
                  label: $strings.homeMenuButtonView,
                  icon: AppIcons.collection,
                  onPressed: () => _handleCollectionPressed(context)),
              _MenuTextBtn(
                label: $strings.homeMenuButtonAbout,
                icon: AppIcons.info,
                onPressed: () => _handleAboutPressed(context),
              ),
            ]
                .animate(interval: 50.ms)
                .fade(delay: $styles.times.pageTransition + 50.ms)
                .slide(begin: Offset(0, .1), curve: Curves.easeOut),
          );
        });
  }

  List<String> labels = [
    '首页',
    '照片墙',
    '时间线',
    'AI聊天',
    '地图',
    '故事模式',
    '查询',
    '知识图谱'
  ];

  Widget _buildGridBtn(BuildContext context, int index, WonderData btnData, Widget targetPage) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: btnData.type.fgColor,
          ),
          child: Center(
            child: Text(
              labels[index],
              style: $styles.text.bodyBold.copyWith(height: 1),
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuTextBtn extends StatelessWidget {
  const _MenuTextBtn({required this.label, required this.onPressed, required this.icon});
  final String label;
  final VoidCallback onPressed;
  final AppIcons icon;

  @override
  Widget build(BuildContext context) {
    return AppBtn(
      expand: true,
      padding: EdgeInsets.symmetric(vertical: $styles.insets.md),
      onPressed: onPressed,
      bgColor: Colors.transparent,
      semanticLabel: label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(icon, color: $styles.colors.offWhite),
          Gap($styles.insets.xs),
          Text(label, style: $styles.text.bodyBold.copyWith(height: 1,color: Colors.white)),
        ],
      ),
    );
  }
}
