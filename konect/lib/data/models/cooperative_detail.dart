class CooperativeDetail {
  final String coopId;
  final String name;
  final String category;
  final String address;
  final String about;
  final String chairperson;
  final int memberCount;
  final String legalStatus;
  final String phone;
  final String email;
  final List<CoopDiscussionRoom> rooms;
  final List<CoopTimelineUpdate> updates;
  final double? latitude;
  final double? longitude;

  const CooperativeDetail({
    required this.coopId,
    required this.name,
    required this.category,
    required this.address,
    required this.about,
    required this.chairperson,
    required this.memberCount,
    required this.legalStatus,
    required this.phone,
    required this.email,
    required this.rooms,
    required this.updates,
    this.latitude,
    this.longitude,
  });

  factory CooperativeDetail.fromJson(Map<String, dynamic> json) {
    return CooperativeDetail(
      coopId: json['coop_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      address: json['address'] ?? '',
      about: json['description'] ?? json['about'] ?? '',
      chairperson: json['chairperson'] ?? '',
      memberCount: json['member_count'] ?? 0,
      legalStatus: json['legal_status'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      rooms: (json['rooms'] as List? ?? [])
          .map((item) => CoopDiscussionRoom.fromJson(item))
          .toList(),
      updates: (json['updates'] as List? ?? [])
          .map((item) => CoopTimelineUpdate.fromJson(item))
          .toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coop_id': coopId,
      'name': name,
      'category': category,
      'address': address,
      'about': about,
      'chairperson': chairperson,
      'member_count': memberCount,
      'legal_status': legalStatus,
      'phone': phone,
      'email': email,
      'rooms': rooms.map((item) => item.toJson()).toList(),
      'updates': updates.map((item) => item.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class CoopDiscussionRoom {
  final String id;
  final String title;
  final String description;
  final String status; // 'Aktif' | 'Selesai'
  final String date;
  final int membersCount;
  final List<String> avatars;

  const CoopDiscussionRoom({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    required this.membersCount,
    required this.avatars,
  });

  factory CoopDiscussionRoom.fromJson(Map<String, dynamic> json) {
    return CoopDiscussionRoom(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Selesai',
      date: json['date'] ?? '',
      membersCount: json['members_count'] ?? 0,
      avatars: List<String>.from(json['avatars'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'date': date,
      'members_count': membersCount,
      'avatars': avatars,
    };
  }
}

class CoopTimelineUpdate {
  final String id;
  final String title;
  final String description;
  final String date;
  final String type; // 'warning' | 'info'

  const CoopTimelineUpdate({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });

  factory CoopTimelineUpdate.fromJson(Map<String, dynamic> json) {
    return CoopTimelineUpdate(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      type: json['type'] ?? 'info',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'type': type,
    };
  }
}
