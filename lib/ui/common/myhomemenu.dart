import 'package:flutter/material.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/ui/screens/timeline/timeline_screen.dart';
import 'package:wonders/ui/screens/home/wonders_home_screen.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/search_page.dart';
import 'package:wonders/ui/screens/collection/collection_screen.dart';
import 'package:wonders/ui/screens/photo_gallery/photo_gallery.dart';
import 'package:wonders/ui/common/chat_page.dart';
import 'package:wonders/ui/screens/webview_screen/webpage.dart';
import 'package:wonders/ui/screens/webview_screen/webview_screen.dart';
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

class HomeMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconGrid(context),
            SizedBox(height: 16.0),
            
          ],
        ),
      ),
    );
  }

  Widget _buildIconGrid(BuildContext context) {
    Widget buildRow(List<Widget> children) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        );
    return Column(
      children: [
        buildRow([
          _buildGridBtn(context, wondersLogic.all[0], FirstScreen()),
          _buildGridBtn(context, wondersLogic.all[1], PhotoGallery(collectionId: 'Kg_h04xvZEo', wonderType: WonderType.greatWall)),
          _buildGridBtn(context, wondersLogic.all[2], TimelineScreen()),
        ]),
        buildRow([
          _buildGridBtn(context, wondersLogic.all[3], ChatPage()),
          SizedBox(
            width: 100,
            child: SvgPicture.asset(SvgPaths.compassFull, colorFilter: $styles.colors.offWhite.colorFilter),
          ),
          _buildGridBtn(context, wondersLogic.all[4], MapScreen()),
          
        ]),
        buildRow([
          _buildGridBtn(context, wondersLogic.all[5], MyHomePage()),
          _buildGridBtn(context, wondersLogic.all[6], WebPage()),
          _buildGridBtn(context, wondersLogic.all[7], WebViewPage()),
          // 如果有第八个页面，可以在这里添加
          // _buildGridBtn(context, wondersLogic.all[7], EighthPage()),
        ]),
      ],
    );
  }

  // Widget _buildBottomBtns(BuildContext context) {
  //   return Column(
  //     children: [
  //       _MenuTextBtn(
  //         label: 'Explore',
  //         icon: AppIcons.timeline,
  //         onPressed: () => Navigator.pushNamed(context, '/timeline'),
  //       ),
  //       _MenuTextBtn(
  //         label: 'View Collection',
  //         icon: AppIcons.collection,
  //         onPressed: () => Navigator.pushNamed(context, '/collection'),
  //       ),
  //       _MenuTextBtn(
  //         label: 'About',
  //         icon: AppIcons.info,
  //         onPressed: () => _handleAboutPressed(context),
  //       ),
  //     ],
  //   );
  // }

  // void _handleAboutPressed(BuildContext context) async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   showAboutDialog(
  //     context: context,
  //     applicationName: 'App Name',
  //     applicationVersion: packageInfo.version,
  //     applicationLegalese: '© 2022 gskinner',
  //     children: [AboutDialogContent()],
  //     applicationIcon: Container(
  //       color: Colors.black,
  //       padding: EdgeInsets.all(8.0),
  //       child: WonderousLogo(width: 52),
  //     ),
  //   );
  // }

  Widget _buildGridBtn(BuildContext context, WonderData btnData, Widget targetPage) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      ),
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: btnData.type.fgColor,
        ),
        child: Center(
          child: Text(
            btnData.title,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _MenuTextBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  _MenuTextBtn({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}