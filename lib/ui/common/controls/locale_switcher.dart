import 'package:wonders/common_libs.dart';

class LocaleSwitcher extends StatelessWidget with GetItMixin {
  LocaleSwitcher({super.key});

  // @override
//   Widget build(BuildContext context) {
//     final locale = watchX((SettingsLogic s) => s.currentLocale);
//     Future<void> handleSwapLocale() async {
//       final newLocale = Locale(locale == 'en' ? 'zh' : 'en');
//       await settingsLogic.changeLocale(newLocale);
//     }

//     return AppBtn.from(
//         text: $strings.localeSwapButton, onPressed: handleSwapLocale, padding: EdgeInsets.all($styles.insets.sm));
//   }
// }
 @override
  Widget build(BuildContext context) {
    // 移除 locale 和 handleSwapLocale 相关的代码
    return Container(); 
  }
}