import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/bookings/widgets/booking_card.dart';
import 'package:dima_project/content/custom_appbar.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_page.dart';
import 'package:dima_project/content/home/gym/new_gym.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/content/home/gym/gym_card.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<NavigatorState> desktopNavKey = GlobalKey<NavigatorState>();
  final TextEditingController _controller = TextEditingController();
  bool _useMobileLayout = true;
  int _selectedGymIndex = -1;
  late GymProvider _gymProvider;
  User? _user;
  List<Gym>? _gymList;
  List<Gym>? _filteredGymList;
  List<Booking> _todaysBookings = [];

  @override
  void initState() {
    super.initState();
    _gymProvider = context.read<GymProvider>();
    if (_gymProvider.gymList == null) {
      _gymProvider.getGymList().then((list) => _filteredGymList = list);
    } else {
      _filteredGymList = _gymProvider.gymList;
    }
    context.read<BookingsProvider>().getTodaysBookings().then((value) {
      setState(() {
        _todaysBookings = value;
      });
    });
    _controller.addListener(_filterGymList);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterGymList() {
    if (_controller.text.isEmpty) {
      setState(() {
        _filteredGymList = _gymList;
      });
    } else {
      setState(() {
        _filteredGymList =
            _gymList
                ?.where(
                  (gym) => gym.name.toLowerCase().contains(
                    _controller.text.toLowerCase(),
                  ),
                )
                .toList();
      });
    }
  }

  /// Refreshes the gym list by fetching it from the provider
  Future<void> _onRefresh() async {
    // Get gym list
    final list = await Provider.of<GymProvider>(
      context,
      listen: false,
    ).getGymList().timeout(
      Duration(seconds: 5),
      onTimeout: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh gym list'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return _filteredGymList ?? [];
      },
    );

    setState(() {
      _filteredGymList = list;
    });

    final value =
        await Provider.of<BookingsProvider>(
          context,
          listen: false,
        ).getTodaysBookings();

    setState(() {
      _todaysBookings = value;
    });
  }

  /// Navigate to the add gym page
  void _navigateToAddGym() {
    // If the screen is desktop, use the desktop navigator
    if (!_useMobileLayout) {
      desktopNavKey.currentState
          ?.push(MaterialPageRoute(builder: (context) => NewGym()))
          .then((_) => _filterGymList());
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewGym()),
    ).then((_) => _filterGymList());
  }

  bool _isFavourite(Gym gym) {
    return _user?.favouriteGyms.contains(gym.id) ?? false;
  }

  Widget _buildTopBar(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SearchBar(
        hintText: 'Search for a gym...',
        controller: _controller,
        trailing:
            _controller.text.isNotEmpty
                ? [
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                    },
                  ),
                ]
                : null,
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        leading: const Icon(Icons.search),
        elevation: WidgetStateProperty.all(0),
        hintStyle: WidgetStatePropertyAll<TextStyle>(
          TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildNewGymButton() {
    return (_user != null && _user!.isAdmin)
        ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextButton(
            onPressed: () => _navigateToAddGym(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Add a new gym',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16.0,
              ),
            ),
          ),
        )
        : Container();
  }

  Widget _buildGymSliverList() {
    return (_filteredGymList == null || _user == null)
        // If the gym list is null, show a loading indicator
        ? SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
        // If the gym list is not null, show the gym list
        // refresh indicator allows the user to refresh the gym list by pulling down
        : SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            Gym gym = _filteredGymList![index];
            int gymIndex = _gymProvider.getGymIndex(gym);
            // If the gym is not in the list, return an empty container
            return gymIndex != -1
                ? GestureDetector(
                  onTap: () => _onGymCardTap(gymIndex),
                  child: GymCard(
                    gymIndex: gymIndex,
                    isFavourite: _isFavourite(gym),
                  ),
                )
                : Container();
          }, childCount: _filteredGymList!.length),
        );
  }

  /// Navigates to the gym page when a gym card is tapped
  void _onGymCardTap(int gymIndex) {
    // If the screen is desktop, use the desktop navigator
    if (!_useMobileLayout) {
      setState(() {
        _selectedGymIndex = gymIndex;
      });
      desktopNavKey.currentState?.push(
        MaterialPageRoute(builder: (context) => GymPage(gymIndex: gymIndex)),
      );
      return;
    }
    // Else use the default navigator
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GymPage(gymIndex: gymIndex)),
    );
  }

  Widget _buildTodaysBookings() {
    var bookingsProvider = context.read<BookingsProvider>();
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        Booking booking = _todaysBookings[index];
        int bookingIndex = bookingsProvider.getBookingIndex(booking.id);
        if (bookingIndex == -1) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: BookingCard(bookingIndex: bookingIndex),
        );
      }, childCount: _todaysBookings.length),
    );
  }

  Widget _buildMobileHome() {
    return CustomScrollView(
      slivers: [
        if (_todaysBookings.isNotEmpty)
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 50.0,
            flexibleSpace: _buildTopBar('Upcoming bookings'),
          ),
        if (_todaysBookings.isNotEmpty) _buildTodaysBookings(),
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 50.0,
          flexibleSpace: _buildTopBar('Discover new activities'),
        ),
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 75.0,
          flexibleSpace: _buildSearchBar(),
        ),
        SliverToBoxAdapter(child: _buildNewGymButton()),
        _buildGymSliverList(),
        SliverToBoxAdapter(child: SizedBox(height: 100.0)),
      ],
    );
  }

  Widget _buildDesktopHome() {
    return Column(
      children: [
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Expanded(child: _buildSearchBar()), _buildNewGymButton()],
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredGymList?.length ?? 0,
                  itemBuilder: (context, index) {
                    Gym gym = _filteredGymList![index];
                    int gymIndex = _gymProvider.getGymIndex(gym);
                    return gymIndex != -1
                        ? GestureDetector(
                          onTap: () => _onGymCardTap(gymIndex),
                          child: GymCard(
                            gymIndex: gymIndex,
                            isFavourite: _isFavourite(gym),
                            isSelected: _selectedGymIndex == gymIndex,
                          ),
                        )
                        : Container();
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Navigator(
                    key: desktopNavKey,
                    onGenerateRoute:
                        (settings) => MaterialPageRoute(
                          builder:
                              (context) => Center(child: Text('Select a gym')),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _gymList = context.watch<GymProvider>().gymList;
    _user = context.watch<UserProvider>().user;
    _useMobileLayout = context.watch<ScreenProvider>().useMobileLayout;
    context.watch<BookingsProvider>().getTodaysBookings().then((value) {
      setState(() {
        _todaysBookings = value;
      });
    });

    // TODO: sort the gym list by distance
    // TODO: replace CircularProgressIndicator with shimmer effect https://docs.flutter.dev/cookbook/effects/shimmer-loading
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _useMobileLayout ? CustomAppBar(user: _user) : null,
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).colorScheme.primary,
        color: Theme.of(context).colorScheme.onPrimary,
        onRefresh: () => _onRefresh(),
        child: _useMobileLayout ? _buildMobileHome() : _buildDesktopHome(),
      ),
    );
  }
}
