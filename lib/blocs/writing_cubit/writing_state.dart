part of 'writing_cubit.dart';

enum WritingStatus { writing, noWriting }

class WritingState extends Equatable {
  final WritingStatus writingStatus;

  final Map<String, Set<String>> channelIdMap;
  final String userId;
  final String name;

  const WritingState(
      {this.writingStatus = WritingStatus.noWriting,
      this.channelIdMap = const {},
      this.userId = '',
      this.name = ''});

  WritingState copyWith(
      {WritingStatus? newWritingStatus,
      Map<String, Set<String>>? newChannelIdMap,
      String? newUserId,
      String? newName}) {
    return WritingState(
        writingStatus: newWritingStatus ?? this.writingStatus,
        channelIdMap: newChannelIdMap ?? this.channelIdMap,
        userId: newUserId ?? this.userId,
        name: newName ?? this.name);
  }

  @override
  List<Object?> get props => [writingStatus, channelIdMap, userId, name];
}
