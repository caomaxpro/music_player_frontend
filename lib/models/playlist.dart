import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';
import 'song.dart';

@Entity()
class Playlist {
  @Id(assignable: true)
  int id; // Auto-increment ID required by ObjectBox

  String uuid; // UUID for the playlist
  String name; // Name of the playlist
  String? description; // Optional description

  // One-to-Many: A playlist can contain many songs
  final songs = ToMany<Song>();

  Playlist({
    required this.name,
    this.description,
    int? id, // Optional parameter for ObjectBox ID
    String? uuid, // Optional parameter for custom UUID
  }) : id = id ?? 0, // Default ID is 0
       uuid =
           uuid ?? const Uuid().v4(); // Generate a UUID if no UUID is provided

  // Convert a Playlist object to a Map (e.g., for saving to state or API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'description': description,
      'songs': songs.map((song) => song.toMap()).toList(),
    };
  }

  // Factory constructor to create a Playlist from a Map
  factory Playlist.fromMap(Map<String, dynamic> map) {
    final playlist = Playlist(
      name: map['name'] ?? 'Untitled Playlist',
      description: map['description'],
      id: map['id'],
      uuid: map['uuid'],
    );
    // Populate songs if available
    if (map['songs'] != null) {
      playlist.songs.addAll(
        (map['songs'] as List).map((songMap) => Song.fromMap(songMap)),
      );
    }
    return playlist;
  }
}
