import 'package:dima_project/content/custom_appbar.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
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
  final TextEditingController _controller = TextEditingController();
  late GymProvider _gymProvider;
  User? _user;
  List<Gym>? _gymList;
  List<Gym>? _filteredGymList;

  @override
  void initState() {
    super.initState();
    _gymProvider = context.read<GymProvider>();
    if (_gymProvider.gymList == null) {
      _gymProvider.getGymList().then((list) => _filteredGymList = list);
    } else {
      _filteredGymList = _gymProvider.gymList;
    }
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
  Future<void> _onRefresh(BuildContext context) async {
    await Provider.of<GymProvider>(context, listen: false).getGymList();
    _filterGymList();
  }

  /// Navigate to the add gym page
  void _navigateToAddGym(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewGym()));
  }

  bool _isFavourite(Gym gym) {
    return _user?.favouriteGyms.contains(gym.id) ?? false;
  }

  Widget _buildTopBar(BuildContext context) {
    return Text(
      'Discover new activities',
      style: TextStyle(color: Colors.black, fontSize: 28.0),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SearchBar(
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
    );
  }

  Widget _buildNewGymButton(BuildContext context) {
    return (_user != null && _user!.isAdmin)
        ? Column(
          children: [
            ElevatedButton(
              onPressed: () => _navigateToAddGym(context),
              style: ElevatedButton.styleFrom(
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
            SizedBox(height: 20.0),
          ],
        )
        : Container();
  }

  Widget _buildGymSliverList(BuildContext context) {
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
                ? GymCard(
                  gymIndex: _gymProvider.getGymIndex(gym),
                  isFavourite: _isFavourite(gym),
                )
                : Container();
          }, childCount: _filteredGymList!.length),
        );
  }

  @override
  Widget build(BuildContext context) {
    _gymList = context.watch<GymProvider>().gymList;
    _user = context.watch<UserProvider>().user;

    // TODO: sort the gym list by distance
    // TODO: show next bookings if any
    // TODO: replace CircularProgressIndicator with shimmer effect https://docs.flutter.dev/cookbook/effects/shimmer-loading
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(user: _user),
      body: Center(
        child: SizedBox(
          width: context.watch<ScreenProvider>().useMobileLayout ? null : 500,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: RefreshIndicator(
              backgroundColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.onPrimary,
              onRefresh: () => _onRefresh(context),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    expandedHeight: 50.0,
                    flexibleSpace: _buildTopBar(context),
                  ),
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    expandedHeight: 75.0,
                    flexibleSpace: _buildSearchBar(context),
                  ),
                  SliverToBoxAdapter(child: _buildNewGymButton(context)),
                  _buildGymSliverList(context),
                  SliverToBoxAdapter(child: SizedBox(height: 100.0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
