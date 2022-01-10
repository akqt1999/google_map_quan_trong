import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
 // final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  static final String androidKey = 'AIzaSyCOYCXNdNdBhCv-H8qokR89JuzlyorAzmM';
  static final String iosKey = 'AIzaSyCOYCXNdNdBhCv-H8qokR89JuzlyorAzmM';
  static final String keyGoong='j0UIH8CE8gcnKzql7Zfd2F9LT6Lur7GaaXGt34My';
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=vn-Vn&components=country:vn&key=$apiKey&sessiontoken=$sessionToken';

    final request2 = 'https://rsapi.goong.io/Place/AutoComplete?api_key=$keyGoong&input=$input&more_compound=true&types=address&language=vn-Vn&components=country:vn';

    final response = await http.get(Uri.parse(request2));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        print('fidshisdfyguigdf__${result['predictions'] }');

        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'],
            p['description']))// co nghia la gan gia tri vo cho cai item roi tra ve list
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  //------------------------

}

