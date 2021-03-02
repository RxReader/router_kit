import 'package:example/models/base.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
class User extends Base {
  User({
    @required int code,
    @required String msg,
    @required String id,
  })  : _id = id,
        super(code: code, msg: msg);

  final String _id;
  @JsonKey(name: 'nickname')
  String name;
}
