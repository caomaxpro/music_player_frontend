import 'package:music_player/models/recording.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

class RecordingPath {
  String path; // Path to the recording file
  int start; // Start time of the recording (in milliseconds)
  int end; // End time of the recording (in milliseconds)

  RecordingPath({required this.path, required this.start, required this.end});

  // Convert a String object to a map

  // Convert a map to a String object

  // Convert a RecordingPath object to a Map
  Map<String, dynamic> toMap() {
    return {'path': path, 'start': start, 'end': end};
  }

  // Factory constructor to create a RecordingPath from a Map
  factory RecordingPath.fromMap(Map<String, dynamic> map) {
    return RecordingPath(
      path: map['path'] ?? '',
      start: map['start'] ?? 0,
      end: map['end'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'RecordingPath(path: $path, start: $start, end: $end)';
  }
}

@Entity()
class Song {
  @Id(assignable: true)
  int id; // Auto-increment ID required by ObjectBox

  @Property()
  String uuid; // UUID for the song

  @Property()
  String title = '';

  @Property()
  String artist = '';

  @Property()
  int duration = 0;

  @Property()
  String filePath = '';

  @Property()
  String vocalPath = '';

  @Property()
  String instrumentalPath = '';

  @Property()
  String imagePath = '';

  @Property()
  String lyrics = '...';

  @Property()
  String amplitude = '';

  @Property()
  String timestampLyrics = '';

  @Property()
  String storagePath = '';

  @Property(type: PropertyType.date)
  DateTime createdDate = DateTime.now();

  @Property(type: PropertyType.date)
  DateTime recentDate = DateTime.now();

  @Backlink('song')
  final recordings = ToMany<Recording>(); // One-to-many relationship with Recording

  Song({
    this.id = 0,
    this.uuid = "",
    this.title = "",
    this.artist = "",
    this.duration = 0,
    this.filePath = "",
    this.imagePath = "",
    this.lyrics = "",
    this.amplitude = '',
    this.timestampLyrics = '',
    this.vocalPath = '',
    this.instrumentalPath = '',
    this.storagePath = '',
    DateTime? createdDate,
    DateTime? recentDate,
  }) : createdDate = createdDate ?? DateTime.now(),
       recentDate = recentDate ?? DateTime.now();

  // Convert a Song object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'artist': artist,
      'duration': duration,
      'filePath': filePath,
      'imagePath': imagePath,
      'lyrics': lyrics,
      'amplitude': amplitude,
      'timestampLyrics': timestampLyrics,
      'vocalPath': vocalPath,
      'instrumentalPath': instrumentalPath,
      'storagePath': storagePath,
      'createdDate': createdDate.toIso8601String(),
      'recentDate': recentDate.toIso8601String(),
    };
  }

  // Factory constructor to create a Song from a Map
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? 0,
      uuid: map['uuid'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      duration: map['duration'] ?? 0,
      filePath: map['filePath'] ?? '',
      imagePath: map['imagePath'] ?? '',
      lyrics: map['lyrics'] ?? '',
      amplitude: map['amplitude'] ?? '',
      timestampLyrics: map['timestampLyrics'] ?? '',
      vocalPath: map['vocalPath'] ?? '',
      instrumentalPath: map['instrumentalPath'] ?? '',
      storagePath: map['storagePath'] ?? '',
      createdDate:
          map['createdDate'] != null
              ? DateTime.parse(map['createdDate'])
              : DateTime.now(),
      recentDate:
          map['recentDate'] != null
              ? DateTime.parse(map['recentDate'])
              : DateTime.now(),
    );
  }

  Song copyWith({
    int? id,
    String? uuid,
    String? title,
    String? artist,
    int? duration,
    String? filePath,
    String? vocalPath,
    String? instrumentalPath,
    String? imagePath,
    String? lyrics,
    String? amplitude,
    String? timestampLyrics,
    String? storagePath,
    DateTime? createdDate,
    DateTime? recentDate,
    ToMany<Recording>? recordings,
  }) {
    return Song(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      vocalPath: vocalPath ?? this.vocalPath,
      instrumentalPath: instrumentalPath ?? this.instrumentalPath,
      imagePath: imagePath ?? this.imagePath,
      lyrics: lyrics ?? this.lyrics,
      amplitude: amplitude ?? this.amplitude,
      timestampLyrics: timestampLyrics ?? this.timestampLyrics,
      storagePath: storagePath ?? this.storagePath,
      createdDate: createdDate ?? this.createdDate,
      recentDate: recentDate ?? this.recentDate,
    );
  }
}
