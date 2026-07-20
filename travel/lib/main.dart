import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // 💡 Modern Mapbox Tile Layer
import 'package:latlong2/latlong.dart'; // 💡 Standard Coordinate System

void main() {
  runApp(const MainApp());
}

// =====================================================================
// DATA MODEL
// =====================================================================

/// A container to bundle all related information for a single destination.
class Destination {
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
  final MapScreen mapScreen;

  const Destination({
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
}

// =====================================================================
// MOCK DATABASE
// =====================================================================

/// A hardcoded list of Destination objects simulating a database/API response.
final List<Destination> myDestinations = [
  const Destination(
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
      idMap: "map_reykjavik",
      markLocation: "pin_reykjavik",
      titlePlace: "Reykjavik",
      snippetData: "Fire & Ice Trip",
      lati: 64.1466,
      lngi: -21.9426,
    ),
  ),
  const Destination(
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
      idMap: "map_lochness",
      markLocation: "pin_lochness",
      titlePlace: "Loch Ness, Highlands",
      snippetData: "Scottish Highlands",
      lati: 57.3229,
      lngi: -4.4244,
    ),
  ),
  const Destination(
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
      idMap: "map_hunza",
      markLocation: "pin_hunza",
      titlePlace: "Hunza Valley",
      snippetData: "Gilgit Baltistan",
      lati: 36.3167,
      lngi: 74.6500,
    ),
  ),
  const Destination(
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
      idMap: "map_bagan",
      markLocation: "pin_bagan",
      titlePlace: "Bagan Temples",
      snippetData: "Ancient City",
      lati: 21.1717,
      lngi: 94.8661,
    ),
  ),
  const Destination(
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
      idMap: "map_queenstown",
      markLocation: "pin_queenstown",
      titlePlace: "Queenstown",
      snippetData: "Adventure Capital",
      lati: -45.0312,
      lngi: 168.6626,
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
      home: HomeScreen(),
    );
  }
}

// =====================================================================
// HOME SCREEN
// =====================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isGrid = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        extendBody: true,
        body: Padding(
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
                    TextButton(
                      onPressed: null,
                      child: Text('South America', style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: null,
                      child: Text('North America', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: null,
                      child: Text('Asia', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: null,
                      child: Text('Europe', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: null,
                      child: Text('Africa', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: isGrid 
                    ? const DestinationGridView()
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 120, top: 16),
                        children: myDestinations.map((destination) {
                          return DestinationCard(
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
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomNavigationBar(),
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
    return GridView.count(
      padding: const EdgeInsets.only(bottom: 120, top: 16),
      primary: false,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      childAspectRatio: 0.85,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.network(
              destination.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent, 
                child: InkWell(
                  onTap: onTap,
                ),
              ),
            ),
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
// DESTINATION DETAIL SCREEN TEMPLATE
// =====================================================================

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: NetworkImage(destination.imageUrl), 
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 150), 
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
                        DestinationInfoSheet(destination: destination), 
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
// BOTTOM NAVIGATION BAR WITH CUSTOM INDICATOR
// =====================================================================

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        child: NavigationBar(
          height: 70,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: Colors.transparent, 
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
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
    return SearchBar(
      hintText: 'Search...',
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(Colors.white),
      leading: const Icon(Icons.search),
      onSubmitted: (String value) {},
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
    final position = LatLng(lati, lngi);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: FlutterMap(
        key: ValueKey(idMap), 
        options: MapOptions(
          initialCenter: position,
          initialZoom: 12.0,
        ),
        children: [
          // This layer streams the beautiful "Outdoors" map graphics straight from Mapbox!
          TileLayer(
            urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYWFkYW0tbWFzIiwiYSI6ImNtcnN2d2NxNDBtMmIyeHNnbXRuMjFqNTUifQ.Sl9MzXttgIOdYalTUzNL9A',
            userAgentPackageName: 'com.example.lorem',
          ),
          // This layer drops a clean Material design pin right onto your destination coordinates
          MarkerLayer(
            markers: [
              Marker(
                point: position,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
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