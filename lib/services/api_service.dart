import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService extends ChangeNotifier {
  Future<String> fetchRandomText() async {
    return http
        .get(
          Uri.parse(
            'https://randommer.io/api/Text/LoremIpsum?loremType=normal&type=words&number=123',
          ),
          headers: {
            "accept": "*/*",
            "X-Api-Key": "851bb4f053b645a1891920d6da154e41",
          },
        )
        .then((value) async {
          if (value.statusCode == 200) {
            return value.body;
          } else {
            throw Exception('fetchRandomRecipe: Erro chamada HTTP');
          }
        });
  }
}

