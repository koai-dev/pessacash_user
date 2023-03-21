import 'package:http/http.dart' as http;

class Controller {
  // url
  static const String ENDPOINT = "https://api.currconv.com/api/v7/convert?";
  static const String COMPACT = "compact=ultra";

  // secret key
  static const String API_KEY = "apiKey=aad14fab70084ba8ac87a465e823472d";

  static Future<http.Response> getMoney(url) async {
    try {
      print(url);
      final response = await http.get(Uri.parse(url));
      return response;
    } catch (e) {
      print("fetch get err $e");
      return null;
    }
  }
}
