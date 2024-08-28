import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<List<dynamic>> fetchResults(String subjectQuery, String title) async {
    final response = await http.get(Uri.parse(
        'https://search-oihidiiqud.cn-shanghai.fcapp.run?subject=$subjectQuery&title=$title'));

    if (response.statusCode == 200) {
      print('响应体: ${json.decode(response.body)}');
      return [json.decode(response.body)];
    } else {
      throw Exception('Failed to load results');
    }
  }

  static Future<List<String>> fetchImageUrls(String manifestUrl) async {
    final response = await http.get(Uri.parse(manifestUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<String> imageUrls = [];

      for (var item in data['items']) {
        var annotationPage = item['items'][0];
        for (var annotation in annotationPage['items']) {
          var imageBody = annotation['body'];
          if (imageBody['type'] == 'Image') {
            imageUrls.add(imageBody['id']);
          }
        }
      }

      return imageUrls;
    } else {
      throw Exception('Failed to load JSON data');
    }
  }
}