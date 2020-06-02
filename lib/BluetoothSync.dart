import 'dart:async';

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

//import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gbsalternative/MainTitle.dart';

import 'DatabaseHelper.dart';
import 'Backup/Register_bk.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class BluetoothSync extends StatefulWidget {
  User curUser;
  String inputMessage;

  BluetoothSync({
    Key key,
    @required this.curUser,
    @required this.inputMessage,
  }) : super(key: key);

  @override
  _BluetoothSync createState() => new _BluetoothSync(curUser, inputMessage);
}

class _BluetoothSync extends State<BluetoothSync> {
  //Initializing databse
  DatabaseHelper db = new DatabaseHelper();

  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  bool isEmpty = false;

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };

  User user;
  String inputMessage;

  _BluetoothSync(User curUser, String _inputMessage) {
    user = curUser;
    inputMessage = _inputMessage;
  }

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  String _messageBuffer = '';
  List<_Message> messages = List<_Message>();

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  /*
  //Scanning bluetooth devices
  _addDeviceTolist(final fb.BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }
  */

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en', 'US'), const Locale('de', 'DE')],
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          //title: Text(AppLocalization.of(context).heyWorld),

          title: Text("Appairer/connecter son apprareil"),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () async {
                // So, that when new devices are paired
                // while the app is running, user can refresh
                // the paired devices list.
                await getPairedDevices().then((_) {
                  show('Liste actualisée');
                });
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: SizedBox(
              height: 1.2 * MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Visibility(
                    visible: _isButtonUnavailable &&
                        _bluetoothState == BluetoothState.STATE_ON,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.yellow,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child:
                              //Text(AppLocalization.of(context).heyWorld)
                              Text(
                            'Activer le Bluetooth',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Switch(
                          value: _bluetoothState.isEnabled,
                          onChanged: (bool value) {
                            future() async {
                              if (value) {
                                await FlutterBluetoothSerial.instance
                                    .requestEnable();
                              } else {
                                await FlutterBluetoothSerial.instance
                                    .requestDisable();
                              }

                              await getPairedDevices();
                              _isButtonUnavailable = false;

                              if (_connected) {
                                _disconnect();
                              }
                            }

                            future().then((_) {
                              setState(() {});
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              "Appareils apparairés",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.blue),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Appareil:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                DropdownButton(
                                  items: _getDeviceItems(),
                                  //items: _buildListViewOfDevices(),
                                  onChanged: (value) =>
                                      setState(() => _device = value),
                                  value:
                                      _devicesList.isNotEmpty ? _device : null,
                                ),
                                RaisedButton(
                                  onPressed: _isButtonUnavailable
                                      ? null
                                      : _connected ? _disconnect : _connect,
                                  child: Text(
                                      _connected ? 'Déconnexion' : 'Connexion'),
                                ),
                              ],
                            ),
                          ),
                          /*Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                              children: <Widget>[
                                new Image.asset(
                                  'assets/ABSeat.png',
                                ),
                              ]
                          ),
                        ),
                      ),
                      */
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 20, 5),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "NOTE: Si vous ne trouvez pas gBs dans la liste, cliquez sur refresh. Sinon, appairez l'appareil en cliquant sur le bouton en dessous.",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 15),
                          RaisedButton(
                            elevation: 2,
                            child: Text("Réglages Bluetooth"),
                            onPressed: () {
                              FlutterBluetoothSerial.instance.openSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  /*
  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<fb.BluetoothDevice>> _buildListViewOfDevices() {
    List<DropdownMenuItem<fb.BluetoothDevice>> items = [];
    widget.devicesList.forEach((device) {
      items.add(DropdownMenuItem(
        child: Column(
          children: <Widget>[
            Text(device.name == '' ? '(unknown device)' : device.name),
            Text(device.id.toString()),
          ],
        ),
        value: device,
      ));
    });

    return items;
  }
  */

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
      _isButtonUnavailable = false;
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;

          connection.input.listen(_onDataReceived).onDone(() {
            // Example: Detect which side closed the connection
            // There should be `isDisconnecting` flag to show are we are (locally)
            // in middle of disconnecting process, should be set before calling
            // `dispose`, `finish` or `close`, which all causes to disconnect.
            // If we except the disconnection, `onDone` should be fired as result.
            // If we didn't except this (no flag set), it means closing by remote.
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });

          setState(() {
            _connected = true;
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });

        if (_connected) {
          //Lorsque l'on viens de l'inscription
          if (inputMessage == "inscription") {
            //Déconnexion immédiate sinon bug lors de lancement de jeux
            _disconnect();
            Navigator.pop(
              context,
              _device.address,
            );
          } else {
            //Insertion dans l'adresse MAC dans la BDD
            User updatedUser = User(
              userId: user.userId,
              userName: user.userName,
              userMode: user.userMode,
              userPic: user.userPic,
              userHeightTop: user.userHeightBottom,
              userHeightBottom: user.userHeightBottom,
              userMacAddress: _device.address,
            );
            db.updateUser(updatedUser);

            //Déconnexion immédiate sinon bug lors de lancement de jeux
            _disconnect();

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainTitle(
                          userIn: user,
                          messageIn: 0,
                        )));
            show('Vous êtes connecté à gBs');
          }
        } else
          show("Échec de connexion");
        /*    connection.input.listen(_onDataReceived).onDone((){
          if (this.mounted) {
            setState(() {});
          }
        }
        );*/

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

//   void _onDataReceived(Uint8List data) {
//     // Allocate buffer for parsed data
//     int backspacesCounter = 0;
//     data.forEach((byte) {
//       if (byte == 8 || byte == 127) {
//         backspacesCounter++;
//       }
//     });
//     Uint8List buffer = Uint8List(data.length - backspacesCounter);
//     int bufferIndex = buffer.length;
//
//     // Apply backspace control character
//     backspacesCounter = 0;
//     for (int i = data.length - 1; i >= 0; i--) {
//       if (data[i] == 8 || data[i] == 127) {
//         backspacesCounter++;
//       } else {
//         if (backspacesCounter > 0) {
//           backspacesCounter--;
//         } else {
//           buffer[--bufferIndex] = data[i];
//         }
//       }
//     }
//   }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    //show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    connection.output.add(utf8.encode("5" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection.output.add(utf8.encode("0" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned Off');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
      //print(_messageBuffer);
    }
  }

  String getValue() {
    return _messageBuffer;
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
