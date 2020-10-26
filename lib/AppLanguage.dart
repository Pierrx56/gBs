import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


/*
* Class servant à détecter et changer la langue de l'application
* */
class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('fr');

  Locale get appLocal => _appLocale ?? Locale("fr");

  /* Détection de la langue du téléphone */
  //Default: English
  Future<Locale> fetchLocale() async {

    String language = Platform.localeName.toLowerCase();
    String curLanguage = language.substring(0, 2);

    if(curLanguage == "en")
      return _appLocale = Locale("en");
    else if(curLanguage == "fr")
      return _appLocale = Locale("fr");
    else
      return _appLocale = Locale("en");

    /*var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('fr');
      return _appLocale;
    }
    _appLocale = Locale(prefs.getString('language_code'));
    return _appLocale;*/
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    /*Changement de la langue en fonction de la langue du téléphone
    * Défaut: fr
    * */
    if (type == Locale("fr")) {
      _appLocale = Locale("fr");
      await prefs.setString('language_code', 'fr');
      await prefs.setString('countryCode', 'FR');
    } else if (type == Locale("en")) {
      _appLocale = Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    }
    notifyListeners();
  }
}
