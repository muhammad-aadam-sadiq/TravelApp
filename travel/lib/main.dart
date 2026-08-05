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
// TOP-LEVEL DATABASE & FUNCTIONS
// =====================================================================

// ⚙️ SYNTAX: 'late' tells Dart we promise to assign this value before it's ever used.
// 🔄 PROCESS: Placed at the top level so ANY screen or widget can read/write to the SQLite DB.
late Future<Database> database;

// ⚙️ SYNTAX: 'late final' means it will be assigned once, but only after initialization.
// 💡 LOGIC: Grabs the single, global instance of the Firebase Firestore connection.
late final FirebaseFirestore db; 

void main() async {
  // 🔄 PROCESS: Required when calling async code (like initializing Firebase or finding folder paths) before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // 🔄 PROCESS: Initializes the core Firebase app for the current platform (Android/iOS).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 💡 LOGIC: Safely initializes the specific database connection ('lorem') after Firebase is ready.
  db = FirebaseFirestore.instance;
  
  // 🔄 PROCESS: 1. Get the OS directory. 2. Append the filename. 3. Open the connection.
  database = openDatabase(
    join(await getDatabasesPath(), 'travelapp.db'),
    onCreate: (db, version) {
      // 💡 LOGIC: This only executes once ever—the first time the app is launched.
      // It sets up the schema (columns) for the local SQLite database.
      return db.execute(
        'CREATE TABLE favorites(id TEXT PRIMARY KEY, name TEXT, location TEXT, imageUrl TEXT, price TEXT)',
      );
    },
    version: 1,
  );

  // 🔄 PROCESS: The entry point UI widget of the app.
  runApp(const MainApp());
}

// =====================================================================
// FIRESTORE CLOUD DATABASE FUNCTIONS
// =====================================================================

// 🔄 PROCESS: Uploads a Destination to Firestore when a user marks it as a favorite.
Future<void> addFavoriteToFirestore(Destination dest) async {
  // ⚙️ SYNTAX: Dynamically maps the passed object's properties into a Firestore-ready JSON structure
  final destinationData = <String, dynamic>{
    "cityName": dest.cityName,
    "countryName": dest.countryName,
    "tourPrice": dest.tourPrice,
    "rating": dest.rating,
    "imageUrl": dest.imageUrl,
  };

  // 💡 LOGIC: Uses .doc().set() instead of .add(). This prevents duplicates! 
  // If the user favors and unfavors multiple times, it updates the same ID instead of creating 10 new ones.
  await db.collection("favorites").doc(dest.cityName).set(destinationData).then((_) =>
      print('☁️ ${dest.cityName} was pushed to Cloud Firestore!'));
}

// 🔄 PROCESS: Removes the Destination from Firestore when a user unfavorites it.
Future<void> removeFavoriteFromFirestore(String cityName) async {
  await db.collection("favorites").doc(cityName).delete().then((_) => 
      print('🗑️ $cityName was removed from Cloud Firestore!'));
}

// =====================================================================
// SQLITE LOCAL DATABASE MODEL & FUNCTIONS
// =====================================================================

// 🔄 PROCESS: Serves as a blueprint to convert raw SQLite row data into usable Dart objects.
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

  // ⚙️ SYNTAX: Converts the object back into a Map so SQLite can write it to the table columns.
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

// 💡 LOGIC: Saves a destination locally. ConflictAlgorithm.replace prevents crashes if saved twice.
Future<void> insertFavorite(Favorite fav) async {
  final db = await database;
  await db.insert('favorites', fav.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

// 🔄 PROCESS: Fetches all rows, iterates through them, and maps them into a list of 'Favorite' objects.
Future<List<Favorite>> getFavoritesList() async {
  final db = await database;
  final List<Map<String, Object?>> favMaps = await db.query('favorites');
  
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

// ⚙️ SYNTAX: 'whereArgs' is used to securely inject the ID to prevent SQL Injection vulnerabilities.
Future<void> deleteFavorite(String id) async {
  final db = await database;
  await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
}

// 💡 LOGIC: Returns true if the query yields results, indicating the place is already favorited locally.
Future<bool> checkIsFavorite(String id) async {
  final db = await database;
  final maps = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
  return maps.isNotEmpty;
}

// =====================================================================
// DATA MODEL (Hardcoded App Data)
// =====================================================================

// 🔄 PROCESS: Groups all relevant information for a single travel destination into one neat package.
class Destination {
  final bool favourite;
  final String imageUrl;
  final String cityName;
  final String countryName;
  final String rating;
  final String reviewCount;
  final String description;
  final String tourTitle;
  final String tourDuration;
  final String tourPrice;
  final String tourPersonText;
  final MapScreen mapScreen; // 💡 LOGIC: UI Widgets can also be stored and passed as variables!

  const Destination({
    required this.favourite,
    required this.imageUrl,
    required this.cityName,
    required this.countryName,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.tourTitle,
    required this.tourDuration,
    required this.tourPrice,
    required this.tourPersonText,
    required this.mapScreen,
  });

  Map<String, Object?> toMap() {
    return {'name': cityName, 'fav': favourite};
  }

  // ⚙️ SYNTAX: Overriding toString() helps with debugging by printing clean, readable text to the console.
  @override
  String toString() {
    return 'travelapp{name: $cityName, fav: $favourite}';
  }
}

// =====================================================================
// MOCK DATABASE
// =====================================================================

// 💡 LOGIC: A static array mimicking an API response. This allows the UI to be built and tested 
// before fully integrating the live backend.
final List<Destination> myDestinations = [
  const Destination(
    favourite: false,
    imageUrl: 'https://ik.imagekit.io/travalot/development/resources/attachments/2025/11/12/8fbd8b80-d71e-11f0-b871-9729adfa2385.jpg?tr=w-1600,h-1067,c-at_max:f-webp:q-85',
    cityName: 'Reykjavik',
    countryName: 'Iceland',
    rating: '4.9/5',
    reviewCount: '187 reviews',
    description: 'Discover Iceland, a breathtaking blend of glaciers, volcanoes, geysers, and the Northern Lights. Walk along black sand beaches, relax in hot springs, and explore ice caves.',
    tourTitle: 'Fire & Ice Trip',
    tourDuration: '6 Days 5 Nights',
    tourPrice: '\$630',
    tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(
      idMap: "map_reykjavik", markLocation: "pin_reykjavik", titlePlace: "Reykjavik", snippetData: "Fire & Ice Trip", lati: 64.1466, lngi: -21.9426,
    ),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSABBDxMTS6VuQiuWr5HSiJBSd4B_IpvBoBqxS0Bes90zbm_tm3gJxnOVc&s=10',
    cityName: 'Highlands',
    countryName: 'Scotland',
    rating: '4.8/5',
    reviewCount: '240 reviews',
    description: 'Experience the rugged beauty of the Scottish Highlands. Visit historic castles, sail across mysterious lochs, and ride the famous Jacobite steam train.',
    tourTitle: 'Loch Ness Tour',
    tourDuration: '3 Days 2 Nights',
    tourPrice: '\$250',
    tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(
      idMap: "map_lochness", markLocation: "pin_lochness", titlePlace: "Loch Ness, Highlands", snippetData: "Scottish Highlands", lati: 57.3229, lngi: -4.4244,
    ),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTEdMuu_LkD2i4gUS_wIvlVbRTetmC7lKTQ1rZl-QdVQ&s=10',
    cityName: 'Hunza Valley',
    countryName: 'Gilgit Baltistan',
    rating: '4.9/5',
    reviewCount: '312 reviews',
    description: 'Explore the majestic peaks of the Karakoram. Walk among the vibrant autumn leaves, visit ancient forts, and meet the incredibly hospitable locals.',
    tourTitle: 'Fairy Meadows',
    tourDuration: '7 Days 6 Nights',
    tourPrice: '\$450',
    tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(
      idMap: "map_hunza", markLocation: "pin_hunza", titlePlace: "Hunza Valley", snippetData: "Gilgit Baltistan", lati: 36.3167, lngi: 74.6500,
    ),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://cdn.kimkim.com/files/a/content_articles/featured_photos/a1317e3c775ca06fb05848852ba24b5d4344ee6a/big-45c4c417598f0104f1d4c7262dedf921.jpg',
    cityName: 'Bagan',
    countryName: 'Myanmar',
    rating: '4.6/5',
    reviewCount: '145 reviews',
    description: 'Discover thousands of ancient Buddhist temples scattered across the plains of Bagan. Take a sunrise hot air balloon ride for a once-in-a-lifetime view.',
    tourTitle: 'Temple Tour',
    tourDuration: '10 Days 9 Nights',
    tourPrice: '\$350',
    tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(
      idMap: "map_bagan", markLocation: "pin_bagan", titlePlace: "Bagan Temples", snippetData: "Ancient City", lati: 21.1717, lngi: 94.8661,
    ),
  ),
  const Destination(
    favourite: false,
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRADpXUik5v4_oyeJPbggxSg7YhVuyuXeJc7pMxAdZsCdwkoT4xuhmGSBRQ&s=10',
    cityName: 'Queenstown',
    countryName: 'New Zealand',
    rating: '5.0/5',
    reviewCount: '500+ reviews',
    description: 'The adventure capital of the world! Bungee jump off historic bridges, cruise through Milford Sound, and hike the stunning trails of the South Island.',
    tourTitle: 'Milford Sound',
    tourDuration: '14 Days 13 Nights',
    tourPrice: '\$900',
    tourPersonText: 'for 1 Person',
    mapScreen: MapScreen(
      idMap: "map_queenstown", markLocation: "pin_queenstown", titlePlace: "Queenstown", snippetData: "Adventure Capital", lati: -45.0312, lngi: 168.6626,
    ),
  ),
];

// =====================================================================
// ROOT APP CONFIGURATION
// =====================================================================

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // 🔄 PROCESS: Bootstraps the application into the Home Screen.
    );
  }
}

// =====================================================================
// HOME SCREEN (Stateful routing)
// =====================================================================

// 💡 LOGIC: Must be Stateful to remember which tab in the Bottom Nav is currently selected.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isGrid = false; // Toggles feed layout between ListView and GridView
  int _currentIndex = 0; // Tracks active tab selection

  @override
  Widget build(BuildContext context) {
    // ⚙️ SYNTAX: SafeArea prevents UI from bleeding into phone notches/status bars.
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        // 💡 LOGIC: Allows the body background to flow under a transparent nav bar.
        extendBody: true, 
        
        // ⚙️ SYNTAX: A ternary operator. If the 3rd tab (index 2) is tapped, show Favorites. Else, Home Feed.
        body: _currentIndex == 2 ? const FavoritesScreen() : _buildHomeFeed(),
        
        bottomNavigationBar: CustomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // 🔄 PROCESS: Calling setState tells Flutter to rebuild the UI with the newly tapped index.
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  // 🔄 PROCESS: Extracted into a method to keep the main build() method clean and readable.
  Widget _buildHomeFeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          const ProfileHeader(),
          const SizedBox(height: 15),
          const SearchBarWidget(),
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
                  // 💡 LOGIC: Toggles the layout state boolean, triggering a re-render.
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
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                TextButton(onPressed: null, child: Text('South America', style: TextStyle(color: Colors.black))),
                TextButton(onPressed: null, child: Text('North America', style: TextStyle(color: Colors.grey))),
                TextButton(onPressed: null, child: Text('Asia', style: TextStyle(color: Colors.grey))),
                TextButton(onPressed: null, child: Text('Europe', style: TextStyle(color: Colors.grey))),
                TextButton(onPressed: null, child: Text('Africa', style: TextStyle(color: Colors.grey))),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // ⚙️ SYNTAX: Expanded tells the child to fill all remaining vertical space on the screen.
          Expanded(
            child: isGrid 
                ? const DestinationGridView()
                : ListView(
                    // 💡 LOGIC: Padding prevents the bottom items from being hidden behind the floating nav bar.
                    padding: const EdgeInsets.only(bottom: 120, top: 16), 
                    // 🔄 PROCESS: Maps the static data array into dynamic Flutter widgets
                    children: myDestinations.map((destination) {
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
                    }).toList(), // 💡 LOGIC: .map() returns an Iterable, so we cast it toList() for the children property.
                  ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// FAVORITES SCREEN (SQLITE UI)
// =====================================================================

// 💡 LOGIC: Must be Stateful to trigger re-renders when a user deletes a favorite from the list.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // ⚙️ SYNTAX: Represents an ongoing background task that will eventually contain the list of favorites.
  late Future<List<Favorite>> _favoritesList;

  @override
  void initState() {
    super.initState();
    _refreshFavorites(); // 🔄 PROCESS: Initiates the database fetch the exact moment the screen opens.
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
            // 💡 LOGIC: FutureBuilder automatically rebuilds itself when the DB fetch task completes.
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

                // ⚙️ SYNTAX: '!' forces unwrapping, asserting data is definitely not null at this stage.
                final favorites = snapshot.data!; 

                // 🔄 PROCESS: ListView.builder is highly optimized; it only renders cards currently visible on screen.
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl, 
                            width: 70, 
                            height: 70, 
                            fit: BoxFit.cover
                          ),
                        ),
                        title: Text(
                          item.name, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text(item.location),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () async {
                            // 💡 LOGIC: Removes it from BOTH databases when deleted from the list UI
                            await deleteFavorite(item.id); // SQLite
                            await removeFavoriteFromFirestore(item.id); // Firestore
                            
                            // Refresh UI
                            _refreshFavorites();
                          },
                        ),
                      ),
                    );
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
// GRID VIEW LAYOUT COMPONENT
// =====================================================================

class DestinationGridView extends StatelessWidget {
  const DestinationGridView({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚙️ SYNTAX: GridView.count allows easy specification of crossAxisCount (columns).
    return GridView.count(
      padding: const EdgeInsets.only(bottom: 120, top: 16),
      primary: false,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      childAspectRatio: 0.85, // 💡 LOGIC: Shapes the grid tiles (width to height ratio).
      children: myDestinations.map((destination) {
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
// REUSABLE DESTINATION CARD
// =====================================================================

// 💡 LOGIC: A stateless, dumb UI component. It just takes data and a click function, and paints itself.
class DestinationCard extends StatelessWidget {
  final Destination destination; 
  final bool isGrid; 
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
              fit: BoxFit.cover, // 🔄 PROCESS: Crops image perfectly without distortion.
              width: double.infinity,
              height: double.infinity,
            ),
            // Ripple Effect Overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent, 
                child: InkWell(
                  onTap: onTap, // 💡 LOGIC: Material + InkWell creates the native Android ripple touch effect.
                ),
              ),
            ),
            // Navigation Icon
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
            // Country Name
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
            // Price Tag
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
            // Duration Tag
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
// DESTINATION DETAIL SCREEN (Stateful DB toggle)
// =====================================================================

// 💡 LOGIC: Must be Stateful to manage the red/black state of the favorite icon dynamically.
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
    _checkFavoriteStatus(); // 🔄 PROCESS: Verifies if the DB already has this saved when screen opens.
  }

  Future<void> _checkFavoriteStatus() async {
    // ⚙️ SYNTAX: widget.destination accesses properties from the Stateful parent class above.
    final status = await checkIsFavorite(widget.destination.cityName);
    setState(() {
      _isFavorited = status;
    });
  }

  void _toggleFavorite() async {
    // 💡 LOGIC: If true, user wants to unfavorite. If false, user wants to favorite.
    if (_isFavorited) {
      await deleteFavorite(widget.destination.cityName); // Removes from local SQLite
      await removeFavoriteFromFirestore(widget.destination.cityName); // Removes from Cloud Firestore
    } else {
      var fav = Favorite(
        id: widget.destination.cityName,
        name: widget.destination.cityName,
        location: widget.destination.countryName,
        imageUrl: widget.destination.imageUrl,
        price: widget.destination.tourPrice,
      );
      await insertFavorite(fav); // Writes to local SQLite
      await addFavoriteToFirestore(widget.destination); // Writes to Cloud Firestore
    }
    
    // 🔄 PROCESS: Flips the boolean visually instantly, regardless of DB response time.
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
            // 💡 LOGIC: Places the large destination image in the background of the screen.
            image: DecorationImage(
              image: NetworkImage(widget.destination.imageUrl), 
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Column(
            children: [
              // Top Action Buttons
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white, 
                        shape: BoxShape.circle
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                        onPressed: () => Navigator.pop(context), // 🔄 PROCESS: Pops screen off the routing stack.
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white, 
                        shape: BoxShape.circle
                      ),
                      child: IconButton(
                        // ⚙️ SYNTAX: Ternary determines icon and color based on DB state.
                        icon: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorited ? Colors.red : Colors.black,
                        ),
                        onPressed: _toggleFavorite, // 🔄 PROCESS: Calls the Cloud + Local Sync method!
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 150), 
              // Bottom Details Sheet
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
// DETAIL SCREEN - TEXT DATA COMPONENT
// =====================================================================

// 🔄 PROCESS: Keeping standard layout components stateless makes rendering cheaper and code modular.
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
          // 💡 LOGIC: Renders the custom MapScreen widget specific to this destination.
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
// HORIZONTAL SCROLLING TOURS
// =====================================================================

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
// MINIATURE TOUR CARD 
// =====================================================================

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
// BOTTOM NAVIGATION BAR
// =====================================================================

// 💡 LOGIC: Passed back up via 'onTap' callback to parent Scaffold to manage screen state.
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
// TOP PROFILE HEADER
// =====================================================================

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
            'Hello, Beatrice',
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
// GENERIC SEARCH BAR WIDGET
// =====================================================================

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    // ⚙️ SYNTAX: Native Material 3 SearchBar component
    return SearchBar(
      hintText: 'Search...',
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(Colors.white),
      leading: const Icon(Icons.search),
      onSubmitted: (String value) {}, // 🔄 PROCESS: Triggered when keyboard 'Enter' is pressed
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
// REUSABLE MAP SCREEN (POWERED BY MAPBOX TILES)
// =====================================================================

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
            urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/tiles/{z}/{x}/{y}?access_token=YOUR_MAPBOX_PUBLIC_TOKEN',
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