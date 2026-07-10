import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

// =====================================================================
// ROOT APP COMPONENT
// =====================================================================
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // Sets the initial screen
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
  // Acts as the memory for our toggle button. False = List, True = Grid.
  bool isgrid = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, // Allows the body to scroll behind the floating nav bar
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Light grey background
        extendBody: true, // Crucial for making the bottom nav bar float
        
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              
              // Top Profile Card & Search Bar
              const CardExample(),
              const SizedBox(height: 15),
              const SearchBarApp(),
              const SizedBox(height: 30),

              // --- HEADER ROW (Title + Toggle Button) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your next trip',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                  ),
                  const Spacer(), // Pushes the button to the far right
                  
                  // The Toggle Button
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        isgrid = !isgrid; // Flips between true/false
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.black,
                    ),
                    // Changes icon dynamically based on current state
                    child: Icon(isgrid ? Icons.list : Icons.grid_view),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // --- HORIZONTAL CATEGORY TABS ---
              SizedBox(
                height: 50, // Fixed height prevents horizontal list from crashing
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

              // --- DYNAMIC CONTENT AREA (List View OR Grid View) ---
              // Expanded forces this section to fill the remaining screen space
              Expanded(
                child: isgrid
                    ? const GridViewOption() // IF TRUE: Show Grid
                    : ListView(              // IF FALSE: Show List
                        // Adds large bottom padding so the last item isn't trapped behind nav bar
                        padding: const EdgeInsets.only(bottom: 120, top: 16),
                        children: <Widget>[
                          // 1. Iceland
                          DestinationCard(
                            imageUrl: 'https://ik.imagekit.io/travalot/development/resources/attachments/2025/11/12/8fbd8b80-d71e-11f0-b871-9729adfa2385.jpg?tr=w-1600,h-1067,c-at_max:f-webp:q-85',
                            title: 'Iceland',
                            duration: '6 days 5 nights',
                            price: '\$630',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DestinationDetailScreen(
                                    headerImageUrl: 'https://ik.imagekit.io/travalot/development/resources/attachments/2025/11/12/8fbd8b80-d71e-11f0-b871-9729adfa2385.jpg?tr=w-1600,h-1067,c-at_max:f-webp:q-85',
                                    cityName: 'Reykjavik',
                                    countryName: 'Iceland',
                                    rating: '4.9/5',
                                    reviewCount: '187 reviews',
                                    description: 'Discover Iceland, a breathtaking blend of glaciers, volcanoes, geysers, and the Northern Lights. Walk along black sand beaches, rela...',
                                    featuredTourTitle: 'Fire & Ice Trip',
                                    featuredTourDuration: '6 Days 5 Nights',
                                    featuredTourPrice: '630 USD',
                                    featuredTourPersonText: 'for 1 Person',
                                    featuredTourImageUrl: 'https://ik.imagekit.io/travalot/development/resources/attachments/2025/11/12/8fbd8b80-d71e-11f0-b871-9729adfa2385.jpg?tr=w-1600,h-1067,c-at_max:f-webp:q-85',
                                  ),
                                ),
                              );
                            },
                          ),

                          // 2. Scotland
                          DestinationCard(
                            imageUrl: 'https://wanderlusters.com/wp-content/uploads/2018/10/Scottish-Highlands-Hiking-Guide.jpg',
                            title: 'Scotland',
                            duration: '5 days 4 nights',
                            price: '\$250',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DestinationDetailScreen(
                                    headerImageUrl: 'https://wanderlusters.com/wp-content/uploads/2018/10/Scottish-Highlands-Hiking-Guide.jpg',
                                    cityName: 'Highlands',
                                    countryName: 'Scotland',
                                    rating: '4.8/5',
                                    reviewCount: '240 reviews',
                                    description: 'Experience the rugged beauty of the Scottish Highlands. Visit historic castles, sail across mysterious lochs, and ride the famous Jacobite steam train.',
                                    featuredTourTitle: 'Loch Ness Tour',
                                    featuredTourDuration: '3 Days 2 Nights',
                                    featuredTourPrice: '250 USD',
                                    featuredTourPersonText: 'for 1 Person',
                                    featuredTourImageUrl: 'https://wanderlusters.com/wp-content/uploads/2018/10/Scottish-Highlands-Hiking-Guide.jpg',
                                  ),
                                ),
                              );
                            },
                          ),

                          // 3. Gilgit Baltistan
                          DestinationCard(
                            imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4oIfiVPNgZ06aCaF5IA36f8jUmlmXeVHY0HDqDVL4-A3Y5v3agbQUyMA&s=10',
                            title: 'Gilgit Baltistan',
                            duration: '7 days 6 nights',
                            price: '\$450',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DestinationDetailScreen(
                                    headerImageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4oIfiVPNgZ06aCaF5IA36f8jUmlmXeVHY0HDqDVL4-A3Y5v3agbQUyMA&s=10',
                                    cityName: 'Hunza Valley',
                                    countryName: 'Gilgit Baltistan',
                                    rating: '4.9/5',
                                    reviewCount: '312 reviews',
                                    description: 'Explore the majestic peaks of the Karakoram. Walk among the vibrant autumn leaves, visit ancient forts, and meet the incredibly hospitable locals.',
                                    featuredTourTitle: 'Fairy Meadows',
                                    featuredTourDuration: '7 Days 6 Nights',
                                    featuredTourPrice: '450 USD',
                                    featuredTourPersonText: 'for 1 Person',
                                    featuredTourImageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4oIfiVPNgZ06aCaF5IA36f8jUmlmXeVHY0HDqDVL4-A3Y5v3agbQUyMA&s=10',
                                  ),
                                ),
                              );
                            },
                          ),

                          // 4. Myanmar
                          DestinationCard(
                            imageUrl: 'https://cdn.kimkim.com/files/a/content_articles/featured_photos/a1317e3c775ca06fb05848852ba24b5d4344ee6a/big-45c4c417598f0104f1d4c7262dedf921.jpg',
                            title: 'Myanmar',
                            duration: '10 days 9 nights',
                            price: '\$350',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DestinationDetailScreen(
                                    headerImageUrl: 'https://cdn.kimkim.com/files/a/content_articles/featured_photos/a1317e3c775ca06fb05848852ba24b5d4344ee6a/big-45c4c417598f0104f1d4c7262dedf921.jpg',
                                    cityName: 'Bagan',
                                    countryName: 'Myanmar',
                                    rating: '4.6/5',
                                    reviewCount: '145 reviews',
                                    description: 'Discover thousands of ancient Buddhist temples scattered across the plains of Bagan. Take a sunrise hot air balloon ride for a once-in-a-lifetime view.',
                                    featuredTourTitle: 'Temple Tour',
                                    featuredTourDuration: '10 Days 9 Nights',
                                    featuredTourPrice: '350 USD',
                                    featuredTourPersonText: 'for 1 Person',
                                    featuredTourImageUrl: 'https://cdn.kimkim.com/files/a/content_articles/featured_photos/a1317e3c775ca06fb05848852ba24b5d4344ee6a/big-45c4c417598f0104f1d4c7262dedf921.jpg',
                                  ),
                                ),
                              );
                            },
                          ),

                          // 5. New Zealand
                          DestinationCard(
                            imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRADpXUik5v4_oyeJPbggxSg7YhVuyuXeJc7pMxAdZsCdwkoT4xuhmGSBRQ&s=10',
                            title: 'New Zealand',
                            duration: '14 days 13 nights',
                            price: '\$900',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DestinationDetailScreen(
                                    headerImageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRADpXUik5v4_oyeJPbggxSg7YhVuyuXeJc7pMxAdZsCdwkoT4xuhmGSBRQ&s=10',
                                    cityName: 'Queenstown',
                                    countryName: 'New Zealand',
                                    rating: '5.0/5',
                                    reviewCount: '500+ reviews',
                                    description: 'The adventure capital of the world! Bungee jump off historic bridges, cruise through Milford Sound, and hike the stunning trails of the South Island.',
                                    featuredTourTitle: 'Milford Sound',
                                    featuredTourDuration: '14 Days 13 Nights',
                                    featuredTourPrice: '900 USD',
                                    featuredTourPersonText: 'for 1 Person',
                                    featuredTourImageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRADpXUik5v4_oyeJPbggxSg7YhVuyuXeJc7pMxAdZsCdwkoT4xuhmGSBRQ&s=10',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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
// BOTTOM NAVIGATION BAR
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
      // Padding pushes the bar away from the edges to make it float
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 25),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        child: NavigationBar(
          height: 70,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent, // Prevents material tinting
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Centers the icons perfectly
          
          // We make the default indicator invisible to use our custom Container below
          indicatorColor: Colors.transparent,
          
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            // 1. Home
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, size: 32.0, color: Colors.black),
              selectedIcon: Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  color: Color(0xFFEE455D), // Pink highlight color
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home, size: 32.0, color: Colors.white),
              ),
              label: '',
            ),
            
            // 2. Calendar
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
            
            // 3. Favorites
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
            
            // 4. Dashboard/Grid
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
// TOP UI COMPONENTS (Profile Header & Search Bar)
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
// DESTINATION CARD WIDGET (Reusable for Grid & List views)
// =====================================================================
class DestinationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String duration;
  final String price;
  final bool isGrid; // Used to shrink dimensions when placed in a grid
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.duration,
    required this.price,
    required this.onTap,
    this.isGrid = false, // Defaults to List View sizing
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dynamic height based on view type
      height: isGrid ? 180 : 220,
      width: double.infinity,
      // GridView provides its own spacing, so we only need margin in ListView
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            
            // Tappable InkWell Layer
            Positioned.fill(
              child: Material(
                color: Colors.transparent, // Invisible material to hold the ripple effect
                child: InkWell(
                  onTap: onTap,
                ),
              ),
            ),
            
            // Top-Right Arrow Button
            Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: isGrid ? 14 : 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.north_east, color: Colors.black, size: isGrid ? 14 : 20),
                  onPressed: onTap,
                ),
              ),
            ),
            
            // Location Title
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: isGrid ? 18 : 28, fontWeight: FontWeight.bold),
              ),
            ),
            
            // Price Tag
            Positioned(
              bottom: 16,
              right: 16,
              child: Text(
                price,
                style: TextStyle(color: Colors.white, fontSize: isGrid ? 14 : 20, fontWeight: FontWeight.bold),
              ),
            ),
            
            // Duration Pill
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Text(
                  duration,
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
      crossAxisCount: 2,
      // 0.85 ratio makes the grid cards slightly taller than they are wide
      childAspectRatio: 0.85,
      children: <Widget>[
        // 1. Iceland
        DestinationCard(
          isGrid: true, // Shrinks fonts and dimensions to fit
          imageUrl: 'https://ik.imagekit.io/travalot/development/resources/attachments/2025/11/12/8fbd8b80-d71e-11f0-b871-9729adfa2385.jpg?tr=w-1600,h-1067,c-at_max:f-webp:q-85',
          title: 'Iceland',
          duration: '6 days 5 nights',
          price: '\$630',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DestinationDetailScreen(
                  headerImageUrl: 'https://ik.imagekit.io/travalot/development/resources/attachments/2025/11/12/8fbd8b80-d71e-11f0-b871-9729adfa2385.jpg?tr=w-1600,h-1067,c-at_max:f-webp:q-85',
                  cityName: 'Reykjavik',
                  countryName: 'Iceland',
                  rating: '4.9/5',
                  reviewCount: '187 reviews',
                  description: 'Discover Iceland, a breathtaking blend of glaciers, volcanoes, geysers, and the Northern Lights. Walk along black sand beaches, rela...',
                  featuredTourTitle: 'Fire & Ice Trip',
                  featuredTourDuration: '6 Days 5 Nights',
                  featuredTourPrice: '630 USD',
                  featuredTourPersonText: 'for 1 Person',
                  featuredTourImageUrl: 'https://ik.imagekit.io/travalot/development/resources/attachments/2025/11/12/8fbd8b80-d71e-11f0-b871-9729adfa2385.jpg?tr=w-1600,h-1067,c-at_max:f-webp:q-85',
                ),
              ),
            );
          },
        ),

        // 2. Scotland
        DestinationCard(
          isGrid: true,
          imageUrl: 'https://wanderlusters.com/wp-content/uploads/2018/10/Scottish-Highlands-Hiking-Guide.jpg',
          title: 'Scotland',
          duration: '5 days 4 nights',
          price: '\$250',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DestinationDetailScreen(
                  headerImageUrl: "https://wanderlusters.com/wp-content/uploads/2018/10/Scottish-Highlands-Hiking-Guide.jpg",
                  cityName: 'Highlands',
                  countryName: 'Scotland',
                  rating: '4.8/5',
                  reviewCount: '240 reviews',
                  description: 'Experience the rugged beauty of the Scottish Highlands. Visit historic castles, sail across mysterious lochs, and ride the famous Jacobite steam train.',
                  featuredTourTitle: 'Loch Ness Tour',
                  featuredTourDuration: '3 Days 2 Nights',
                  featuredTourPrice: '250 USD',
                  featuredTourPersonText: 'for 1 Person',
                  featuredTourImageUrl: 'https://wanderlusters.com/wp-content/uploads/2018/10/Scottish-Highlands-Hiking-Guide.jpg',
                ),
              ),
            );
          },
        ),

        // 3. Gilgit
        DestinationCard(
          isGrid: true,
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4oIfiVPNgZ06aCaF5IA36f8jUmlmXeVHY0HDqDVL4-A3Y5v3agbQUyMA&s=10',
          title: 'Gilgit',
          duration: '7 days 6 nights',
          price: '\$450',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DestinationDetailScreen(
                  headerImageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4oIfiVPNgZ06aCaF5IA36f8jUmlmXeVHY0HDqDVL4-A3Y5v3agbQUyMA&s=10',
                  cityName: 'Hunza Valley',
                  countryName: 'Gilgit Baltistan',
                  rating: '4.9/5',
                  reviewCount: '312 reviews',
                  description: 'Explore the majestic peaks of the Karakoram. Walk among the vibrant autumn leaves, visit ancient forts, and meet the incredibly hospitable locals.',
                  featuredTourTitle: 'Fairy Meadows',
                  featuredTourDuration: '7 Days 6 Nights',
                  featuredTourPrice: '450 USD',
                  featuredTourPersonText: 'for 1 Person',
                  featuredTourImageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4oIfiVPNgZ06aCaF5IA36f8jUmlmXeVHY0HDqDVL4-A3Y5v3agbQUyMA&s=10',
                ),
              ),
            );
          },
        ),

        // 4. Myanmar
        DestinationCard(
          isGrid: true,
          imageUrl: 'https://cdn.kimkim.com/files/a/content_articles/featured_photos/a1317e3c775ca06fb05848852ba24b5d4344ee6a/big-45c4c417598f0104f1d4c7262dedf921.jpg',
          title: 'Myanmar',
          duration: '10 days 9 nights',
          price: '\$350',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DestinationDetailScreen(
                  headerImageUrl: 'https://cdn.kimkim.com/files/a/content_articles/featured_photos/a1317e3c775ca06fb05848852ba24b5d4344ee6a/big-45c4c417598f0104f1d4c7262dedf921.jpg',
                  cityName: 'Bagan',
                  countryName: 'Myanmar',
                  rating: '4.6/5',
                  reviewCount: '145 reviews',
                  description: 'Discover thousands of ancient Buddhist temples scattered across the plains of Bagan. Take a sunrise hot air balloon ride for a once-in-a-lifetime view.',
                  featuredTourTitle: 'Temple Tour',
                  featuredTourDuration: '10 Days 9 Nights',
                  featuredTourPrice: '350 USD',
                  featuredTourPersonText: 'for 1 Person',
                  featuredTourImageUrl: 'https://cdn.kimkim.com/files/a/content_articles/featured_photos/a1317e3c775ca06fb05848852ba24b5d4344ee6a/big-45c4c417598f0104f1d4c7262dedf921.jpg',
                ),
              ),
            );
          },
        ),

        // 5. New Zealand
        DestinationCard(
          isGrid: true,
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRADpXUik5v4_oyeJPbggxSg7YhVuyuXeJc7pMxAdZsCdwkoT4xuhmGSBRQ&s=10',
          title: 'New Zealand',
          duration: '14 days 13 nights',
          price: '\$900',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DestinationDetailScreen(
                  headerImageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRADpXUik5v4_oyeJPbggxSg7YhVuyuXeJc7pMxAdZsCdwkoT4xuhmGSBRQ&s=10',
                  cityName: 'Queenstown',
                  countryName: 'New Zealand',
                  rating: '5.0/5',
                  reviewCount: '500+ reviews',
                  description: 'The adventure capital of the world! Bungee jump off historic bridges, cruise through Milford Sound, and hike the stunning trails of the South Island.',
                  featuredTourTitle: 'Milford Sound',
                  featuredTourDuration: '14 Days 13 Nights',
                  featuredTourPrice: '900 USD',
                  featuredTourPersonText: 'for 1 Person',
                  featuredTourImageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRADpXUik5v4_oyeJPbggxSg7YhVuyuXeJc7pMxAdZsCdwkoT4xuhmGSBRQ&s=10',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// =====================================================================
// DESTINATION DETAIL SCREEN TEMPLATE
// =====================================================================
class DestinationDetailScreen extends StatelessWidget {
  // Required data variables so this single screen can show ANY destination!
  final String headerImageUrl;
  final String cityName;
  final String countryName;
  final String rating;
  final String reviewCount;
  final String description;
  final String featuredTourTitle;
  final String featuredTourDuration;
  final String featuredTourPrice;
  final String featuredTourPersonText;
  final String featuredTourImageUrl;

  const DestinationDetailScreen({
    super.key,
    required this.headerImageUrl,
    required this.cityName,
    required this.countryName,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.featuredTourTitle,
    required this.featuredTourDuration,
    required this.featuredTourPrice,
    required this.featuredTourPersonText,
    required this.featuredTourImageUrl,
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
            // Draws the destination photo across the background of the screen
            image: DecorationImage(
              image: NetworkImage(headerImageUrl),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
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
                        icon: const Icon(Icons.menu, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              // --- SCROLLING CONTENT SHEET ---
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // This invisible box pushes the white container down so the photo is visible!
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
                      // Renders the data sheet component
                      child: DestinationInfoSheet(
                        cityName: cityName,
                        countryName: countryName,
                        rating: rating,
                        reviewCount: reviewCount,
                        description: description,
                        tourTitle: featuredTourTitle,
                        tourDuration: featuredTourDuration,
                        tourPrice: featuredTourPrice,
                        tourPersonText: featuredTourPersonText,
                        tourImageUrl: featuredTourImageUrl,
                      ),
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
// DESTINATION DETAIL - WHITE CONTENT SHEET
// =====================================================================
class DestinationInfoSheet extends StatelessWidget {
  final String cityName;
  final String countryName;
  final String rating;
  final String reviewCount;
  final String description;
  final String tourTitle;
  final String tourDuration;
  final String tourPrice;
  final String tourPersonText;
  final String tourImageUrl;

  const DestinationInfoSheet({
    super.key,
    required this.cityName,
    required this.countryName,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.tourTitle,
    required this.tourDuration,
    required this.tourPrice,
    required this.tourPersonText,
    required this.tourImageUrl,
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
              Text(cityName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(rating, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(countryName, style: const TextStyle(color: Colors.grey, fontSize: 16)),
              Text(reviewCount, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text('Read more', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          const SizedBox(height: 32),
          const Text('Upcoming tours', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Renders the horizontal list of smaller tour cards
          UpcomingToursList(
            tourPersonText: tourPersonText,
            tourPrice: tourPrice,
            tourTitle: tourTitle,
            tourDuration: tourDuration,
            tourImageUrl: tourImageUrl,
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// DESTINATION DETAIL - HORIZONTAL TOURS SCROLLER
// =====================================================================
class UpcomingToursList extends StatelessWidget {
  final String tourPersonText;
  final String tourPrice;
  final String tourTitle;
  final String tourDuration;
  final String tourImageUrl;

  const UpcomingToursList({
    super.key,
    required this.tourTitle,
    required this.tourDuration,
    required this.tourPrice,
    required this.tourPersonText,
    required this.tourImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // The dynamic featured tour passed from the parent widget
          TourCard(
            imageUrl: tourImageUrl,
            title: tourTitle,
            duration: tourDuration,
            price: tourPrice,
            person: tourPersonText,
          ),
          // Placeholder tour 1
          TourCard(
            imageUrl: tourImageUrl,
            title: tourTitle,
            duration: tourDuration,
            price: tourPrice,
            person: tourPersonText,
          ),
          // Placeholder tour 2
          TourCard(
            imageUrl: tourImageUrl,
            title: tourTitle,
            duration: tourDuration,
            price: tourPrice,
            person: tourPersonText,
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SMALL TOUR CARD (Used inside the Detail Screen's horizontal list)
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
      margin: const EdgeInsets.only(right: 15), // Spacing between cards
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