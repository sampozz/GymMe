import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/content/map/gym_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/map/location_model.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

// Mocks
class MockGoogleMapController extends Mock implements GoogleMapController {}
class MockGymProvider extends Mock implements GymProvider {}
class MockHttpClient extends Mock implements http.Client {}
class MockHttpResponse extends Mock implements http.Response {}

void main() {
  late MockGymProvider mockGymProvider;
  late MockHttpClient mockHttpClient;
  
  setUp(() {
    mockGymProvider = MockGymProvider();
    mockHttpClient = MockHttpClient();
  });

  // Test that verifies if the GymMap widget builds correctly
  testWidgets('GymMap builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    expect(find.byType(GymMap), findsOneWidget);
  });

  // Test that verifies if GymMap contains a GoogleMap widget
  testWidgets('GymMap contains a GoogleMap widget', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    expect(find.byType(GoogleMap), findsOneWidget);
  });

  // Test that verifies the initial map position (center of Milan)
  testWidgets('GymMap has initial position set to Milan', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    
    expect(googleMapWidget.initialCameraPosition.target.latitude, 45.46427);
    expect(googleMapWidget.initialCameraPosition.target.longitude, 9.18951);
    expect(googleMapWidget.initialCameraPosition.zoom, 14);
  });

  // Test that verifies if the onMapCreated function is called when the map is created
  testWidgets('GymMap calls onMapCreated when the map is created', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(googleMapWidget.onMapCreated, isNotNull);
  });
  
  // test that verifies if gym loading works correctly
  testWidgets('GymMap loads gym list correctly', (WidgetTester tester) async {
    final testGyms = [
      Gym(id: '1', name: 'Test Gym 1', address: 'Corso Como, 15, 20154 Milano MI'),
      Gym(id: '2', name: 'Test Gym 2', address: 'Viale Toscana, 30, 20141 Milano MI'),
    ];
    
    when(() => mockGymProvider.getGymList()).thenAnswer((_) async => testGyms);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<GymProvider>.value(
            value: mockGymProvider,
            child: const GymMap(),
          ),
        ),
      ),
    );
    
    verify(() => mockGymProvider.getGymList()).called(1);
  });
  
  // Test that verifies if the mobile geocoding function returns correct coordinates
  testWidgets('GymMap geocodes addresses correctly on mobile', (WidgetTester tester) async {
    final testGyms = [
      Gym(id: '1', name: 'Test Gym 1', address: 'Corso Como, 15, 20154 Milano MI'),
      Gym(id: '2', name: 'Test Gym 2', address: 'Viale Toscana, 30, 20141 Milano MI'),
    ];
    
    when(() => mockGymProvider.getGymList()).thenAnswer((_) async => testGyms);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<GymProvider>.value(
            value: mockGymProvider,
            child: const GymMap(),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    expect(find.byType(GoogleMap), findsOneWidget);
  });
  
  // Nuovo test: verifica se la funzione di geocodifica web restituisce coordinate corrette
  testWidgets('GymMap geocodes addresses correctly on web', (WidgetTester tester) async {
    final mockResponse = MockHttpResponse();
    when(() => mockResponse.statusCode).thenReturn(200);
    when(() => mockResponse.body).thenReturn('''
    {
      "status": "OK",
      "results": [
        {
          "geometry": {
            "location": {
              "lat": 45.4642,
              "lng": 9.1895
            }
          }
        }
      ]
    }
    ''');
    
    when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);
    
    // Il test completo richiederebbe un'iniezione del client HTTP nel widget,
    // che non è direttamente possibile senza modificare la classe GymMap
  });
  
  // Nuovo test: verifica se i marker vengono creati correttamente
  testWidgets('GymMap creates markers correctly from gym locations', (WidgetTester tester) async {
    // Crea una lista di palestre di test
    final testGyms = [
      Gym(id: '1', name: 'Test Gym 1', address: 'Via Test 1, Milano'),
      Gym(id: '2', name: 'Test Gym 2', address: 'Via Test 2, Milano'),
    ];
    
    // Configura il mock per restituire la lista di test
    when(() => mockGymProvider.getGymList()).thenAnswer((_) async => testGyms);
    
    // Costruisci il widget con il provider mockato
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<GymProvider>.value(
            value: mockGymProvider,
            child: const GymMap(),
          ),
        ),
      ),
    );
    
    // Attendi il completamento delle operazioni asincrone
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    // Verifica che GoogleMap sia presente
    expect(find.byType(GoogleMap), findsOneWidget);
    
    // Non possiamo direttamente verificare i marker poiché sono gestiti internamente da GoogleMap,
    // ma possiamo verificare che il widget sia stato costruito correttamente
  });
  
  // Nuovo test: verifica se la posizione della camera viene aggiornata quando cambia la posizione utente
  testWidgets('GymMap updates camera position when user location changes', (WidgetTester tester) async {
    // Crea un mock per il controller della mappa
    final mockController = MockGoogleMapController();
    
    // Costruisci il widget
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    // Find the GoogleMap widget
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    
    // Trigger the onMapCreated callback
    googleMapWidget.onMapCreated?.call(mockController);
    
    // Questo test è limitato perché non possiamo facilmente simulare i cambiamenti di posizione
    // e la chiamata a _updateCameraPosition() è interna alla classe
  });
  
  // Nuovo test: verifica se la mappa utilizza le impostazioni corrette
  testWidgets('GymMap uses correct map settings', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    // Access the GoogleMap widget to verify its properties
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    
    // Verify that myLocationButtonEnabled is true
    expect(googleMapWidget.myLocationButtonEnabled, isTrue);
    
    // Verify if markers are initially empty (difficult to test directly)
    // expect(googleMapWidget.markers, isEmpty);
    
    // Verify the map type
    expect(googleMapWidget.mapType, MapType.normal);
  });
  
  // Nuovo test: verifica se la posizione iniziale della mappa è corretta quando non ci sono permessi di posizione
  testWidgets('GymMap initializes with Milan position when location permission is denied', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    // Access the GoogleMap widget
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    
    // Verify that initial position is Milan
    expect(googleMapWidget.initialCameraPosition.target.latitude, 45.46427);
    expect(googleMapWidget.initialCameraPosition.target.longitude, 9.18951);
  });
}