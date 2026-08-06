import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:sqflite/sqflite.dart';
// ⚙️ SYNTAX: 'hide context' prevents the 'context' variable in the path package 
// from colliding with Flutter's BuildContext, which is heavily used in UI routing.
import 'package:path/path.dart' hide context;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


// =====================================================================
// 1. TOP-LEVEL DATABASE INITIALIZATION
// =====================================================================

// 🎮 CONTROLS: The global connection to the local SQLite (Offline) database.
// ⚙️ SYNTAX: 'late' promises Dart we will assign this value before it is ever used.
late Future<Database> database;

// 🎮 CONTROLS: The global connection to the Cloud Firestore (Online) database.
// ⚙️ SYNTAX: 'late final' means it will be assigned exactly once, but only after Firebase boots up.
late final FirebaseFirestore db; 

// 🎮 CONTROLS: The absolute starting point of the entire application.
void main() async {
  // 🔄 PROCESS: Required when calling async code (like finding folder paths) before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // 🔄 PROCESS: Initializes the core Firebase app for the current device (Android/iOS).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 💡 LOGIC: Safely hooks up the default Firestore database now that Firebase is ready.
  db = FirebaseFirestore.instance;
  
  // 🔄 PROCESS: 1. Get the OS directory. 2. Append the filename. 3. Open the SQLite connection.
  database = openDatabase(
    join(await getDatabasesPath(), 'travelapp.db'),
    onCreate: (db, version) {
      // 💡 LOGIC: Executes once on fresh install to build the table structure (columns).
      return db.execute(
        'CREATE TABLE favorites(id TEXT PRIMARY KEY, name TEXT, location TEXT, imageUrl TEXT, price TEXT)',
      );
    },
    version: 1,
  );

  // 🔄 PROCESS: Boots up the actual visual interface.
  runApp(const MainApp());
}


// =====================================================================
// 2. CLOUD FIRESTORE FUNCTIONS (ONLINE DB)
// =====================================================================

// 🎮 CONTROLS: Pushing a favorited place to Google's Cloud Servers.
Future<void> addFavoriteToFirestore(Destination dest) async {
  // ⚙️ SYNTAX: Maps the Dart object's properties into a JSON dictionary format.
  final destinationData = <String, dynamic>{
    "cityName": dest.cityName,
    "countryName": dest.countryName,
    "tourPrice": dest.tourPrice,
    "rating": dest.rating,
    "imageUrl": dest.imageUrl,
    "continent": dest.continent, 
  };

  // 💡 LOGIC: Uses .doc(cityName).set() to use the city name as the ID. 
  // This physically prevents duplicates from being created if tapped multiple times.
  await db.collection("favorites").doc(dest.cityName).set(destinationData).then((_) {
    print('☁️ ${dest.cityName} pushed to Cloud Firestore!');
  });
}

// 🎮 CONTROLS: Deleting a place from Google's Cloud Servers when unfavorited.
Future<void> removeFavoriteFromFirestore(String cityName) async {
  await db.collection("favorites").doc(cityName).delete().then((_) {
    print('🗑️ $cityName removed from Cloud Firestore!');
  });
}


// =====================================================================
// 3. SQLITE FUNCTIONS & MODEL (OFFLINE DB)
// =====================================================================

// 🎮 CONTROLS: Blueprint for reading/writing local SQLite data.
class Favorite {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String price;

  Favorite({
    required this.id, 
    required this.name, 
    required this.location, 
    required this.imageUrl, 
    required this.price
  });

  // ⚙️ SYNTAX: Converts the object back into a Map so SQLite can write it to rows/columns.
  Map<String, Object?> toMap() {
    return {
      'id': id, 
      'name': name, 
      'location': location, 
      'imageUrl': imageUrl, 
      'price': price
    };
  }
}

// 🎮 CONTROLS: Saves destination locally.
Future<void> insertFavorite(Favorite fav) async {
  final db = await database;
  // 💡 LOGIC: ConflictAlgorithm.replace overwrites existing data instead of crashing if it exists.
  await db.insert('favorites', fav.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

// 🎮 CONTROLS: Fetches all saved items to display on the "Favorites" tab.
Future<List<Favorite>> getFavoritesList() async {
  final db = await database;
  final List<Map<String, Object?>> favMaps = await db.query('favorites');
  
  // 🔄 PROCESS: Loops through raw database rows and converts them back into 'Favorite' Dart objects.
  return [
    for (final {
          'id': id as String, 
          'name': name as String, 
          'location': location as String, 
          'imageUrl': imageUrl as String, 
          'price': price as String
        } in favMaps)
      Favorite(id: id, name: name, location: location, imageUrl: imageUrl, price: price),
  ];
}

// 🎮 CONTROLS: Deletes destination locally.
Future<void> deleteFavorite(String id) async {
  final db = await database;
  // ⚙️ SYNTAX: 'whereArgs' securely injects the ID to block SQL Injection attacks.
  await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
}

// 🎮 CONTROLS: Checks if a place is already saved when opening its Detail Screen.
Future<bool> checkIsFavorite(String id) async {
  final db = await database;
  final maps = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
  return maps.isNotEmpty; // 💡 LOGIC: True if it finds a match, False if empty.
}


// =====================================================================
// 4. MAIN DATA MODEL
// =====================================================================

// 🎮 CONTROLS: The master blueprint for how a Destination is built across the entire app.
class Destination {
  final bool favourite;
  final String imageUrl;
  final String cityName;
  final String countryName;
  final String continent; 
  final String rating;
  final String reviewCount;
  final String description;
  final String tourTitle;
  final String tourDuration;
  final String tourPrice;
  final String tourPersonText;
  final MapScreen mapScreen; 

  const Destination({
    required this.favourite,
    required this.imageUrl,
    required this.cityName,
    required this.countryName,
    required this.continent, 
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.tourTitle,
    required this.tourDuration,
    required this.tourPrice,
    required this.tourPersonText,
    required this.mapScreen,
  });
}


// =====================================================================
// 5. MOCK DATABASE (30 LOCATIONS)
// =====================================================================

// 🎮 CONTROLS: The hardcoded data that acts as our primary server for the app.
final List<Destination> myDestinations = [
  
  // ---------------- EUROPE ----------------
  const Destination(
    favourite: false,
    imageUrl: 'https://ik.imagekit.io/travalot/development/resources/attachments/2025/11/12/8fbd8b80-d71e-11f0-b871-9729adfa2385.jpg?tr=w-1600,h-1067,c-at_max:f-webp:q-85',
    cityName: 'Reykjavik', countryName: 'Iceland', continent: 'Europe', rating: '4.9/5', reviewCount: '187 reviews',
    description: 'Discover Iceland, a breathtaking blend of glaciers, volcanoes, geysers, and the Northern Lights.',
    tourTitle: 'Fire & Ice Trip', tourDuration: '6 Days 5 Nights', tourPrice: '\$630', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_reykjavik", markLocation: "pin_reykjavik", titlePlace: "Reykjavik", snippetData: "Fire & Ice", lati: 64.1466, lngi: -21.9426),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSABBDxMTS6VuQiuWr5HSiJBSd4B_IpvBoBqxS0Bes90zbm_tm3gJxnOVc&s=10',
    cityName: 'Highlands', countryName: 'Scotland', continent: 'Europe', rating: '4.8/5', reviewCount: '240 reviews',
    description: 'Experience the rugged beauty of the Scottish Highlands and ride the famous Jacobite steam train.',
    tourTitle: 'Loch Ness Tour', tourDuration: '3 Days 2 Nights', tourPrice: '\$250', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_lochness", markLocation: "pin_lochness", titlePlace: "Highlands", snippetData: "Scottish Lochs", lati: 57.3229, lngi: -4.4244),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/paris,eiffel_tower/all',
    cityName: 'Paris', countryName: 'France', continent: 'Europe', rating: '4.7/5', reviewCount: '530 reviews',
    description: 'The City of Light awaits. Marvel at the Eiffel Tower, explore the Louvre, and stroll along the Seine.',
    tourTitle: 'City of Light', tourDuration: '4 Days 3 Nights', tourPrice: '\$450', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_paris", markLocation: "pin_paris", titlePlace: "Paris", snippetData: "Eiffel Tower", lati: 48.8566, lngi: 2.3522),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/rome,colosseum/all',
    cityName: 'Rome', countryName: 'Italy', continent: 'Europe', rating: '4.9/5', reviewCount: '620 reviews',
    description: 'Step into ancient history by visiting the Colosseum, the Pantheon, and throwing a coin into the Trevi Fountain.',
    tourTitle: 'Roman Empire', tourDuration: '5 Days 4 Nights', tourPrice: '\$500', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_rome", markLocation: "pin_rome", titlePlace: "Rome", snippetData: "Colosseum", lati: 41.9028, lngi: 12.4964),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/athens,acropolis/all',
    cityName: 'Athens', countryName: 'Greece', continent: 'Europe', rating: '4.6/5', reviewCount: '310 reviews',
    description: 'Explore the cradle of Western civilization. Gaze upon the mighty Parthenon standing atop the Acropolis.',
    tourTitle: 'Acropolis Walk', tourDuration: '4 Days 3 Nights', tourPrice: '\$380', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_athens", markLocation: "pin_athens", titlePlace: "Athens", snippetData: "Parthenon", lati: 37.9838, lngi: 23.7275),
  ),

  // ---------------- ASIA ----------------
  const Destination(
    favourite: false,
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTEdMuu_LkD2i4gUS_wIvlVbRTetmC7lKTQ1rZl-QdVQ&s=10',
    cityName: 'Gilgit', countryName: 'Pakistan', continent: 'Asia', rating: '4.9/5', reviewCount: '312 reviews',
    description: 'Explore the majestic peaks of Gilgit Baltistan in the Karakoram. Walk among the vibrant autumn leaves.',
    tourTitle: 'Fairy Meadows', tourDuration: '7 Days 6 Nights', tourPrice: '\$450', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_hunza", markLocation: "pin_hunza", titlePlace: "Gilgit", snippetData: "Karakoram", lati: 35.9208, lngi: 74.3083),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://cdn.kimkim.com/files/a/content_articles/featured_photos/a1317e3c775ca06fb05848852ba24b5d4344ee6a/big-45c4c417598f0104f1d4c7262dedf921.jpg',
    cityName: 'Bagan', countryName: 'Myanmar', continent: 'Asia', rating: '4.6/5', reviewCount: '145 reviews',
    description: 'Discover thousands of ancient Buddhist temples scattered across the plains of Bagan on a hot air balloon.',
    tourTitle: 'Temple Tour', tourDuration: '10 Days 9 Nights', tourPrice: '\$350', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_bagan", markLocation: "pin_bagan", titlePlace: "Bagan", snippetData: "Ancient City", lati: 21.1717, lngi: 94.8661),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/kyoto,temple/all',
    cityName: 'Kyoto', countryName: 'Japan', continent: 'Asia', rating: '4.9/5', reviewCount: '480 reviews',
    description: 'Walk through endless torii gates at Fushimi Inari, explore bamboo forests, and witness tea ceremonies.',
    tourTitle: 'Cultural Heritage', tourDuration: '5 Days 4 Nights', tourPrice: '\$580', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_kyoto", markLocation: "pin_kyoto", titlePlace: "Kyoto", snippetData: "Fushimi Inari", lati: 35.0116, lngi: 135.7681),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/bangkok,grand_palace/all',
    cityName: 'Bangkok', countryName: 'Thailand', continent: 'Asia', rating: '4.7/5', reviewCount: '700+ reviews',
    description: 'Experience the bustling floating markets, golden temples, and world-class street food of Thailand\'s capital.',
    tourTitle: 'Grand Palace', tourDuration: '6 Days 5 Nights', tourPrice: '\$400', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_bangkok", markLocation: "pin_bangkok", titlePlace: "Bangkok", snippetData: "Floating Market", lati: 13.7563, lngi: 100.5018),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/bali,rice_terrace/all',
    cityName: 'Bali', countryName: 'Indonesia', continent: 'Asia', rating: '4.8/5', reviewCount: '850 reviews',
    description: 'Relax in tropical luxury. Surf ocean waves, hike active volcanoes, and find peace in terraced rice paddies.',
    tourTitle: 'Island Retreat', tourDuration: '8 Days 7 Nights', tourPrice: '\$650', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_bali", markLocation: "pin_bali", titlePlace: "Bali", snippetData: "Tropical Paradise", lati: -8.4095, lngi: 115.1889),
  ),

  // ---------------- OCEANIA ----------------
  const Destination(
    favourite: false,
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRADpXUik5v4_oyeJPbggxSg7YhVuyuXeJc7pMxAdZsCdwkoT4xuhmGSBRQ&s=10',
    cityName: 'Queenstown', countryName: 'New Zealand', continent: 'Oceania', rating: '5.0/5', reviewCount: '500+ reviews',
    description: 'The adventure capital of the world! Bungee jump off historic bridges and cruise through Milford Sound.',
    tourTitle: 'Milford Sound', tourDuration: '14 Days 13 Nights', tourPrice: '\$900', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_queenstown", markLocation: "pin_queenstown", titlePlace: "Queenstown", snippetData: "Adventure Capital", lati: -45.0312, lngi: 168.6626),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/sydney,opera_house/all',
    cityName: 'Sydney', countryName: 'Australia', continent: 'Oceania', rating: '4.7/5', reviewCount: '620 reviews',
    description: 'Catch a show at the iconic Opera House, surf the waves at Bondi Beach, and explore the vibrant harbor life.',
    tourTitle: 'Harbor Highlights', tourDuration: '7 Days 6 Nights', tourPrice: '\$750', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_sydney", markLocation: "pin_sydney", titlePlace: "Sydney", snippetData: "Opera House", lati: -33.8688, lngi: 151.2093),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/fiji,ocean/all',
    cityName: 'Nadi', countryName: 'Fiji', continent: 'Oceania', rating: '4.8/5', reviewCount: '190 reviews',
    description: 'Relax on pristine white-sand beaches, snorkel in crystal-clear coral reefs, and enjoy the ultimate getaway.',
    tourTitle: 'Island Escape', tourDuration: '5 Days 4 Nights', tourPrice: '\$520', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_fiji", markLocation: "pin_fiji", titlePlace: "Nadi", snippetData: "Tropical Beaches", lati: -17.8022, lngi: 177.4136),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/samoa,beach/all',
    cityName: 'Apia', countryName: 'Samoa', continent: 'Oceania', rating: '4.6/5', reviewCount: '110 reviews',
    description: 'Discover the heart of Polynesia. Swim in the To Sua Ocean Trench and experience authentic island culture.',
    tourTitle: 'Polynesian Magic', tourDuration: '6 Days 5 Nights', tourPrice: '\$480', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_samoa", markLocation: "pin_samoa", titlePlace: "Apia", snippetData: "Ocean Trench", lati: -13.8333, lngi: -171.7667),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/vanuatu,island/all',
    cityName: 'Port Vila', countryName: 'Vanuatu', continent: 'Oceania', rating: '4.7/5', reviewCount: '140 reviews',
    description: 'Dive among WWII shipwrecks, stand on the edge of an active volcano, and swim in beautiful blue lagoons.',
    tourTitle: 'Volcano Safari', tourDuration: '7 Days 6 Nights', tourPrice: '\$590', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_vanuatu", markLocation: "pin_vanuatu", titlePlace: "Port Vila", snippetData: "Blue Lagoon", lati: -17.7333, lngi: 168.3167),
  ),

  // ---------------- SOUTH AMERICA ----------------
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/cusco,machu_picchu/all',
    cityName: 'Cusco', countryName: 'Peru', continent: 'South America', rating: '4.9/5', reviewCount: '410 reviews',
    description: 'Acclimatize in the historic capital of the Inca Empire before trekking to the ruins of Machu Picchu.',
    tourTitle: 'Inca Trail', tourDuration: '8 Days 7 Nights', tourPrice: '\$850', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_cusco", markLocation: "pin_cusco", titlePlace: "Cusco", snippetData: "Inca Capital", lati: -13.5226, lngi: -71.9673),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/rio,christ_the_redeemer/all',
    cityName: 'Rio de Janeiro', countryName: 'Brazil', continent: 'South America', rating: '4.7/5', reviewCount: '380 reviews',
    description: 'Experience the energy of Copacabana, take a cable car up Sugarloaf Mountain, and stand beneath Christ the Redeemer.',
    tourTitle: 'Carnival Vibe', tourDuration: '6 Days 5 Nights', tourPrice: '\$600', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_rio", markLocation: "pin_rio", titlePlace: "Rio", snippetData: "Copacabana", lati: -22.9068, lngi: -43.1729),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/bariloche,mountains/all',
    cityName: 'Bariloche', countryName: 'Argentina', continent: 'South America', rating: '4.8/5', reviewCount: '210 reviews',
    description: 'Explore the gateway to Patagonia. Hike around breathtaking lakes, taste chocolate, and ski towering peaks.',
    tourTitle: 'Alpine Lakes', tourDuration: '5 Days 4 Nights', tourPrice: '\$450', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_bariloche", markLocation: "pin_bariloche", titlePlace: "Bariloche", snippetData: "Patagonia Gateway", lati: -41.1335, lngi: -71.3103),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/cartagena,colonial/all',
    cityName: 'Cartagena', countryName: 'Colombia', continent: 'South America', rating: '4.6/5', reviewCount: '275 reviews',
    description: 'Wander through perfectly preserved colonial streets, colorful balconies, and warm Caribbean beaches.',
    tourTitle: 'Colonial Charm', tourDuration: '4 Days 3 Nights', tourPrice: '\$350', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_cartagena", markLocation: "pin_cartagena", titlePlace: "Cartagena", snippetData: "Old City Walls", lati: 10.3910, lngi: -75.4794),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/santiago,andes/all',
    cityName: 'Santiago', countryName: 'Chile', continent: 'South America', rating: '4.7/5', reviewCount: '320 reviews',
    description: 'Discover a bustling metropolis surrounded by the snow-capped Andes mountains and world-class vineyards.',
    tourTitle: 'Andes Valley', tourDuration: '5 Days 4 Nights', tourPrice: '\$410', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_santiago", markLocation: "pin_santiago", titlePlace: "Santiago", snippetData: "Andes Views", lati: -33.4489, lngi: -70.6693),
  ),

  // ---------------- NORTH AMERICA ----------------
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/banff,lake_louise/all',
    cityName: 'Banff', countryName: 'Canada', continent: 'North America', rating: '4.9/5', reviewCount: '450 reviews',
    description: 'Immerse yourself in the Canadian Rockies. Canoe across turquoise waters and hike pine forests.',
    tourTitle: 'Rockies Trip', tourDuration: '6 Days 5 Nights', tourPrice: '\$550', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_banff", markLocation: "pin_banff", titlePlace: "Banff", snippetData: "Lake Louise", lati: 51.1784, lngi: -115.5708),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/cancun,resort/all',
    cityName: 'Cancun', countryName: 'Mexico', continent: 'North America', rating: '4.6/5', reviewCount: '320 reviews',
    description: 'Enjoy the vibrant nightlife, dive into hidden cenotes, and relax at luxurious Caribbean resorts.',
    tourTitle: 'Caribbean Coast', tourDuration: '4 Days 3 Nights', tourPrice: '\$400', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_cancun", markLocation: "pin_cancun", titlePlace: "Cancun", snippetData: "Resort Life", lati: 21.1619, lngi: -86.8515),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/new_york,statue_of_liberty/all',
    cityName: 'New York', countryName: 'USA', continent: 'North America', rating: '4.8/5', reviewCount: '800+ reviews',
    description: 'The city that never sleeps. See a Broadway show, walk Central Park, and admire the skyline.',
    tourTitle: 'Big Apple Tour', tourDuration: '5 Days 4 Nights', tourPrice: '\$700', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_nyc", markLocation: "pin_nyc", titlePlace: "New York", snippetData: "Times Square", lati: 40.7128, lngi: -74.0060),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/costa_rica,rainforest/all',
    cityName: 'San Jose', countryName: 'Costa Rica', continent: 'North America', rating: '4.7/5', reviewCount: '240 reviews',
    description: 'Your gateway to lush rainforests, incredible wildlife, soaring volcanoes, and the Pura Vida lifestyle.',
    tourTitle: 'Pura Vida Trek', tourDuration: '7 Days 6 Nights', tourPrice: '\$500', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_sanjose", markLocation: "pin_sanjose", titlePlace: "San Jose", snippetData: "Jungle Safari", lati: 9.9281, lngi: -84.0907),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/jamaica,beach/all',
    cityName: 'Montego Bay', countryName: 'Jamaica', continent: 'North America', rating: '4.6/5', reviewCount: '190 reviews',
    description: 'Soak up the sun, float down lazy rivers, and enjoy world-famous jerk cuisine to a reggae beat.',
    tourTitle: 'Reggae Retreat', tourDuration: '5 Days 4 Nights', tourPrice: '\$450', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_jamaica", markLocation: "pin_jamaica", titlePlace: "Montego Bay", snippetData: "Beach Resort", lati: 18.4714, lngi: -77.9229),
  ),

  // ---------------- AFRICA ----------------
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/cape_town,table_mountain/all',
    cityName: 'Cape Town', countryName: 'South Africa', continent: 'Africa', rating: '4.8/5', reviewCount: '350 reviews',
    description: 'Take a cable car up Table Mountain, visit the penguins, and drive along the stunning Cape Peninsula.',
    tourTitle: 'Peninsula Drive', tourDuration: '7 Days 6 Nights', tourPrice: '\$580', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_capetown", markLocation: "pin_capetown", titlePlace: "Cape Town", snippetData: "Table Mountain", lati: -33.9249, lngi: 18.4241),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/cairo,pyramids/all',
    cityName: 'Cairo', countryName: 'Egypt', continent: 'Africa', rating: '4.7/5', reviewCount: '410 reviews',
    description: 'Step back in time. Stand before the Great Pyramids of Giza and explore the Egyptian Museum.',
    tourTitle: 'Pharaohs Path', tourDuration: '6 Days 5 Nights', tourPrice: '\$480', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_cairo", markLocation: "pin_cairo", titlePlace: "Cairo", snippetData: "The Pyramids", lati: 30.0444, lngi: 31.2357),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/marrakech,medina/all',
    cityName: 'Marrakech', countryName: 'Morocco', continent: 'Africa', rating: '4.6/5', reviewCount: '290 reviews',
    description: 'Get lost in bustling souks, admire grand palaces, and sleep under the stars in the Sahara Desert.',
    tourTitle: 'Desert & Souks', tourDuration: '5 Days 4 Nights', tourPrice: '\$390', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_marrakech", markLocation: "pin_marrakech", titlePlace: "Marrakech", snippetData: "Medina Souks", lati: 31.6295, lngi: -7.9811),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/nairobi,safari/all',
    cityName: 'Nairobi', countryName: 'Kenya', continent: 'Africa', rating: '4.8/5', reviewCount: '415 reviews',
    description: 'Experience the wildlife capital of the world. Spot lions against the city skyline and explore Maasai markets.',
    tourTitle: 'Safari Getaway', tourDuration: '5 Days 4 Nights', tourPrice: '\$620', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_nairobi", markLocation: "pin_nairobi", titlePlace: "Nairobi", snippetData: "Safari Capital", lati: -1.2921, lngi: 36.8219),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://loremflickr.com/600/400/zanzibar,beach/all',
    cityName: 'Zanzibar', countryName: 'Tanzania', continent: 'Africa', rating: '4.7/5', reviewCount: '230 reviews',
    description: 'Sail on traditional dhows, smell the exotic spices, and relax on stunning Indian Ocean beaches.',
    tourTitle: 'Spice Island', tourDuration: '6 Days 5 Nights', tourPrice: '\$510', tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(idMap: "map_zanzibar", markLocation: "pin_zanzibar", titlePlace: "Zanzibar", snippetData: "Stone Town", lati: -6.1659, lngi: 39.2026),
  ),
];


// =====================================================================
// 6. ROOT APP WIDGET
// =====================================================================

// 🎮 CONTROLS: The absolute root of the widget tree. Wraps the app in Material Design.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // 🔄 PROCESS: Forwards the user directly to the Home Screen.
    );
  }
}


// =====================================================================
// 7. HOME SCREEN (FEED & STATE MANAGEMENT)
// =====================================================================

// 🎮 CONTROLS: The main screen that users see. 
// 💡 LOGIC: Must be Stateful to remember which tab is tapped, the grid view toggle, search query, and continent.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isGrid = false; // Toggles feed layout between ListView and GridView
  int _currentIndex = 0; // Tracks active tab selection in the Bottom Nav Bar
  
  // ✅ Tracks user inputs for filtering
  String _searchQuery = '';
  String _selectedContinent = 'All';

  // 🎮 CONTROLS: The filtering system for the Home Feed.
  // 💡 LOGIC: An easy-to-read custom getter that actively shrinks the master list directly on the home screen.
  List<Destination> get _filteredDestinations {
    return myDestinations.where((dest) {
      
      // 💡 LOGIC: First, check if the continent matches the selected button.
      bool isContinentMatch = (_selectedContinent == 'All') || (dest.continent == _selectedContinent);
      
      // 💡 LOGIC: Second, check if the typed search text matches the city or country.
      bool isSearchMatch = true; 
      if (_searchQuery.isNotEmpty) {
        String queryText = _searchQuery.toLowerCase();
        isSearchMatch = dest.cityName.toLowerCase().contains(queryText) || 
                        dest.countryName.toLowerCase().contains(queryText) ||
                        dest.tourTitle.toLowerCase().contains(queryText);
      }
      
      // 🔄 PROCESS: Only show the destination if BOTH conditions are true.
      return isContinentMatch && isSearchMatch;
      
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ⚙️ SYNTAX: SafeArea prevents UI from bleeding into phone notches/status bars.
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        
        // 💡 LOGIC: extendBody allows the background to flow under a transparent/floating nav bar.
        extendBody: true, 
        
        // 🎮 CONTROLS: Screen Routing
        // ⚙️ SYNTAX: A ternary operator. If the 3rd tab (index 2) is tapped, render the Favorites Screen. Else, the Feed.
        body: _currentIndex == 2 ? const FavoritesScreen() : _buildHomeFeed(),
        
        bottomNavigationBar: CustomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // 🔄 PROCESS: Calling setState forces Flutter to repaint the UI with the newly tapped index.
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  // 🎮 CONTROLS: The layout of the scrollable home feed (Profile, Search, Slider, Cards).
  // 🔄 PROCESS: Extracted into its own method to keep the main build() function clean and readable.
  Widget _buildHomeFeed() {
    // The dynamic list of continents to build our slider from.
    final List<String> continents = ['All', 'South America', 'North America', 'Asia', 'Europe', 'Africa', 'Oceania'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          const ProfileHeader(),
          const SizedBox(height: 15),
          
          // 🎮 CONTROLS: The Standard In-Place Search Bar
          SearchBarWidget(
            onSearchChanged: (value) {
              // 🔄 PROCESS: Updates state with whatever you type, immediately filtering the list below!
              setState(() {
                _searchQuery = value; 
              });
            },
          ),
          
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select your next trip',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton(
                onPressed: () {
                  // 💡 LOGIC: Flips the boolean, forcing the Expanded widget below to switch to GridView.
                  setState(() {
                    isGrid = !isGrid;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  backgroundColor: Colors.black,
                ),
                child: Icon(isGrid ? Icons.list : Icons.grid_view),
              ),
            ],
          ),
          const SizedBox(height: 5),
          
          // 🎮 CONTROLS: The Continent Filter Slider
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: continents.length,
              itemBuilder: (context, index) {
                final continent = continents[index];
                final isSelected = continent == _selectedContinent; 
                
                return TextButton(
                  onPressed: () {
                    // 🔄 PROCESS: Updates state, causing _filteredDestinations to recalculate and repaint.
                    setState(() {
                      _selectedContinent = continent;
                    });
                  },
                  child: Text(
                    continent, 
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 15),
          
          // 🎮 CONTROLS: The List/Grid Display of Destination Cards
          // ⚙️ SYNTAX: Expanded tells the child to fill all remaining vertical space down to the bottom of the screen.
          Expanded(
            child: isGrid 
                // Grid Layout
                ? DestinationGridView(destinations: _filteredDestinations) 
                // List Layout
                : ListView(
                    // 💡 LOGIC: Heavy bottom padding prevents the last item from getting stuck behind the floating nav bar.
                    padding: const EdgeInsets.only(bottom: 120, top: 16), 
                    
                    // 🔄 PROCESS: Maps the CONTINENT FILTERED array into individual DestinationCard widgets.
                    children: _filteredDestinations.map((destination) {
                      return DestinationCard(
                        destination: destination,
                        onTap: () {
                          // ⚙️ SYNTAX: MaterialPageRoute handles the native sliding screen transition automatically.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DestinationDetailScreen(
                                destination: destination,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(), // ⚙️ SYNTAX: .map() returns an Iterable, so we must cast it back .toList().
                  ),
          ),
        ],
      ),
    );
  }
}


// =====================================================================
// 8. FAVORITES SCREEN (SQLITE UI - REFRESHED THEME)
// =====================================================================

// 🎮 CONTROLS: The screen shown when the Heart icon is tapped in the Bottom Nav Bar.
// 💡 LOGIC: Must be Stateful to trigger re-renders when a user actively deletes a favorite from the list.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // ⚙️ SYNTAX: Represents an ongoing background task that will eventually contain the list of saved trips.
  late Future<List<Favorite>> _favoritesList;

  @override
  void initState() {
    super.initState();
    // 🔄 PROCESS: Initiates the database fetch the exact moment this screen is opened.
    _refreshFavorites(); 
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesList = getFavoritesList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Text(
            'Saved Trips', 
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 20),
          Expanded(
            // 💡 LOGIC: FutureBuilder automatically rebuilds itself when the database fetch task completes.
            child: FutureBuilder<List<Favorite>>(
              future: _favoritesList,
              builder: (context, snapshot) {
                // 1. Shows a loading spinner while waiting for SQLite response
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2. Shows a fallback message if the database query returns empty
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No favorites yet!'));
                }

                // ⚙️ SYNTAX: '!' forces unwrapping, asserting to Dart that data is definitely not null at this stage.
                final favorites = snapshot.data!; 

                // 🔄 PROCESS: ListView.builder is highly optimized; it only renders cards currently visible on screen.
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    
                    // 💡 LOGIC: Search the master list to find the full Destination object that matches this saved SQLite item.
                    Destination? savedDestination;
                    for (var dest in myDestinations) {
                      if (dest.cityName == item.id) {
                        savedDestination = dest;
                      }
                    }

                    // 🔄 PROCESS: If we successfully found it, display it using the beautiful DestinationCard theme.
                    if (savedDestination != null) {
                      return DestinationCard(
                        destination: savedDestination,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DestinationDetailScreen(destination: savedDestination!),
                            ),
                          ).then((_) => _refreshFavorites()); 
                          // 🔄 PROCESS: The .then() ensures that if the user unfavorites the item in the detail screen,
                          // this list will automatically refresh and hide it the moment they swipe back!
                        },
                      );
                    }
                    
                    // ⚙️ SYNTAX: Fallback empty container if something goes wrong.
                    return const SizedBox.shrink(); 
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// =====================================================================
// 9. GRID VIEW COMPONENT
// =====================================================================

// 🎮 CONTROLS: Renders the 2-column grid layout when the user toggles the grid icon.
class DestinationGridView extends StatelessWidget {
  // 💡 LOGIC: Accepts a dynamic list of destinations from the parent so filtering works perfectly in Grid mode too.
  final List<Destination> destinations;
  
  const DestinationGridView({
    super.key,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    // ⚙️ SYNTAX: GridView.count allows easy specification of crossAxisCount (columns).
    return GridView.count(
      padding: const EdgeInsets.only(bottom: 120, top: 16),
      primary: false, // Disables internal scrolling if parent is already scrolling.
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      childAspectRatio: 0.85, // 💡 LOGIC: Shapes the grid tiles (width to height ratio).
      
      // 🔄 PROCESS: Maps the filtered list into visual Cards.
      children: destinations.map((destination) { 
        return DestinationCard(
          isGrid: true,
          destination: destination,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DestinationDetailScreen(
                  destination: destination,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}


// =====================================================================
// 10. REUSABLE DESTINATION CARD
// =====================================================================

// 🎮 CONTROLS: The visual appearance of a single destination in the feed, grid, and favorites tab.
// 💡 LOGIC: A stateless, "dumb" UI component. It just takes data and a click function, and paints itself.
class DestinationCard extends StatelessWidget {
  final Destination destination; 
  final bool isGrid; // Determines if it should render tall (List) or squat (Grid).
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isGrid ? 180 : 220,
      width: double.infinity,
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 15),
      
      // ⚙️ SYNTAX: ClipRRect rounds the sharp corners of the rectangular image child.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Image.network(
              destination.imageUrl,
              fit: BoxFit.cover, // 🔄 PROCESS: Crops image perfectly without squishing or distortion.
              width: double.infinity,
              height: double.infinity,
            ),
            
            // Ripple Effect Overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent, 
                child: InkWell(
                  onTap: onTap, // 💡 LOGIC: Material + InkWell creates the native Android splash/ripple touch effect.
                ),
              ),
            ),
            
            // Top Right Navigation Icon
            Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: isGrid ? 14 : 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.north_east,
                    color: Colors.black,
                    size: isGrid ? 14 : 20,
                  ),
                  onPressed: onTap,
                ),
              ),
            ),
            
            // Bottom Left Country Name
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                destination.countryName, 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isGrid ? 18 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Bottom Right Price Tag
            Positioned(
              bottom: 16,
              right: 16,
              child: Text(
                destination.tourPrice, 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isGrid ? 14 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Top Left Duration Tag
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  destination.tourDuration, 
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isGrid ? 10 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================================
// 11. DESTINATION DETAIL SCREEN
// =====================================================================

// 🎮 CONTROLS: The full-page view showing details, description, maps, and tours for a clicked place.
// 💡 LOGIC: Must be Stateful to manage the dynamic red/black state of the favorite icon when tapped.
class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
  });

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  bool _isFavorited = false; // Tracks current UI state

  @override
  void initState() {
    super.initState();
    // 🔄 PROCESS: Verifies if SQLite already has this place saved the exact moment the screen opens.
    _checkFavoriteStatus(); 
  }

  Future<void> _checkFavoriteStatus() async {
    // ⚙️ SYNTAX: 'widget.destination' allows this state class to access properties from its Stateful parent.
    final status = await checkIsFavorite(widget.destination.cityName);
    setState(() {
      _isFavorited = status;
    });
  }

  // 🎮 CONTROLS: The synchronization logic between Local UI, Local DB, and Cloud DB.
  void _toggleFavorite() async {
    // 💡 LOGIC: If true, the user wants to unfavorite. If false, the user wants to favorite.
    if (_isFavorited) {
      await deleteFavorite(widget.destination.cityName); // Removes from offline SQLite
      await removeFavoriteFromFirestore(widget.destination.cityName); // Removes from online Firestore
    } else {
      var fav = Favorite(
        id: widget.destination.cityName,
        name: widget.destination.cityName,
        location: widget.destination.countryName,
        imageUrl: widget.destination.imageUrl,
        price: widget.destination.tourPrice,
      );
      await insertFavorite(fav); // Writes to offline SQLite
      await addFavoriteToFirestore(widget.destination); // Writes to online Firestore
    }
    
    // 🔄 PROCESS: Flips the boolean visually instantly, keeping the UI snappy regardless of DB response times.
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            // 💡 LOGIC: Places the large destination image locked to the background of the screen.
            image: DecorationImage(
              image: NetworkImage(widget.destination.imageUrl), 
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Column(
            children: [
              
              // 🎮 CONTROLS: Top Action Buttons (Back & Favorite)
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                        onPressed: () => Navigator.pop(context), // 🔄 PROCESS: Pops screen off the routing stack.
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(
                        // ⚙️ SYNTAX: Ternary operator determines icon style and color based on DB state.
                        icon: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorited ? Colors.red : Colors.black,
                        ),
                        onPressed: _toggleFavorite, // 🔄 PROCESS: Triggers the Cloud + Local Sync method!
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 150), // Spacer pushes the bottom sheet down
              
              // 🎮 CONTROLS: Bottom White Details Sheet
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DestinationInfoSheet(destination: widget.destination), 
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =====================================================================
// 12. DETAILS SHEET COMPONENT (TEXT & LAYOUT)
// =====================================================================

// 🎮 CONTROLS: The textual information and layout inside the white bottom sheet of the Detail Screen.
// 🔄 PROCESS: Keeping standard layout components stateless makes rendering cheaper and code highly modular.
class DestinationInfoSheet extends StatelessWidget {
  final Destination destination;

  const DestinationInfoSheet({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                destination.cityName,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                destination.rating,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                destination.countryName,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                destination.reviewCount,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            destination.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 2.5),
          const Text(
            'Read more',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Upcoming tours',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          UpcomingToursList(destination: destination),
          const SizedBox(height: 25),
          const Text(
            'Location',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          
          // 💡 LOGIC: Plugs in the dynamic MapScreen widget attached to this specific destination object.
          SizedBox(
            height: 250, 
            width: double.infinity,
            child: destination.mapScreen, 
          ),
        ],
      ),
    );
  }
}


// =====================================================================
// 13. UPCOMING TOURS CAROUSEL
// =====================================================================

// 🎮 CONTROLS: The horizontal sliding list of mini tour cards at the bottom of the Detail Screen.
class UpcomingToursList extends StatelessWidget {
  final Destination destination; 

  const UpcomingToursList({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 175,
      // ⚙️ SYNTAX: By default ListView is vertical. We set it horizontal to create a carousel.
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          TourCard(
            imageUrl: destination.imageUrl,
            title: destination.tourTitle,
            duration: destination.tourDuration,
            price: destination.tourPrice,
            person: destination.tourPersonText,
          ),
          TourCard(
            imageUrl: destination.imageUrl,
            title: destination.tourTitle,
            duration: destination.tourDuration,
            price: destination.tourPrice,
            person: destination.tourPersonText,
          ),
          TourCard(
            imageUrl: destination.imageUrl,
            title: destination.tourTitle,
            duration: destination.tourDuration,
            price: destination.tourPrice,
            person: destination.tourPersonText,
          ),
        ],
      ),
    );
  }
}


// =====================================================================
// 14. MINIATURE TOUR CARD 
// =====================================================================

// 🎮 CONTROLS: The UI for a single mini tour card in the carousel.
class TourCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String duration;
  final String price;
  final String person;

  const TourCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.duration,
    required this.price,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170, 
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.topRight, 
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.north_east, color: Colors.black, size: 18),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1, // ⚙️ SYNTAX: Prevents multiline overflow on long names
                      overflow: TextOverflow.ellipsis, // 🔄 PROCESS: Truncates text with '...' 
                    ),
                    Text(
                      duration,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    person,
                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// =====================================================================
// 15. BOTTOM NAVIGATION BAR
// =====================================================================

// 🎮 CONTROLS: The floating 4-icon navigation bar at the bottom of the screen.
// 💡 LOGIC: Passed back up via the 'onTap' callback to the parent Scaffold to manage screen state.
class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        child: NavigationBar(
          height: 70,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent, // ⚙️ SYNTAX: Removes default Material 3 color tinting
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Hides text labels
          indicatorColor: Colors.transparent, // Hides default pill-shaped selection
          onDestinationSelected: onTap, // 🔄 PROCESS: Triggers function in parent widget
          selectedIndex: currentIndex,
          destinations: <Widget>[
            // 💡 LOGIC: Uses a custom red container for 'selectedIcon' to override standard styling.
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, size: 32.0, color: Colors.black),
              selectedIcon: Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(color: Color(0xFFEE455D), shape: BoxShape.circle),
                child: const Icon(Icons.home, size: 32.0, color: Colors.white),
              ),
              label: '',
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined, size: 28.0, color: Colors.black),
              selectedIcon: Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(color: Color(0xFFEE455D), shape: BoxShape.circle),
                child: const Icon(Icons.calendar_today, size: 28.0, color: Colors.white),
              ),
              label: '',
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border, size: 32.0, color: Colors.black),
              selectedIcon: Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(color: Color(0xFFEE455D), shape: BoxShape.circle),
                child: const Icon(Icons.favorite, size: 32.0, color: Colors.white),
              ),
              label: '',
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined, size: 32.0, color: Colors.black),
              selectedIcon: Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(color: Color(0xFFEE455D), shape: BoxShape.circle),
                child: const Icon(Icons.grid_view, size: 32.0, color: Colors.white),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================================
// 16. TOP PROFILE HEADER
// =====================================================================

// 🎮 CONTROLS: The simple "Hello, Aadam" greeting at the top of the feed.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // ⚙️ SYNTAX: ListTile provides an instant, perfectly aligned row with leading, title, and trailing spots.
        ListTile(
          leading: const Icon(Icons.account_circle, size: 40),
          title: const Text(
            'Hello, Aadam!', 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Welcome to TripGlide',
            style: TextStyle(color: Colors.grey),
          ),
          trailing: FloatingActionButton.small(
            onPressed: () {},
            backgroundColor: Colors.white,
            elevation: 0,
            child: const Icon(Icons.menu, color: Colors.black),
          ),
        ),
      ],
    );
  }
}


// =====================================================================
// 17. IN-PLACE SEARCH BAR
// =====================================================================

// 🎮 CONTROLS: The standard white Search Bar that filters the list directly below it.
// 💡 LOGIC: Completely themed to match the rest of the app with white backgrounds and no drop shadows.
class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchBarWidget({
    super.key, 
    required this.onSearchChanged
  });

  @override
  Widget build(BuildContext context) {
    // ⚙️ SYNTAX: Native Material 3 SearchBar component
    return SearchBar(
      hintText: 'Search destinations...',
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(Colors.white), 
      leading: const Icon(Icons.search),
      
      // 🔄 PROCESS: Triggers filtering logic every time a single letter is typed or deleted!
      onChanged: onSearchChanged, 
      
      trailing: [
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () {},
        ),
      ],
    );
  }
}


// =====================================================================
// 18. REUSABLE MAP SCREEN (POWERED BY MAPBOX TILES)
// =====================================================================

// 🎮 CONTROLS: The interactive map box rendered inside the Detail Screen.
// 💡 LOGIC: Extracted into its own component to prevent map rendering logic from cluttering the detail screen.
class MapScreen extends StatelessWidget {
  final String idMap;
  final String markLocation;
  final String titlePlace;
  final String snippetData;
  final double lati;
  final double lngi;
  
  const MapScreen({
    super.key,
    required this.idMap,
    required this.markLocation,
    required this.titlePlace,
    required this.snippetData,
    required this.lati,
    required this.lngi,
  });

  @override
  Widget build(BuildContext context) {
    // 🔄 PROCESS: Combines simple double coordinates into the LatLng object expected by flutter_map.
    final position = LatLng(lati, lngi);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: FlutterMap(
        key: ValueKey(idMap), // ⚙️ SYNTAX: Enforces widget identity to prevent state bugs when scrolling lists.
        options: MapOptions(
          initialCenter: position,
          initialZoom: 12.0, // 💡 LOGIC: Controls how close the camera starts to the pin.
        ),
        children: [
          // 🔄 PROCESS: Downloads the map graphics (tiles) dynamically from Mapbox over the internet.
          TileLayer(
            urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/tiles/{z}/{x}/{y}?access_token=YOUR PUBLIC TOKEN OF MAPBOX',
            userAgentPackageName: 'com.example.lorem', // Required by flutter_map to identify network requests
          ),
          
          // 💡 LOGIC: Drops a location pin exactly on top of the coordinates provided.
          MarkerLayer(
            markers: [
              Marker(
                point: position,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}