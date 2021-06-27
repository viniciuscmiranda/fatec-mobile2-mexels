import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'dart:convert' as json;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _getImages().then((value) => print(value));
  }

  static String _busca;

  static const String API_KEY =
      '563492ad6f9170000100000138ebcf46dfe846438ba4880c2067a459';

  Future _getImages() async {
    final urlCuratedPhotos =
        'https://api.pexels.com/v1/curated?per_page=40&page=1';

    final urlSearch =
        'https://api.pexels.com/v1/search?query=$_busca&per_page=40&page=1';

    var url = _busca == null || _busca.isEmpty ? urlCuratedPhotos : urlSearch;

    http.Response response =
        await http.get(Uri.parse(url), headers: {'Authorization': API_KEY});

    if (response.statusCode == 200) {
      return json.jsonDecode(response.body);
    } else {
      print("Erro ao obte imagens. Status Code: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF232A34),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xFF232A34),
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/pexels-white.png'),
                    height: 35,
                    fit: BoxFit.fitHeight,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        onSubmitted: (text) {
                          setState(() {
                            _busca = text;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                  future: _getImages(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Container(
                          width: 200,
                          height: 200,
                          alignment: Alignment.center,
                          child: Loading(
                            indicator: BallPulseIndicator(),
                            size: 200,
                            color: Colors.white,
                          ),
                        );
                      default:
                        print(snapshot.connectionState);
                        if (snapshot.hasError) {
                          return DeuRuimWidget(
                            mensagem: "Erro ao obter dados da API Pexels",
                            icon: FontAwesomeIcons.exclamationTriangle,
                          );
                        } else if ((_getCount(snapshot.data['photos'])) == 0) {
                          return DeuRuimWidget(
                            mensagem: "Nao encontramos resultados",
                            icon: FontAwesomeIcons.sadCry,
                          );
                        } else {
                          return Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: _createImageGrid(context, snapshot),
                          );
                        }
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  int _getCount(List data) {
    // O operador ?? valida se é nulo, caso contrário retorna um valor qualquer.
    return data.length ?? 0;
  }

  Widget _createImageGrid(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.only(top: 5, bottom: 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: _getCount(snapshot.data["photos"]),
      itemBuilder: (context, index) {
        return PexelsImage(data: snapshot.data, index: index);
      },
    );
  }
}

class PexelsImage extends StatelessWidget {
  final Map data;
  final int index;

  PexelsImage({@required this.data, @required this.index});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            data["photos"][index]["src"]["medium"],
            fit: BoxFit.cover,
            height: 300,
          ),
          LabelImageData(data: data, index: index),
        ],
      ),
    );
  }
}

class LabelImageData extends StatelessWidget {
  const LabelImageData({
    @required this.data,
    @required this.index,
  });

  final Map data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          height: 30,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Fotografo: ${data["photos"][index]["photographer"]}",
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.left,
              ),
              Text(
                "ID Fotografo: ${data["photos"][index]["photographer_id"]}",
                style: TextStyle(color: Colors.white, fontSize: 8),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeuRuimWidget extends StatelessWidget {
  final String mensagem;
  final IconData icon;

  DeuRuimWidget({this.mensagem, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Text(
            mensagem,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        SizedBox(
          height: 25,
        ),
        Icon(
          icon,
          color: Colors.green.shade500,
          size: 72,
        ),
      ],
    );
  }
}
