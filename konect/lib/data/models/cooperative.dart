class CooperativeItem {
  final String id;
  final String name;
  final String address;
  final String distance;
  final String imageUrl;
  final String category; // 'Sembako' | 'Simpan Pinjam' | 'Pertanian'
  final bool isOpen;
  final double? latitude;
  final double? longitude;

  const CooperativeItem({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.imageUrl,
    required this.category,
    required this.isOpen,
    this.latitude,
    this.longitude,
  });

  CooperativeItem copyWith({
    String? id,
    String? name,
    String? address,
    String? distance,
    String? imageUrl,
    String? category,
    bool? isOpen,
    double? latitude,
    double? longitude,
  }) {
    return CooperativeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isOpen: isOpen ?? this.isOpen,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory CooperativeItem.fromJson(Map<String, dynamic> json) {
    return CooperativeItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      distance: json['distance'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      isOpen: json['is_open'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distance': distance,
      'image_url': imageUrl,
      'category': category,
      'is_open': isOpen,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
