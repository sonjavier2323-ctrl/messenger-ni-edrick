class Peer {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final DateTime lastSeen;

  Peer({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  factory Peer.fromJson(Map<String, dynamic> json) {
    return Peer(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ipAddress'],
      port: json['port'],
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }

  Peer copyWith({
    String? id,
    String? name,
    String? ipAddress,
    int? port,
    DateTime? lastSeen,
  }) {
    return Peer(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Peer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Peer(id: $id, name: $name, ipAddress: $ipAddress, port: $port)';
  }
}
