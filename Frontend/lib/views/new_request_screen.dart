import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ignite/widgets/bottom_flushbar.dart';
import 'package:theme_provider/theme_provider.dart';

import '../widgets/clipping_class.dart';
import '../widgets/request_form.dart';
import '../widgets/top_button_request.dart';

const double kStartupLat = 41.9038243;
const double kStartupLong = 12.4476838;

class NewRequestScreen extends StatefulWidget {
  @override
  _NewRequestScreenState createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  LatLng _curloc;
  bool _getPositionCalled;
  Future<void> _getPosition() async {
    if (!this._getPositionCalled) {
      this._getPositionCalled = true;
      new BottomFlushbar(
        "Posizione attuale",
        "Verrà impiegata la posizione attuale non appena sarà attivo il GPS",
        Icon(
          Icons.gps_fixed,
          color: Colors.white,
        ),
        context,
      ).show();
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _curloc = LatLng(position.latitude, position.longitude);
      });
      this._getPositionCalled = false;
    } else {
      new BottomFlushbar(
        "Richiesta già effettuata",
        "Il fix del GPS è già stato richiesto",
        Icon(
          Icons.gps_fixed,
          color: Colors.white,
        ),
        context,
      ).show();
    }
  }

  Future initFuture() async {
    await Future.wait([this._getPosition()]);
  }

  @override
  void initState() {
    super.initState();
    this._getPositionCalled = false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      extendBody: true,
      backgroundColor: ThemeProvider.themeOf(context).id == "main"
          ? Colors.red[900]
          : Colors.grey[700],
      body: Column(
        children: <Widget>[
          ClipPath(
            clipper: ClippingClass(),
            child: Container(
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 42,
                    ),
                    child: TopButtonRequest(
                      context: context,
                      title: "Utilizza la posizione corrente",
                      subtitle: "Ottieni le informazioni tramite GPS",
                      icon: Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
                      function: () async {
                        this._getPosition();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: RequestForm(
              isNewRequest: true,
              lat: _curloc == null ? null : _curloc.latitude,
              long: _curloc == null ? null : _curloc.longitude,
            ),
          ),
        ],
      ),
    );
  }
}
