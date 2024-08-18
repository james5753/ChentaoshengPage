import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/fade_color_transition.dart';
import 'package:wonders/ui/wonder_illustrations/common/illustration_piece.dart';
import 'package:wonders/ui/wonder_illustrations/common/paint_textures.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration_builder.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration_config.dart';

// 定义一个无状态的组件类，表示“长城插图”
class GreatWallIllustration extends StatelessWidget {
  // 构造函数，接受一个必需的参数 config，super.key 是用于父类的构造函数
  GreatWallIllustration({super.key, required this.config});

  // 插图的配置参数，是一个 WonderIllustrationConfig 类型的对象
  final WonderIllustrationConfig config;

  // 插图资源文件的路径，使用 WonderType 枚举类中 greatWall 的 assetPath 属性
  final String assetPath = WonderType.greatWall.assetPath;

  // 前景色，同样从 WonderType 枚举类中获取
  final fgColor = WonderType.greatWall.fgColor;

  // 背景色，从 WonderType 枚举类中获取
  final bgColor = WonderType.greatWall.bgColor;

  @override
  // 重写 build 方法，构建 widget
  Widget build(BuildContext context) {
    // 返回一个 WonderIllustrationBuilder 组件，用于组织插图的各个部分
    return WonderIllustrationBuilder(
      config: config, // 插图的配置
      bgBuilder: _buildBg, // 构建背景的方法
      mgBuilder: _buildMg, // 构建中景的方法
      fgBuilder: _buildFg, // 构建前景的方法
      wonderType: WonderType.greatWall, // 使用的 Wonder 类型
    );
  }

  // 构建背景的方法，返回一个 Widget 列表
  List<Widget> _buildBg(BuildContext context, Animation<double> anim) {
    return [
      // 渐变颜色过渡效果组件
      FadeColorTransition(animation: anim, color: $styles.colors.shift(fgColor, 1)),
      // 填充整个父组件的定位组件
      // Positioned.fill(
      //   child: IllustrationPiece(
      //     fileName: 'foreground-right.png', // 图像文件名称
      //     alignment: Alignment.center, // 对齐方式
      //     initialScale: 0.2, // 初始缩放比例
      //     //initialOffset: Offset(-40, 60), // 初始偏移
      //     heightFactor: 1, // 高度因子
      //     //fractionalOffset: Offset(-.4, .45), // 分数偏移
      //     zoomAmt: 0.7, // 缩放量
      //     //dynamicHzOffset: -150, // 动态水平偏移
      //   ),
      // ),
      // 插图的某一部分
      // IllustrationPiece(
      //   fileName: 'foreground-right.png', // 图像文件名称
      //   //initialOffset: Offset(0, 50), // 初始偏移
      //   enableHero: true, // 是否启用 Hero 动画
      //   heightFactor: config.shortMode ? .07 : .25, // 高度因子
      //   minHeight: 120, // 最小高度
      //   offset: config.shortMode ? Offset(-40, context.heightPx * -.06) : Offset(-65, context.heightPx * -.3), // 偏移位置
      // ),
    ];
  }

  // 构建中景的方法，返回一个 Widget 列表
  List<Widget> _buildMg(BuildContext context, Animation<double> anim) {
    return [
      Positioned.fill(
        child: IllustrationPiece(
          fileName: 'foreground-right.png', // 图像文件名称
          alignment: Alignment.center, // 对齐方式
          initialScale: 0.02, // 初始缩放比例
          //initialOffset: Offset(-40, 60), // 初始偏移
          heightFactor: 1, // 高度因子
          //fractionalOffset: Offset(-.4, .45), // 分数偏移
          zoomAmt: 0.7, // 缩放量
          //dynamicHzOffset: -150, // 动态水平偏移
        ),
      ),
    ];
  }

  // 构建前景的方法，返回一个 Widget 列表
  List<Widget> _buildFg(BuildContext context, Animation<double> anim) {
    return [
      // 插图的左前景部分 
      IllustrationPiece(
        fileName: 'great-wall.png', // 图像文件名称
        alignment: Alignment.bottomCenter, // 对齐方式
        //initialOffset: Offset(20, 40), // 初始偏移
        initialScale: .95, // 初始缩放比例
        heightFactor: 1, // 高度因子
        fractionalOffset: Offset(.05, .00), // 分数偏移
        zoomAmt: .1, // 缩放量
        dynamicHzOffset: 150, // 动态水平偏移
      ),
      IllustrationPiece(
        fileName: 'foreground-left.png', // 图像文件名称
        alignment: Alignment.bottomCenter, // 对齐方式
        initialScale: 0.3, // 初始缩放比例
        //initialOffset: Offset(-40, 60), // 初始偏移
        heightFactor: .85, // 高度因子
        fractionalOffset: Offset(.05, .00), // 分数偏移
        zoomAmt: .25, // 缩放量
        dynamicHzOffset: -150, // 动态水平偏移
      ),
      // 插图的右前景部分
     
    ];
  }
}