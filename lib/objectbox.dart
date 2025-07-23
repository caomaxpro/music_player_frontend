// TODO Implement this library.
import 'objectbox.g.dart'; // File được tạo tự động bởi build_runner

class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store);

  static Future<ObjectBox> create() async {
    final store = await openStore(); // Hàm này được tạo trong objectbox.g.dart
    return ObjectBox._create(store);
  }
}
