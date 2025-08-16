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
  String amplitude = '';
  String timestampLyrics = '';
  String storagePath = ''; // <--- Add this line
  @Property(type: PropertyType.date)
  DateTime createdDate = DateTime.now(); // New field
  @Property(type: PropertyType.date)
  DateTime recentDate = DateTime.now(); // Added field

  Song({
    this.id = 0,
    this.uuid = "",
    this.title = "",
    this.artist = "",
    this.duration = 0,
    this.filePath = "",
    this.audioImgUri = "",
    this.lyrics = "",
    this.amplitude = '',
    this.timestampLyrics = '',
    this.vocalPath = '',
    this.instrumentalPath = '',
    this.storagePath = '', // <--- Add this line
    DateTime? createdDate,
    DateTime? recentDate,
  }) : createdDate = createdDate ?? DateTime.now(),
       recentDate = recentDate ?? DateTime.now();

  factory Song.withCustomId({
    required String title,
    required String artist,
    required int duration,
    required String filePath,
    required String audioImgUri,
    required String lyrics,
    String amplitude = '',
    String timestampLyrics = '',
    String vocalPath = '',
    String instrumentalPath = '',
    String storagePath = '',
    DateTime? createdDate,
    DateTime? recentDate,
  }) {
    final uuid = const Uuid().v4();
    return Song(
      id: 0,
      uuid: uuid,
      title: title,
      artist: artist,
      duration: duration,
      filePath: filePath,
      audioImgUri: audioImgUri,
      lyrics: lyrics,
      amplitude: amplitude,
      timestampLyrics: timestampLyrics,
      vocalPath: vocalPath,
      instrumentalPath: instrumentalPath,
      storagePath: storagePath,
      createdDate: createdDate ?? DateTime.now(),
      recentDate: recentDate ?? DateTime.now(),
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
      'filePath': filePath,
      'audioImgUri': audioImgUri,
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
      uuid: map['uuid'] ?? const Uuid().v4(),
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      duration: map['duration'] ?? 0,
      filePath: map['filePath'] ?? '',
      audioImgUri: map['audioImgUri'] ?? '',
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

  // In your Song class
  Song copyWith({
    int? id,
    String? uuid,
    String? title,
    String? artist,
    int? duration,
    String? filePath,
    String? vocalPath,
    String? instrumentalPath,
    String? audioImgUri,
    String? lyrics,
    String? amplitude,
    String? timestampLyrics,
    String? storagePath,
    DateTime? createdDate,
    DateTime? recentDate,
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
      audioImgUri: audioImgUri ?? this.audioImgUri,
      lyrics: lyrics ?? this.lyrics,
      amplitude: amplitude ?? this.amplitude,
      timestampLyrics: timestampLyrics ?? this.timestampLyrics,
      storagePath: storagePath ?? this.storagePath,
      createdDate: createdDate ?? this.createdDate,
      recentDate: recentDate ?? this.recentDate,
    );
  }
}
