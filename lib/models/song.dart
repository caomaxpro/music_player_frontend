import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

@Entity()
class Song {
  @Id(assignable: true)
  int id; // Auto-increment ID required by ObjectBox

  String uuid; // UUID for the song
  String title = '';
  String artist = '';
  int duration = 0;
  String filePath = '';
  String vocalPath = '';
  String instrumentalPath = '';
  String audioImgUri = '';
  String lyrics = '...';
  bool isOnlineSearch = false; // New field to track online search status
  String amplitude = ''; // New field to store amplitude data
  String timestampLyrics = ''; // New field to store lyrics with timestamps

  @Transient()
  bool? isExpanded; // This field will not be stored in the database

  Song({
    this.id = 0,
    this.uuid = "", // UUID is now required
    required this.title,
    required this.artist,
    required this.duration,
    required this.filePath,
    required this.audioImgUri,
    required this.lyrics,
    this.isOnlineSearch = false, // Default value is false
    this.amplitude = '', // Default value is empty
    this.timestampLyrics = '', // Default value is empty
    this.vocalPath = '',
    this.instrumentalPath = '',
    this.isExpanded, // Optional parameter for temporary state
  });

  factory Song.withCustomId({
    required String title,
    required String artist,
    required int duration,
    required String filePath,
    required String audioImgUri,
    required String lyrics,
    bool isOnlineSearch = false, // Default value for online search
    String amplitude = '', // Default value for amplitude
    String timestampLyrics = '', // Default value for timestamped lyrics
    String vocalPath = '',
    String instrumentalPath = '',
    bool? isExpanded,
  }) {
    final uuid = const Uuid().v4(); // Generate a UUID
    return Song(
      id: 0, // Default ID is 0 for ObjectBox
      uuid: uuid, // Assign the generated UUID
      title: title,
      artist: artist,
      duration: duration,
      filePath: filePath,
      audioImgUri: audioImgUri,
      lyrics: lyrics,
      isOnlineSearch: isOnlineSearch,
      amplitude: amplitude,
      timestampLyrics: timestampLyrics,
      vocalPath: vocalPath,
      instrumentalPath: instrumentalPath,
      isExpanded: isExpanded,
    );
  }

  // Convert a Song object to a Map (e.g., for saving to state or API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'artist': artist,
      'duration': duration,
      'filePath': filePath, // Changed to camelCase
      'audioImgUri': audioImgUri, // Changed to camelCase
      'lyrics': lyrics,
      'amplitude': amplitude, // Added amplitude field
      'timestampLyrics': timestampLyrics, // Added timestampLyrics field
      'vocalPath': vocalPath,
      'instrumentalPath': instrumentalPath,
      'isOnlineSearch': isOnlineSearch, // Changed to camelCase
      // 'isExpanded' is intentionally excluded from the Map
    };
  }

  // Factory constructor to create a Song from a Map
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? 0, // Default to 0 if ID is not provided
      uuid: map['uuid'] ?? const Uuid().v4(), // Generate a UUID if not provided
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      duration: map['duration'] ?? 0,
      filePath: map['filePath'] ?? '', // Changed to camelCase
      audioImgUri: map['audioImgUri'] ?? '', // Changed to camelCase
      lyrics: map['lyrics'] ?? '',
      amplitude: map['amplitude'] ?? '', // Added amplitude field
      timestampLyrics:
          map['timestampLyrics'] ?? '', // Added timestampLyrics field
      isOnlineSearch: map['isOnlineSearch'] ?? false, // Changed to camelCase
    );
  }
}
