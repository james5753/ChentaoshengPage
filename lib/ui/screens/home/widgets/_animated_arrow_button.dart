part of '../wonders_home_screen.dart';

/// 一个箭头图标，淡出后淡入并下滑，最终以全透明度回到初始位置。
class _AnimatedArrowButton extends StatelessWidget {
  _AnimatedArrowButton({required this.onTap, required this.semanticTitle});

  final String semanticTitle; // 语义化标签，用于无障碍支持
  final VoidCallback onTap; // 按钮点击时调用的回调函数

  // 从1渐变到0再变回到1
  final _fadeOutIn = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: .5), // 第一半段：从透明到不可见
    TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: .5), // 第二半段：从不可见变回透明
  ]);

  // 前半段保持顶部对齐，后半段跳转到底部再滑动回到顶部
  final _slideDown = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: .5), // 保持顶部对齐
    TweenSequenceItem(tween: Tween(begin: -1, end: 1), weight: .5) // 向下滑动然后返回顶部
  ]);

  @override
  Widget build(BuildContext context) {
    final Duration duration = $styles.times.med; // 动画持续时间
    final btnLbl = $strings.animatedArrowSemanticSwipe(semanticTitle); // 获取按钮语义标签
    return AppBtn.basic(
      semanticLabel: btnLbl, // 绑定语义标签
      onPressed: onTap, // 绑定点击事件
      child: SizedBox(
        height: 80, // 按钮高度
        width: 50, // 按钮宽度
        child: Animate(
          effects: [
            CustomEffect(builder: _buildOpacityTween, duration: duration, curve: Curves.easeOut), // 添加自定义淡入淡出的动画效果
            CustomEffect(builder: _buildSlideTween, duration: duration, curve: Curves.easeOut), // 添加自定义下滑的动画效果
          ],
          child: Transform.rotate(
            angle: pi * .5, // 将图标旋转90度
            child: Icon(Icons.chevron_right, size: 42, color: $styles.colors.white), // 箭头图标
          ),
        ),
      ),
    );
  }

  // 构造用于渐变透明度的动画
  Widget _buildOpacityTween(BuildContext _, double value, Widget child) {
    final opacity = _fadeOutIn.evaluate(AlwaysStoppedAnimation(value)); // 评估当前时刻的透明度值
    return Opacity(opacity: opacity, child: child); // 返回具有当前透明度的子组件
  }

  // 构造用于上下滑动的动画
  Widget _buildSlideTween(BuildContext _, double value, Widget child) {
    double yOffset = _slideDown.evaluate(AlwaysStoppedAnimation(value)); // 评估当前时刻的Y轴偏移量
    return Align(alignment: Alignment(0, -1 + yOffset * 2), child: child); // 调整子组件的对齐方式
  }
}