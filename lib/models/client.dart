import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
class Client extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String address;

  @HiveField(3)
  String phone;

  Client({
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
  });
}
