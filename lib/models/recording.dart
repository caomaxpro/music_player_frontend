import 'package:music_player/models/song.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Recording {
  @Id(assignable: true)
  int id; // Auto-increment ID required by ObjectBox

  @Property()
  String title;

  @Property()
  String path; // Path to the recording file

  @Property()
  String clipedPath;

  @Property()
  int start; // Start time of the recording (in milliseconds)

  @Property()
  int end; // End time of the recording (in milliseconds)

  @Property()
  int durationMs; // End time of the recording (in milliseconds)

  @Property()
  DateTime createdDate;

  final song = ToOne<Song>(); // One-to-many relationship with Song

  Recording({
    this.id = 0,
    required this.title,
    required this.path,
    required this.clipedPath,
    required this.start,
    required this.end,
    required this.durationMs,
    required this.createdDate,
  });
}
