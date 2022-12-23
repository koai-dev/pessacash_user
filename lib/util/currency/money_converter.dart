import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'Controller.dart';
import 'currency.dart';

class MoneyConverter {
  static const MethodChannel _channel = const MethodChannel('money_converter');

  static Future<Currency> convert(Currency from, Currency to) async {
    try {
      if (from.type.isEmpty || to.type.isEmpty) {
        print("type or ammount is missing");
        return null;
      }

      if (from.amount == null) {
        from.amount = 1.0;
      }
      String url =
          "${Controller.ENDPOINT}q=${from.type}_${to.type}&${Controller.API_KEY}&${Controller.COMPACT}";

      Response resp = (await Controller.getMoney(url));
      print(resp.body);

      double unitValue = double.parse(jsonDecode(resp.body)['${from.type}_${to.type}'].toString());

      double value = from.amount * unitValue;

      return Currency(to.type,amount: value, symbol: to.symbol);
    } catch (err) {
      print("convert err $err");
      return Currency(from.type, amount: from.amount, symbol: from.symbol);
    }
  }
}
