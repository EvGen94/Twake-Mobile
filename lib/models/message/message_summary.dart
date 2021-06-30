import 'package:json_annotation/json_annotation.dart';

part 'message_summary.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageSummary {
  final int date;

  @JsonKey(defaultValue: '0')
  final String sender;

  @JsonKey(defaultValue: 'Guest')
  final String senderName;

  final String title;

  final String? text;

  String? displayContentWithMention;

  MessageSummary({
    required this.date,
    required this.sender,
    required this.senderName,
    required this.title,
    this.text,
    this.displayContentWithMention
  });

  factory MessageSummary.fromJson(Map<String, dynamic> json) {
    return _$MessageSummaryFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$MessageSummaryToJson(this);
  }
}
