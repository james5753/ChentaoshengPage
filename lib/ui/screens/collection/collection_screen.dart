import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wonders/ui/screens/webview_screen/webview_screen.dart';
import 'package:wonders/styles/styles.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_title_text.dart';
import 'package:wonders/ui/screens/home_menu/home_menu.dart';
import 'package:wonders/logic/data/wonders_data/great_wall_data.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isSmoothMove=true; //默认使用瞬移
  List<List<LatLng>> _allPaths = [];
  MapController _mapController = MapController();  // 初始化MapController

  final List<Map<String, dynamic>> _events = [
    {
      'time': '1899年',
      'event': '福州：出生于福建福州',
      'location': LatLng(26.0745, 119.2965), // 福州
    },
    {
      'time': '1918年',
      'event': '北京：考入北京工业专科学校应用化学科，攻读制糖、酿造等课程',
      'location': LatLng(39.9042, 116.4074), // 北京
    },
    {
      'time': '1922年',
      'event': '济南：到山东济南黄台溥益糖厂酒精厂工作',
      'location': LatLng(36.6512, 117.1201), // 济南
    },
    {
      'time': '1927年',
      'event': '北京：在母校兼任讲师',
      'location': LatLng(39.9042, 116.4074), // 北京
    },
    {
      'time': '1930年',
      'event': '南京：担任南京中央工业试验所任酿造室主任',
      'location': LatLng(32.0603, 118.7969), // 南京
    },
    {
      'time': '1932年',
      'event': '美国：在路易斯安那大学的奥杜邦糖业学院学习',
      'location': LatLng(30.4583, -91.1403), // 美国路易斯安那州
    },
    {
      'time': '1934年',
      'event': '上海：担任上海中国酒精厂总化学师',
      'location': LatLng(31.2304, 121.4737), // 上海
    },
    {
      'time': '1949年',
      'event': '东北：帮助糖厂、酒精厂复工',
      'location': LatLng(41.8057, 123.4315), // 东北沈阳
    },
    {
      'time': '1949年',
      'event': '西北：勘察甜菜糖厂的建厂地址',
      'location': LatLng(36.03, 103.83), // 西北兰州
    },
    {
      'time': '1950年',
      'event': '无锡：担任江南大学食品工业系教授',
      'location': LatLng(31.4912, 120.3119), // 无锡
    },
    {
      'time': '1953年',
      'event': '上海：担任上海第一地方工业局化验室顾问',
      'location': LatLng(31.2304, 121.4737), // 上海
    },
    {
      'time': '1957年',
      'event': '上海：在上海化学化工学会作“谷氨酸发酵”的学术报告',
      'location': LatLng(31.1704, 121.5937), // 上海
    },
    {
      'time': '1960年',
      'event': '北京：在北京科学会堂作“核酸在食品工业中的应用”的学术报告',
      'location': LatLng(39.9042, 116.4074), // 北京
    },
    {
      'time': '1982年',
      'event': '上海：入职上海科学技术大学',
      'location': LatLng(31.176, 121.595), // 上海
    },
    {
      'time': '1992年',
      'event': '上海：病逝于上海',
      'location': LatLng(31.1304, 121.3737), // 上海
    },
  ];

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Generate all paths on init
    for (int i = 1; i < _events.length; i++) {
      final newPath = _getCurvedPath(_events[i - 1]['location'], _events[i]['location']);
      _allPaths.add(newPath);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<LatLng> _getCurvedPath(LatLng start, LatLng end) {
    List<LatLng> path = [];
    double curvature = 0.2; // 曲率参数，值越大曲线越弯曲

    double controlLat = (start.latitude + end.latitude) / 2 + curvature * (end.longitude - start.longitude);
    double controlLng = (start.longitude + end.longitude) / 2 - curvature * (end.latitude - start.latitude);
    LatLng controlPoint = LatLng(controlLat, controlLng);

    int numPoints = 40; // 路径点的数量，值越大曲线越平滑
    for (int i = 0; i <= numPoints; i++) {
      double t = i / numPoints;
      double lat = (1 - t) * (1 - t) * start.latitude + 2 * (1 - t) * t * controlPoint.latitude + t * t * end.latitude;
      double lng = (1 - t) * (1 - t) * start.longitude + 2 * (1 - t) * t * controlPoint.longitude + t * t * end.longitude;
      path.add(LatLng(lat, lng));
    }

    return path;
  }

    void _smoothMoveToCurrentLocation() async {   //平滑移动
    LatLng targetLocation = _events[_currentStep]['location'];
    LatLng currentLocation = _mapController.center;
    int steps = 10; // 定义平滑移动的步数
    double latStep = (targetLocation.latitude - currentLocation.latitude) / steps;
    double lngStep = (targetLocation.longitude - currentLocation.longitude) / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(Duration(milliseconds: 10), () {
        double newLat = currentLocation.latitude + latStep * i;
        double newLng = currentLocation.longitude + lngStep * i;
        _mapController.move(LatLng(newLat, newLng), 6.0); // 6.0 是缩放级别，可以根据需求调整
      });
    }
  }

  void _animatedMoveToCurrentLocation() {   //瞬移
    LatLng targetLocation = _events[_currentStep]['location'];
    _mapController.move(targetLocation, _mapController.zoom);
  }

  void _toggleMoveMode() {    //切换移动方式
    setState(() {
      _isSmoothMove = !_isSmoothMove;
    });
  }

  ScrollController _scrollController = ScrollController();


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF9ECE4),
    appBar: AppBar(
      title: Text('GIS地图'),
      centerTitle: true,
      backgroundColor: Color(0xFF642828),
      automaticallyImplyLeading: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Tenor',
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.normal,
      ),
      actions: [
           Positioned(
            right: 40,
            top: 10,
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.white), // 设置图标颜色为白色以便在黑色背景上可见
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => HomeMenu(data: GreatWallData()),
                  );
                },
              ),
            ),
        ],
    ),
    body: Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: _mapController, // 添加 MapController
                options: MapOptions(
                  center: _events[_currentStep]['location'], // 初始化时的中心点
                  zoom: 6.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
                    subdomains: ['1', '2', '3', '4'],
                  ),
                  MarkerLayer(
                    markers: _events.map((event) {
                      return Marker(
                        width: 80.0,
                        height: 80.0,
                        point: event['location'],
                        builder: (ctx) => Tooltip(
                          message: event['time'],
                          child: AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(seconds: 1),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(event['time']),
                                    content: Text(event['event']),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text('关闭'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                child: Icon(Icons.location_on,
                                    color: Colors.red, size: 30),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  PolylineLayer(
                    polylines: _allPaths.map((path) {
                      return Polyline(
                        points: path,
                        strokeWidth: 2.0,
                        color: Colors.blue,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0, top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*删除“进入故事模式”按钮*/ 
                // SizedBox(
                //   width: 140, // 调整按钮宽度
                //   height: 40, // 调整按钮高度
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Color(0xFF6C795B), // 深灰色背景
                //       foregroundColor: Colors.white, // 白色文字
                //     ),
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => WebViewPage()),
                //       );
                //     },
                //     child: Text('进入故事模式'),
                //   ),
                // ),
                // SizedBox(height: 20), // 按钮之间的间距
                SizedBox(
                  width: 140, // 调整按钮宽度
                  height: 40, // 调整按钮高度
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C795B), // 深灰色背景
                      foregroundColor: Colors.white, // 白色文字
                    ),
                    onPressed: _toggleMoveMode,
                    child: Text(
                        _isSmoothMove ? '切换平滑移动' : '切换动画移动'),
                  ),
                ),
                SizedBox(height: 20), // 按钮之间的间距
                SizedBox(
                  width: 140, // 调整按钮宽度
                  height: 40, // 调整按钮高度
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C795B), // 深灰色背景
                      foregroundColor: Colors.white, // 白色文字
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    child: Text('返回时间起点'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 30.0,
          left: 20.0,
          right: 20.0,
          child: Container(
            height: 60.0,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF6C795B),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward),
                    color: Colors.white,
                    iconSize: 36,
                    padding: EdgeInsets.all(0),
                    onPressed: _currentStep < _events.length - 1
                        ? () {
                            setState(() {
                              _currentStep++;
                              _isSmoothMove
                                  ? _animatedMoveToCurrentLocation()
                                  : _smoothMoveToCurrentLocation(); // 根据移动方式调用不同的方法
                              _controller.reset();
                              _controller.forward();
                              showModalBottomSheet(
                                context: context,
                                builder: (ctx) {
                                  // 在弹窗显示后两秒钟自动关闭
                                  Future.delayed(Duration(seconds: 2), () {
                                    if (Navigator.of(ctx).canPop()) {
                                      Navigator.of(ctx).pop();
                                    }
                                  });
                                  return Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _events[_currentStep]['time'],
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          _events[_currentStep]['event'],
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 16.0),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Text('关闭'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            });
                          }
                        : null,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    disabledColor: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_events.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                if (_currentStep >= index) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(
                                          _events[index]['time']),
                                      content: Text(
                                          _events[index]['event']),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Text('关闭'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0), // 增加按钮之间的间距
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: index <=
                                              _currentStep
                                          ? Color(0xFF6C795B)
                                          : Colors.grey,
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _events[index]['time'],
                                      style: TextStyle(
                                        color: index <= _currentStep
                                            ? Color(0xFF6C795B)
                                            : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

}
