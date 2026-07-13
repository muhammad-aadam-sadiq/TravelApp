import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

// =====================================================================
// 1. DATA MODEL (The Blueprint)
// =====================================================================
// This class acts as a container to bundle all related information for a 
// single destination. Instead of passing 10 variables around, we pass 1 object.
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
  });
}

// =====================================================================
// 2. MOCK DATABASE
// =====================================================================
// A hardcoded list of Destination objects. In a real app, this data 
// would typically be fetched from an API or a database like Firebase.
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
  ),
  const Destination(
    imageUrl: 'https://images.ctfassets.net/rc3dlxapnu6k/5gU2tKCncSVhSKGLZuhocq/f862b40488d9ec4f6246a17ac7f9f5c2/Schottland__Glenfinnan_Viaduct-2.jpg?w=800&q=60&fm=webp',
    cityName: 'Highlands',
    countryName: 'Scotland',
    rating: '4.8/5',
    reviewCount: '240 reviews',
    description: 'Experience the rugged beauty of the Scottish Highlands. Visit historic castles, sail across mysterious lochs, and ride the famous Jacobite steam train.',
    tourTitle: 'Loch Ness Tour',
    tourDuration: '3 Days 2 Nights',
    tourPrice: '\$250',
    tourPersonText: 'for 1 Person',
  ),
  const Destination(
    imageUrl: 'https://www.arabnews.pk/sites/default/files/styles/n_670_395/public/2025/01/03/4560177-1578019235.jpg?itok=wnu_fCIT',
    cityName: 'Hunza Valley',
    countryName: 'Gilgit Baltistan',
    rating: '4.9/5',
    reviewCount: '312 reviews',
    description: 'Explore the majestic peaks of the Karakoram. Walk among the vibrant autumn leaves, visit ancient forts, and meet the incredibly hospitable locals.',
    tourTitle: 'Fairy Meadows',
    tourDuration: '7 Days 6 Nights',
    tourPrice: '\$450',
    tourPersonText: 'for 1 Person',
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
      home: HomeScreen(), // Directs to our main UI
    );
  }
}

// =====================================================================
// HOME SCREEN (Stateful to handle Grid vs List toggle)
// =====================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variable tracking current layout. False = List, True = Grid.
  bool isgrid = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, // Ensures the list scrolls *behind* the floating nav bar
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Soft grey background
        extendBody: true, // CRUCIAL: Allows the background/content to flow under the NavigationBar
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              const CardExample(), // Top Profile Header
              const SizedBox(height: 15),
              const SearchBarApp(), // Search Bar
              const SizedBox(height: 30),
              
              // --- Title & Layout Toggle Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select your next trip', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.left, textDirection: .ltr),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      // Calling setState forces the screen to rebuild with the new isgrid value
                      setState(() {
                        isgrid = !isgrid;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.black,
                    ),
                    // Dynamically changes icon based on current state
                    child: Icon(isgrid ? Icons.list : Icons.grid_view),
                  ),
                ]
              ),
              
              const SizedBox(height: 5),
              
              // --- Category Filters (Horizontal Scroll) ---
              SizedBox(
                height: 50, // Constrains height so the horizontal ListView doesn't throw an error
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
              
              // --- Dynamic Content Area ---
              // Expanded forces this section to take up all remaining vertical space
              Expanded(
                child: isgrid 
                    ? const GridViewOption() // Render Grid if true
                    : ListView(              // Render List if false
                        // Bottom padding ensures the last item isn't hidden behind the Nav Bar
                        padding: const EdgeInsets.only(bottom: 120, top: 16),
                        
                        // 💡 THE MAGIC LOOP: Iterates over the myDestinations list 
                        // and dynamically creates a DestinationCard for each one!
                        children: myDestinations.map((destinationData) {
                          return DestinationCard(
                            destination: destinationData, // Pass the specific data object
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DestinationDetailScreen(
                                    destination: destinationData, // Pass data to next screen
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(), // Converts the map operation back into a List of widgets
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const NavigationExample(),
      ),
    );
  }
}

// =====================================================================
// GRID VIEW LAYOUT COMPONENT
// =====================================================================
class GridViewOption extends StatelessWidget {
  const GridViewOption({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.only(bottom: 120, top: 16),
      primary: false,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2, // 2 items per row
      childAspectRatio: 0.85, // Adjusts proportion so cards are taller than they are wide
      
      // Similar magic loop as the ListView, but passes isGrid: true
      children: myDestinations.map((destinationData) {
        return DestinationCard(
          isGrid: true, // Tells the card to shrink its UI for the grid
          destination: destinationData,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DestinationDetailScreen(
                  destination: destinationData,
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
// REUSABLE DESTINATION CARD (Adapts to List or Grid)
// =====================================================================
class DestinationCard extends StatelessWidget {
  final Destination destination; 
  final bool isGrid; 
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.isGrid = false, // Defaults to List View formatting
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ternary operators adjust dimensions based on view mode
      height: isGrid ? 180 : 220,
      width: double.infinity,
      // Grid handles its own spacing, so margin is 0 when in grid mode
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 1. Background Image
            Image.network(destination.imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            
            // 2. Ripple Effect Layer
            // Placing Material > InkWell inside the Stack ensures the splash effect overlays the image
            Positioned.fill(
              child: Material(
                color: Colors.transparent, 
                child: InkWell(
                  onTap: onTap,
                ),
              ),
            ),
            
            // 3. Top Right Action Button
            Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: isGrid ? 14 : 18, // Shrinks in grid view
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.north_east, color: Colors.black, size: isGrid ? 14 : 20),
                  onPressed: onTap,
                ),
              ),
            ),
            
            // 4. Country Text (Bottom Left)
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                destination.countryName, 
                style: TextStyle(color: Colors.white, fontSize: isGrid ? 18 : 28, fontWeight: FontWeight.bold),
              ),
            ),
            
            // 5. Price Text (Bottom Right)
            Positioned(
              bottom: 16,
              right: 16,
              child: Text(
                destination.tourPrice, 
                style: TextStyle(color: Colors.white, fontSize: isGrid ? 14 : 20, fontWeight: FontWeight.bold),
              ),
            ),
            
            // 6. Duration Pill (Top Left)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Text(
                  destination.tourDuration, 
                  style: TextStyle(color: Colors.black, fontSize: isGrid ? 10 : 14, fontWeight: FontWeight.bold),
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
  final Destination destination; // The single data object powering this screen

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
          // We set the background image on the parent container so elements can scroll over it
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: NetworkImage(destination.imageUrl), 
              fit: BoxFit.fitWidth, // Prevents extreme zooming
              alignment: Alignment.topCenter, // Pins image to the top
            ),
          ),
          child: Column(
            children: [
              // --- FIXED APP BAR BUTTONS ---
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

              // --- SCROLLING WHITE CONTENT SHEET ---
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // This invisible box pushes the white container down so the photo is visible above it
                    const SizedBox(height: 150),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      // Pass the model deeper into the layout hierarchy
                      child: DestinationInfoSheet(destination: destination), 
                    ),
                  ],
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
              Text(destination.cityName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(destination.rating, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(destination.countryName, style: const TextStyle(color: Colors.grey, fontSize: 16)),
              Text(destination.reviewCount, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            destination.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text('Read more', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          const SizedBox(height: 32),
          const Text('Upcoming tours', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          UpcomingToursList(destination: destination), 
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
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Render Dynamic Tour from the model
          TourCard(
            imageUrl: destination.imageUrl,
            title: destination.tourTitle,
            duration: destination.tourDuration,
            price: destination.tourPrice,
            person: destination.tourPersonText,
          ),
          // Render Placeholders (In a real app, the Model would contain a List of Tours)
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
      width: 170, // Fixed width prevents horizontal list views from throwing constraints errors
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
            // alignment efficiently places the child (action button) without needing Positioned
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
                    // TextOverflow.ellipsis ensures long text gets '...' instead of wrapping or crashing
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(person, style: const TextStyle(color: Colors.grey, fontSize: 9)),
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
class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding pushes the bar away from the edges to make it float visually
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        child: NavigationBar(
          height: 70,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent, // Prevents default Material purple/grey tinting
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          
          // 💡 TRICK: We make the default Material indicator invisible so we can provide our own custom circular shape
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
              // Our custom 55x55 circular indicator that shows when selected
              selectedIcon: Container(
                width: 55, height: 55,
                decoration: const BoxDecoration(color: Color(0xFFEE455D), shape: BoxShape.circle),
                child: const Icon(Icons.home, size: 32.0, color: Colors.white),
              ),
              label: '',
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined, size: 28.0, color: Colors.black),
              selectedIcon: Container(
                width: 55, height: 55,
                decoration: const BoxDecoration(color: Color(0xFFEE455D), shape: BoxShape.circle),
                child: const Icon(Icons.calendar_today, size: 28.0, color: Colors.white),
              ),
              label: '',
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border, size: 32.0, color: Colors.black),
              selectedIcon: Container(
                width: 55, height: 55,
                decoration: const BoxDecoration(color: Color(0xFFEE455D), shape: BoxShape.circle),
                child: const Icon(Icons.favorite, size: 32.0, color: Colors.white),
              ),
              label: '',
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined, size: 32.0, color: Colors.black),
              selectedIcon: Container(
                width: 55, height: 55,
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
class CardExample extends StatelessWidget {
  const CardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.account_circle, size: 40),
          title: const Text('Hello, Beatrice', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          subtitle: const Text('Welcome to TripGlide', style: TextStyle(color: Colors.grey)),
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
class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Search...',
      elevation: WidgetStateProperty.all(0), // Removes drop shadow for a flatter look
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