import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
class User {
  const User({
    required this.id,
    required this.name,
    this.brief,
  });

  final String id;
  final String name;
  final String? brief;
}
