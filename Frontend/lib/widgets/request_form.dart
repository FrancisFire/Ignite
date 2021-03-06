import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ignite/models/user.dart';
import 'package:ignite/widgets/top_flushbar.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:intl/intl.dart';

import '../models/hydrant.dart';
import '../models/request.dart';
import '../providers/auth_provider.dart';
import '../providers/services_provider.dart';
import 'loading_shimmer.dart';
import 'remove_glow.dart';
import 'request_form_dropdownlisttile.dart';
import 'request_form_textlisttile.dart';

class RequestForm extends StatefulWidget {
  Request oldRequest;
  Hydrant oldHydrant;
  double lat;
  double long;
  String _firstAttack;
  String _secondAttack;
  String _pressure;
  String _cap;
  String _city;
  String _color;
  DateTime _lastCheck;
  String _notes;
  String _opening;
  String _street;
  String _number;
  String _type;
  String _vehicle;
  bool isNewRequest;
  List<String> _attackValues;
  List<String> _colorValues;
  List<String> _typeValues;
  List<String> _vehicleValues;

  List<String> _openingValues;

  List<String> _pressureValues;
  RequestForm({
    @required this.lat,
    @required this.long,
    @required this.isNewRequest,
    this.oldRequest,
    this.oldHydrant,
  });

  @override
  _RequestFormState createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  List<Placemark> _placeMarks;
  bool _isFireman;
  String _userMail;
  User _user;

  Future<void> getFuturePlacemark() async {
    try {
      _placeMarks = await Geolocator().placemarkFromCoordinates(
        widget.lat,
        widget.long,
      );
    } catch (e) {
      _placeMarks = null;
    }
  }

  Future getIsFireman() async {
    _isFireman = await ServicesProvider()
        .getUsersServices()
        .isUserFiremanById(_user.getId());
  }

  Future getUserMail() async {
    _userMail = await AuthProvider().getUserMail();
  }

  Future getUser() async {
    _user =
        await ServicesProvider().getUsersServices().getUserByMail(_userMail);
  }

  Future initFuture() async {
    await Future.wait([
      this.getFuturePlacemark(),
      this.getUserMail(),
      this.buildValues(),
    ]);
    await Future.wait([
      this.getUser(),
    ]);
    await Future.wait([
      this.getIsFireman(),
    ]);
  }

  Future<void> buildValues() async {
    widget._attackValues =
        await ServicesProvider().getValuesServices().getAttacks();
    widget._colorValues =
        await ServicesProvider().getValuesServices().getColors();
    widget._typeValues =
        await ServicesProvider().getValuesServices().getTypes();
    widget._vehicleValues =
        await ServicesProvider().getValuesServices().getVehicles();
    widget._openingValues =
        await ServicesProvider().getValuesServices().getOpenings();
    widget._pressureValues =
        await ServicesProvider().getValuesServices().getPressures();
  }

  List<Widget> buildListTileList(List<Placemark> placemark) {
    List<Widget> tiles = new List<Widget>();
    tiles.addAll([
      RequestFormTextListTile(
        label: 'Latitudine',
        hintText: 'Inserisci la latitudine',
        initValue: widget.lat == null ? "" : widget.lat.toString(),
        icon: Icon(
          Icons.location_on,
          color: ThemeProvider.themeOf(context).id == "main"
              ? Colors.red[900]
              : Colors.white,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Inserisci un valore';
          } else if (!((double.parse(value) > -90) &&
              (double.parse(value) < 90))) {
            return 'Inserisci una latitudine valida';
          } else
            return null;
        },
        onSaved: (value) {
          setState(() {
            widget.lat = double.parse(value);
          });
        },
        textInputType: TextInputType.numberWithOptions(),
      ),
      RequestFormTextListTile(
        label: 'Longitudine',
        hintText: 'Inserisci la longitudine',
        initValue: widget.long == null ? "" : widget.long.toString(),
        icon: Icon(
          Icons.location_on,
          color: ThemeProvider.themeOf(context).id == "main"
              ? Colors.red[900]
              : Colors.white,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Inserisci un valore';
          } else if (!((double.parse(value) > -180) &&
              (double.parse(value) < 180))) {
            return 'Inserisci una longitudine valida';
          } else
            return null;
        },
        onSaved: (value) {
          setState(() {
            widget.long = double.parse(value);
          });
        },
        textInputType: TextInputType.numberWithOptions(),
      ),
      RequestFormTextListTile(
        label: 'Città',
        hintText: 'Inserisci la città',
        initValue: (widget.isNewRequest)
            ? ((placemark == null) ? "" : placemark[0].locality)
            : widget.oldHydrant.getCity(),
        icon: Icon(
          Icons.location_city,
          color: ThemeProvider.themeOf(context).id == "main"
              ? Colors.red[900]
              : Colors.white,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Inserisci un valore';
          } else
            return null;
        },
        onSaved: (value) {
          setState(() {
            widget._city = value;
          });
        },
        textInputType: TextInputType.text,
      ),
      RequestFormTextListTile(
        label: 'Via',
        hintText: 'Inserisci la via',
        initValue: (widget.isNewRequest)
            ? ((placemark == null) ? "" : placemark[0].thoroughfare)
            : widget.oldHydrant.getStreet(),
        icon: Icon(
          Icons.nature_people,
          color: ThemeProvider.themeOf(context).id == "main"
              ? Colors.red[900]
              : Colors.white,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Inserisci un valore';
          } else
            return null;
        },
        onSaved: (value) {
          setState(() {
            widget._street = value;
          });
        },
        textInputType: TextInputType.text,
      ),
      RequestFormTextListTile(
        label: 'Numero civico',
        hintText: 'Inserisci il numero civico',
        initValue: (widget.isNewRequest) ? "" : widget.oldHydrant.getNumber(),
        icon: Icon(
          Icons.format_list_numbered,
          color: ThemeProvider.themeOf(context).id == "main"
              ? Colors.red[900]
              : Colors.white,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Inserisci un valore';
          } else
            return null;
        },
        onSaved: (value) {
          setState(() {
            widget._number = value;
          });
        },
        textInputType: TextInputType.numberWithOptions(),
      ),
      RequestFormTextListTile(
        label: 'CAP',
        hintText: 'Inserisci il CAP',
        initValue: (widget.isNewRequest)
            ? ((placemark == null) ? "" : placemark[0].postalCode)
            : widget.oldHydrant.getCap(),
        icon: Icon(
          Icons.grain,
          color: ThemeProvider.themeOf(context).id == "main"
              ? Colors.red[900]
              : Colors.white,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Inserisci un valore';
          } else
            return null;
        },
        onSaved: (value) {
          setState(() {
            widget._cap = value;
          });
        },
        textInputType: TextInputType.numberWithOptions(),
      ),
      RequestFormTextListTile(
        label: 'Note',
        hintText: 'Inserisci le note',
        initValue: (widget.isNewRequest) ? "" : widget.oldHydrant.getNotes(),
        icon: Icon(
          Icons.speaker_notes,
          color: ThemeProvider.themeOf(context).id == "main"
              ? Colors.red[900]
              : Colors.white,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Inserisci un valore';
          } else
            return null;
        },
        onSaved: (value) {
          setState(() {
            widget._notes = value;
          });
        },
        textInputType: TextInputType.text,
      ),
      _isFireman
          ? SizedBox(
              height: 0,
              width: 0,
            )
          : SizedBox(
              height: 106,
            ),
    ]);
    if (_isFireman) {
      tiles.addAll([
        RequestFormDropDownListTile(
          hintText: "Seleziona il primo attacco",
          label: "Primo Attacco",
          values: widget._attackValues,
          icon: Icon(
            Icons.looks_one,
            color: ThemeProvider.themeOf(context).id == "main"
                ? Colors.red[900]
                : Colors.white,
          ),
          onChangedFunction: (value) {
            widget._firstAttack = value;
          },
        ),
        RequestFormDropDownListTile(
          hintText: "Seleziona il secondo attacco",
          label: "Secondo Attacco",
          values: widget._attackValues,
          icon: Icon(
            Icons.looks_two,
            color: ThemeProvider.themeOf(context).id == "main"
                ? Colors.red[900]
                : Colors.white,
          ),
          onChangedFunction: (value) {
            widget._secondAttack = value;
          },
        ),
        RequestFormDropDownListTile(
          hintText: "Seleziona la pressione",
          label: "Pressione",
          values: widget._pressureValues,
          icon: Icon(
            Icons.layers,
            color: ThemeProvider.themeOf(context).id == "main"
                ? Colors.red[900]
                : Colors.white,
          ),
          onChangedFunction: (value) {
            widget._pressure = value;
          },
        ),
        RequestFormDropDownListTile(
          hintText: "Seleziona l'apertura",
          label: "Apertura",
          values: widget._openingValues,
          icon: Icon(
            Icons.open_in_browser,
            color: ThemeProvider.themeOf(context).id == "main"
                ? Colors.red[900]
                : Colors.white,
          ),
          onChangedFunction: (value) {
            widget._opening = value;
          },
        ),
        RequestFormDropDownListTile(
          hintText: "Seleziona il tipo",
          label: "Tipo",
          values: widget._typeValues,
          icon: Icon(
            Icons.featured_play_list,
            color: ThemeProvider.themeOf(context).id == "main"
                ? Colors.red[900]
                : Colors.white,
          ),
          onChangedFunction: (value) {
            widget._type = value;
          },
        ),
        RequestFormDropDownListTile(
          hintText: "Seleziona il colore",
          label: "Colore",
          values: widget._colorValues,
          icon: Icon(
            Icons.format_paint,
            color: ThemeProvider.themeOf(context).id == "main"
                ? Colors.red[900]
                : Colors.white,
          ),
          onChangedFunction: (value) {
            widget._color = value;
          },
        ),
        RequestFormDropDownListTile(
          hintText: "Seleziona il veicolo",
          label: "Veicolo",
          values: widget._vehicleValues,
          icon: Icon(
            Icons.rv_hookup,
            color: ThemeProvider.themeOf(context).id == "main"
                ? Colors.red[900]
                : Colors.white,
          ),
          onChangedFunction: (value) {
            widget._vehicle = value;
          },
        ),
        ListTile(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              backgroundColor: Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              label: Text(
                'Ultimo controllo',
                style: TextStyle(
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
          subtitle: Theme(
            data: ThemeData(
              buttonTheme: ThemeProvider.themeOf(context).data.buttonTheme,
              accentColor: ThemeProvider.themeOf(context).data.accentColor,
              primaryColor: ThemeProvider.themeOf(context).data.primaryColor,
              fontFamily: 'Nunito',
            ),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(8.0),
              child: DateTimeField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ThemeProvider.themeOf(context).id == "main"
                      ? Colors.white
                      : Colors.grey[850],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    color: ThemeProvider.themeOf(context).id == "main"
                        ? Colors.red[900]
                        : Colors.white,
                  ),
                  counterStyle: TextStyle(
                    color: ThemeProvider.themeOf(context).id == "main"
                        ? Colors.grey
                        : Colors.white,
                    fontFamily: 'Nunito',
                  ),
                  hintText: 'Inserisci data ultimo controllo',
                  hintStyle: TextStyle(
                    color: ThemeProvider.themeOf(context).id == "main"
                        ? Colors.grey
                        : Colors.white,
                    fontFamily: 'Nunito',
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      style: BorderStyle.none,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      color: Colors.redAccent,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(
                  color: ThemeProvider.themeOf(context).id == "main"
                      ? Colors.grey
                      : Colors.white,
                  fontFamily: 'Nunito',
                ),
                format: DateFormat("dd-MM-yyyy"),
                onShowPicker: (context, value) {
                  return showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    initialDate: value ?? DateTime.now(),
                    lastDate: DateTime.now(),
                    locale: Locale('it'),
                  );
                },
                validator: (value) {
                  if (value == null) {
                    return 'Inserisci un valore';
                  } else
                    return null;
                },
                onSaved: (value) {
                  setState(() {
                    widget._lastCheck = value;
                  });
                },
              ),
            ),
          ),
        ),
        SizedBox(
          height: 75,
        ),
      ]);
    }
    return tiles;
  }

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder(
        future: this.initFuture(),
        builder: (context, result) {
          switch (result.connectionState) {
            case ConnectionState.none:
              return new LoadingShimmer();
            case ConnectionState.active:
            case ConnectionState.waiting:
              return new LoadingShimmer();
            case ConnectionState.done:
              return Form(
                key: _key,
                child: ScrollConfiguration(
                  behavior: RemoveGlow(),
                  child: SingleChildScrollView(
                    child: Column(
                      children: this.buildListTileList(_placeMarks),
                    ),
                  ),
                ),
              );
          }
          return null;
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.done,
        ),
        backgroundColor: Colors.orangeAccent,
        onPressed: () {
          if (_key.currentState.validate()) {
            _key.currentState.save();
            Hydrant newHydrant = _isFireman
                ? Hydrant.fromFireman(
                    widget._firstAttack,
                    widget._secondAttack,
                    widget._pressure,
                    widget._cap,
                    widget._city,
                    widget.lat,
                    widget.long,
                    widget._color,
                    widget._lastCheck,
                    widget._notes,
                    widget._opening,
                    widget._street,
                    widget._number,
                    widget._type,
                    widget._vehicle,
                  )
                : Hydrant.fromCitizen(
                    widget._cap,
                    widget._city,
                    widget.lat,
                    widget.long,
                    widget._notes,
                    widget._street,
                    widget._number,
                  );
            if (widget.isNewRequest) {
              ServicesProvider()
                  .getRequestsServices()
                  .addRequest(
                    newHydrant,
                    _user.getId(),
                  )
                  .then((request) {
                if (request == null) {
                  new TopFlushbar("Errore",
                          "Errore nell'aggiunta della richiesta", false)
                      .show(context);
                } else {
                  new TopFlushbar(
                          "Idrante segnalato",
                          (_isFireman)
                              ? "L'idrante è stato aggiunto con successo alla mappa!"
                              : "La segnalazione dell'idrante è stata effettuata con successo!",
                          true)
                      .show(context);
                }
              });
            } else {
              newHydrant.setId(widget.oldHydrant.getId());
              ServicesProvider()
                  .getRequestsServices()
                  .approveRequest(
                      newHydrant, widget.oldRequest.getId(), _user.getId())
                  .then((status) {
                if (status) {
                  new TopFlushbar(
                          "Idrante registrato",
                          "La richiesta è stata approvata e l'idrante è stato aggiunto con successo alla mappa!",
                          true)
                      .show(context);
                } else {
                  new TopFlushbar("Errore",
                          "Errore nell'approvazione della richiesta", false)
                      .show(context);
                }
              });
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          } else {
            new TopFlushbar(
                    "Compila tutti i campi!",
                    "Si prega di compilare tutti i campi affinchè la registazione di un nuovo idrante abbia esito positivo",
                    false)
                .show(context);
          }
        },
      ),
    );
  }
}
