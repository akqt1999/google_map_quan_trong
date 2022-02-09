import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:prefs/prefs.dart';
import 'package:flutter/widgets.dart';
import 'package:testspappp/address_seach.dart';
import 'package:testspappp/place_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'address_input.dart';
import 'lcoation_service.dart';
import 'package:image/image.dart' as image;

import 'package:flutter_svg/flutter_svg.dart';


class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

final searchScaffoldKey = GlobalKey<ScaffoldState>();
final homeScaffoldKey = GlobalKey<ScaffoldState>();


class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller=Completer();

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      //   target: LatLng(37.43296265331129, -122.08832357078792),
      target: LatLng(16.038988698505317, 108.21491418372946),
      tilt: 50.440717697143555,
      zoom: 19.151926040649414); //CameraPosition nay la no se

  static final Marker _kGooglePlexMarker = Marker(
      markerId: MarkerId('_kGooglePlex'),
      infoWindow: InfoWindow(title: 'google fexler'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(16.038988698505317, 108.21491418372946));

  static final Marker _kPlexMarker = Marker(
      markerId: MarkerId('_PlexMarker'),
      infoWindow: InfoWindow(title: 'cai lon be nhu'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      position: LatLng(16.038824, 108.215279));

  static final Polyline _kpolyline = Polyline(
      polylineId: PolylineId('_kpolyline'),
      points: [
        LatLng(16.038988698505317, 108.21491418372946),
        LatLng(16.038824, 108.215279)
      ],
      width: 5,
      color: Colors.red);

  static final Polygon _kpolygon = Polygon(
      polygonId: PolygonId('_kpolygon'),
      points: [
        LatLng(16.038988698505317, 108.21491418372946),
        LatLng(16.038824, 108.215279),
        LatLng(16.036906, 108.215579),
        // LatLng(16.037061, 108.216995)
      ],
      fillColor: Colors.black12);

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();

  List<LatLng> polygonLatLngs = <LatLng>[];
  List<LatLng> polylineLatLngs = <LatLng>[];

  final _destinationController = TextEditingController();
  final _originController = TextEditingController(); //10:28

  int _polygonIdCouter = 0;
  int _polylineIdCouter = 0;
  int _clickMapCouter = 0;
  int _markerCouter = 0;
  String markerId = "";
  bool countLoad = false;

  static LatLng _initPosition;
  static LatLng _lastMapPosition = _initPosition;


  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    // _setMarker(LatLng(16.038824, 108.215279), "cai lon be nhu");
    super.initState();
    _getCurrentLocation();

    if (_initPosition != null) {
      _setMarker(
          poin: _initPosition,
          nameProvince: "xin chao",
          nameMarker: "do\nan");
    }
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }


  Future<void> _setMarker(
      {LatLng poin, String nameProvince, String nameMarker}) async {
    String markerId = "markerID_$_markerCouter";
    _markerCouter++;

    setState(() async {
      var marker = Marker(
          markerId: MarkerId(markerId),
          position: poin,
          //   icon:BitmapDescriptor.fromBytes(desiredMarker),
          icon: await bitmapDescriptorFromSvgAsset(context, nameMarker),

          // alpha: 0.1,
          infoWindow: InfoWindow(
            title: nameProvince,
          ));

      _markers.add(
        marker,
      );
    });
  }


  _search() async {
    final sessionToken = Uuid().v4();
    print("sessionToken:$sessionToken");
    final Suggestion result = await showSearch(
        context: context, delegate: AddressSearch(sessionToken));
    if (result != null) {
      setState(() {
        _originController.text = result.description;
      });
    }
  }

  void _setPolygson() {
    final String polygonId = 'polygons_$_polygonIdCouter';
    _polygonIdCouter++;
    _polygons.add(Polygon(
        polygonId: PolygonId(polygonId),
        points: polygonLatLngs,
        strokeColor: Colors.red,
        strokeWidth: 2,
        fillColor: Colors.black12));
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineId = 'polyline_$_polylineIdCouter';
    _polylineIdCouter++;

    _polylines.add(Polyline(
      polylineId: PolylineId(polylineId),
      width: 2,
      color: Colors.red,
      points: points
          .map(
            (e) => LatLng(e.latitude, e.longitude),
      )
          .toList(),
    ));
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller.complete(controller);
    });
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('loii_: Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('loii_: Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print(
          'loii_: Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    print("loii_: ${position.latitude},${position.longitude}");
    setState(() {
      _initPosition = new LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) async {

    });
    return Scaffold(
      appBar: AppBar(
        title: Text("bu lon be nhu"),
      ),
      body: _initPosition == null
          ? Center(child: Text('loading map...'),)
          : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              //Expanded co nghia la no se lay tat cac cai khaong casch con lai
              Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: AddressInput(
                          controller: _originController,
                          iconData: Icons.gps_fixed,
                          hintText: "origin",
                          enabled: true,
                          onTap: _search,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: AddressInput(
                          controller: _destinationController,
                          iconData: Icons.directions,
                          hintText: "destination",
                          enabled: true,
                          onTap: () async {
                            final sessionToken = Uuid().v4();
                            final Suggestion result = await showSearch(
                                context: context,
                                delegate: AddressSearch(sessionToken));
                            _destinationController.text = result.description;
                          },
                        ),
                      ),
                    ],
                  )),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () async {
                        // da nang , quang nam
                        var directions = await LocationService().getDirections(
                            _originController.text,
                            _destinationController.text);

                        _goToPlace(
                            directions['start_location']['lat'],
                            directions['start_location']['lng'],
                            directions['bounds_ne'],
                            directions['bounds_sw']);

                        print(directions['polyline_decoded']);

                        setState(() {
                          _setPolyline(directions['polyline_decoded']);
                        });

                        // da nang , quang nam
                        //var direction = await LocationService()
                        //      .getDirections();
                        // _goToPlace(place);
                      },
                      icon: Icon(Icons.search)),
                  InkWell(
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 28,
                    ),
                    onTap: () {
                      print("cc");
                      //    LocationService().getCurrentLovcation();
                    },
                  )
                ],
              ),
            ],
          ),
          Expanded(
              flex: 5,
              child: GoogleMap(
                //  polygons: {_kpolygon},
                //markers: {_kGooglePlexMarker, _kPlexMarker},
                //mapType: MapType.normal,
                //polylines: {_kpolyline},
                polylines: _polylines,
                polygons: _polygons,
                markers: _markers,
                zoomGesturesEnabled: true,
                onCameraMove: _onCameraMove,
                initialCameraPosition: CameraPosition(
                    target: _initPosition,
                    zoom: 18
                ),
                onMapCreated: (GoogleMapController controller){
                  _controller.complete(controller);
                },
                onTap: (point) async {
                  _clickMapCouter++;
                  polylineLatLngs.add(point);
                  if (_clickMapCouter == 2) {
                    var directions = await LocationService()
                        .getDirectionsByLatLng(
                        origin: polylineLatLngs[0],
                        destination: polylineLatLngs[1]);
                    _setPolyline(directions['polyline_decoded']);

                    print('fads${directions['distance']['text']}');
                  }
                  // var directions=await LocationService().
                  //  getDirectionsByLatLng(destination: point,origin: point);

                  var detailAddress = await LocationService()
                      .getNameAddressByLatLng(
                      lat: point.latitude, lng: point.longitude);

                  setState(() {
                    _setMarker(
                        poin: point,
                        nameProvince: detailAddress,
                        nameMarker: 'do\nan');

                    //polygonLatLngs.add(point);
                    // _setPolygson();
                  });
                },
              ))
        ],
      ),
    );
  }

  Future<void> _goToPlace(double lat, double lng, Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw) async {
    // final double lat = place['geometry']['location']['lat'];
    //   final double lng = place['geometry']['location']['lng'];

    //var nameProvince = place['address_components'][0]['long_name'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );
    //_setMarker(LatLng(lat, lng), nameProvince);
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(BuildContext context,
      String price) async {
    // Read SVG file as String
    // String svgString = await DefaultAssetBundle.of(context).loadString(assetName,);
    // Create DrawableRoot from SVG String
    String svgStrings =
    '''<svg width="75" height="50" xmlns="http://www.w3.org/2000/svg">

  <path stroke="#000" id="svg_1" d="m0.823 12.223c-1.368-2.628-1.008-5.004 0.684-6.984 1.8-2.088 4.932-3.78 9.792-5.22 6.66 4.68 13.644 9.864 21.636 15.696 7.884 5.904
    20.124 14.436 25.452 19.188 5.148 4.428 2.484 0.108 5.616 8.028 3.096 7.992 7.344 20.952 12.888 39.456 8.713-0.36 17.1 0.468 25.848 2.088
    8.678 1.728 19.549 5.076 25.813 7.956 6.121 2.772 9.684 5.76 10.836 8.82l0.684 8.712-2.088 1.404c-5.939 26.712-10.08 50.58-12.563 72.576-2.521
    21.889-2.232 39.744-2.449 58.283-0.287 18.504-0.107 35.354 0.684 51.66-17.459 5.113-33.947
    7.344-50.58 6.984-16.559-0.469-32.471-3.564-48.167-9.432-2.556-31.752-5.328-62.064-8.748-92.484-3.384-30.42-7.272-59.544-11.52-88.632l-2.448-1.08v-8.028c3.816-6.192 10.656-10.764 20.952-14.112 10.296-3.276 23.4-5.184 40.14-5.58l-12.564-34.74c-8.496-5.76-16.776-11.268-25.128-17.1-8.42-5.827-16.484-11.551-24.764-17.455z" stroke-width="1.5" fill="#78c188"/>
  <path stroke="#000" id="svg_2" d="m9.175 2.107c-3.24 1.332-5.4 2.592-6.624 4.176-1.26 1.44-1.44 4.176-0.684 4.896 0.792 0.612 3.78 0.108 5.22-0.684
     1.116-0.828 1.98-2.88 2.448-4.212 0.504-1.476 0.792-2.736 0.72-4.176h-1.08z" stroke-width="1.5" fill="#78c188"/>

  <text  y="19.77155" x="24.02531" fill="#ffffff">$price</text>
</svg>''';

    //------------

// preserve" viewBox="-190 0 840.089 300.889" enable-background="new -190 0  840.089 340.889"
    String cc = '''
    <svg
     width="70045" height="50940"
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://www.w3.org/2000/svg"
    xmlns:cc="http://web.resource.org/cc/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:svg="http://www.w3.org/2000/svg"



    space="preserve" viewBox="0 0 240.089 500.889" enable-background="new 0 0 240.089 300.889" overflow="visible">
    <g id="Layer_1">
          <g font-size="101" font-family="sans-serif" fill="black" stroke="none"
          text-anchor="middle">
 <text  y="325" x="16">"đồ ăn"</text>
  </g>
  <p>
    Terms & Info
  </p>
    <g stroke-miterlimit="10" stroke="#000" stroke-width=".036" clip-rule="evenodd" fill-rule="evenodd">
    <path d="m0.823 12.223c-1.368-2.628-1.008-5.004 0.684-6.984 1.8-2.088 4.932-3.78 9.792-5.22 6.66 4.68 13.644 9.864 21.636 15.696 7.884 5.904
    20.124 14.436 25.452 19.188 5.148 4.428 2.484 0.108 5.616 8.028 3.096 7.992 7.344 20.952 12.888 39.456 8.713-0.36 17.1 0.468 25.848 2.088
    8.678 1.728 19.549 5.076 25.813 7.956 6.121 2.772 9.684 5.76 10.836 8.82l0.684 8.712-2.088 1.404c-5.939 26.712-10.08 50.58-12.563 72.576-2.521
    21.889-2.232 39.744-2.449 58.283-0.287 18.504-0.107 35.354 0.684 51.66-17.459 5.113-33.947
    7.344-50.58 6.984-16.559-0.469-32.471-3.564-48.167-9.432-2.556-31.752-5.328-62.064-8.748-92.484-3.384-30.42-7.272-59.544-11.52-88.632l-2.448-1.08v-8.028c3.816-6.192 10.656-10.764 20.952-14.112 10.296-3.276 23.4-5.184 40.14-5.58l-12.564-34.74c-8.496-5.76-16.776-11.268-25.128-17.1-8.42-5.827-16.484-11.551-24.764-17.455z"/>

    <path d="m9.175 2.107c-3.24 1.332-5.4 2.592-6.624 4.176-1.26 1.44-1.44 4.176-0.684 4.896 0.792 0.612 3.78 0.108 5.22-0.684
     1.116-0.828 1.98-2.88 2.448-4.212 0.504-1.476 0.792-2.736 0.72-4.176h-1.08z" fill="#fff"/>
    <path d="m4.999 13.267c2.556 0.145 4.536-0.432 5.94-1.728 1.332-1.368 2.196-3.42 2.448-6.3l46.764 33.876 20.953 62.46c-2.484
     1.044-4.32 1.332-5.939 0.72-1.621-0.612-2.736-2.016-3.493-4.212l-19.189-50.261c5.22 0.936 7.632 1.332 7.668 1.044-0.144-0.252-2.664-1.188-7.992-2.664 4.104-1.296 6.12-1.98 6.048-2.196-0.108-0.216-2.304 0.072-6.588 0.864 2.052-3.78 2.952-5.652 2.844-5.76-0.18-0.072-1.368 1.476-3.708 5.076-15.228-10.295-30.492-20.592-45.756-30.924z" fill="#fff"/>
    <path d="m77.611 84.835l1.043 3.852c5.51-0.648 11.449-0.324 18.504 0.684 6.984 1.152 22.285 5.004 23.006 5.58 0.432 0.324-12.744-2.484-19.514-3.132-6.84-0.648-13.68-0.936-20.951-0.72l3.133 9.108c1.115-0.108 1.654-0.648 1.764-1.764-0.072-1.152-1.836-4.68-1.404-4.896 0.504-0.36 3.42 2.376 4.176 3.492 0.721 1.044 0.504 2.16-0.359 3.492-1.08 1.368-2.773 4.032-5.904 4.536-3.277 0.288-11.269-1.368-13.284-2.448-2.088-1.08-1.692-2.52 1.044-4.176l-1.728-7.344c-4.932-0.72-10.008-0.72-15.372 0-5.436 0.72-15.732 4.248-16.74 4.212-1.008-0.252 5.652-3.996 10.8-5.256 5.04-1.26 11.556-2.124 19.548-2.448l-1.728-3.132c-9 0.036-17.352 0.756-25.488 2.448-8.244 1.548-17.964 4.968-23.04 7.344-5.004 2.304-7.38 4.932-6.984 6.624 0.36 1.548 2.556 1.62 9.072 3.132 6.48 1.476 16.452 4.68 29.34 5.58 12.888 0.792 33.732 0.288 47.125-0.684 13.211-1.116 25.486-3.996 32.111-5.58 6.48-1.62 7.703-1.98 6.984-3.852-0.973-1.944-6.049-5.04-11.881-7.344-5.904-2.448-15.803-5.4-23.039-6.624-7.234-1.261-13.931-1.44-20.23-0.685z" fill="#fff"/>
    <path d="m11.623 111.55l-1.044-5.616 6.624 1.404 0.72 3.852 4.536 1.044 1.044-3.132 6.624 1.044 1.044 4.176 4.896 1.044 1.728-4.176 8.388 1.404 1.044 4.536 6.624 0.324 1.764-4.536 7.668 0.36 1.764 4.536h5.904l1.764-4.896 8.389 0.36 1.367 3.852 5.941-0.36 1.402-4.536 7.344-0.36 2.09 3.132 6.982-1.044 1.045-3.816 6.264-1.404 3.168 3.492 4.859-1.404 2.449-4.536 4.896-1.404 3.131 3.168 3.852-1.044-0.359 3.456c-5.545 1.764-12.275 3.348-20.592 4.896-8.389 1.44-18.648 3.312-28.98 4.212-10.295 0.828-20.484 2.34-32.796 1.044-12.463-1.35-26.215-4.37-41.551-9.05z" fill="#fff"/>
    <path d="m7.087 112.74c3.492 2.772 10.368 5.076 20.952 6.984 10.656 1.944 26.604 4.824 42.228 4.536 15.624-0.324 39.745-4.572 50.616-6.264 10.729-1.692 13.607-3.852 13.607-3.852s-2.482 5.328-3.852 13.176c-1.332 7.884-2.016 10.872-2.771 20.592-11.699 18.036-26.531 29.483-45.035 34.921-18.613 5.363-40.213 4.428-65.629-2.809-0.252-1.08-1.044-7.164-2.772-18.396-1.731-11.35-4.179-27.37-7.347-48.89z" fill="#fff"/>
    <path d="m17.923 184.23c7.776 3.025 16.92 4.717 28.26 5.221 11.34 0.396 25.272 2.447 38.737-2.447 13.248-5.041 26.604-13.969 40.5-27.217-2.232 17.641-3.744 33.732-4.537 49.104-0.791 15.301-1.008 29.197-0.359 42.266-17.533 6.588-34.057 9.791-50.256 9.756-16.236-0.037-31.428-3.457-46.404-10.117-0.216-3.924-0.756-11.195-1.764-22.355-0.969-11.3-2.409-25.67-4.173-44.21z" fill="#fff"/>
    <path d="m23.863 254.29c-0.504 1.225 3.168 2.809 11.16 4.896 8.1 2.051 22.212 7.596 36.648 7.309 14.256-0.396 30.239-3.492 48.493-9.434l-0.686 27.938c-14.832 4.752-29.664 6.947-45.035 6.982-15.516-0.107-30.78-2.555-46.764-7.344-0.324-6.695-0.792-12.275-1.404-17.424-0.604-5.17-1.504-9.34-2.404-12.94z" fill="#fff"/>
    </g>

    </g>

    </svg>''';
//space="preserve" viewBox="0 0 140.089 300.889" enable-background="new 0 0 140.089 300.889" overflow="visible">
    String cc2 = '''

 <svg
    width="745" height="540"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
     xmlns="http://www.w3.org/2000/svg" xmlns:cc="http://web.resource.org/cc/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:svg="http://www.w3.org/2000/svg"
      space="preserve" viewBox="0 0 23.089 39.889" enable-background="new 0 0 140.089 300.889" overflow="visible">
  <g id="Layer_1">
    <g stroke-miterlimit="10" stroke="#000" stroke-width=".036" clip-rule="evenodd" fill-rule="evenodd">
      <path d="m0.823 12.223c-1.368-2.628-1.008-5.004 0.684-6.984 1.8-2.088 4.932-3.78 9.792-5.22 6.66 4.68 13.644 9.864 21.636 15.696 7.884 5.904 20.124 14.436 25.452 19.188 5.148 4.428 2.484 0.108 5.616 8.028 3.096 7.992 7.344 20.952 12.888 39.456 8.713-0.36 17.1 0.468 25.848 2.088 8.678 1.728 19.549 5.076 25.813 7.956 6.121 2.772 9.684 5.76 10.836 8.82l0.684 8.712-2.088 1.404c-5.939 26.712-10.08 50.58-12.563 72.576-2.521 21.889-2.232 39.744-2.449 58.283-0.287 18.504-0.107 35.354 0.684 51.66-17.459 5.113-33.947 7.344-50.58 6.984-16.559-0.469-32.471-3.564-48.167-9.432-2.556-31.752-5.328-62.064-8.748-92.484-3.384-30.42-7.272-59.544-11.52-88.632l-2.448-1.08v-8.028c3.816-6.192 10.656-10.764 20.952-14.112 10.296-3.276 23.4-5.184 40.14-5.58l-12.564-34.74c-8.496-5.76-16.776-11.268-25.128-17.1-8.42-5.827-16.484-11.551-24.764-17.455z"/>
      <path d="m9.175 2.107c-3.24 1.332-5.4 2.592-6.624 4.176-1.26 1.44-1.44 4.176-0.684 4.896 0.792 0.612 3.78 0.108 5.22-0.684 1.116-0.828 1.98-2.88 2.448-4.212 0.504-1.476 0.792-2.736 0.72-4.176h-1.08z" fill="#fff"/>
      <path d="m4.999 13.267c2.556 0.145 4.536-0.432 5.94-1.728 1.332-1.368 2.196-3.42 2.448-6.3l46.764 33.876 20.953 62.46c-2.484 1.044-4.32 1.332-5.939 0.72-1.621-0.612-2.736-2.016-3.493-4.212l-19.189-50.261c5.22 0.936 7.632 1.332 7.668 1.044-0.144-0.252-2.664-1.188-7.992-2.664 4.104-1.296 6.12-1.98 6.048-2.196-0.108-0.216-2.304 0.072-6.588 0.864 2.052-3.78 2.952-5.652 2.844-5.76-0.18-0.072-1.368 1.476-3.708 5.076-15.228-10.295-30.492-20.592-45.756-30.924z" fill="#fff"/>
      <path d="m77.611 84.835l1.043 3.852c5.51-0.648 11.449-0.324 18.504 0.684 6.984 1.152 22.285 5.004 23.006 5.58 0.432 0.324-12.744-2.484-19.514-3.132-6.84-0.648-13.68-0.936-20.951-0.72l3.133 9.108c1.115-0.108 1.654-0.648 1.764-1.764-0.072-1.152-1.836-4.68-1.404-4.896 0.504-0.36 3.42 2.376 4.176 3.492 0.721 1.044 0.504 2.16-0.359 3.492-1.08 1.368-2.773 4.032-5.904 4.536-3.277 0.288-11.269-1.368-13.284-2.448-2.088-1.08-1.692-2.52 1.044-4.176l-1.728-7.344c-4.932-0.72-10.008-0.72-15.372 0-5.436 0.72-15.732 4.248-16.74 4.212-1.008-0.252 5.652-3.996 10.8-5.256 5.04-1.26 11.556-2.124 19.548-2.448l-1.728-3.132c-9 0.036-17.352 0.756-25.488 2.448-8.244 1.548-17.964 4.968-23.04 7.344-5.004 2.304-7.38 4.932-6.984 6.624 0.36 1.548 2.556 1.62 9.072 3.132 6.48 1.476 16.452 4.68 29.34 5.58 12.888 0.792 33.732 0.288 47.125-0.684 13.211-1.116 25.486-3.996 32.111-5.58 6.48-1.62 7.703-1.98 6.984-3.852-0.973-1.944-6.049-5.04-11.881-7.344-5.904-2.448-15.803-5.4-23.039-6.624-7.234-1.261-13.931-1.44-20.23-0.685z" fill="#fff"/>
      <path d="m11.623 111.55l-1.044-5.616 6.624 1.404 0.72 3.852 4.536 1.044 1.044-3.132 6.624 1.044 1.044 4.176 4.896 1.044 1.728-4.176 8.388 1.404 1.044 4.536 6.624 0.324 1.764-4.536 7.668 0.36 1.764 4.536h5.904l1.764-4.896 8.389 0.36 1.367 3.852 5.941-0.36 1.402-4.536 7.344-0.36 2.09 3.132 6.982-1.044 1.045-3.816 6.264-1.404 3.168 3.492 4.859-1.404 2.449-4.536 4.896-1.404 3.131 3.168 3.852-1.044-0.359 3.456c-5.545 1.764-12.275 3.348-20.592 4.896-8.389 1.44-18.648 3.312-28.98 4.212-10.295 0.828-20.484 2.34-32.796 1.044-12.463-1.35-26.215-4.37-41.551-9.05z" fill="#fff"/>
      <path d="m7.087 112.74c3.492 2.772 10.368 5.076 20.952 6.984 10.656 1.944 26.604 4.824 42.228 4.536 15.624-0.324 39.745-4.572 50.616-6.264 10.729-1.692 13.607-3.852 13.607-3.852s-2.482 5.328-3.852 13.176c-1.332 7.884-2.016 10.872-2.771 20.592-11.699 18.036-26.531 29.483-45.035 34.921-18.613 5.363-40.213 4.428-65.629-2.809-0.252-1.08-1.044-7.164-2.772-18.396-1.731-11.35-4.179-27.37-7.347-48.89z" fill="#fff"/>
      <path d="m17.923 184.23c7.776 3.025 16.92 4.717 28.26 5.221 11.34 0.396 25.272 2.447 38.737-2.447 13.248-5.041 26.604-13.969 40.5-27.217-2.232 17.641-3.744 33.732-4.537 49.104-0.791 15.301-1.008 29.197-0.359 42.266-17.533 6.588-34.057 9.791-50.256 9.756-16.236-0.037-31.428-3.457-46.404-10.117-0.216-3.924-0.756-11.195-1.764-22.355-0.969-11.3-2.409-25.67-4.173-44.21z" fill="#fff"/>
      <path d="m23.863 254.29c-0.504 1.225 3.168 2.809 11.16 4.896 8.1 2.051 22.212 7.596 36.648 7.309 14.256-0.396 30.239-3.492 48.493-9.434l-0.686 27.938c-14.832 4.752-29.664 6.947-45.035 6.982-15.516-0.107-30.78-2.555-46.764-7.344-0.324-6.695-0.792-12.275-1.404-17.424-0.604-5.17-1.504-9.34-2.404-12.94z" fill="#fff"/>
    </g>
  </g>
</svg>

''';
//--------

    String svgStringsvipnhat =
    '''<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
    viewBox="-290 0 1250 1250" enable-background="new 0 0 1000 1000" xml:space="preserve">
<metadata> Svg Vector Icons : http://www.onlinewebfonts.com/icon </metadata>
<g><g transform="translate(0.000000,511.000000) scale(0.100000,-0.100000)">
<path fill="#78c188" d="M7085.4,4032.4l-984.8-975.2l-128.2-440.4l-128.2-438l-556.5,4.8L4731,2191l-14.5,145.2c-33.9,355.7-181.5,660.6-442.8,921.9c-191.2,191.2-401.7,317-655.8,396.8c-239.6,75-634,75-871.1,0c-484-152.4-856.6-508.1-1023.6-972.7c-75-212.9-99.2-590.4-53.2-825.1c84.7-435.5,416.2-863.9,830-1074.4c142.8-70.2,450.1-152.4,578.3-152.4h91.9v-2710.1V-4790H5106h1935.8v3484.4v3484.4l-394.4,4.8l-396.9,7.3l96.8,333.9l96.8,331.5l953.4,946.1l955.8,948.5l-128.2,128.3c-70.2,72.6-135.5,130.7-142.8,130.7C8075.1,5007.6,7627.4,4569.6,7085.4,4032.4z M3363.8,3316.2c312.1-48.4,655.8-280.7,813-546.9c84.7-142.8,154.9-365.4,154.9-486.4v-104H3751h-580.7v-580.7v-580.7H3088c-130.7,0-379.9,87.1-537.2,188.7c-186.3,121-309.7,263.8-416.2,488.8c-77.4,157.3-89.5,208.1-96.8,406.5c-7.3,167,0,268.6,31.5,382.3c108.9,406.5,500.9,759.8,912.3,830C3160.6,3342.8,3187.2,3342.8,3363.8,3316.2z M5711,1726.4c-12.1-38.7-208.1-699.3-435.6-1471.2c-227.5-771.9-423.5-1439.8-438-1480.9l-26.6-79.8h-626.7h-626.7V243.1v1548.6h1086.5h1088.9L5711,1726.4z M6654.7,243.1v-1548.6h-716.3c-670.3,0-716.2,2.4-706.6,43.6c7.3,21.8,212.9,718.7,457.3,1548.6L6132,1791.7h261.3h261.3V243.1z M4694.7-1702.4c0-7.3-118.6-416.2-266.2-912.2c-145.2-496.1-266.2-917.1-266.2-934c0-26.6,331.5-142.8,350.9-123.4c4.8,4.8,140.3,450.1,297.6,987.3l290.4,980l776.7,7.3l776.8,4.8v-1355.1v-1355.1H5106H3557.4v1355.1v1355.1H4126C4438.2-1692.7,4694.7-1697.6,4694.7-1702.4z"/></g></g>
  <text  y="19.77155" x="24.02531" fill="#000000">$price</text>end
     <g font-size="371" font-family="sans-serif" fill="red" stroke="none"
          text-anchor="end">
 <text  y="625" x="296">$price</text>
  </g>
</svg>
 ''';
    //----
    String svgStringsvipnhat3 =
    '''<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
<g><g transform="translate(0.000000,511.000000) scale(0.100000,-0.100000)"><path d="M7085.4,4032.4l-984.8-975.2l-128.2-440.4l-128.2-438l-556.5,4.8L4731,2191l-14.5,145.2c-33.9,355.7-181.5,660.6-442.8,921.9c-191.2,191.2-401.7,317-655.8,396.8c-239.6,75-634,75-871.1,0c-484-152.4-856.6-508.1-1023.6-972.7c-75-212.9-99.2-590.4-53.2-825.1c84.7-435.5,416.2-863.9,830-1074.4c142.8-70.2,450.1-152.4,578.3-152.4h91.9v-2710.1V-4790H5106h1935.8v3484.4v3484.4l-394.4,4.8l-396.9,7.3l96.8,333.9l96.8,331.5l953.4,946.1l955.8,948.5l-128.2,128.3c-70.2,72.6-135.5,130.7-142.8,130.7C8075.1,5007.6,7627.4,4569.6,7085.4,4032.4z M3363.8,3316.2c312.1-48.4,655.8-280.7,813-546.9c84.7-142.8,154.9-365.4,154.9-486.4v-104H3751h-580.7v-580.7v-580.7H3088c-130.7,0-379.9,87.1-537.2,188.7c-186.3,121-309.7,263.8-416.2,488.8c-77.4,157.3-89.5,208.1-96.8,406.5c-7.3,167,0,268.6,31.5,382.3c108.9,406.5,500.9,759.8,912.3,830C3160.6,3342.8,3187.2,3342.8,3363.8,3316.2z M5711,1726.4c-12.1-38.7-208.1-699.3-435.6-1471.2c-227.5-771.9-423.5-1439.8-438-1480.9l-26.6-79.8h-626.7h-626.7V243.1v1548.6h1086.5h1088.9L5711,1726.4z M6654.7,243.1v-1548.6h-716.3c-670.3,0-716.2,2.4-706.6,43.6c7.3,21.8,212.9,718.7,457.3,1548.6L6132,1791.7h261.3h261.3V243.1z M4694.7-1702.4c0-7.3-118.6-416.2-266.2-912.2c-145.2-496.1-266.2-917.1-266.2-934c0-26.6,331.5-142.8,350.9-123.4c4.8,4.8,140.3,450.1,297.6,987.3l290.4,980l776.7,7.3l776.8,4.8v-1355.1v-1355.1H5106H3557.4v1355.1v1355.1H4126C4438.2-1692.7,4694.7-1697.6,4694.7-1702.4z"/></g></g>
  <text  y="19.77155" x="24.02531" fill="#000000">$price</text>
</svg>
 ''';

    //------
    String svgStringsvipnhat2 =
    '''<svg width="75" height="50" xmlns="http://www.w3.org/2000/svg">

  <path stroke="#000" id="svg_1" d="m0.823 12.223c-1.368-2.628-1.008-5.004 0.684-6.984 1.8-2.088 4.932-3.78 9.792-5.22 6.66 4.68 13.644 9.864 21.636 15.696 7.884 5.904 20.124 14.436 25.452 19.188 5.148 4.428 2.484 0.108 5.616 8.028 3.096 7.992 7.344 20.952 12.888 39.456 8.713-0.36 17.1 0.468 25.848 2.088 8.678 1.728 19.549 5.076 25.813 7.956 6.121 2.772 9.684 5.76 10.836 8.82l0.684 8.712-2.088 1.404c-5.939 26.712-10.08 50.58-12.563 72.576-2.521 21.889-2.232 39.744-2.449 58.283-0.287 18.504-0.107 35.354 0.684 51.66-17.459 5.113-33.947 7.344-50.58 6.984-16.559-0.469-32.471-3.564-48.167-9.432-2.556-31.752-5.328-62.064-8.748-92.484-3.384-30.42-7.272-59.544-11.52-88.632l-2.448-1.08v-8.028c3.816-6.192 10.656-10.764 20.952-14.112 10.296-3.276 23.4-5.184 40.14-5.58l-12.564-34.74c-8.496-5.76-16.776-11.268-25.128-17.1-8.42-5.827-16.484-11.551-24.764-17.455z"/>
      <path d="m9.175 2.107c-3.24 1.332-5.4 2.592-6.624 4.176-1.26 1.44-1.44 4.176-0.684 4.896 0.792 0.612 3.78 0.108 5.22-0.684 1.116-0.828 1.98-2.88 2.448-4.212 0.504-1.476 0.792-2.736 0.72-4.176h-1.08z" fill="#fff"/>
      <path d="m4.999 13.267c2.556 0.145 4.536-0.432 5.94-1.728 1.332-1.368 2.196-3.42 2.448-6.3l46.764 33.876 20.953 62.46c-2.484 1.044-4.32 1.332-5.939 0.72-1.621-0.612-2.736-2.016-3.493-4.212l-19.189-50.261c5.22 0.936 7.632 1.332 7.668 1.044-0.144-0.252-2.664-1.188-7.992-2.664 4.104-1.296 6.12-1.98 6.048-2.196-0.108-0.216-2.304 0.072-6.588 0.864 2.052-3.78 2.952-5.652 2.844-5.76-0.18-0.072-1.368 1.476-3.708 5.076-15.228-10.295-30.492-20.592-45.756-30.924z" fill="#fff"/>
      <path d="m77.611 84.835l1.043 3.852c5.51-0.648 11.449-0.324 18.504 0.684 6.984 1.152 22.285 5.004 23.006 5.58 0.432 0.324-12.744-2.484-19.514-3.132-6.84-0.648-13.68-0.936-20.951-0.72l3.133 9.108c1.115-0.108 1.654-0.648 1.764-1.764-0.072-1.152-1.836-4.68-1.404-4.896 0.504-0.36 3.42 2.376 4.176 3.492 0.721 1.044 0.504 2.16-0.359 3.492-1.08 1.368-2.773 4.032-5.904 4.536-3.277 0.288-11.269-1.368-13.284-2.448-2.088-1.08-1.692-2.52 1.044-4.176l-1.728-7.344c-4.932-0.72-10.008-0.72-15.372 0-5.436 0.72-15.732 4.248-16.74 4.212-1.008-0.252 5.652-3.996 10.8-5.256 5.04-1.26 11.556-2.124 19.548-2.448l-1.728-3.132c-9 0.036-17.352 0.756-25.488 2.448-8.244 1.548-17.964 4.968-23.04 7.344-5.004 2.304-7.38 4.932-6.984 6.624 0.36 1.548 2.556 1.62 9.072 3.132 6.48 1.476 16.452 4.68 29.34 5.58 12.888 0.792 33.732 0.288 47.125-0.684 13.211-1.116 25.486-3.996 32.111-5.58 6.48-1.62 7.703-1.98 6.984-3.852-0.973-1.944-6.049-5.04-11.881-7.344-5.904-2.448-15.803-5.4-23.039-6.624-7.234-1.261-13.931-1.44-20.23-0.685z" fill="#fff"/>
      <path d="m11.623 111.55l-1.044-5.616 6.624 1.404 0.72 3.852 4.536 1.044 1.044-3.132 6.624 1.044 1.044 4.176 4.896 1.044 1.728-4.176 8.388 1.404 1.044 4.536 6.624 0.324 1.764-4.536 7.668 0.36 1.764 4.536h5.904l1.764-4.896 8.389 0.36 1.367 3.852 5.941-0.36 1.402-4.536 7.344-0.36 2.09 3.132 6.982-1.044 1.045-3.816 6.264-1.404 3.168 3.492 4.859-1.404 2.449-4.536 4.896-1.404 3.131 3.168 3.852-1.044-0.359 3.456c-5.545 1.764-12.275 3.348-20.592 4.896-8.389 1.44-18.648 3.312-28.98 4.212-10.295 0.828-20.484 2.34-32.796 1.044-12.463-1.35-26.215-4.37-41.551-9.05z" fill="#fff"/>
      <path d="m7.087 112.74c3.492 2.772 10.368 5.076 20.952 6.984 10.656 1.944 26.604 4.824 42.228 4.536 15.624-0.324 39.745-4.572 50.616-6.264 10.729-1.692 13.607-3.852 13.607-3.852s-2.482 5.328-3.852 13.176c-1.332 7.884-2.016 10.872-2.771 20.592-11.699 18.036-26.531 29.483-45.035 34.921-18.613 5.363-40.213 4.428-65.629-2.809-0.252-1.08-1.044-7.164-2.772-18.396-1.731-11.35-4.179-27.37-7.347-48.89z" fill="#fff"/>
      <path d="m17.923 184.23c7.776 3.025 16.92 4.717 28.26 5.221 11.34 0.396 25.272 2.447 38.737-2.447 13.248-5.041 26.604-13.969 40.5-27.217-2.232 17.641-3.744 33.732-4.537 49.104-0.791 15.301-1.008 29.197-0.359 42.266-17.533 6.588-34.057 9.791-50.256 9.756-16.236-0.037-31.428-3.457-46.404-10.117-0.216-3.924-0.756-11.195-1.764-22.355-0.969-11.3-2.409-25.67-4.173-44.21z" fill="#fff"/>
      <path d="m23.863 254.29c-0.504 1.225 3.168 2.809 11.16 4.896 8.1 2.051 22.212 7.596 36.648 7.309 14.256-0.396 30.239-3.492 48.493-9.434l-0.686 27.938c-14.832 4.752-29.664 6.947-45.035 6.982-15.516-0.107-30.78-2.555-46.764-7.344-0.324-6.695-0.792-12.275-1.404-17.424-0.604-5.17-1.504-9.34-2.404-12.94z"
   stroke-width="1.5" fill="#78c188"/>
  <text  y="19.77155" x="24.02531" fill="#000000">$price</text>
</svg>''';

//--------

    String svgStringUrl = '''<svg viewBox="0 0 200 200"
  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <image xlink:href="https://cdn-icons-png.flaticon.com/512/38/38431.png" height="200" width="200"/>
  <text  y="19.77155" x="24.02531" fill="#78c188">$price</text>
</svg>''';

    String svgStringUrl1 = '''<svg
  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <image xlink:href="https://cdn-icons-png.flaticon.com/512/38/38431.png" height="200" width="200"/>
  <text  y="59.77155" x="24.02531" fill="#78c188">$price</text>
</svg>''';

    //
    //https://mdn.mozillademos.org/files/6457/mdn_logo_only_color.png
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(
      svgStringsvipnhat,
      null,
    );

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width =
        75 * devicePixelRatio; // where 32 is your SVG's original width
    double height = 50 * devicePixelRatio; // same thing

    // Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }

/*
  Future<ui.Image> getUiImage(String imageAssetPath, int height, int width) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    image.Image baseSizeImage = image.decodeImage(assetImageByteData.buffer.asUint8List());
    image.Image resizeImage = image.copyResize(baseSizeImage, height: height, width: width);
    ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(String title) async {
    int IMAGE_WIDTH = 45;
    int IMAGE_HEIGHT = 45;
    AssetBundle bundle = DefaultAssetBundle.of(context);
    PictureRecorder recorder = new PictureRecorder();

    Canvas c = new Canvas(recorder);

    ui.Image myImage = await getUiImage( "assets/images/image.jpeg", IMAGE_WIDTH, IMAGE_HEIGHT);

    TextSpan span = new TextSpan(
      style: new TextStyle(
        color: Colors.white,
        fontSize: 35.0,
        fontWeight: FontWeight.bold,
      ),
      text: title,
    );

    TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.text = TextSpan(
      text: title,
      style: TextStyle(
        fontSize: 35.0,
        color: Colors.red,
        letterSpacing: 1.0,
        fontFamily: 'Roboto Bold',
      ),
    );


    tp.layout();
    tp.paint(c, new Offset(20.0, 10.0));

    /* Do your painting of the custom icon here, including drawing text, shapes, etc. */

    Picture p = recorder.endRecording();
    ByteData pngBytes =
    await (await p.toImage(tp.width.toInt() + 40, tp.height.toInt() + 20))
        .toByteData(format: ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes.buffer);

    return BitmapDescriptor.fromBytes(data);
  }

  Future<Uint8List> getBytesFromCanvas(String text) async {

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.grey;
    final int size = 100; //change this according to your app

    canvas.drawCircle(Offset(size / 1, size / 9), size / 1.0, paint1);



    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,//you can write your own text here or take from parameter
      style: TextStyle(
          fontSize: size / 3, color: Colors.black, fontWeight: FontWeight.bold),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
    );

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();

  }
*/


}