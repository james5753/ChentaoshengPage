import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CollectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GIS地图'),
        centerTitle: true,
        //automaticallyImplyLeading: false, // 按钮回退的功能
        backgroundColor: Color.fromARGB(255, 221, 160, 160), // 设置AppBar的背景颜色
        titleTextStyle: TextStyle(
          color: Color.fromARGB(168, 0, 0, 0), // 设置标题文字颜色
          fontSize: 20.0, // 设置标题文字大小
          fontWeight: FontWeight.bold, // 设置标题文字粗细
          ),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(35.8617, 104.1954), // 中国的地理中心
          zoom: 4.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
            subdomains: ['1', '2', '3', '4'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(39.9042, 116.4074), // 北京
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BeijingScreen()),
                    );
                  },
                  child: Container(
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ),
              ),
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(31.2304, 121.4737), // 上海
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShanghaiScreen()),
                    );
                  },
                  child: Container(
                    child: Icon(Icons.location_on, color: Colors.blue, size: 40),
                  ),
                ),
              ),
              // 其他标记...
            ],
          ),
        ],
      ),
    );
  }
}

// 示例目标界面
class BeijingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('北京'),
      ),
      body: Center(
        child: Text('欢迎来到北京！'),
      ),
    );
  }
}

class ShanghaiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上海'),
      ),
      body: Center(
        child: Text('欢迎来到上海！'),
      ),
    );
  }
}