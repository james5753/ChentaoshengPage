import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/logic/data/wonders_data/search/search_data.dart';
import 'package:wonders/ui/common/app_icons.dart';
import 'package:wonders/ui/common/controls/app_header.dart';
import 'package:wonders/ui/common/static_text_scale.dart';
import 'package:wonders/ui/common/utils/app_haptics.dart';
import 'package:wonders/ui/screens/artifact/artifact_search/time_range_selector/expanding_time_range_selector.dart';

part 'widgets/_result_tile.dart';
part 'widgets/_results_grid.dart';
part 'widgets/_search_input.dart';

/// 用户可以使用此屏幕按名称或时间轴搜索 MET（大都会艺术博物馆）服务器上的文物。搜索结果将显示为图像，用户可以单击这些图像以获取详细信息。
class ArtifactSearchScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  ArtifactSearchScreen({super.key, required this.type});
  final WonderType type; // 文物类别

  @override
  State<ArtifactSearchScreen> createState() => _ArtifactSearchScreenState();
}

class _ArtifactSearchScreenState extends State<ArtifactSearchScreen> with GetItStateMixin {
  List<SearchData> _searchResults = []; // 搜索结果列表
  List<SearchData> _filteredResults = []; // 过滤后的结果列表
  String _query = ''; // 搜索查询

  // 使用文物类型获取相关文物数据
  late final WonderData wonder = wondersLogic.getData(widget.type);
  
  // 面板控制器，用于控制搜索面板的打开和关闭状态
  late final PanelController panelController = PanelController(
    settingsLogic.isSearchPanelOpen.value,
  )..addListener(_handlePanelControllerChanged);
  
  // 搜索可视化控制器，用于展示搜索结果
  late final SearchVizController vizController = SearchVizController(
    _searchResults,
    minYear: wondersLogic.timelineStartYear, // 文物开始时间
    maxYear: wondersLogic.timelineEndYear, // 文物结束时间
  );

  // 文物开始和结束年使用浮点数表示
  late double _startYear = wonder.artifactStartYr * 1.0, _endYear = wonder.artifactEndYr * 1.0;

  @override
  void initState() {
    _updateResults(); // 初始化时更新搜索结果
    panelController.addListener(() {
      AppHaptics.lightImpact(); // 添加轻微的振动反馈
    });
    super.initState();
  }

  @override
  void dispose() {
    panelController.dispose(); // 释放面板控制器
    vizController.dispose(); // 释放可视化控制器
    super.dispose();
  }

  // 处理提交的搜索查询
  void _handleSearchSubmitted(String query) {
    _query = query;
    _updateResults(); // 更新搜索结果
  }

  // 处理时间轴变化
  void _handleTimelineChanged(double start, double end) {
    _startYear = start;
    _endYear = end;
    _updateFilter(); // 更新过滤结果
  }

  // 处理搜索结果被点击
  void _handleResultPressed(SearchData o) => context.go(ScreenPaths.artifact(o.id.toString()));

  // 处理面板控制器状态变化
  void _handlePanelControllerChanged() {
    settingsLogic.isSearchPanelOpen.value = panelController.value;
  }

  // 更新搜索结果
  void _updateResults() {
    if (_query.isEmpty) {
      _searchResults = wonder.searchData;
    } else {
      // 在标题和关键词中进行全字匹配搜索。
      // 这是一个比较简单的搜索，但对演示用户界面足够了。
      final RegExp q = RegExp('\\b${_query}s?\\b', caseSensitive: false);
      _searchResults = wonder.searchData.where((o) => o.title.contains(q) || o.keywords.contains(q)).toList();
    }
    vizController.value = _searchResults; // 更新可视化控制器的值
    _updateFilter(); // 更新过滤结果
  }

  // 更新过滤结果
  void _updateFilter() {
    _filteredResults = _searchResults.where((o) => o.year >= _startYear && o.year <= _endYear).toList();
    setState(() {}); // 刷新界面
  }

  @override
  Widget build(BuildContext context) {
    // 将橙色调淡一点：
    vizController.color = Color.lerp($styles.colors.accent1, $styles.colors.black, 0.2)!;
    Widget content = GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus, // 轻触解除焦点
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppHeader(title: $strings.artifactsSearchTitleBrowse, subtitle: wonder.title), // 应用程序头部
          Container(
            color: $styles.colors.black, // 背景颜色
            padding: EdgeInsets.fromLTRB($styles.insets.sm, $styles.insets.sm, $styles.insets.sm, 0),
            child: _SearchInput(onSubmit: _handleSearchSubmitted, wonder: wonder), // 搜索输入组件
          ),
          Container(
            color: $styles.colors.black,
            padding: EdgeInsets.all($styles.insets.xs * 1.5),
            child: _buildStatusText(context), // 状态文本
          ),
          Expanded(
            child: RepaintBoundary(
              // 重新绘制边界
              child: _filteredResults.isEmpty
                  ? _buildEmptyIndicator(context) // 构建空指示器
                  : _ResultsGrid(
                      searchResults: _filteredResults,
                      onPressed: _handleResultPressed, // 结果点击事件
                    ),
            ),
          ),
        ],
      ),
    );

    return Stack(children: [
      Positioned.fill(child: ColoredBox(color: $styles.colors.greyStrong, child: content)), // 背景色
      Positioned.fill(
        child: RepaintBoundary(
          child: ExpandingTimeRangeSelector(
            wonder: wonder,
            startYear: _startYear,
            endYear: _endYear,
            panelController: panelController,
            vizController: vizController,
            onChanged: _handleTimelineChanged, // 时间轴变化事件
          ),
        ),
      ),
    ]);
  }

  // 构建状态文本
  Widget _buildStatusText(BuildContext context) {
    final TextStyle statusStyle = $styles.text.body.copyWith(color: $styles.colors.accent1);
    if (_searchResults.isEmpty) {
      return StaticTextScale(
        child: Text(
          $strings.artifactsSearchLabelNotFound,
          textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
          style: statusStyle,
          textAlign: TextAlign.center,
        ),
      );
    }
    return MergeSemantics(
      child: StaticTextScale(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Gap($styles.insets.sm), // 间隔
          Text(
            $strings.artifactsSearchLabelFound(_searchResults.length, _filteredResults.length),
            textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
            style: statusStyle,
          ),
          AppBtn.basic(
            semanticLabel: $strings.artifactsSearchButtonToggle,
            onPressed: () => panelController.toggle(), // 切换面板
            enableFeedback: false, // 反馈已在面板控制器变化时处理
            child: Text(
              $strings.artifactsSearchSemanticTimeframe,
              textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
              style: statusStyle.copyWith(decoration: TextDecoration.underline),
            ),
          ),
          Gap($styles.insets.sm),
        ]),
      ),
    );
  }

  // 构建空状态指示器
  Widget _buildEmptyIndicator(BuildContext context) {
    final strings = $strings;
    String text =
        '${strings.artifactsSearchLabelAdjust} ${_searchResults.isEmpty ? strings.artifactsSearchLabelSearch : strings.artifactsSearchLabelTimeframe}';
    IconData icon = _searchResults.isEmpty ? Icons.search_outlined : Icons.edit_calendar_outlined;
    Color color = $styles.colors.greyMedium;
    Widget widget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Icon(icon, size: $styles.insets.xl, color: color.withOpacity(0.5)),
        Gap($styles.insets.xs),
        Text(text, style: $styles.text.body.copyWith(color: color)),
        Spacer(
          flex: 3,
        ),
      ],
    );
    if (_searchResults.isNotEmpty) {
      widget = GestureDetector(child: widget, onTap: () => panelController.toggle());
    }
    return widget;
  }
}

// 面板控制器，继承自 ValueNotifier
class PanelController extends ValueNotifier<bool> {
  PanelController(super.value);
  void toggle() => value = !value; // 切换面板状态
}

// 这是一个基本的 ValueNotifier，但在赋值时总是通知监听者而不检查相等性。
class SearchVizController extends ChangeNotifier {
  SearchVizController(
    List<SearchData> value, {
    required this.minYear, // 最小年份
    required this.maxYear, // 最大年份
    this.color = Colors.black,
  }) : _value = value;

  Color color; // 颜色
  final int minYear; // 最小年份
  final int maxYear; // 最大年份

  List<SearchData> _value; // 搜索结果
  List<SearchData> get value => _value; // 获取搜索结果
  set value(List<SearchData> value) {
    _value = value; // 设置搜索结果
    notifyListeners(); // 通知监听者
  }
}