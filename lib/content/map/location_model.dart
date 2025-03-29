class Locations {
  final List<GymLocation> gyms;
  
  Locations({required this.gyms});
}

// GymLocation class to represent gym data with coordinates
class GymLocation {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  
  GymLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.lat, 
    required this.lng
  });
}