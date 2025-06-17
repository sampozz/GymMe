import 'package:flutter/material.dart';
import 'package:gymme/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class HomeLoading extends StatelessWidget {
  Color baseColor = Colors.grey[300]!;
  Color highlightColor = Colors.grey[100]!;

  HomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return CustomScrollView(
      slivers: [
        // Upcoming bookings section
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 50.0,
          flexibleSpace: _buildShimmerText(width: 180, height: 24),
        ),
        // Booking cards
        SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (context, index) => _buildShimmerBookingCard(),
            ),
          ),
        ),
        // Discover section title
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 50.0,
          flexibleSpace: _buildShimmerText(width: 220, height: 24),
        ),
        // Search bar
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 75.0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildShimmerSearchBar(),
          ),
        ),
        // Gym cards
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildShimmerGymCard(),
            childCount: 6,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 100.0)),
      ],
    );
  }

  Widget _buildShimmerText({required double width, required double height}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSearchBar() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }

  Widget _buildShimmerGymCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 15,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(width: 150, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBookingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
