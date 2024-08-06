import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _events = [
    {
      'time': '2000年',
      'event': '事件1',
      'location': LatLng(39.9042, 116.4074), // 北京
    },
    {
      'time': '2002年',
      'event': '事件2',
      'location': LatLng(31.2304, 121.4737), // 上海
    },
    {
      'time': '2003年',
      'event': '事件3',
      'location': LatLng(34, 125), // 
    },
    {
      'time': '2005年',
      'event': '事件4',
      'location': LatLng(31.2304, 126), // 
    },
    {
      'time': '2007年',
      'event': '事件5',
      'location': LatLng(31.2304, 129), // 
    },
    {
      'time': '2009年',
      'event': '事件6',
      'location': LatLng(29, 121.4737), // 
    },
    // 其他事件...
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<LatLng> _getArrowPath() {
    List<LatLng> path = [];
    for (int i = 0; i <= _currentStep; i++) {
      path.add(_events[i]['location']);
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GIS地图'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 221, 160, 160),
        titleTextStyle: TextStyle(
          color: Color.fromARGB(168, 0, 0, 0),
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(34.0, 115.0),
                    zoom: 6.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
                      subdomains: ['1', '2', '3', '4'],
                    ),
                    MarkerLayer(
                      markers: _events.sublist(0, _currentStep + 1).map((event) {
                        return Marker(
                          width: 80.0,
                          height: 80.0,
                          point: event['location'],
                          builder: (ctx) => Tooltip(
                            message: event['time'],
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
                                child: Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _getArrowPath().sublist(0, _currentStep),
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _currentStep > 0
                                  ? [_events[_currentStep - 1]['location'], _events[_currentStep]['location']]
                                  : [],
                              strokeWidth: 4.0,
                              color: Colors.blue.withOpacity(_animation.value),
                              isDotted: false, // 修改为实线
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 30.0,
            left: 120.0, // 调整左箭头的位置
            right: 120.0, // 调整右箭头的位置
            child: Container(
              height: 60.0,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue, // 背景色
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Colors.white,
                      iconSize: 36,
                      padding: EdgeInsets.all(0),
                      onPressed: _currentStep > 0 ? () {
                        setState(() {
                          _currentStep--;
                          _controller.reset();
                          _controller.forward();
                        });
                      } : null,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      disabledColor: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_events.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentStep = index;
                              _controller.reset();
                              _controller.forward();
                            });
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: index <= _currentStep ? Colors.blue : Colors.grey,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                _events[index]['time'],
                                style: TextStyle(
                                  color: index <= _currentStep ? Colors.blue : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue, // 背景色
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      color: Colors.white,
                      iconSize: 36,
                      padding: EdgeInsets.all(0),
                      onPressed: _currentStep < _events.length - 1 ? () {
                        setState(() {
                          _currentStep++;
                          _controller.reset();
                          _controller.forward();
                        });
                      } : null,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      disabledColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


