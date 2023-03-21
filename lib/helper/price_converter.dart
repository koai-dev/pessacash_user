import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';
import 'package:phone_number/phone_number.dart';
import 'package:six_cash/controller/profile_screen_controller.dart';
import 'package:six_cash/controller/splash_controller.dart';

import '../util/currency/currency.dart';
import '../util/currency/money_converter.dart';

class PriceConverter {
  static Future<String> convertPrice(double price,
      {double discount,
      String discountType,
      int asFixed = 2,
      bool isLocal = false,
      ProfileController profileController}) async {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price - discount;
      } else if (discountType == 'percent') {
        price = price - ((discount / 100) * price);
      }
    }
    String _currencySymbol = !isLocal
        ? Get.find<SplashController>().configModel.currencySymbol
        : (await currencyChange(profileController.userInfo.phone)).symbol;
    return Get.find<SplashController>().configModel.currencyPosition == 'left'
        ? '$_currencySymbol${(price).toStringAsFixed(asFixed).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
        : '${(price).toStringAsFixed(asFixed).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
            '$_currencySymbol';
  }

  static String convertPriceLocal(
    double price, {
    double discount,
    String discountType,
    int asFixed = 2,
  }) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price - discount;
      } else if (discountType == 'percent') {
        price = price - ((discount / 100) * price);
      }
    }
    String _currencySymbol =
        Get.find<SplashController>().configModel.currencySymbol;
    return Get.find<SplashController>().configModel.currencyPosition == 'left'
        ? '$_currencySymbol${(price).toStringAsFixed(asFixed).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
        : '${(price).toStringAsFixed(asFixed).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
            '$_currencySymbol';
  }

  static double convertWithDiscount(BuildContext context, double price,
      double discount, String discountType) {
    if (discountType == 'amount') {
      price = price - discount;
    } else if (discountType == 'percent') {
      price = price - ((discount / 100) * price);
    }
    return price;
  }

  static double calculation(
      double amount, double discount, String type, int quantity) {
    double calculatedAmount = 0;
    if (type == 'amount') {
      calculatedAmount = discount * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(BuildContext context, String price,
      String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : '\$'} OFF';
  }

  static double withCashOutCharge(double amount) {
    return (amount *
                Get.find<SplashController>().configModel.cashOutChargePercent) /
            100 +
        amount;
  }

  static double withSendMoneyCharge(double amount) {
    return amount +
        Get.find<SplashController>().configModel.sendMoneyChargeFlat;
  }

  static String availableBalance() {
    String _currencySymbol =
        Get.find<SplashController>().configModel.currencySymbol;
    String _currentBalance =
        Get.find<ProfileController>().userInfo.balance.toStringAsFixed(2);
    return Get.find<SplashController>().configModel.currencyPosition == 'left'
        ? '$_currencySymbol$_currentBalance'
        : '$_currentBalance$_currencySymbol';
  }

  static String newBalanceWithDebit({
    @required double inputBalance,
    @required double charge,
  }) {
    String _currencySymbol =
        Get.find<SplashController>().configModel.currencySymbol;
    String _currentBalance = (Get.find<ProfileController>().userInfo.balance -
            (inputBalance + charge))
        .toStringAsFixed(2);
    return Get.find<SplashController>().configModel.currencyPosition == 'left'
        ? '$_currencySymbol$_currentBalance'
        : '$_currentBalance$_currencySymbol';
  }

  static String newBalanceWithCredit({
    @required double inputBalance,
  }) {
    String _currencySymbol =
        Get.find<SplashController>().configModel.currencySymbol;
    String _currentBalance =
        (Get.find<ProfileController>().userInfo.balance + inputBalance)
            .toStringAsFixed(2);
    return Get.find<SplashController>().configModel.currencyPosition == 'left'
        ? '$_currencySymbol$_currentBalance'
        : '$_currentBalance$_currencySymbol';
  }

  static String balanceInputHint() {
    String _currencySymbol =
        Get.find<SplashController>().configModel.currencySymbol;
    String _balance = '0';
    return Get.find<SplashController>().configModel.currencyPosition == 'left'
        ? '$_currencySymbol$_balance'
        : '$_balance$_currencySymbol';
  }

  static String balanceWithSymbol({String balance}) {
    String _currencySymbol =
        Get.find<SplashController>().configModel.currencySymbol;
    return Get.find<SplashController>().configModel.currencyPosition == 'left'
        ? '$_currencySymbol$balance'
        : '$balance$_currencySymbol';
  }

  static Future<Currency> convertCurrency(
      double origin, String currentPhone) async {
    final response = await MoneyConverter.convert(
        Currency(Currency.USD,
            amount: origin,
            symbol: Get.find<SplashController>().configModel.currencySymbol),
        await currencyChange(currentPhone));
    return Currency(response.type,
        amount: response.amount, symbol: response.symbol);
  }

  static Future<Currency> currencyChange(String currentPhone) async {
    PhoneNumber phoneNumber = await PhoneNumberUtil().parse(currentPhone);
    Currency locale = findCurrency(phoneNumber);
    return locale;
  }

  static Currency findCurrency(PhoneNumber phoneNumber) {
    if (phoneNumber.countryCode == "257") {
      return Currency("BIF", symbol: "FBu");
    } else if (phoneNumber.countryCode == "255") {
      return Currency("TZS", symbol: "Tsh");
    } else if (phoneNumber.countryCode == "254") {
      return Currency("KES", symbol: "Ksh");
    } else if (phoneNumber.countryCode == "233") {
      return Currency("GHS", symbol: "GH₵");
    } else {
      var format = NumberFormat.simpleCurrency(locale: Platform.localeName);
      return Currency(format.currencyName, symbol: format.currencySymbol);
    }
  }
}
