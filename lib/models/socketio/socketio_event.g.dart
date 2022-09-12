// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socketio_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketIOEvent _$SocketIOEventFromJson(Map<String, dynamic> json) =>
    SocketIOEvent(
      name: json['name'] as String,
      data: WritingData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SocketIOEventToJson(SocketIOEvent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'data': instance.data.toJson(),
    };

MessageData _$MessageDataFromJson(Map<String, dynamic> json) => MessageData(
      action: $enumDecode(_$IOEventActionEnumMap, json['action']),
      messageId: json['message_id'] as String,
      threadId: json['thread_id'] as String,
    );

Map<String, dynamic> _$MessageDataToJson(MessageData instance) =>
    <String, dynamic>{
      'action': _$IOEventActionEnumMap[instance.action],
      'message_id': instance.messageId,
      'thread_id': instance.threadId,
    };

const _$IOEventActionEnumMap = {
  IOEventAction.remove: 'remove',
  IOEventAction.update: 'update',
};

WritingData _$WritingDataFromJson(Map<String, dynamic> json) => WritingData(
      type: json['type'] as String,
      event: WritingEvent.fromJson(json['event'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WritingDataToJson(WritingData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'event': instance.event,
    };

WritingEvent _$WritingEventFromJson(Map<String, dynamic> json) => WritingEvent(
      json['thread_id'] as String,
      json['channel_id'] as String,
      json['name'] as String,
      json['user_id'] as String,
      json['is_writing'] as bool,
    );

Map<String, dynamic> _$WritingEventToJson(WritingEvent instance) =>
    <String, dynamic>{
      'thread_id': instance.threadId,
      'channel_id': instance.channelId,
      'user_id': instance.userId,
      'name': instance.name,
      'is_writing': instance.isWriting,
    };
