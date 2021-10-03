import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<Album> createAlbum(String aname, String loc, String desc) async {
  final response = await http.get(
    Uri.parse(
        'https://WildAware-Server-and-Hardware.neeltron.repl.co/input?aname=' +
            aname +
            '&loc=' +
            loc +
            '&desc=' +
            desc),
  );
  print(response.body);
  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create album.');
  }
}

class Album {
  final String aname;
  final String loc;
  final String desc;

  Album({required this.aname, required this.loc, required this.desc});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      aname: json['aname'],
      loc: json['heading'],
      desc: json['desc'],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const MyHomePage(title: 'WildAware'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Image.network(
                'https://sandycrazylocus.neeltron.repl.co/wildawaremain.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              alignment: const Alignment(0, 0.7),
              child: FlatButton(
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 20.0),
                ),
                color: Colors.lightGreen,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyStatefulWidget()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static final List<Widget> _widgetOptions = <Widget>[
    allSightings(),
    const MyCustomForm(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WildAware'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.greenAccent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nature_people_outlined),
            label: 'Report a Sighting',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: callAsyncFetch(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return reportForm(snapshot.data ?? "");
          } else {
            return reportForm("");
          }
        });
    // Build a Form widget using the _formKey created above.
  }

  Future<String> callAsyncFetch() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return "";
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return "";
      }
    }

    _locationData = await location.getLocation();
    List<geocoding.Placemark> placemarks =
        await geocoding.placemarkFromCoordinates(
            _locationData.latitude ?? 0.0, _locationData.longitude ?? 0.0);
    geocoding.Placemark placeMark = placemarks[0];
    String? name = placeMark.name;
    // String subLocality = placeMark.subLocality;
    String? locality = placeMark.locality;
    String? administrativeArea = placeMark.administrativeArea;
    // String subAdministrativeArea = placeMark.administrativeArea;
    String? postalCode = placeMark.postalCode;
    String? country = placeMark.country;
    // String subThoroughfare = placeMark.subThoroughfare;
    String? thoroughfare = placeMark.thoroughfare;
    return "$name, $thoroughfare, $locality, $administrativeArea, $postalCode, $country";
  }

  Widget reportForm(location) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _name = TextEditingController();
    final TextEditingController _loc = TextEditingController(text: location);
    final TextEditingController _desc = TextEditingController();
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://sandycrazylocus.neeltron.repl.co/frog.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Name of the Animal'),
              controller: _name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Location'),
              controller: _loc,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              controller: _desc,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                    createAlbum(_name.text, _loc.text, _desc.text);
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List> getList() async {
  var url = "https://WildAware-Server-and-Hardware.neeltron.repl.co/output";
  HttpClient client = HttpClient();
  HttpClientRequest request = await client.getUrl(Uri.parse(url));
  HttpClientResponse response = await request.close();
  return response.transform(utf8.decoder).transform(json.decoder).toList();
}

Widget allSightings() {
  return FutureBuilder(
      future: getList(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 50,
            color: Colors.lightGreen,
            child: const Center(child: Text('No animals sighted!')),
          );
        }
        List content = snapshot.data![0];
        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: content.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Image.network(
                //   content[index]['image_url'],
                //   width: double.infinity,
                //   fit: BoxFit.cover,
                // ),
                ListTile(
                  leading: const Icon(Icons.album),
                  title: Text('${content[index]['aname']}'),
                  subtitle: Text('${content[index]['desc']}'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Found at ${content[index]['loc']}'),
                    TextButton(
                      child: const Text('Report'),
                      onPressed: () {/* ... */},
                    ),
                  ],
                ),
              ],
            ));
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        );
      });
}
