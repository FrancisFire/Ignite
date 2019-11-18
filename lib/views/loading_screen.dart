import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:ignite/models/app_state.dart';
import 'package:theme_provider/theme_provider.dart';
import '../main.dart';
import 'fireman_screen.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  LatLng _curloc;
  String _mapStyle;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isFireman;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor:
          ThemeProvider.themeOf(context).data.primaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor:
          ThemeProvider.themeOf(context).data.primaryColor,
    ));
    return MaterialApp(
      home: SplashScreen.navigate(
        next: (context) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return _isFireman
                ? FiremanScreen()
                : Homepage(
                    position: this._curloc,
                    jsonStyle: this._mapStyle,
                  );
          }));
        },
        name: 'assets/general/intro.flr',
        backgroundColor: ThemeProvider.themeOf(context).data.primaryColor,
        loopAnimation: '1',
        until: () => this._untilFunction(),
        endAnimation: '1',
      ),
    );
  }

  Widget screenChange() {
    Widget _temp;

    if (_isFireman) {
      _temp = FiremanScreen();
    } else {
      _temp = Homepage(
        position: this._curloc,
        jsonStyle: this._mapStyle,
      );
    }

    return _temp;
  }

  Future _untilFunction() async {
    await this._getIsFireman();
    await this._getPosition();
    await this._loadJson();
  }

  Future<dynamic> _getIsFireman() async {
    _isFireman = await Provider.of<AppState>(context).isCurrentUserFireman();
  }

  Future<dynamic> _getPosition() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _curloc = LatLng(position.latitude, position.longitude);
    });
  }

  Future<dynamic> _loadJson() async {
    await rootBundle
        .loadString(
            'assets/general/${ThemeProvider.optionsOf<CustomMapStyle>(context).filename}.json')
        .then((string) {
      _mapStyle = string;
    });
  }
}
