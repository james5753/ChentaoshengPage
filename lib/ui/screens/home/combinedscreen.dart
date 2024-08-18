import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/data/wonders_data/great_wall_data.dart';
import 'package:wonders/ui/screens/editorial/editorial_screen.dart';
import 'package:wonders/ui/screens/home/wonders_home_screen.dart';


class CombinedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            FirstScreen(),
            EditorialScreen(),
          ],
        ),
      ),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600, // 模拟FirstScreen的高度
      color: Colors.blue,
      child: Center(child: Text('First Screen', style: TextStyle(fontSize: 24, color: Colors.white))),
    );
  }
}

class EditorialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 800, // 模拟EditorialScreen的高度
      color: Colors.green,
      child: Center(child: Text('Editorial Screen', style: TextStyle(fontSize: 24, color: Colors.white))),
    );
  }
}


