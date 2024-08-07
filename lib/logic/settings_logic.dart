import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/platform_info.dart';
import 'package:wonders/logic/common/save_load_mixin.dart';

class SettingsLogic with ThrottledSaveLoadMixin {
  @override
  String get fileName => 'settings.dat';

  late final hasCompletedOnboarding = ValueNotifier<bool>(false)..addListener(scheduleSave);
  late final hasDismissedSearchMessage = ValueNotifier<bool>(false)..addListener(scheduleSave);
  late final isSearchPanelOpen = ValueNotifier<bool>(true)..addListener(scheduleSave);
  late final currentLocale = ValueNotifier<String?>('zh')..addListener(scheduleSave);
  late final prevWonderIndex = ValueNotifier<int?>(null)..addListener(scheduleSave);

  final bool useBlurs = !PlatformInfo.isAndroid;


  @override
  void copyFromJson(Map<String, dynamic> value) {
    hasCompletedOnboarding.value = value['hasCompletedOnboarding'] ?? false;
    hasDismissedSearchMessage.value = value['hasDismissedSearchMessage'] ?? false;
    currentLocale.value = value['zh'];
    isSearchPanelOpen.value = value['isSearchPanelOpen'] ?? false;
    prevWonderIndex.value = value['lastWonderIndex'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'hasCompletedOnboarding': hasCompletedOnboarding.value,
      'hasDismissedSearchMessage': hasDismissedSearchMessage.value,
      'currentLocale': currentLocale.value,
      'isSearchPanelOpen': isSearchPanelOpen.value,
      'lastWonderIndex': prevWonderIndex.value,
    };
  }
}
