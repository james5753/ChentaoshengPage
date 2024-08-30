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
import 'package:shared_preferences/shared_preferences.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key, required this.data});
  final WonderData data;

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  // Track the current selected index
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheImages();
    });
  }

  void _loadSelectedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldResetIndex = prefs.getBool('should_reset_index') ?? true;

    if (shouldResetIndex) {
      setState(() {
        _selectedIndex = 0;
      });
      await prefs.setBool('should_reset_index', false);
    } else {
      setState(() {
        _selectedIndex = prefs.getInt('selected_index') ?? 0;
      });
    }
  }

  void _onPageSelected(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = index;
    });
    await prefs.setInt('selected_index', index);
  }

  void _precacheImages() {
    final List<String> imagePaths = [
      'assets/images/_common/3.0x/tab-editorial-active.png',
      'assets/images/_common/3.0x/tab-photo-active.png',
      'assets/images/_common/3.0x/tab-timeline-active.png',
      'assets/images/_common/3.0x/tab-aichat-active.png',
      'assets/images/_common/3.0x/tab-map-active.png',
      'assets/images/_common/3.0x/tab-story-active.png',
      'assets/images/_common/3.0x/tab-search-active.png',
      'assets/images/_common/3.0x/tab-contact-active.png',
    ];

    for (var imagePath in imagePaths) {
      precacheImage(AssetImage(imagePath), context);
    }
  }


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

                  Gap($styles.insets.xl),
                  _buildIconGrid(context)
                      .animate()
                      .fade(duration: $styles.times.fast)
                      .scale(begin: Offset(.8, .8), curve: Curves.easeOut),
                  Gap($styles.insets.lg),
                  //_buildBottomBtns(context),
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
          separatorBuilder: () => Gap($styles.insets.sm),
          children: children.map((child) => Flexible(child: child)).toList(),
        );
    return SingleChildScrollView(
      child: Center(
        child: SeparatedColumn(
          separatorBuilder: () => Gap($styles.insets.sm),
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRow([
              _buildGridBtn(context, 0, wondersLogic.all[0], FirstScreen(), 'assets/images/_common/3.0x/tab-editorial.png'),
              _buildGridBtn(context, 1, wondersLogic.all[1], PhotoGallery(collectionId: 'Kg_h04xvZEo', wonderType: WonderType.greatWall), 'assets/images/_common/3.0x/tab-photo.png'),
              _buildGridBtn(context, 2, wondersLogic.all[2], TimelineScreen(), 'assets/images/_common/3.0x/tab-timeline.png'),
            ]),
            buildRow([
              _buildGridBtn(context, 3, wondersLogic.all[3], ChatPage(), 'assets/images/_common/3.0x/tab-aichat.png'),
              SizedBox(
                width: 96,
                child: SvgPicture.asset(SvgPaths.compassFull, colorFilter: $styles.colors.offWhite.colorFilter),
              ),
              _buildGridBtn(context, 4, wondersLogic.all[4], MapScreen(), 'assets/images/_common/3.0x/tab-map.png'),
            ]),
            buildRow([
              _buildGridBtn(context, 5, wondersLogic.all[5], WebViewPage(), 'assets/images/_common/3.0x/tab-story.png'),
              _buildGridBtn(context, 6, wondersLogic.all[6], MyHomePage(), 'assets/images/_common/3.0x/tab-search.png'),
              _buildGridBtn(context, 7, wondersLogic.all[7], WebPage(), 'assets/images/_common/3.0x/tab-contact.png'),
            ]),
          ],
        ),
      ),
    );
  }

   Widget _buildGridBtn(BuildContext context, int index, WonderData buttondata, Widget screen, String imagePath) {
    String displayImagePath = _selectedIndex == index
        ? imagePath.replaceFirst('.png', '-active.png')
        : imagePath;

    return GestureDetector(
      onTap: () {
        _onPageSelected(index);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(displayImagePath, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
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
